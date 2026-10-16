#!/usr/bin/env python3
"""Static regression checks for the LEDERG PROJECT source and clean DB import."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "gamemodes" / "new.pwn"
SQL = ROOT / "database" / "LEDERG-PROJECT-phpMyAdmin.sql"
LEGACY_SQL = ROOT / "gs147466.sql"

EXPECTED_TABLES = {
    "accounts", "auto_business", "banlist", "business", "freekassa_payments",
    "houses", "job_business", "kvartiry", "log_paymoney", "log_player",
    "log_transfermoney", "log_vibory", "polit_team", "warehouse",
}
EXPECTED_SEED_TABLES = {
    "auto_business", "business", "houses", "job_business", "kvartiry", "warehouse",
}


def main() -> int:
    source = SOURCE.read_bytes().decode("cp1251", errors="strict")
    sql = SQL.read_text(encoding="utf-8", errors="strict")

    create_tables = set(re.findall(r"CREATE TABLE\s+`([^`]+)`", sql, re.IGNORECASE))
    insert_tables = set(re.findall(r"INSERT INTO\s+`([^`]+)`", sql, re.IGNORECASE))
    account_insert = re.search(
        r"mysql_format\(dbHandle,\s*query,\s*sizeof\(query\),\s*"
        r"\"INSERT INTO `accounts`.*?\",",
        source,
        re.IGNORECASE | re.DOTALL,
    )
    startup_guard = source.find("if(!LoadMySQLSettings())")
    connect_pos = source.find("dbHandle = mysql_connect", max(startup_guard, 0))
    query_pos = source.find("mysql_function_query(dbHandle", max(connect_pos, 0))
    settings_end = source.find("stock LoadMySQLSettings()")
    ban_callback_start = source.find("public CheckBan(playerid)")
    account_callback_start = source.find("public GetAccount(playerid)", ban_callback_start)
    ban_callback = source[ban_callback_start:account_callback_start] if ban_callback_start >= 0 and account_callback_start > ban_callback_start else ""
    log_start = source.find("public LOG(tablename[], tname[], itext[])")
    log_end = source.find("\n}", log_start) if log_start >= 0 else -1
    log_function = source[log_start:log_end] if log_start >= 0 and log_end > log_start else ""

    query_format_strings = []
    for match in re.finditer(r"mysql_format\([^;]*?\);", source, re.DOTALL):
        literals = re.findall(r'"([^"]*)"', match.group(0))
        if literals:
            query_format_strings.append(literals[0])
    raw_percent_s = [fmt for fmt in query_format_strings if "%s" in fmt]

    checks = {
        "clean phpMyAdmin import exists": SQL.is_file(),
        "personal legacy dump removed from current tree": not LEGACY_SQL.exists(),
        "source has the LEDERG faction labels": all(
            name in source for name in ("Бандера ОПГ", "LEDERG ОПГ", "Вагнер ОПГ")
        ),
        "old faction labels removed": not any(
            name in source for name in ("Трамповское ОПГ", "Майкопское ОПГ", "Одесское ОПГ")
        ),
        "old timed VK promotion removed": "vk.com/id86774603" not in source,
        "legacy external game branding removed": "Rage RolePlay" not in source,
        "game mode title is LEDERG PROJECT": 'SetGameModeText("LEDERG PROJECT")' in source,
        "email registration remains enabled": "dialog_EMAIL" in source and "data_EMAIL" in source,
        "registration explains no email verification": "Подтверждение по почте не требуется." in source,
        "account insert stores email": bool(account_insert and "`email`" in account_insert.group(0)),
        "email verification code path is removed": all(
            item not in source for item in ("EmailCode(", "CheckEmail(", "<a_mail>", "dialog_OKEMAIL", "dialog_ALOGIN")
        ),
        "auto-save calls are preserved": all(
            item in source
            for item in (
                "SaveJBData(b);", "SaveKVData(kv);", "SaveABData(a);",
                "SaveHouseData(h);", "SaveBusinessData(b);", "SaveWarehouse();",
            )
        ),
        "SQL has exactly the expected source-compatible tables": create_tables == EXPECTED_TABLES,
        "accounts email field matches Pawn code": bool(
            re.search(r"CREATE TABLE `accounts`[\s\S]*?`email`\s+varchar\(50\)\s+NOT NULL", sql)
        ),
        "account nicknames have a unique database constraint": bool(
            re.search(r"ALTER TABLE `accounts`\\s+ADD UNIQUE KEY `uq_accounts_name` \\(`name`\\)", sql, re.IGNORECASE)
        ),
        "accounts.id is auto-increment": bool(
            re.search(
                r"ALTER TABLE `accounts`\s+MODIFY `id` int\(111\) NOT NULL AUTO_INCREMENT",
                sql,
                re.IGNORECASE,
            )
        ),
        "clean SQL omits personal account rows": not re.search(
            r"^\s*INSERT INTO `accounts`", sql, re.IGNORECASE | re.MULTILINE
        ),
        "clean SQL omits legacy bans and payment records": not any(
            re.search(rf"^\s*INSERT INTO `{table}`", sql, re.IGNORECASE | re.MULTILINE)
            for table in ("banlist", "freekassa_payments", "log_player", "log_paymoney", "log_transfermoney", "log_vibory")
        ),
        "clean SQL has no DROP/CREATE DATABASE statements": not re.search(
            r"^\s*(?:DROP\s+(?:TABLE|DATABASE)|CREATE\s+DATABASE)\b",
            sql,
            re.IGNORECASE | re.MULTILINE,
        ),
        "clean SQL seeds world/property tables": EXPECTED_SEED_TABLES.issubset(insert_tables),
        "clean SQL closes transaction and restores FK checks": (
            re.search(r"\bCOMMIT\s*;", sql, re.IGNORECASE) is not None
            and re.search(r"SET FOREIGN_KEY_CHECKS\s*=\s*1\s*;", sql, re.IGNORECASE) is not None
        ),
        "account registration escapes all string parameters": (
            account_insert is not None
            and "MD5('%e')" in account_insert.group(0)
            and account_insert.group(0).count("%e") >= 5
            and "%s" not in account_insert.group(0)
        ),
        "login password is escaped in the CheckBan callback": "AND `password` = MD5('%e')" in ban_callback
        and "MD5('%s')" not in ban_callback,
        "ban removal escapes player-provided name": "DELETE FROM `banlist` WHERE `name` = '%e'" in source,
        "political-team insert escapes all user-provided strings": "VALUES ('%e', '%e', '%e')" in source,
        "audit log validates table names and escapes row values": (
            all(f'"{table}"' in log_function for table in ("log_player", "log_paymoney", "log_transfermoney"))
            and "VALUES ('%e',NOW(), '%e', '%e')" in log_function
        ),
        "SQL formats contain no raw string placeholders except the allowlisted log table": (
            len(raw_percent_s) == 1 and raw_percent_s[0].count("%s") == 1 and "`%s`" in raw_percent_s[0]
        ),
        "admin name lookups escape supplied values": source.count("SELECT * FROM `accounts` WHERE `name` = '%e'") >= 3
        and "SELECT * FROM `accounts` WHERE `name` = '%s'" not in source,
        "MySQL configuration failure stops startup before queries": (
            startup_guard >= 0 and connect_pos > startup_guard and query_pos > connect_pos
            and 'SendRconCommand("exit");' in source[startup_guard:connect_pos]
            and 'SendRconCommand("exit");' in source[connect_pos:query_pos]
        ),
        "MySQL settings validate required non-empty fields": all(
            item in source[settings_end:]
            for item in (
                'ini_getString(FileID, "host"', 'ini_getString(FileID, "username"',
                'ini_getString(FileID, "password"', 'ini_getString(FileID, "database"',
                "MySQL host, username, password, and database must not be empty.",
            )
        ),
        "MySQL settings buffers support long values": "new MySQLSettings[MYSQL_SETTINGS][128];" in source,
        "game-mode exit closes only an initialized DB handle": "if(dbHandle) mysql_close(dbHandle);" in source,
        "hard-coded MySQL secrets removed": not any(
            item in source for item in ("#define MySQL_HOST", "#define MySQL_USER", "#define MySQL_PASS", "#define MySQL_DB")
        ),
    }

    failed = 0
    for name, passed in checks.items():
        print(f'{"PASS" if passed else "FAIL"}: {name}')
        failed += not passed
    print(f"\n{len(checks) - failed}/{len(checks)} checks passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

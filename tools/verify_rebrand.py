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
        "registration SQL escapes strings rather than inserting raw referral input": (
            account_insert is not None
            and "MD5('%e')" in account_insert.group(0)
            and account_insert.group(0).count("%e") >= 5
            and "%s" not in account_insert.group(0)
        ),
        "login SQL escapes password input": "AND `password` = MD5('%e')" in source,
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

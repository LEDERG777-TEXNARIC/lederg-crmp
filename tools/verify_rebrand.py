#!/usr/bin/env python3
"""Static regression checks for LEDERG PROJECT branding and registration auth."""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "gamemodes" / "new.pwn"
SQL = ROOT / "gs147466.sql"

def main() -> int:
    source = SOURCE.read_bytes().decode("cp1251", errors="replace")
    sql = SQL.read_text(encoding="utf-8", errors="replace")
    checks = {
        "new faction labels": all(x in source for x in ("Бандера ОПГ", "LEDERG ОПГ", "Вагнер ОПГ")),
        "old faction labels removed": not any(x in source for x in ("Трамповское ОПГ", "Майкопское ОПГ", "Одесское ОПГ")),
        "old timed VK ad removed": "vk.com/id86774603" not in source,
        "new game mode title": 'SetGameModeText("LEDERG PROJECT")' in source,
        "email field remains in registration": "dialog_EMAIL" in source and "data_EMAIL" in source,
        "email remains in account INSERT": "`email`" in source and "data_EMAIL" in source,
        "email verification function removed": "EmailCode(" not in source and "CheckEmail(" not in source and "<a_mail>" not in source,
        "email activation dialogs removed": "dialog_OKEMAIL" not in source and "dialog_ALOGIN" not in source,
        "auto-save calls preserved": all(x in source for x in ("SaveJBData(b);", "SaveKVData(kv);", "SaveABData(a);", "SaveHouseData(h);", "SaveBusinessData(b);", "SaveWarehouse();")),
        "SQL email column retained": "`email` varchar(50) NOT NULL" in sql,
        "account ID remains auto-increment": "MODIFY `id` int(111) NOT NULL AUTO_INCREMENT" in sql,
    }
    for name, ok in checks.items():
        print(("PASS" if ok else "FAIL") + ": " + name)
    return 0 if all(checks.values()) else 1

if __name__ == "__main__":
    raise SystemExit(main())

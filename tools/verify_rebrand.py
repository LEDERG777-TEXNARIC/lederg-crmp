#!/usr/bin/env python3
"""Regression checks for LEDERG PROJECT branding and timed-ad removal."""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "gamemodes" / "new.pwn"
def main() -> int:
    source = SOURCE.read_bytes().decode("cp1251", errors="replace")
    ignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
    checks = {
        "new faction labels": all(x in source for x in ("Бандера ОПГ", "LEDERG ОПГ", "Вагнер ОПГ")),
        "old faction labels removed": not any(x in source for x in ("Трамповское ОПГ", "Майкопское ОПГ", "Одесское ОПГ")),
        "old timed VK ad removed": "vk.com/id86774603" not in source,
        "old site removed": "bicbai.ru" not in source,
        "game mode title updated": 'SetGameModeText("LEDERG PROJECT")' in source,
        "old title removed": "Positive TV" not in source,
        "DB macros removed": not any(line.startswith("#define MySQL_" + name) for line in source.splitlines() for name in ("HOST", "USER", "PASS", "DB")),
        "auto-save preserved": all(x in source for x in ("SaveJBData(b);", "SaveKVData(k);", "SaveABData(a);", "SaveHouseData(h);", "SaveBusinessData(b);", "SaveWarehouse();")),
        "runtime secrets ignored": all(x in ignore for x in ("server.cfg", "scriptfiles/mysql_settings.ini", "*.sql", "*.log")),
        "safe config templates exist": (ROOT / "server.cfg.example").is_file() and (ROOT / "scriptfiles" / "mysql_settings.example.ini").is_file(),
    }
    for name, ok in checks.items(): print(("PASS" if ok else "FAIL") + ": " + name)
    return 0 if all(checks.values()) else 1
if __name__ == "__main__": raise SystemExit(main())

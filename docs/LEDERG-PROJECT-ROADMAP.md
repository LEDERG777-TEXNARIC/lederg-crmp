# LEDERG PROJECT — CR:MP hardening roadmap

## Completed in this branch
- [x] Rebrand the server/game-mode titles and primary in-game TextDraw branding.
- [x] Rename faction display labels while preserving IDs 5, 6, and 7.
- [x] Remove recurring VK promotion without removing autosave operations.
- [x] Remove hard-coded database credentials and add local configuration templates.
- [x] Disable email-code verification while retaining the email field in registration.
- [x] Add a sanitized phpMyAdmin import with 14 source-compatible tables and clean world/property seeds.
- [x] Remove the old player-data SQL dump from the current source tree.
- [x] Validate MySQL configuration and stop startup on missing settings or connection failure.
- [x] Escape SQL string inputs in identified account, ban, political-team, admin-lookup, and audit-log queries.
- [x] Add automated GitHub Actions checks for source and SQL safety.

## Still required before production
- [ ] Rotate exposed credentials and clean sensitive Git history.
- [ ] Compile `gamemodes/new.pwn` with the compatible compiler and includes, then replace stale `gamemodes/new.amx`.
- [ ] Test that MySQL connection loss/misconfiguration fails safely and valid credentials load every required table.
- [ ] Test registration/login, load/save and account uniqueness with a disposable database.
- [ ] Test the gamemode on staging: spawn, faction menus, warehouses, property/vehicles, captures, bans/admin tools and autosaves.
- [ ] Run a backup/restore test.
- [ ] Review rights to modify and redistribute upstream code and binaries.

## Follow-up hardening
- Inventory and pin the exact compiler, includes, server binary and plugin versions.
- Review all SQL writes and error callbacks; record errors without logging passwords or player secrets.
- Plan a compatible migration away from MD5 password hashes rather than changing the hash format in place.
- Add repeatable builds and runtime integration tests when the compatible toolchain is available.

## Acceptance gate
Do not deploy until the matching AMX compiles, the clean SQL import and login/save flows pass staging, a restore test succeeds, and exposed credentials/history risks have been addressed.

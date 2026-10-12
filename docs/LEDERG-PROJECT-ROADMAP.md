# LEDERG PROJECT — CR:MP modernization roadmap

## Slice 1 — branding and repository hygiene
- [x] Rebrand server/game-mode titles and TextDraw logo.
- [x] Rename faction display labels while preserving IDs 5, 6, and 7.
- [x] Remove timed VK promotion without removing save operations.
- [x] Remove hard-coded DB macros; add local config templates and ignore rules.
- [ ] Rotate exposed credentials and clean sensitive Git history.
- [ ] Compile matching `gamemodes/new.amx` with compatible compiler/includes.

## Slice 2 — reproducible build
- Inventory includes, plugins, binaries, and compiler version.
- Capture baseline compiler output; pin compatible compiler and resolve warnings incrementally.
- Build maintained gamemodes/filterscripts; never deploy source/AMX mismatch.
- Add clean repeatable build and CI.

## Slice 3 — database correctness
- Test DB connect/reconnect, registration/login, load/save, and outage handling on a disposable copy.
- Audit password storage and SQL error handling; plan migrations instead of rewriting records blindly.
- Test backup/restore for accounts, assets, houses, businesses, and faction storage.

## Slice 4 — gameplay UX
- Review GPS, org menus, leader assignment, warehouses, capture messages, map markers, welcome/donate/rules screens, and all TextDraws.
- Preserve IDs, enum values, DB columns, and persisted keys unless a migration is planned.
- Test spawn, registration, admin flows, and faction gameplay on staging.

## Slice 5 — operations and release
- Add DB/save error logs without passwords or player secrets.
- Document backups, health checks, restart behavior, and rollback.
- Keep provider ports/tunnels in host config, not hard-coded secrets.
- Release only after compile, staging smoke tests, restore test, and license review.

## Acceptance gate
Do not deploy until the matching AMX compiles, branding checks pass, login/save flows work on staging, and exposed credentials are rotated and purged from public history.

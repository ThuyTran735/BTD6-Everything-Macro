# Project structure (v3.0.0)

The big v2 files were split in v3 so debugging does not mean scrolling through 1,500-2,000 lines every time.

## Compatibility wrappers

Files like `Scripts/RoundLogic.ahk`, `Scripts/UpgradeLogic.ahk`, `Scripts/GameStateLogic.ahk`, and the large UI files still exist. They are intentionally tiny now and only include the focused files under the new folders. This keeps old map scripts and tests working.

## Where things live

- `Scripts/Gameplay/Rounds/` - round OCR, Glacial Trail cleanup, validation, recovery, and waiting.
- `Scripts/Gameplay/Upgrades/` - upgrade timing, panel reuse, buying, waiting, and locked-upgrade handling.
- `Scripts/Gameplay/GameState/` - popups, victory/defeat, home-screen checks, and run reset.
- `Scripts/Navigation/` - map/mode navigation plus hero selection.
- `Scripts/UI/Common/` - shared window chrome, launcher visibility, child-run IPC, and launcher monitoring.
- `Scripts/UI/Controls/` - custom buttons, lists, and dropdowns.
- `Scripts/UI/Launcher/` - launcher drawing and run/queue start logic.
- `Scripts/UI/Queue/` - queue manager, queue job builder, and queue profile code.
- `Scripts/UI/Run/` - the in-run HUD and run-count prompt.
- `Scripts/UI/Settings/` - settings toggles, update checks, and log controls.
- `Tools/StrategyBuilder/` - Strategy Builder window, editors, import/export, overlays, and chrome.

## A couple rules worth keeping

1. Map scripts should keep including `Scripts\IncludeAll.ahk`; they should not reach into the new internal folders directly.
2. If one of the compatibility wrappers starts getting real logic again, move that logic into the matching folder instead.
3. Keep map-specific OCR workarounds (like Glacial Trail) isolated so they cannot change normal OCR on every map.
4. Comments should explain *why* something odd exists. There is no need to narrate obvious assignments line by line.

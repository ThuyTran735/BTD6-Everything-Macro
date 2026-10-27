# Project structure (v3.6.2)

The big v2 files were split in v3 so debugging does not mean scrolling through 1,500-2,000 lines every time.

## Compatibility wrappers

Files like `Scripts/RoundLogic.ahk`, `Scripts/UpgradeLogic.ahk`, `Scripts/GameStateLogic.ahk`, and the large UI files still exist. They are intentionally tiny now and only include the focused files under the new folders. This keeps old map scripts and tests working.

## Where things live

- `Scripts/Gameplay/Rounds/` - round OCR, Glacial Trail cleanup, validation, recovery, and waiting.
- `Scripts/Gameplay/Upgrades/` - upgrade timing, panel state/detection, buying, waiting, and locked-upgrade handling.
- `Scripts/Monkey Logic/` - monkey/tower-specific behavior for Banana Farms, Subs, Dartling, Heli, Mermonkey, Mortar, and Spike Factory.
- `Scripts/Gameplay/Game State/` - popups, collection rewards, victory/defeat, home-screen checks, and run reset.
- `Scripts/GameSpeedLogic.ahk` - scheduled speed changes, with FindText confirmation and 250 ms retries for Fast.
- `Scripts/InputHelpers.ahk` - held keys/clicks, focus checks, `SelectTowerForTargeting` and `SendTargetingSteps` for normal/Spike Factory targeting, and `RepeatMapClicks` for scheduled clicks at a fixed screen position.
- `Scripts/TargetingLogic.ahk` - normal targeting profiles and forward step calculation; Spike Factory's separate profile lives in `Scripts/Monkey Logic/SpikeFactoryLogic.ahk`. Both use the shared targeting input helpers.
- `Scripts/SpecialTargetingLogic.ahk` - shared manual PgDn-and-click sequence: 300 ms after PgDn, 250 ms after the click, and 300 ms after closing the panel.
- `Scripts/Navigation/` - map/mode navigation plus hero selection.
- `Scripts/Collection Event/` - bonus-badge patterns, six-card scan regions, and Expert Impoppable map selection.
- `Scripts/UI/Common/` - shared window chrome, launcher visibility, child-run IPC, and launcher monitoring.
- `Scripts/UI/Controls/` - custom buttons, lists, and dropdowns.
- `Scripts/UI/Launcher/` - launcher drawing, run/queue start logic, and the Auto Collection Event session.
- `Scripts/UI/Queue/` - queue manager, queue job builder, and queue profile code.
- `Scripts/UI/Run/` - the in-run HUD and run-count prompt.
- `Scripts/UI/Settings/` - settings toggles, update checks, log controls, and UserData backup/restore.
- `Tools/StrategyBuilder/` - Strategy Builder window, editors, import/export, overlays, and chrome. `BuilderHistory.ahk` owns snapshots and undo/redo; `BuilderPersistence.ahk` owns draft saves/recovery; `BuilderDialogs.ahk` owns decision prompts.
- `UserData/StrategyBuilder/` - default location for personal editable drafts and generated exports; recovery checkpoints always stay here. Saves can use other folders, but only files inside UserData are covered by its Git exclusion and backups. Older backups need no conversion.

## Targeting input ownership

Normal and Spike Factory mode changes use `SelectTowerForTargeting` for a held click and 250 ms panel settle, then `SendTargetingSteps` for a 100 ms Tab hold and 150 ms released gap per step, including the final step. Keep these delays in the shared helpers rather than adding sleeps or extra Tab presses to map strategies. Dartling and Heli mode switching use separate routines.

The helpers check focus, record `TARGETING FAILED`, and return `false` when those checks fail; they do not retry a partially sent sequence. The stored targeting mode is expected state, not visual readback. Keep diagnostic wording clear about requests versus observed game state.

## Adding collection-event badges

Add new badges to `CollectionEventBadgePatterns` in `Scripts/Collection Event/CollectionEventPatterns.ahk`. Each event has a name and an array of FindText captures. Put alternate appearances of the same badge in that event's array; add another entry for a new event.

The scanner combines these captures automatically, so new badges do not need changes to map selection. Reopen `Main.ahk` after editing the catalog. Keep reward-screen Collect/Back patterns in `Scripts/Gameplay/Game State/CollectionRewardPatterns.ahk`; those buttons are handled separately from map badges.

## A couple rules worth keeping

1. Map scripts should keep including `Scripts\IncludeAll.ahk`; they should not reach into the new internal folders directly.
2. If one of the compatibility wrappers starts getting real logic again, move that logic into the matching folder instead.
3. Keep map-specific OCR workarounds (like Glacial Trail) isolated so they cannot change normal OCR on every map.
4. Comments should explain *why* something odd exists. There is no need to narrate obvious assignments line by line.

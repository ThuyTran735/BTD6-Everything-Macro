# BTD6 Everything Macro
**Current version: v3.2.1**

The app version used by the macro and update checker is defined in `Scripts/Version.ahk`. The version shown in this README is maintained manually when a release is published.

### Current release highlights

- Fixed README GitHub Markdown formatting so headings, bold text, links, lists, tables, and code blocks render correctly.
- Added 24 new Beginner strategies across Tree Stump, Town Center, Middle Of The Road, and One Two Tree.
- Each of those four maps now includes Easy Standard, Primary Only, Deflation, Medium Standard, Military Only, and Reverse strategies.
- Added Strategy Builder REMAP ALL X/Y support so an imported strategy can keep its rounds, upgrades, delays, targeting, sells, abilities, and speed actions while placement coordinates are recaptured for another map.
- Added Strategy Builder upgrade-coordinate overrides for moving maps such as Geared, plus F3 coordinate capture and per-monkey remembered upgrade values.
- Made the Strategy Builder window more compact so it stays clear of the Windows taskbar while keeping the current editing controls.
- Simplified Daily Chest handling to repeatedly click the chest spot and scan for the home Play button until the chest flow is finished.
- Added scheduled game-speed control so strategies can switch between normal and fast speed at a specific round and in-round delay.

A work-in-progress AutoHotkey macro for Bloons TD 6. It can pick a map, load a strategy, place and upgrade towers, watch the current round, handle wins/losses, and get back to the menu for another run.

It is built around a **1920×1080 Windows display and 1920×1080 BTD6 fullscreen** setup. It also requires **AutoHotkey v2**.

## Progress
You can see which maps and modes are finished here:

**[OPEN THE MAP & MODE TRACKER](https://docs.google.com/spreadsheets/d/1uqV7fzFkcJIGeEd6xj-hhhBuhY8A40UP8oUbox0J6VI/edit?usp=sharing)**

## What it currently does
- Finds strategy files inside the `Maps` folder
- Lets you choose a category, map, and mode from the launcher
- Places towers and buys upgrades
- Handles normal targeting plus coordinate-based Dartling, Heli, Mermonkey, and Mortar special targeting
- Handles tower abilities
- Reads the current round
- Detects victory, defeat, and several menu popups
- Retries failed queued runs and defeated manual / Monkey EXP runs when Auto Retry is enabled
- Supports normal runs and grind modes from the launcher
- Supports favorites for maps, Monkey EXP scripts, and queue profiles
- Supports reusable Queue Profiles that can be saved, loaded, updated, renamed, and deleted
- Remembers the last launcher mode, its relevant selections, and the last successfully run Default-mode `.ahk` strategy between restarts when **REMEMBER LAST STATE** is enabled
- Uses themed confirmation dialogs before deleting profiles, clearing the queue, or closing an active run
- Can export and import the full `UserData` folder from Settings so preferences, favorites, profiles, history, and logs can be carried between versions

This project is still being worked on, so not every map or mode has a strategy yet. Check the tracker above for the current list.

## v3.0.0 code layout
v3.0.0 reorganizes the large script files without changing the public include paths used by map scripts. Files such as `RoundLogic.ahk`, `UpgradeLogic.ahk`, and the larger UI files are now small entry files that include focused pieces from subfolders.

The main folders are now easier to follow:

```text
Scripts/Gameplay/          Round, upgrade, and game-state internals
Scripts/Navigation/        Map/mode/hero navigation pieces
Scripts/UI/Common/         Shared window/launcher helpers
Scripts/UI/Controls/       Custom buttons, lists, and dropdowns
Scripts/UI/Launcher/       Main launcher window and run-start flow
Scripts/UI/Queue/          Queue manager, job builder, and queue profiles
Scripts/UI/Run/            Run HUD and run-count prompt
Scripts/UI/Settings/       Settings window, updates, and log controls
Tools/StrategyBuilder/     Strategy Builder editor/import/export pieces
```

The old top-level files are intentionally kept as compatibility wrappers, so existing map strategies can continue using `Scripts\IncludeAll.ahk` without path changes.

## Installation
### 1. Install AutoHotkey v2
Go to the official AutoHotkey website:

**[Download AutoHotkey](https://www.autohotkey.com/)**

Download and install the latest **v2** release. The macro will not work with AutoHotkey v1.

If `.ahk` files do not open after installing it:

1. Right-click `Main.ahk`.
2. Choose **Open with**.
3. Select **AutoHotkey v2**.
4. Turn on **Always use this app** if Windows gives you the option.

### 2. Download the macro
1. Open the GitHub repository.
2. Click the green **Code** button.
3. Click **Download ZIP**.
4. Extract the ZIP somewhere easy to find.
5. Keep every folder together. Do not move `Main.ahk` away from `Scripts`, `Lib`, or `Maps`.

Do not run the macro from inside the ZIP. Extract it first.

## BTD6 setup
Before starting the macro:

- Set your **Windows display resolution to 1920×1080**.
- Run BTD6 in fullscreen at **1920×1080**.
- Keep the game on the monitor where the strategy coordinates were recorded.
- Make sure Windows display scaling and the BTD6 UI scale have not changed.
- Open the BTD6 hotkey settings and **reset every hotkey to its default**. If you have changed any tower, ability, upgrade, targeting, or menu hotkeys, reset them before using the macro.

### Important focus / hotkey warning
Before using the macro, open BTD6's hotkey settings and **reset every hotkey to its default first**. After the reset, manually bind these three monkeys:

| Monkey | Hotkey |
|---|---|
| Mermonkey | `F6` |
| Skywarden | `F7` |
| Desperado | `F8` |

Leave every other hotkey at its default. Different bindings can make the macro place the wrong tower, buy the wrong upgrade, or stop the strategy completely.

BTD6 can also get into a bad keyboard/focus state after **Alt+Tab** or **Tab**.

- Do **not** use Alt+Tab or Tab while BTD6 is being used with the macro.
- If you need to click another application, press the **Windows key** first, then switch to the other application from there.
- If you accidentally use Alt+Tab or Tab, completely close and restart BTD6 before running the macro again.
- Use the macro at your own risk. The macro author is not responsible for bans, suspensions, lost progress, or other action taken against your game account from using it.

The launcher shows this setup/warning screen before continuing. It appears on each startup unless you check **Never show this warning again** before pressing **I AGREE - CONTINUE**. Leaving the box unchecked lets you continue normally but keeps the reminder for the next launch.

The warning preference is versioned. Existing installs that hid an older warning will see this updated version once so they can choose whether to hide it again.

## Special targeting towers
Some towers use a map coordinate instead of normal First / Last / Close / Strong targeting. The macro has dedicated helpers for these towers.

### Dartling Gunner
```ahk
AimDartling(TowerSetup["Dartling A"], 1000, 350)
RetargetDartling(TowerSetup["Dartling A"], 750, 600)
```

Dartling starts with `Normal` targeting. The helpers lock or move its aim point using the special-target control. Bottom-path xx4/xx5 Dartlings can also use `Target Independent`.

### Heli Pilot
```ahk
LockHeliInPlace(TowerSetup["Heli A"], 1000, 350)
RetargetHeli(TowerSetup["Heli A"], 750, 600)
```

Heli starts with `Follow Mouse`. The helper switches it to `Lock in Place` and sets the requested coordinate. Pursuit is tracked when the required upgrade is purchased.

### Mermonkey
```ahk
PlaceMermonkeyTotem(TowerSetup["Mermonkey A"], 950, 320)
RetargetMermonkeyTotem(TowerSetup["Mermonkey A"], 760, 570)
```

The Allure Totem helper is intended for bottom-path xx4/xx5 Mermonkeys.

### Mortar Monkey
```ahk
SetMortarTarget(TowerSetup["Mortar A"], 1000, 350)
RetargetMortar(TowerSetup["Mortar A"], 750, 600)
```

Mortar uses a fixed map target instead of the normal targeting modes.

All four special-target systems use the same input timing: **Page Down -> 300 ms -> click -> 250 ms -> close the upgrade panel -> 100 ms**. This keeps the targeting reliable and prevents an old upgrade panel from interfering with the next tower placement or upgrade action.

## Running the macro
1. Start BTD6 and wait until you are on the main menu.
2. Double-click `Main.ahk`.
3. Click **SELECT SCRIPT** and choose the strategy you want to use.
4. Confirm it with **USE STRATEGY**.
5. Choose the run count and click **START RUN**, or press:

```text
Ctrl + Shift + P
```

Once a run starts, avoid moving the mouse or pressing game hotkeys unless you are stopping the macro.

The launcher uses its full **CLOSE** button to exit the macro. Secondary windows intentionally do not have an extra X; use their **BACK**, **CANCEL**, or **GOT IT** action instead. **CLOSE RUN** remains available only while a run is active because it stops automation rather than simply closing a window. All custom windows use the same dark four-sided frame instead of a bright top-only stripe.

By default, the launcher also remembers where you left off. Default mode restores the last category and map, Monkey EXP Grind restores the last monkey category and EXP script, and **Select Script** restores the last Default-mode `.ahk` strategy that successfully started running, including its difficulty when that strategy is still available for the selected map. You can disable this from **Settings -> REMEMBER LAST STATE**. Disabling it clears the saved launcher / strategy state. These values are stored only in `UserData` and are not tracked by Git.

To move your setup to another macro version, open **Settings -> BACKUP / RESTORE USER DATA**. **EXPORT USER DATA** creates a dated backup containing the full `UserData` folder. **IMPORT USER DATA** merges a backup into the current copy and overwrites matching files while keeping files that only exist in the newer version. Restart the macro after importing so all restored values are reloaded.

## Scheduled game speed
Strategies can switch BTD6 between normal and fast speed with `SetGameSpeed()`. The normal strategy delay field still works, so speed changes can happen partway through a round.

```ahk
[39, 10000, () => SetGameSpeed("Normal")],
[41, 0, () => SetGameSpeed("Fast")],
```

The example slows the game down 10 seconds into round 39, then returns to fast speed as soon as round 41 is detected. `StartGame()` still presses Space twice at the beginning, so normal map runs begin at fast speed. Strategy Builder can add and import these speed actions too.

## Folder layout
```text
Main.ahk        Starts the launcher
Scripts/        Navigation, placement, upgrades, rounds, UI, and recovery
Maps/           Map strategy files
Lib/            FindText and OCR libraries
Docs/           Strategy-writing notes
Test/           Test scripts
```

The launcher scans the `Maps` folder when it starts. A map only shows up when it has a runnable `.ahk` strategy file.

## Troubleshooting
### `Main.ahk` will not run
Make sure AutoHotkey **v2** is installed. If Windows asks which program should open the file, choose AutoHotkey v2.

### The launcher is empty
Make sure the entire `Maps` folder was extracted and that the strategy files are still inside their category and map folders.

### Towers are clicking in the wrong place
Check that both the Windows display and BTD6 are set to 1920×1080, with BTD6 running fullscreen. A different resolution, UI scale, display scale, or monitor layout can throw off the saved coordinates.

### A tower is not placing
Reset the BTD6 hotkeys to their defaults, then set Mermonkey to `F6`, Skywarden to `F7`, and Desperado to `F8`. Restart the macro after changing the bindings.

### Round or button detection stops working
BTD6 updates can change parts of the UI. The matching FindText pattern may need to be captured again after a game update.

## Notes
- This macro sends normal mouse and keyboard input; it does not edit BTD6 files.
- If the game is not where the strategy expects it to be, stop the script before trying again.
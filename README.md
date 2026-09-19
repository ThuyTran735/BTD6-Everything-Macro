# BTD6 Everything Macro

**Current version: v1.9.0**

The app version used by the macro and update checker is defined in `Scripts/Version.ahk`. The version shown in this README is maintained manually when a release is published.

### Current release highlights

- Added millisecond upgrade timing diagnostics for round detection, monkey selection, green-upgrade detection, hotkey sends, and purchase confirmation
- Logs now record when the user manually closes an active run
- Added dedicated Dartling Gunner aim and retarget helpers
- Added dedicated Heli Pilot Lock in Place and retarget helpers
- Added Mermonkey Allure Totem placement and retarget helpers for xx4/xx5
- Added dedicated Mortar target and retarget helpers
- Standardized special-target actions to Page Down -> 300 ms -> click -> 250 ms -> close panel -> 100 ms
- Special-target helpers now close the upgrade panel after setting a location so later placement and upgrade actions start cleanly
- Updated the map template and map-script guide with Dartling, Heli, Mermonkey, and Mortar examples
- Daily Chest uses ten 325 ms clicks with no redundant Close-button scan
- Centralized version control remains in `Scripts/Version.ahk`


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
- Retries failed runs when the strategy allows it
- Supports normal runs and grind modes from the launcher
- Supports favorites for maps, Monkey EXP scripts, and queue profiles
- Supports reusable Queue Profiles that can be saved, loaded, updated, renamed, and deleted
- Uses themed confirmation dialogs before deleting profiles, clearing the queue, or closing an active run

This project is still being worked on, so not every map or mode has a strategy yet. Check the tracker above for the current list.

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

After resetting the hotkeys, set these three special monkey hotkeys:

| Monkey | Hotkey |
|---|---|
| Desperado | `Shift + Q` |
| Mermonkey | `Shift + W` |
| Skywarden | `Shift + E` |

Leave every other hotkey at its default. Different bindings can make the macro place the wrong tower, buy the wrong upgrade, or stop the strategy completely.

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

To close it completely, right-click the AutoHotkey tray icon and click **Exit**.

## Folder layout

```text
Main.ahk        Starts the launcher
Scripts/        Navigation, placement, upgrades, rounds, UI, and recovery
Maps/           Map strategy files
Lib/            FindText and OCR libraries
Docs/           Strategy-writing notes
Test/           Test scripts
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

Reset the BTD6 hotkeys to their defaults, then restart the macro.

### Round or button detection stops working

BTD6 updates can change parts of the UI. The matching FindText pattern may need to be captured again after a game update.

## Notes

- This macro sends normal mouse and keyboard input; it does not edit BTD6 files.
- If the game is not where the strategy expects it to be, stop the script before trying again.
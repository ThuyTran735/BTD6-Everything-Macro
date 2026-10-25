# BTD6 Everything Macro
**Current version: v3.5.7**

The app version used by the macro and update checker is defined in `Scripts/Version.ahk`. The version shown in this README is maintained manually when a release is published.

### Current release highlights (v3.5.7)

- Fixed button captions and **?** badges disappearing after hover or clicks, stuck pressed colors, and light borders flashing on dark controls.
- Reduced unnecessary repainting across launcher modes, lists, settings, queue windows, and Strategy Builder tabs/resizing. Reopening menus preserves their existing windows; toggling queue controls keeps launcher selections.
- Fixed dropdown positioning at display scaling and screen edges, arrow overlap, and popups remaining visible after their owner closes or hides.
- Removed the opaque first frame from Builder monkey labels and fixed clipped queued-retry HUD text. The existing dark theme, fonts, and button animations are retained.
- Completed a UI regression audit at 125% display scaling. See [UIVisualTestReport.txt](Docs/UIVisualTestReport.txt) for coverage and limits.

### Previous release highlights (v3.5.6)

- Added **Undo / Redo** in Strategy Builder with **Ctrl+Z / Ctrl+Y** for placements, actions, edits, and deletions.
- Added **Save / Discard / Cancel** before closing, clearing, or importing over unsaved work. **Save draft / Ctrl+S** keeps unfinished fields as well as saved rows.
- Added local draft recovery after an unexpected close. Editable drafts and generated `.ahk` exports stay inside **UserData/StrategyBuilder**, which is excluded from Git and included in UserData backups.
- Fixed window growth after coordinate capture and remapping, and kept dropdowns from covering help dialogs. Case-only monkey renames now update linked actions.

### v3.5.5 highlights

- Fixed Strategy Builder growing wider and taller when closing **?** help popups. Help now returns focus without changing the window size or position.
- Added **TOOLS → Name function from map + mode** in Strategy Builder. It follows existing names such as `DarkCastleImpoppable` and uses the difficulty for Standard modes, such as `MonkeyMeadowEasy`.

### v3.5.4 highlights

- Fixed Strategy Builder's right-click menus, **ROW OPTIONS**, and **TOOLS** failing to open.
- Restored the full clickable area of Builder buttons while keeping their animations and separate **?** help buttons.
- **NEW** now clearly reports when the monkey form is ready for another entry. Saved rows stay unchanged.
- Added **Repeat clicks** to Strategy Builder: schedule a set number of left clicks at one coordinate, with a chosen interval between clicks.
- Removed queue buttons from **Auto Collection Event** and expanded its remaining controls. Event runs ignore pending queue jobs; those jobs stay available when you switch back to another mode.
- Fast-speed actions now verify the game's Fast icon with FindText, retrying Space with a 250 ms wait if the icon is missing.

### v3.5.3 highlights

- Added an Expert [Infernal - Impoppable](Maps/Expert/Infernal/Hard/InfernalImpoppable.ahk) strategy for rounds **6-100**.
- Added Expert map-detection patterns for **Bloody Puddles, Workshop, Quad, and Muddy Puddles**.
- Updated Infernal's map-detection pattern and corrected **Inferno** to **Infernal** in map data and the Ace EXP strategy.

### v3.5.2 highlights

- Rebuilt **Strategy Builder** around Monkeys, Actions, and Export views, with a cleaner dark layout and fewer buttons on each screen.
- Added direct editing for scheduled actions. One action-type form shows the fields you need and keeps edited actions in their original order.
- Added checks for placement coordinates, timing, upgrade paths, and actions scheduled before placement or after selling. Copy and Save always generate fresh code from the current strategy.
- Strategy Builder now writes the correct starting and ending rounds for each mode, including **6-100 for Impoppable and CHIMPS**, while keeping round 0 for pregame setup.

A work-in-progress AutoHotkey macro for Bloons TD 6. It can pick a map, load a strategy, place and upgrade towers, watch the current round, handle wins/losses, and get back to the menu for another run.

It is built around a **1920×1080 Windows display and 1920×1080 BTD6 fullscreen** setup. It also requires **AutoHotkey v2**.

## Progress
You can see which maps and modes are finished here:

**[OPEN THE MAP & MODE TRACKER](https://docs.google.com/spreadsheets/d/1uqV7fzFkcJIGeEd6xj-hhhBuhY8A40UP8oUbox0J6VI/edit?usp=sharing)**

## What it currently does
- Finds strategy files inside the `Maps` folder
- Lets you choose a category, map, and mode from the launcher
- Places towers and buys upgrades
- Supports automatic Banana Farm collection while strategies are idle and waiting for rounds
- Handles normal targeting plus coordinate-based Dartling, Heli, Mermonkey, and Mortar special targeting
- Handles tower abilities
- Reads the current round
- Detects victory, defeat, and several menu popups
- Retries failed queued runs and defeated manual / Monkey EXP runs when Auto Retry is enabled
- Supports normal runs and grind modes from the launcher
- Rescans the Halloween collection-event bonus between runs; unsupported maps are skipped, and event mode never runs a lower difficulty to unlock Impoppable
- Checks all six map cards separately, pairing each right-edge event badge with the map in that same card
- Supports favorites for maps, Monkey EXP scripts, and queue profiles
- Supports reusable Queue Profiles that can be saved, loaded, updated, renamed, and deleted
- Remembers the last launcher mode, its relevant selections, and the last successfully run Default-mode `.ahk` strategy between restarts when **REMEMBER LAST STATE** is enabled
- Uses themed confirmation dialogs before deleting profiles, clearing the queue, or closing an active run
- Can export and import the full `UserData` folder from Settings so preferences, favorites, profiles, history, and logs can be carried between versions

This project is still being worked on, so not every map or mode has a strategy yet. Check the tracker above for the current list.

## Current code layout
The v3 code layout keeps the public include paths used by map scripts stable while grouping internal logic into focused folders. Files such as `RoundLogic.ahk`, `UpgradeLogic.ahk`, `GameStateLogic.ahk`, and the larger UI files are small entry files that include the focused pieces from those folders.

The main folders are now easier to follow:

```text
Scripts/Gameplay/          Round, upgrade, and game-state internals
Scripts/Gameplay/Game State/  Popup, victory/defeat, home-screen, and run-state logic
Scripts/Monkey Logic/      Monkey/tower-specific behavior such as Farm collection and special targeting
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

## Strategy Builder

Open `Tools\StrategyBuilder.ahk` to create a strategy or use **IMPORT** to load an existing `.ahk` file or a saved `.btd6draft`.

**Save draft / Ctrl+S** preserves the full editor in `UserData/StrategyBuilder/Drafts`; **Save .ahk** exports added rows to `UserData/StrategyBuilder/Exports`. Recovery copies also stay in UserData. Exporting code does not replace saving an editable draft. Close Strategy Builder before importing a UserData backup so autosave cannot overwrite restored work. Backups from older versions still work.

For step-by-step instructions and a practice example, read [StrategyBuilderHowTo.txt](Docs/StrategyBuilderHowTo.txt).

- **Monkeys:** add each monkey or hero, its placement coordinates, round, and delay. Double-click a placement to edit it; **NEW** starts another entry.
- **Actions:** choose Upgrade, Targeting, Sell, Ability, Game speed, Repeat clicks, or a banana collection toggle. The form shows the relevant fields. Double-click an action to edit it without moving its row; actions with the same round and delay keep their order.
- **Export:** generate a preview, copy the code, or save an `.ahk` file. Copy and Save rebuild the code from your current strategy and check it before exporting.

**ROW OPTIONS** contains edit and delete. **TOOLS** contains **Name function from map + mode**, monkey labels, coordinate remapping, and Clear. The naming tool fills the Function field from your current map and mode, removes spaces and punctuation, and uses Easy/Medium/Hard for Standard. It runs only when selected, so custom and imported function names stay editable. If the name changes, the old preview is cleared; Generate, Copy, and Save use the new name for both the function and its final call. The **?** button opens a short guide. Use **F2** to capture a placement, **F3** for a tower's current position, **F5** for a targeting point, or **F6** for a Repeat clicks point.

The builder checks whole-number rounds and delays, coordinates within the 1920×1080 screen, legal upgrade paths, and whether an action runs before placement or after selling. Imports still warn when a script contains actions the builder cannot edit; review that warning before saving a replacement.

For a midgame click sequence, choose **Repeat clicks** and enter **Click X**, **Click Y**, **Click count**, and **Interval (ms)**. Use **F6 CAPTURE** to record the click point. Round and Delay set when the sequence starts; Interval is the pause between its clicks. For example, round **20**, delay **1000**, point **960, 540**, count **3**, and interval **250** makes three left clicks at that point with a 250 ms pause between clicks, once the scheduled delay has elapsed. The next strategy action waits for the sequence to finish. No monkey selection is needed, and the nearby **?** buttons explain each field.

Exports include the selected mode's round limits: Easy **1-40**, Medium **1-60**, Hard **3-80**, Impoppable/CHIMPS **6-100**, and Deflation **31-60**. Round **0** remains pregame setup. Explicit imported limits are kept until you change the difficulty or mode.

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

Expert Impoppable strategies have a separate Monkey Knowledge warning. These strategies were built and tested with all Monkey Knowledge researched/unlocked, so running them without full Monkey Knowledge may change the expected cash, costs, cooldowns, or bonuses and can cause a loss. The warning appears before an Expert Impoppable run (or before a queue containing one) unless you check **Don't show this warning again** and continue.

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
5. Choose a run count or select **Infinite (until stopped)**, then click **START RUN**, or press:

```text
Ctrl + Shift + P
```

Once a run starts, avoid moving the mouse or pressing game hotkeys unless you are stopping the macro. To stop the active run or queue immediately, press:

```text
Ctrl + Shift + X
```

The emergency-stop hotkey skips the normal confirmation dialog so automation stops immediately. The shortcut is also shown on the Cycle HUD while a run is active.

The launcher uses its full **CLOSE** button to exit the macro. Secondary windows intentionally do not have an extra X; use their **BACK**, **CANCEL**, or **GOT IT** action instead. **CLOSE RUN** remains available only while a run is active and asks for confirmation before stopping automation. All custom windows use the same dark four-sided frame instead of a bright top-only stripe.

By default, the launcher also remembers where you left off. Default mode restores the last category and map, Monkey EXP Grind restores the last monkey category and EXP script, and **Select Script** restores the last Default-mode `.ahk` strategy that successfully started running, including its difficulty when that strategy is still available for the selected map. You can disable this from **Settings -> REMEMBER LAST STATE**. Disabling it clears the saved launcher / strategy state. These values are stored only in `UserData` and are not tracked by Git.

To move your setup to another macro version, open **Settings -> BACKUP / RESTORE USER DATA**. **EXPORT USER DATA** creates a dated backup containing the full `UserData` folder. **IMPORT USER DATA** merges a backup into the current copy and overwrites matching files while keeping files that only exist in the newer version. Restart the macro after importing so all restored values are reloaded.


## Moving-map targeting coordinates

Normal targeting actions can optionally include the tower's current X/Y position. This is useful on maps where the tower itself moves after placement.

```ahk
[34, 750, () => SetTargeting(TowerSetup["Sniper A"], "First", 763, 1029)],
```

The extra coordinates only override where the macro clicks to select the tower for that targeting action. If X/Y are omitted, `SetTargeting()` continues using the tower's original placement coordinates. Strategy Builder can capture these targeting coordinates with **F5**.

## Banana Farm collection
Banana Farm collection is opt-in per strategy. Enable it with a normal scheduled strategy action, so the existing round and delay fields control exactly when automatic collection begins.

```ahk
[20, 0, () => EnableBananaCollection()],
```

A delayed start works the same way:

```ahk
[20, 1500, () => EnableBananaCollection()],
```

That enables Banana Farm collection 1.5 seconds into round 20. After it is enabled, the macro only moves the mouse for bananas while it is otherwise waiting for a future strategy round. It does not run a separate background timer, so tower placement, upgrades, abilities, targeting, navigation, and recovery keep priority.

You do **not** schedule collection for individual Farms. Keep Banana Farms in `TowerSetup` like normal and place them with `PlaceTower()`. Any placed tower with `type: "Farm"` or `type: "Banana Farm"` is picked up automatically, including Farms placed after collection has already been enabled.

```ahk
[10, 0, () => PlaceTower(TowerSetup["Farm A"])],
[10, 500, () => EnableBananaCollection()],
[20, 0, () => PlaceTower(TowerSetup["Farm B"])],
```

BTD6 collects loose bananas when the mouse hovers over the Banana Farm itself, so the macro only needs the Farm's center coordinate. Collection rotates through eligible Farms **one at a time**. Each idle collection step moves to one Farm, stays there for about **300 ms**, then returns to `WaitForRound()` before visiting the next Farm. This lets the macro re-read the round and run any due placement, upgrade, ability, targeting, or other scheduled action before banana collection continues. When the strategy becomes idle again, collection resumes with the next eligible Farm.

If a Farm is under or close to the Cycle HUD, the HUD is hidden before the mouse moves to the Farm using the same protection used for tower placement and map clicks.

With multiple eligible Farms, the idle rotation is effectively:

```text
Farm A (300 ms) -> round/action check -> Farm B (300 ms) -> round/action check -> Farm C -> repeat
```

A Farm is removed from automatic collection as soon as its tracked upgrades show a path that no longer needs normal banana pickup:

- **Monkey Bank or higher** (`middle path >= 3`)
- **Marketplace or higher** (`bottom path >= 3`)

The check uses the Farm's live `upgrades` array, so no extra strategy action is needed after those upgrades are purchased. Strategy Builder includes **ENABLE BANANA COLLECTION** and **DISABLE BANANA COLLECTION** actions that use the same Round and Delay fields. You can also write the action manually:

```ahk
[60, 0, () => DisableBananaCollection()],
```

## Scheduled game speed
Strategies can switch BTD6 between normal and fast speed with `SetGameSpeed()`. The normal strategy delay field still works, so speed changes can happen partway through a round.

```ahk
[39, 10000, () => SetGameSpeed("Normal")],
[41, 0, () => SetGameSpeed("Fast")],
```

The example slows the game down 10 seconds into round 39, then returns to fast speed as soon as round 41 is detected. `StartGame()` presses Space twice for normal modes (start the round, then enable fast speed). Apopalypse starts automatically, so it presses Space once to switch the running match to fast speed. Strategy Builder can add and import these speed actions too.

`SetGameSpeed("Fast")` checks the Fast icon even when the macro already remembers Fast. If the icon is absent, it presses Space, waits 250 ms, and scans a fresh frame. It makes at most five attempts and reports `GAME SPEED FAILED` if Fast cannot be confirmed. An already-visible Fast icon needs no key press. Normal requests still use the tracked speed; the supplied pattern confirms Fast only.

## Folder layout
```text
Main.ahk        Starts the launcher
Scripts/        Navigation, placement, upgrades, rounds, UI, and recovery
Scripts/Monkey Logic/  Monkey/tower-specific behavior and Banana Farm collection
Scripts/Gameplay/Game State/  Popup, victory/defeat, home-screen, and run-state logic
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

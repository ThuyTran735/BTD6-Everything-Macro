#Requires AutoHotkey v2.0

#Include ..\Scripts\IncludeAll.ahk


RunConfig := {
    category: "Beginner",
    map: "Monkey Meadow",
    difficulty: "Easy",
    gameMode: "Standard",
    hero: "Quincy"
}


global TowerSetup := Map(
    "Hero", {
        type: "Hero",
        x: 629,
        y: 504,
        placed: false,
        upgrades: [0, 0, 0]
    },

    "Dart A", {
        type: "Dart",
        x: 353,
        y: 409,
        placed: false,
        upgrades: [0, 0, 0]
    }
)


strategy := [
    [0, 0, () => PlaceTower(TowerSetup["Hero"])],
    [3, 0, () => PlaceTower(TowerSetup["Dart A"])],
    [5, 0, () => UpgradeTower(TowerSetup["Dart A"], "002")],
    [7, 0, () => UpgradeTower(TowerSetup["Dart A"], "022")],
    [8, 0, () => UpgradeTower(TowerSetup["Dart A"], "024")]
]


ToolTip("Starting navigation test...")
Sleep(1000)
ToolTip()


if !NavigateToMap(
    RunConfig.category,
    RunConfig.map,
    RunConfig.difficulty,
    RunConfig.gameMode,
    RunConfig.hero
) {
    MsgBox("Navigation failed.")
    ExitApp()
}


ToolTip("Waiting for game to load...")

if !WaitForGameLoad() {
    MsgBox("Game load detection failed.")
    ExitApp()
}

ToolTip()


ResetRoundTracking()


ToolTip("Starting game...")
Sleep(500)
ToolTip()

if !StartGame() {
    MsgBox("Could not start game.")
    ExitApp()
}


if !RunStrategy(strategy) {
    MsgBox("Strategy failed.")
    ExitApp()
}


MsgBox("Test completed successfully.")
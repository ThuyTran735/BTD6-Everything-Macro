#Requires AutoHotkey v2.0

#Include ..\Scripts\IncludeAll.ahk


RunConfig := {
    category: "Beginner",
    map: "Monkey Meadow",
    difficulty: "Easy",
    gameMode: "Standard",
    hero: false
}


global TowerSetup := Map(
    "Dart A", {
        type: "Dart",
        x: 1598,
        y: 282,
        placed: false,
        upgrades: [0, 0, 0]
    }
)


strategy := [
    [0, 0, () => PlaceTower(TowerSetup["Dart A"])],

    [1, 0, () => UpgradeTower(TowerSetup["Dart A"], "005")],
]


ToolTip("Starting navigation test...")
Sleep(500)
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


if !WaitForGameLoad() {
    MsgBox("Game load detection failed.")
    ExitApp()
}


ResetRoundTracking()
ResetTowerSetup()


pregameResult := RunPregameStrategy(strategy)


if pregameResult = "Victory" {
    if !HandleVictory()
        MsgBox("Victory handling failed.")

    ExitApp()
}


if pregameResult = "Defeat" {
    MsgBox("Defeat detected during pregame.")
    ExitApp()
}


if pregameResult = false {
    MsgBox("Pregame strategy failed.")
    ExitApp()
}


ResetRoundTracking()


if !StartGame() {
    MsgBox("Could not start game.")
    ExitApp()
}


result := RunStrategy(strategy)


if result = "Victory" {
    if !HandleVictory() {
        MsgBox("Victory handling failed.")
        ExitApp()
    }

    MsgBox("Victory.")
    ExitApp()
}


if result = "Defeat" {
    MsgBox("Defeat detected.")
    ExitApp()
}


if result = false {
    MsgBox("Strategy failed.")
    ExitApp()
}


MsgBox("Test completed.")
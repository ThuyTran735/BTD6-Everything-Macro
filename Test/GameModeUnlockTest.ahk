#Requires AutoHotkey v2.0

#Include ..\Scripts\IncludeAll.ahk


global RunConfig := {
    category: "Beginner",
    map: "In The Loop",
    difficulty: "Easy",
    gameMode: "Deflation",

    hero: false,

    maxAttempts: 1,
    wingmonkeyMK: false,

    startRound: 31,
    endRound: 60
}


global TowerSetup := Map(
    "Dart A", {
        type: "Dart",
        x: 317,
        y: 707,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    }
)


strategy := [
    ; Deflation setup.
    [0, 0, () => PlaceTower(
        TowerSetup["Dart A"]
    )],

    [0, 0, () => UpgradeTower(
        TowerSetup["Dart A"],
        "024"
    )],
]


ToolTip(
    "Testing automatic game-mode unlock..."
    "`nRequested mode: Deflation"
)

Sleep(1500)
ToolTip()


result := RunMapStrategy(strategy)


if result {
    MsgBox(
        "Game-mode unlock test completed successfully."
    )

    ExitApp()
}


if result = "Locked" {
    MsgBox(
        "Test stopped because the game mode "
        "could not be unlocked automatically."
    )

    ExitApp()
}


MsgBox(
    "Game-mode unlock test failed."
)


ExitApp()
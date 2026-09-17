#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\Scripts\IncludeAll.ahk

; V1.5 end-to-end run test.
; Uses the same RunMapStrategy() pipeline as real map scripts.
global RunConfig := {
    category: "Beginner",
    map: "Monkey Meadow",
    difficulty: "Easy",
    gameMode: "Standard",
    hero: false,
    wingmonkeyMK: false
}

global TowerSetup := Map(
    "Dart A", {
        type: "Dart",
        x: 316,
        y: 405,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    }
)

strategy := [
    [0, 0, () => PlaceTower(TowerSetup["Dart A"])],
    [1, 0, () => UpgradeTower(TowerSetup["Dart A"], "002")]
]

result := RunMapStrategy(strategy)

if result {
    MsgBox("Full game test completed successfully.", "BTD6 V1.5 Test")
} else {
    MsgBox(
        "Full game test failed."
        "`n`nReason: " GetRunFailureReason("Unknown failure"),
        "BTD6 V1.5 Test"
    )
}

ExitApp()
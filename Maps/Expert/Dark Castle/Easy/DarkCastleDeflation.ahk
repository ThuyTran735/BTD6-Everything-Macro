#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


DarkCastleDeflation() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: false,

        ; Maximum number of attempts before giving up.
        maxAttempts: 3,

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false,

        startRound: 31,
        endRound: 60,
    }


    global TowerSetup := Map(
        "Dart A", {
            type: "Dart",
            x: 850,
            y: 658,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
    )


    strategy := [
        [0, 0, () => PlaceTower(
            TowerSetup["Dart A"]
        )],

        [0, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "025"
        )],
    ]

    return RunMapStrategy(strategy)
}

DarkCastleDeflation()
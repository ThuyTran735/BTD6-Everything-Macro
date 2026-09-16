#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


BombEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: "Captain Churchill",

        ; Maximum number of attempts before giving up.
        maxAttempts: 3,

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false,

        startRound: 31,
        endRound: 60,
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 909,
            y: 439,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Boomerang A", {
            type: "Boomerang",
            x: 1010,
            y: 442,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Bomb A", {
            type: "Bomb",
            x: 803,
            y: 441,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Bomb B", {
            type: "Bomb",
            x: 911,
            y: 667,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Bomb C", {
            type: "Bomb",
            x: 543,
            y: 464,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Village A", {
            type: "Village",
            x: 721,
            y: 388,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
    )


    strategy := [
        [0, 0, () => PlaceTower(
            TowerSetup["Boomerang A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "302"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Hero"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Bomb A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Bomb A"],
            "204"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Bomb B"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Bomb B"],
            "204"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Bomb C"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Bomb C"],
            "042"
        )],

        [0, 0, () => SetTargeting(
            TowerSetup["Bomb C"],
            "Strong"
        )],

        [32, 0, () => PlaceTower(
            TowerSetup["Village A"]
        )],


        [32, 0, () => UpgradeTower(
            TowerSetup["Village A"],
            "020"
        )],
    ]

    return RunMapStrategy(strategy)
}

BombEXP()
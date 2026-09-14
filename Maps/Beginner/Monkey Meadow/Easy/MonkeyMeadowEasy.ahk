#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk


MonkeyMeadowEasy() {
    global RunConfig := {
        category: "Beginner",
        map: "Monkey Meadow",
        difficulty: "Easy",
        gameMode: "Standard",

        hero: "Quincy",

        ; Maximum number of attempts before giving up.
        maxAttempts: 3,

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 495,
            y: 504,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart A", {
            type: "Dart",
            x: 316,
            y: 405,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart B", {
            type: "Dart",
            x: 316,
            y: 260,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart C", {
            type: "Dart",
            x: 130,
            y: 509,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart D", {
            type: "Dart",
            x: 255,
            y: 604,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Boomerang A", {
            type: "Boomerang",
            x: 308,
            y: 508,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )


    strategy := [
        ; Round 0 = before Round 1 starts.

        [0, 0, () => PlaceTower(
            TowerSetup["Hero"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart A"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Boomerang A"]
        )],

        [2, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "002"
        )],

        [4, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "202"
        )],

        [6, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "002"
        )],

        [8, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "022"
        )],

        [10, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "023"
        )],

        [15, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "203"
        )],

        [15, 0, () => SetTargeting(
            TowerSetup["Boomerang A"],
            "Last"
        )],

        [23, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "204"
        )],

        [27, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "024"
        )],

        [28, 0, () => PlaceTower(
            TowerSetup["Dart B"]
        )],

        [28, 0, () => UpgradeTower(
            TowerSetup["Dart B"],
            "024"
        )],

        [35, 0, () => PlaceTower(
            TowerSetup["Dart C"]
        )],

        [35, 0, () => UpgradeTower(
            TowerSetup["Dart C"],
            "024"
        )],

        [38, 0, () => PlaceTower(
            TowerSetup["Dart D"]
        )],

        [38, 0, () => UpgradeTower(
            TowerSetup["Dart D"],
            "024"
        )],
    ]

    return RunMapStrategy(strategy)
}

MonkeyMeadowEasy()
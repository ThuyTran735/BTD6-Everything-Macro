#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


DartEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: "Captain Churchill",

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false,

        startRound: 31,
        endRound: 60,
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 989,
            y: 429,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart A", {
            type: "Dart",
            x: 797,
            y: 447,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart B", {
            type: "Dart",
            x: 797,
            y: 674,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart C", {
            type: "Dart",
            x: 893,
            y: 669,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart D", {
            type: "Dart",
            x: 546,
            y: 475,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart E", {
            type: "Dart",
            x: 537,
            y: 640,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart F", {
            type: "Dart",
            x: 883,
            y: 440,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart G", {
            type: "Dart",
            x: 359,
            y: 562,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
    )


    strategy := [
        [0, 0, () => PlaceTower(
            TowerSetup["Hero"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "024"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart B"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Dart B"],
            "024"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart C"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Dart C"],
            "024"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart D"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Dart D"],
            "024"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart E"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Dart E"],
            "024"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart F"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Dart F"],
            "024"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart G"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Dart G"],
            "003"
        )],

        [60, 8000, () => UseAbility("1")],
        [60, 8250, () => UseAbility("2")],
        [60, 8500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

DartEXP()
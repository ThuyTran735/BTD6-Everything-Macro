#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


DartEXP() {
    ; Navigation and round bounds for this saved strategy.
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


    ; Named placement records. Helpers update placed, upgrades, and targeting during the run.
    ; The X/Y values here remain the original placement points.
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
    )


    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
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
            "402"
        )],

        [0, 0, () => SetTargeting(
            TowerSetup["Dart F"],
            "Strong"
        )],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

DartEXP()
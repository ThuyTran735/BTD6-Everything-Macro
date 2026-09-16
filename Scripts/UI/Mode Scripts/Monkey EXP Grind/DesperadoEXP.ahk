#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


DesperadoEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: "Churchill",

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
            x: 994,
            y: 434,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Desperado A", {
            type: "Desperado",
            x: 892,
            y: 442,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Desperado B", {
            type: "Desperado",
            x: 570,
            y: 489,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Desperado C", {
            type: "Desperado",
            x: 737,
            y: 673,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Desperado D", {
            type: "Desperado",
            x: 800,
            y: 441,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Desperado E", {
            type: "Desperado",
            x: 979,
            y: 664,
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
            TowerSetup["Desperado A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Desperado A"],
            "240"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Desperado B"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Desperado B"],
            "023"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Desperado C"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Desperado C"],
            "023"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Desperado D"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Desperado D"],
            "023"
        )],

        [32, 0, () => PlaceTower(
            TowerSetup["Desperado E"]
        )],


        [32, 0, () => UpgradeTower(
            TowerSetup["Desperado E"],
            "210"
        )],
    ]

    return RunMapStrategy(strategy)
}

DesperadoEXP()
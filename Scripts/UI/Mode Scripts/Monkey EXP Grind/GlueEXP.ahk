#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


GlueEXP() {
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
            x: 959,
            y: 434,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper A", {
            type: "Sniper",
            x: 1453,
            y: 565,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Glue A", {
            type: "Glue",
            x: 865,
            y: 442,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Glue B", {
            type: "Glue",
            x: 1008,
            y: 678,
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
            TowerSetup["Sniper A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Sniper A"],
            "024"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Glue A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Glue A"],
            "420"
        )],

        [32, 0, () => PlaceTower(
            TowerSetup["Glue B"]
        )],


        [32, 0, () => UpgradeTower(
            TowerSetup["Glue B"],
            "320"
        )],
    ]

    return RunMapStrategy(strategy)
}

GlueEXP()
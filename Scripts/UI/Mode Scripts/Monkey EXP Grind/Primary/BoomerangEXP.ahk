#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


BoomerangEXP() {
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
            x: 908,
            y: 426,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Boomerang A", {
            type: "Boomerang",
            x: 1003,
            y: 444,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Boomerang B", {
            type: "Boomerang",
            x: 803,
            y: 444,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Boomerang C", {
            type: "Boomerang",
            x: 720,
            y: 424,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Boomerang D", {
            type: "Boomerang",
            x: 745,
            y: 330,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Village A", {
            type: "Village",
            x: 849,
            y: 339,
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
            "402"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Hero"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Boomerang B"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Boomerang B"],
            "204"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Boomerang C"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Boomerang C"],
            "204"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Village A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Village A"],
            "320"
        )],

        [32, 0, () => PlaceTower(
            TowerSetup["Boomerang D"]
        )],


        [32, 0, () => UpgradeTower(
            TowerSetup["Boomerang D"],
            "022"
        )],
    ]

    return RunMapStrategy(strategy)
}

BoomerangEXP()
#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


BoomerangEXP() {
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


    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
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

        [0, 0, () => PlaceTower(
            TowerSetup["Boomerang D"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Boomerang D"],
            "022"
        )],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

BoomerangEXP()
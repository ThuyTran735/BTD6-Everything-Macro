#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


TackEXP() {
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
            x: 1004,
            y: 437,
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

        "Tack A", {
            type: "Tack",
            x: 853,
            y: 447,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Tack B", {
            type: "Tack",
            x: 563,
            y: 488,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Tack C", {
            type: "Tack",
            x: 563,
            y: 621,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Tack D", {
            type: "Tack",
            x: 724,
            y: 667,
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
            TowerSetup["Tack A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Tack A"],
            "420"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Tack B"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Tack B"],
            "204"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Tack C"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Tack C"],
            "230"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Tack D"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Tack D"],
            "032"
        )],

        [60, 8000, () => UseAbility("1")],
        [60, 8250, () => UseAbility("2")],
        [60, 8500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

TackEXP()
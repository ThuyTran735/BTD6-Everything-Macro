#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk


TinkertonDeflation() {
    global RunConfig := {
        category: "Beginner",
        map: "Tinkerton",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: "Psi",

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false,

        startRound: 31,
        endRound: 60,
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 804,
            y: 757,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Ace A", {
            type: "Ace",
            x: 645,
            y: 754,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Ace B", {
            type: "Ace",
            x: 645,
            y: 660,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Village A", {
            type: "Village",
            x: 789,
            y: 626,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Alchemist A", {
            type: "Alchemist",
            x: 655,
            y: 586,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )


    strategy := [
        [0, 0, () => PlaceTower(
            TowerSetup["Hero"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Ace A"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Ace B"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Village A"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Alchemist A"]
        )],

        [0, 0, () => UpgradeTower(
            TowerSetup["Ace A"],
            "203"
        )],

        [0, 0, () => UpgradeTower(
            TowerSetup["Ace B"],
            "203"
        )],

        [0, 0, () => UpgradeTower(
            TowerSetup["Village A"],
            "220"
        )],

        [0, 0, () => UpgradeTower(
            TowerSetup["Alchemist A"],
            "420"
        )],
    ]

    return RunMapStrategy(strategy)
}

TinkertonDeflation()
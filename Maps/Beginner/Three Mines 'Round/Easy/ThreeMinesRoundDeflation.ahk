#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


ThreeMinesRoundDeflation() {
    global RunConfig := {
        category: "Beginner",
        map: "Three Mines 'Round",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: "Psi",

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
            x: 1532,
            y: 595,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Ace A", {
            type: "Ace",
            x: 1373,
            y: 592,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Ace B", {
            type: "Ace",
            x: 1373,
            y: 498,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Village A", {
            type: "Village",
            x: 1517,
            y: 464,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Alchemist A", {
            type: "Alchemist",
            x: 1383,
            y: 424,
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

ThreeMinesRoundDeflation()
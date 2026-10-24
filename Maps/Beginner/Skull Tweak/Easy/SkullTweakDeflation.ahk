#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


SkullTweakDeflation() {
    ; Navigation and round bounds for this saved strategy.
    global RunConfig := {
        category: "Beginner",
        map: "Skull Tweak",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: "Psi",

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
            x: 1560,
            y: 1022,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Ace A", {
            type: "Ace",
            x: 1401,
            y: 1019,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Ace B", {
            type: "Ace",
            x: 1401,
            y: 925,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Village A", {
            type: "Village",
            x: 1545,
            y: 891,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Alchemist A", {
            type: "Alchemist",
            x: 1449,
            y: 851,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )


    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
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

SkullTweakDeflation()
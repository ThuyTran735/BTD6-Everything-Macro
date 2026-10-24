#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


DesperadoEXP() {
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


    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
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

        [0, 0, () => PlaceTower(
            TowerSetup["Desperado E"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Desperado E"],
            "210"
        )],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

DesperadoEXP()
#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


IceEXP() {
    ; Navigation and round bounds for this saved strategy.
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: "Silas",

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
            x: 920,
            y: 443,
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

        "Ice A", {
            type: "Ice",
            x: 569,
            y: 491,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Ice B", {
            type: "Ice",
            x: 571,
            y: 619,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Ice C", {
            type: "Ice",
            x: 1004,
            y: 441,
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
            TowerSetup["Sniper A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Sniper A"],
            "024"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Ice A"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Ice A"],
            "420"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Ice B"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Ice B"],
            "302"
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Ice C"]
        )],


        [0, 0, () => UpgradeTower(
            TowerSetup["Ice C"],
            "204"
        )],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

IceEXP()
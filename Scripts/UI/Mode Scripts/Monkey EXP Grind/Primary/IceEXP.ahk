#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

; #Include Location Of IncludeAll.ahk


IceEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",

        hero: "Silas",

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

        [60, 4000, () => UseAbility("1")],
        [60, 4250, () => UseAbility("2")],
    ]

    return RunMapStrategy(strategy)
}

IceEXP()
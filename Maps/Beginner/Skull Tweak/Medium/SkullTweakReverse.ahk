#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk


SkullTweakReverse() {
    global RunConfig := {
        category: "Beginner",
        map: "Skull Tweak",
        difficulty: "Medium",
        gameMode: "Reverse",

        hero: "Quincy",

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 524,
            y: 310,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper A", {
            type: "Sniper",
            x: 182,
            y: 215,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper B", {
            type: "Sniper",
            x: 178,
            y: 295,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper C", {
            type: "Sniper",
            x: 175,
            y: 383,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper D", {
            type: "Sniper",
            x: 92,
            y: 264,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper E", {
            type: "Sniper",
            x: 89,
            y: 358,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
    )


    strategy := [
        ; Round 0 = before Round 1 starts.

        [0, 0, () => PlaceTower(
            TowerSetup["Hero"]
        )],

        [3, 0, () => PlaceTower(
            TowerSetup["Sniper A"]
        )],

        [3, 0, () => SetTargeting(
            TowerSetup["Sniper A"],
            "Strong"
        )],

        [6, 0, () => PlaceTower(
            TowerSetup["Sniper B"]
        )],

        [7, 0, () => UpgradeTower(
            TowerSetup["Sniper A"],
            "110"
        )],

        [10, 0, () => UpgradeTower(
            TowerSetup["Sniper B"],
            "022"
        )],

        [17, 0, () => UpgradeTower(
            TowerSetup["Sniper A"],
            "220"
        )],

        [24, 0, () => PlaceTower(
            TowerSetup["Sniper C"]
        )],

        [24, 0, () => UpgradeTower(
            TowerSetup["Sniper C"],
            "022"
        )],

        [34, 0, () => UpgradeTower(
            TowerSetup["Sniper B"],
            "024"
        )],

        [39, 0, () => UpgradeTower(
            TowerSetup["Sniper A"],
            "320"
        )],

        [41, 0, () => UpgradeTower(
            TowerSetup["Sniper C"],
            "024"
        )],

        [48, 0, () => UpgradeTower(
            TowerSetup["Sniper A"],
            "420"
        )],

        [49, 0, () => PlaceTower(
            TowerSetup["Sniper D"]
        )],

        [49, 0, () => UpgradeTower(
            TowerSetup["Sniper D"],
            "204"
        )],

        [52, 0, () => PlaceTower(
            TowerSetup["Sniper E"]
        )],

        [52, 0, () => SetTargeting(
            TowerSetup["Sniper E"],
            "Strong"
        )],

        [52, 0, () => UpgradeTower(
            TowerSetup["Sniper E"],
            "420"
        )],
    ]

    return RunMapStrategy(strategy)
}

SkullTweakReverse()
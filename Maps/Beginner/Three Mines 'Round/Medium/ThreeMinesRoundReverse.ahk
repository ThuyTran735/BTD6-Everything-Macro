#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk


ThreeMinesRoundReverse() {
    global RunConfig := {
        category: "Beginner",
        map: "Three Mines 'Round",
        difficulty: "Medium",
        gameMode: "Reverse",

        hero: "Quincy",

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 731,
            y: 677,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper A", {
            type: "Sniper",
            x: 280,
            y: 240,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper B", {
            type: "Sniper",
            x: 276,
            y: 328,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper C", {
            type: "Sniper",
            x: 266,
            y: 440,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper D", {
            type: "Sniper",
            x: 260,
            y: 733,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Sniper E", {
            type: "Sniper",
            x: 255,
            y: 837,
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

ThreeMinesRoundReverse()
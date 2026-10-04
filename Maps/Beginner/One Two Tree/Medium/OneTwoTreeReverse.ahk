#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

OneTwoTreeReverse() {
    global RunConfig := {
        category: "Beginner",
        map: "One Two Tree",
        difficulty: "Medium",
        gameMode: "Reverse",
        hero: "Quincy",
        wingmonkeyMK: false
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 964,
            y: 270,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 444,
            y: 267,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper B", {
            type: "Sniper",
            x: 521,
            y: 264,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper C", {
            type: "Sniper",
            x: 602,
            y: 265,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper D", {
            type: "Sniper",
            x: 687,
            y: 259,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper E", {
            type: "Sniper",
            x: 774,
            y: 262,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [3, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [3, 0, () => SetTargeting(TowerSetup["Sniper A"], "Strong")],
        [6, 0, () => PlaceTower(TowerSetup["Sniper B"])],
        [7, 0, () => UpgradeTower(TowerSetup["Sniper A"], "110")],
        [10, 0, () => UpgradeTower(TowerSetup["Sniper B"], "022")],
        [17, 0, () => UpgradeTower(TowerSetup["Sniper A"], "220")],
        [24, 0, () => PlaceTower(TowerSetup["Sniper C"])],
        [24, 0, () => UpgradeTower(TowerSetup["Sniper C"], "022")],
        [34, 0, () => UpgradeTower(TowerSetup["Sniper B"], "024")],
        [39, 0, () => UpgradeTower(TowerSetup["Sniper A"], "320")],
        [41, 0, () => UpgradeTower(TowerSetup["Sniper C"], "024")],
        [48, 0, () => UpgradeTower(TowerSetup["Sniper A"], "420")],
        [49, 0, () => PlaceTower(TowerSetup["Sniper D"])],
        [49, 0, () => UpgradeTower(TowerSetup["Sniper D"], "204")],
        [52, 0, () => PlaceTower(TowerSetup["Sniper E"])],
        [52, 0, () => SetTargeting(TowerSetup["Sniper E"], "Strong")],
        [52, 0, () => UpgradeTower(TowerSetup["Sniper E"], "420")]
    ]

    return RunMapStrategy(strategy)
}

OneTwoTreeReverse()

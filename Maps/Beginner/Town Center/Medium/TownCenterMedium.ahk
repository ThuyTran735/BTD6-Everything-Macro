#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

TownCenterMedium() {
    global RunConfig := {
        category: "Beginner",
        map: "Town Center",
        difficulty: "Medium",
        gameMode: "Standard",
        hero: "Quincy",
        wingmonkeyMK: false
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 568,
            y: 489,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 355,
            y: 399,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper B", {
            type: "Sniper",
            x: 254,
            y: 401,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper C", {
            type: "Sniper",
            x: 296,
            y: 480,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper D", {
            type: "Sniper",
            x: 404,
            y: 475,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper E", {
            type: "Sniper",
            x: 185,
            y: 483,
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

TownCenterMedium()

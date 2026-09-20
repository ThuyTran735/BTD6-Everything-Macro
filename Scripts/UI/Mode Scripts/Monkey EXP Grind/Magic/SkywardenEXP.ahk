#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

SkywardenEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",
        hero: "Captain Churchill",
        wingmonkeyMK: false,
        startRound: 31,
        endRound: 60,
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 991,
            y: 439,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden A", {
            type: "Skywarden",
            x: 733,
            y: 441,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden B", {
            type: "Skywarden",
            x: 806,
            y: 450,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden C", {
            type: "Skywarden",
            x: 734,
            y: 658,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden D", {
            type: "Skywarden",
            x: 806,
            y: 660,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden E", {
            type: "Skywarden",
            x: 878,
            y: 449,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden F", {
            type: "Skywarden",
            x: 875,
            y: 667,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden A"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden B"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden C"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden D"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden E"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden F"])],

        [0, 0, () => UpgradeTower(TowerSetup["Skywarden A"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden B"], "240")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden C"], "204")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden D"], "230")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden E"], "220")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden F"], "200")],

        [60, 8000, () => UseAbility("1")],
        [60, 8250, () => UseAbility("2")],
        [60, 8500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

SkywardenEXP()

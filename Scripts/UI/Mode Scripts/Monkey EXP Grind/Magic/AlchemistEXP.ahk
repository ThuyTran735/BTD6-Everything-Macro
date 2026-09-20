#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

AlchemistEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",
        hero: false,
        wingmonkeyMK: false,
        startRound: 31,
        endRound: 60,
    }

    global TowerSetup := Map(
        "Sniper A", {
            type: "Sniper",
            x: 1455,
            y: 554,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 1524,
            y: 485,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist B", {
            type: "Alchemist",
            x: 1526,
            y: 592,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist C", {
            type: "Alchemist",
            x: 810,
            y: 448,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist D", {
            type: "Alchemist",
            x: 805,
            y: 662,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [0, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [0, 0, () => PlaceTower(TowerSetup["Alchemist B"])],
        [0, 0, () => PlaceTower(TowerSetup["Alchemist C"])],
        [0, 0, () => PlaceTower(TowerSetup["Alchemist D"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sniper A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Alchemist C"], "220")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

AlchemistEXP()

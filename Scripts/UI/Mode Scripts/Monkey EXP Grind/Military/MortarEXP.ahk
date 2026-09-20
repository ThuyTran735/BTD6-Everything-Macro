#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

MortarEXP() {
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
            x: 986,
            y: 431,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 1450,
            y: 492,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mortar A", {
            type: "Mortar",
            x: 1560,
            y: 421,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Target"
        },
        "Mortar B", {
            type: "Mortar",
            x: 1565,
            y: 568,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Target"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [0, 0, () => PlaceTower(TowerSetup["Mortar A"])],
        [0, 0, () => PlaceTower(TowerSetup["Mortar B"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sniper A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Mortar A"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Mortar B"], "310")],

        [0, 0, () => SetMortarTarget(
            TowerSetup["Mortar A"],
            729,
            546
        )],

        [0, 0, () => SetMortarTarget(
            TowerSetup["Mortar B"],
            729,
            546
        )],

        [60, 8000, () => UseAbility("1")],
        [60, 8250, () => UseAbility("2")],
        [60, 8500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

MortarEXP()

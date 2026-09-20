#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

NinjaEXP() {
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
            x: 988,
            y: 438,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 1458,
            y: 560,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja A", {
            type: "Ninja",
            x: 882,
            y: 446,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja B", {
            type: "Ninja",
            x: 878,
            y: 662,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja C", {
            type: "Ninja",
            x: 769,
            y: 447,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [0, 0, () => PlaceTower(TowerSetup["Ninja A"])],
        [0, 0, () => PlaceTower(TowerSetup["Ninja B"])],
        [0, 0, () => PlaceTower(TowerSetup["Ninja C"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sniper A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Ninja A"], "402")],
        [0, 0, () => UpgradeTower(TowerSetup["Ninja B"], "402")],
        [0, 0, () => UpgradeTower(TowerSetup["Ninja C"], "301")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

NinjaEXP()

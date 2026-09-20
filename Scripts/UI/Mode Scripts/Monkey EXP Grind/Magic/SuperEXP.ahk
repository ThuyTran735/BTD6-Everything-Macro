#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

SuperEXP() {
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
            x: 990,
            y: 424,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super A", {
            type: "Super",
            x: 853,
            y: 429,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super B", {
            type: "Super",
            x: 855,
            y: 681,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Super A"])],
        [0, 0, () => PlaceTower(TowerSetup["Super B"])],

        [0, 0, () => UpgradeTower(TowerSetup["Super A"], "203")],
        [0, 0, () => UpgradeTower(TowerSetup["Super B"], "100")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

SuperEXP()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

MermonkeyEXP() {
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
            x: 996,
            y: 437,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey A", {
            type: "Mermonkey",
            x: 904,
            y: 443,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey B", {
            type: "Mermonkey",
            x: 816,
            y: 437,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey C", {
            type: "Mermonkey",
            x: 730,
            y: 422,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Mermonkey A"])],
        [0, 0, () => PlaceTower(TowerSetup["Mermonkey B"])],
        [0, 0, () => PlaceTower(TowerSetup["Mermonkey C"])],

        [0, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "042")],
        [0, 0, () => UpgradeTower(TowerSetup["Mermonkey B"], "402")],
        [0, 0, () => UpgradeTower(TowerSetup["Mermonkey C"], "013")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

MermonkeyEXP()

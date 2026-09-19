#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

BuccaneerEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",
        hero: "Captain Churchill",
        wingmonkeyMK: false
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 993,
            y: 435,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer A", {
            type: "Buccaneer",
            x: 1103,
            y: 427,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer B", {
            type: "Buccaneer",
            x: 1090,
            y: 707,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer C", {
            type: "Buccaneer",
            x: 1192,
            y: 717,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Buccaneer A"])],
        [0, 0, () => PlaceTower(TowerSetup["Buccaneer B"])],
        [0, 0, () => PlaceTower(TowerSetup["Buccaneer C"])],
        [0, 0, () => UpgradeTower(TowerSetup["Buccaneer A"], "402")],
        [0, 0, () => UpgradeTower(TowerSetup["Buccaneer B"], "320")],
        [0, 0, () => UpgradeTower(TowerSetup["Buccaneer C"], "220")]
    ]

    return RunMapStrategy(strategy)
}

BuccaneerEXP()

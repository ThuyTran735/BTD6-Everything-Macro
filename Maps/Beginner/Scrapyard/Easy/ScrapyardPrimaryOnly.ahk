#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

ScrapyardPrimaryOnly() {
    global RunConfig := {
        category: "Beginner",
        map: "Scrapyard",
        difficulty: "Easy",
        gameMode: "Primary Only",
        hero: "Quincy",
        wingmonkeyMK: false
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 684,
            y: 445,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart A", {
            type: "Dart",
            x: 636,
            y: 861,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 677,
            y: 514,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 679,
            y: 587,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart D", {
            type: "Dart",
            x: 532,
            y: 872,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Boomerang A", {
            type: "Boomerang",
            x: 679,
            y: 670,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Dart A"])],
        [3, 0, () => PlaceTower(TowerSetup["Boomerang A"])],
        [5, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "002")],
        [7, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "202")],
        [8, 0, () => UpgradeTower(TowerSetup["Dart A"], "002")],
        [10, 0, () => UpgradeTower(TowerSetup["Dart A"], "022")],
        [12, 0, () => UpgradeTower(TowerSetup["Dart A"], "023")],
        [17, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "203")],
        [17, 0, () => SetTargeting(TowerSetup["Boomerang A"], "Last")],
        [25, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "204")],
        [28, 0, () => UpgradeTower(TowerSetup["Dart A"], "024")],
        [30, 0, () => PlaceTower(TowerSetup["Dart B"])],
        [30, 0, () => UpgradeTower(TowerSetup["Dart B"], "024")],
        [36, 0, () => PlaceTower(TowerSetup["Dart C"])],
        [36, 0, () => UpgradeTower(TowerSetup["Dart C"], "024")],
        [38, 0, () => PlaceTower(TowerSetup["Dart D"])],
        [38, 0, () => UpgradeTower(TowerSetup["Dart D"], "024")]
    ]

    return RunMapStrategy(strategy)
}

ScrapyardPrimaryOnly()

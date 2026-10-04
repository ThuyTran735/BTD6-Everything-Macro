#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

OneTwoTreePrimaryOnly() {
    global RunConfig := {
        category: "Beginner",
        map: "One Two Tree",
        difficulty: "Easy",
        gameMode: "Primary Only",
        hero: "Quincy",
        wingmonkeyMK: false
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 210,
            y: 781,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart A", {
            type: "Dart",
            x: 207,
            y: 857,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 204,
            y: 320,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 293,
            y: 318,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart D", {
            type: "Dart",
            x: 243,
            y: 393,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Boomerang A", {
            type: "Boomerang",
            x: 288,
            y: 801,
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

OneTwoTreePrimaryOnly()

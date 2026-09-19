#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk


SpaPitsPrimaryOnly() {
    global RunConfig := {
        category: "Beginner",
        map: "Spa Pits",
        difficulty: "Easy",
        gameMode: "Primary Only",

        hero: "Quincy",

        wingmonkeyMK: false
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 677,
            y: 357,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart A", {
            type: "Dart",
            x: 607,
            y: 281,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 419,
            y: 239,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 540,
            y: 155,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart D", {
            type: "Dart",
            x: 579,
            y: 670,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Boomerang A", {
            type: "Boomerang",
            x: 516,
            y: 239,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
    )

    strategy := [
        ; Round 0 = before Round 1 starts.

        [0, 0, () => PlaceTower(
            TowerSetup["Hero"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart A"]
        )],

        [3, 0, () => PlaceTower(
            TowerSetup["Boomerang A"]
        )],

        [5, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "002"
        )],

        [7, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "202"
        )],

        [8, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "002"
        )],

        [10, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "022"
        )],

        [12, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "023"
        )],

        [17, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "203"
        )],

        [17, 0, () => SetTargeting(
            TowerSetup["Boomerang A"],
            "Last"
        )],

        [25, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "204"
        )],

        [28, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "024"
        )],

        [30, 0, () => PlaceTower(
            TowerSetup["Dart B"]
        )],

        [30, 0, () => UpgradeTower(
            TowerSetup["Dart B"],
            "024"
        )],

        [36, 0, () => PlaceTower(
            TowerSetup["Dart C"]
        )],

        [36, 0, () => UpgradeTower(
            TowerSetup["Dart C"],
            "024"
        )],

        [38, 0, () => PlaceTower(
            TowerSetup["Dart D"]
        )],

        [38, 0, () => UpgradeTower(
            TowerSetup["Dart D"],
            "024"
        )],
    ]

    return RunMapStrategy(strategy)
}

SpaPitsPrimaryOnly()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

MiddleOfTheRoadPrimaryOnly() {
    ; Navigation and round bounds for this saved strategy.
    global RunConfig := {
        category: "Beginner",
        map: "Middle Of The Road",
        difficulty: "Easy",
        gameMode: "Primary Only",
        hero: "Quincy",
        wingmonkeyMK: false
    }

    ; Named placement records. Helpers update placed, upgrades, and targeting during the run.
    ; The X/Y values here remain the original placement points.
    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 474,
            y: 504,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart A", {
            type: "Dart",
            x: 544,
            y: 498,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 476,
            y: 442,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 633,
            y: 496,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart D", {
            type: "Dart",
            x: 630,
            y: 606,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Boomerang A", {
            type: "Boomerang",
            x: 482,
            y: 592,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
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

MiddleOfTheRoadPrimaryOnly()

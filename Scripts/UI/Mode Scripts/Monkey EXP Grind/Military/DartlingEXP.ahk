#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

DartlingEXP() {
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
        "Dartling A", {
            type: "Dartling",
            x: 1454,
            y: 570,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Normal"
        },
        "Dartling B", {
            type: "Dartling",
            x: 1456,
            y: 478,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Normal"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Dartling A"])],
        [0, 0, () => PlaceTower(TowerSetup["Dartling B"])],
        [0, 0, () => UpgradeTower(TowerSetup["Dartling A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Dartling B"], "120")],

        [0, 0, () => SetDartlingTargeting(
            TowerSetup["Dartling A"],
            "Target Independent"
        )],

        [0, 0, () => AimDartling(
            TowerSetup["Dartling B"],
            729,
            546
        )],

        [60, 8000, () => UseAbility("1")],
        [60, 8250, () => UseAbility("2")],
        [60, 8500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

DartlingEXP()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

DartlingEXP() {
    ; Navigation and round bounds for this saved strategy.
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

    ; Named placement records. Helpers update placed, upgrades, and targeting during the run.
    ; The X/Y values here remain the original placement points.
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

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
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

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

DartlingEXP()

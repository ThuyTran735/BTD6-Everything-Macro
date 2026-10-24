#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

HeliEXP() {
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
            x: 980,
            y: 420,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Heli A", {
            type: "Heli",
            x: 946,
            y: 815,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Follow Mouse"
        },
        "Heli B", {
            type: "Heli",
            x: 754,
            y: 816,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Follow Mouse"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Heli A"])],
        [0, 0, () => PlaceTower(TowerSetup["Heli B"])],
        [0, 0, () => UpgradeTower(TowerSetup["Heli A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Heli B"], "032")],

        [0, 0, () => LockHeliInPlace(
            TowerSetup["Heli A"],
            729,
            546
        )],

        [0, 0, () => LockHeliInPlace(
            TowerSetup["Heli B"],
            729,
            546
        )],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

HeliEXP()

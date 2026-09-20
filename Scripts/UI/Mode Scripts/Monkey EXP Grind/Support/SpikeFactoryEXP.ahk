#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

SpikeFactoryEXP() {
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
            x: 997,
            y: 439,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "SpikeFactory A", {
            type: "SpikeFactory",
            x: 853,
            y: 437,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "SpikeFactory B", {
            type: "SpikeFactory",
            x: 737,
            y: 430,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["SpikeFactory A"])],
        [0, 0, () => PlaceTower(TowerSetup["SpikeFactory B"])],

        [0, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["SpikeFactory B"], "130")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

SpikeFactoryEXP()

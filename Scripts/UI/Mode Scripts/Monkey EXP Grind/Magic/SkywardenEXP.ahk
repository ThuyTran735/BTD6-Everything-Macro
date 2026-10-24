#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

SkywardenEXP() {
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
            x: 991,
            y: 439,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden A", {
            type: "Skywarden",
            x: 733,
            y: 441,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden B", {
            type: "Skywarden",
            x: 806,
            y: 450,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden C", {
            type: "Skywarden",
            x: 734,
            y: 658,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden D", {
            type: "Skywarden",
            x: 806,
            y: 660,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden E", {
            type: "Skywarden",
            x: 878,
            y: 449,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden F", {
            type: "Skywarden",
            x: 875,
            y: 667,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden A"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden B"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden C"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden D"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden E"])],
        [0, 0, () => PlaceTower(TowerSetup["Skywarden F"])],

        [0, 0, () => UpgradeTower(TowerSetup["Skywarden A"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden B"], "240")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden C"], "204")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden D"], "230")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden E"], "220")],
        [0, 0, () => UpgradeTower(TowerSetup["Skywarden F"], "200")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

SkywardenEXP()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

TownCenterDeflation() {
    ; Navigation and round bounds for this saved strategy.
    global RunConfig := {
        category: "Beginner",
        map: "Town Center",
        difficulty: "Easy",
        gameMode: "Deflation",
        hero: "Psi",
        wingmonkeyMK: false,
        startRound: 31,
        endRound: 60
    }

    ; Named placement records. Helpers update placed, upgrades, and targeting during the run.
    ; The X/Y values here remain the original placement points.
    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 1098,
            y: 875,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace A", {
            type: "Ace",
            x: 952,
            y: 899,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Ace B", {
            type: "Ace",
            x: 953,
            y: 1013,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Village A", {
            type: "Village",
            x: 1090,
            y: 970,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 840,
            y: 958,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Ace A"])],
        [0, 0, () => PlaceTower(TowerSetup["Ace B"])],
        [0, 0, () => PlaceTower(TowerSetup["Village A"])],
        [0, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [0, 0, () => UpgradeTower(TowerSetup["Ace A"], "203")],
        [0, 0, () => UpgradeTower(TowerSetup["Ace B"], "203")],
        [0, 0, () => UpgradeTower(TowerSetup["Village A"], "220")],
        [0, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "420")]
    ]

    return RunMapStrategy(strategy)
}

TownCenterDeflation()

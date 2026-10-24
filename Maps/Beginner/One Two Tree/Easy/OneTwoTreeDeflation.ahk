#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

OneTwoTreeDeflation() {
    ; Navigation and round bounds for this saved strategy.
    global RunConfig := {
        category: "Beginner",
        map: "One Two Tree",
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
            x: 1223,
            y: 257,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace A", {
            type: "Ace",
            x: 1090,
            y: 252,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace B", {
            type: "Ace",
            x: 911,
            y: 251,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 1103,
            y: 155,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 1002,
            y: 184,
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

OneTwoTreeDeflation()

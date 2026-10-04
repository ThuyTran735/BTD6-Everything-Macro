#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

TreeStumpDeflation() {
    global RunConfig := {
        category: "Beginner",
        map: "Tree Stump",
        difficulty: "Easy",
        gameMode: "Deflation",
        hero: "Psi",
        wingmonkeyMK: false,
        startRound: 31,
        endRound: 60
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 1601,
            y: 502,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace A", {
            type: "Ace",
            x: 1556,
            y: 409,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Ace B", {
            type: "Ace",
            x: 1557,
            y: 315,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Village A", {
            type: "Village",
            x: 1421,
            y: 436,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 1422,
            y: 333,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

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

TreeStumpDeflation()

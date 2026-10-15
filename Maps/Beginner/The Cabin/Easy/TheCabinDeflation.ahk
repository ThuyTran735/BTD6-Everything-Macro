#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

ScrapyardDeflation() {
    global RunConfig := {
        category: "Beginner",
        map: "Scrapyard",
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
            x: 1002,
            y: 813,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace A", {
            type: "Ace",
            x: 878,
            y: 782,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace B", {
            type: "Ace",
            x: 694,
            y: 791,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 851,
            y: 899,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 760,
            y: 868,
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

ScrapyardDeflation()

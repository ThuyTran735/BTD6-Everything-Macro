#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

AceEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Inferno",
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
            x: 838,
            y: 705,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace A", {
            type: "Ace",
            x: 1572,
            y: 629,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Ace B", {
            type: "Ace",
            x: 1570,
            y: 530,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Ace C", {
            type: "Ace",
            x: 100,
            y: 620,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Ace D", {
            type: "Ace",
            x: 98,
            y: 527,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Ace A"])],
        [0, 0, () => UpgradeTower(TowerSetup["Ace A"], "203")],

        [0, 0, () => PlaceTower(TowerSetup["Ace B"])],
        [0, 0, () => UpgradeTower(TowerSetup["Ace B"], "023")],

        [0, 0, () => PlaceTower(TowerSetup["Ace C"])],
        [0, 0, () => UpgradeTower(TowerSetup["Ace C"], "203")],

        [0, 0, () => PlaceTower(TowerSetup["Ace D"])],
        [0, 0, () => UpgradeTower(TowerSetup["Ace D"], "203")],

        [60, 8000, () => UseAbility("1")],
        [60, 8250, () => UseAbility("2")],
        [60, 8500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

AceEXP()

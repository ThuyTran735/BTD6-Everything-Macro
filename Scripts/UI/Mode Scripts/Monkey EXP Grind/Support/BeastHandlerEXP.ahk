#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

BeastHandlerEXP() {
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
            x: 998,
            y: 439,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "BeastHandler A", {
            type: "Beast Handler",
            x: 770,
            y: 441,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Engineer A", {
            type: "Engineer",
            x: 918,
            y: 673,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Engineer B", {
            type: "Engineer",
            x: 806,
            y: 667,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["BeastHandler A"])],
        [0, 0, () => PlaceTower(TowerSetup["Engineer A"])],
        [0, 0, () => PlaceTower(TowerSetup["Engineer B"])],

        [0, 0, () => UpgradeTower(TowerSetup["Engineer A"], "410")],
        [0, 0, () => UpgradeTower(TowerSetup["Engineer B"], "400")],
        [0, 0, () => UpgradeTower(TowerSetup["BeastHandler A"], "014")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

BeastHandlerEXP()

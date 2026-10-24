#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

EngineerEXP() {
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
            x: 994,
            y: 428,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Engineer A", {
            type: "Engineer",
            x: 797,
            y: 446,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Engineer B", {
            type: "Engineer",
            x: 802,
            y: 661,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Engineer C", {
            type: "Engineer",
            x: 880,
            y: 440,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Engineer D", {
            type: "Engineer",
            x: 890,
            y: 665,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Engineer E", {
            type: "Engineer",
            x: 726,
            y: 675,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Engineer F", {
            type: "Engineer",
            x: 719,
            y: 417,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Engineer A"])],
        [0, 0, () => PlaceTower(TowerSetup["Engineer B"])],
        [0, 0, () => PlaceTower(TowerSetup["Engineer C"])],
        [0, 0, () => PlaceTower(TowerSetup["Engineer D"])],
        [0, 0, () => PlaceTower(TowerSetup["Engineer E"])],
        [0, 0, () => PlaceTower(TowerSetup["Engineer F"])],

        [0, 0, () => UpgradeTower(TowerSetup["Engineer A"], "230")],
        [0, 0, () => UpgradeTower(TowerSetup["Engineer B"], "230")],
        [0, 0, () => UpgradeTower(TowerSetup["Engineer C"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Engineer D"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Engineer E"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Engineer F"], "110")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

EngineerEXP()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

SuperEXP() {
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
            x: 990,
            y: 424,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super A", {
            type: "Super",
            x: 853,
            y: 429,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super B", {
            type: "Super",
            x: 855,
            y: 681,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Super A"])],
        [0, 0, () => PlaceTower(TowerSetup["Super B"])],

        [0, 0, () => UpgradeTower(TowerSetup["Super A"], "203")],
        [0, 0, () => UpgradeTower(TowerSetup["Super B"], "100")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

SuperEXP()

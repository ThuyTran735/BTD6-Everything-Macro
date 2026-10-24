#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

DruidEXP() {
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
            x: 995,
            y: 434,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 1456,
            y: 563,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Druid A", {
            type: "Druid",
            x: 871,
            y: 446,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Druid B", {
            type: "Druid",
            x: 789,
            y: 443,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Druid C", {
            type: "Druid",
            x: 788,
            y: 670,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [0, 0, () => PlaceTower(TowerSetup["Druid A"])],
        [0, 0, () => PlaceTower(TowerSetup["Druid B"])],
        [0, 0, () => PlaceTower(TowerSetup["Druid C"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sniper A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Druid A"], "402")],
        [0, 0, () => UpgradeTower(TowerSetup["Druid B"], "230")],
        [0, 0, () => UpgradeTower(TowerSetup["Druid C"], "110")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

DruidEXP()

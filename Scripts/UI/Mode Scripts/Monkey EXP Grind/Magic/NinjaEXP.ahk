#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

NinjaEXP() {
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
            x: 988,
            y: 438,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 1458,
            y: 560,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja A", {
            type: "Ninja",
            x: 882,
            y: 446,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja B", {
            type: "Ninja",
            x: 878,
            y: 662,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja C", {
            type: "Ninja",
            x: 769,
            y: 447,
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
        [0, 0, () => PlaceTower(TowerSetup["Ninja A"])],
        [0, 0, () => PlaceTower(TowerSetup["Ninja B"])],
        [0, 0, () => PlaceTower(TowerSetup["Ninja C"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sniper A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Ninja A"], "402")],
        [0, 0, () => UpgradeTower(TowerSetup["Ninja B"], "402")],
        [0, 0, () => UpgradeTower(TowerSetup["Ninja C"], "301")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

NinjaEXP()

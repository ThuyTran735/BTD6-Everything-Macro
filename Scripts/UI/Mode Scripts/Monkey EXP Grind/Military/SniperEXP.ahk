#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

SniperEXP() {
    ; Navigation and round bounds for this saved strategy.
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",
        hero: false,
        wingmonkeyMK: false,
        startRound: 31,
        endRound: 60,
    }

    ; Named placement records. Helpers update placed, upgrades, and targeting during the run.
    ; The X/Y values here remain the original placement points.
    global TowerSetup := Map(
        "Sniper A", {
            type: "Sniper",
            x: 1455,
            y: 473,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper B", {
            type: "Sniper",
            x: 1451,
            y: 573,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper C", {
            type: "Sniper",
            x: 1453,
            y: 671,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [0, 0, () => PlaceTower(TowerSetup["Sniper B"])],
        [0, 0, () => PlaceTower(TowerSetup["Sniper C"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sniper A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Sniper B"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Sniper C"], "130")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

SniperEXP()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

SniperEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",
        hero: false,
        wingmonkeyMK: false
    }

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

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [0, 0, () => PlaceTower(TowerSetup["Sniper B"])],
        [0, 0, () => PlaceTower(TowerSetup["Sniper C"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sniper A"], "024")],
        [0, 0, () => UpgradeTower(TowerSetup["Sniper B"], "420")],
        [0, 0, () => UpgradeTower(TowerSetup["Sniper C"], "130")],

        [60, 8000, () => UseAbility("1")],
        [60, 8250, () => UseAbility("2")],
        [60, 8500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

SniperEXP()

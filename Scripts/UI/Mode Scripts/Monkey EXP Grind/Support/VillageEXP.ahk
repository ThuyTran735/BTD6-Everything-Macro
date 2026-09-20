#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

VillageEXP() {
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
            x: 986,
            y: 437,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 1453,
            y: 561,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Boomerang A", {
            type: "Boomerang",
            x: 740,
            y: 424,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 1558,
            y: 551,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village B", {
            type: "Village",
            x: 841,
            y: 420,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [0, 0, () => PlaceTower(TowerSetup["Boomerang A"])],
        [0, 0, () => PlaceTower(TowerSetup["Village A"])],
        [0, 0, () => PlaceTower(TowerSetup["Village B"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sniper A"], "204")],
        [0, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "302")],
        [0, 0, () => UpgradeTower(TowerSetup["Village A"], "220")],
        [0, 0, () => UpgradeTower(TowerSetup["Village B"], "301")],

        [0, 0, () => SetTargeting(
            TowerSetup["Sniper A"],
            "Strong"
        )],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

VillageEXP()

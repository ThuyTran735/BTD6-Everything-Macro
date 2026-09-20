#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

SubEXP() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Castle",
        difficulty: "Easy",
        gameMode: "Deflation",
        hero: "Quincy",
        wingmonkeyMK: false,
        startRound: 31,
        endRound: 60,
    }

    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 540,
            y: 432,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sub A", {
            type: "Sub",
            x: 1215,
            y: 417,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Sub B", {
            type: "Sub",
            x: 1209,
            y: 709,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Sub C", {
            type: "Sub",
            x: 1108,
            y: 426,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Sub D", {
            type: "Sub",
            x: 1100,
            y: 728,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Sub E", {
            type: "Sub",
            x: 1158,
            y: 333,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Sub F", {
            type: "Sub",
            x: 1157,
            y: 831,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Sub A"])],
        [0, 0, () => PlaceTower(TowerSetup["Sub B"])],
        [0, 0, () => PlaceTower(TowerSetup["Sub C"])],
        [0, 0, () => PlaceTower(TowerSetup["Sub D"])],
        [0, 0, () => PlaceTower(TowerSetup["Sub E"])],
        [0, 0, () => PlaceTower(TowerSetup["Sub F"])],

        [0, 0, () => UpgradeTower(TowerSetup["Sub A"], "204")],
        [0, 0, () => UpgradeTower(TowerSetup["Sub B"], "204")],
        [0, 0, () => UpgradeTower(TowerSetup["Sub C"], "230")],
        [0, 0, () => UpgradeTower(TowerSetup["Sub D"], "230")],
        [0, 0, () => UpgradeTower(TowerSetup["Sub E"], "230")],
        [0, 0, () => UpgradeTower(TowerSetup["Sub F"], "220")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

SubEXP()

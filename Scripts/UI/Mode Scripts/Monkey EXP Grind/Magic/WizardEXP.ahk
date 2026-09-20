#Requires AutoHotkey v2.0

#Include ..\..\..\..\IncludeAll.ahk

WizardEXP() {
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
            x: 987,
            y: 425,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard A", {
            type: "Wizard",
            x: 845,
            y: 446,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard B", {
            type: "Wizard",
            x: 727,
            y: 433,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard C", {
            type: "Wizard",
            x: 845,
            y: 663,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard D", {
            type: "Wizard",
            x: 726,
            y: 669,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [0, 0, () => PlaceTower(TowerSetup["Wizard A"])],
        [0, 0, () => PlaceTower(TowerSetup["Wizard B"])],
        [0, 0, () => PlaceTower(TowerSetup["Wizard C"])],
        [0, 0, () => PlaceTower(TowerSetup["Wizard D"])],

        [0, 0, () => UpgradeTower(TowerSetup["Wizard A"], "042")],
        [0, 0, () => UpgradeTower(TowerSetup["Wizard B"], "204")],
        [0, 0, () => UpgradeTower(TowerSetup["Wizard C"], "302")],
        [0, 0, () => UpgradeTower(TowerSetup["Wizard D"], "202")],

        [60, 6000, () => UseAbility("1")],
        [60, 6250, () => UseAbility("2")],
        [60, 6500, () => UseAbility("3")],
    ]

    return RunMapStrategy(strategy)
}

WizardEXP()

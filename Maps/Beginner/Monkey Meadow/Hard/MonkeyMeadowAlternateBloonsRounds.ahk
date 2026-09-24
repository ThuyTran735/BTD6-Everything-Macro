#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

MonkeyMeadowAlternateBloonsRounds() {
    global RunConfig := {
        category: "Beginner",
        map: "Monkey Meadow",
        difficulty: "Hard",
        gameMode: "Alternate Bloons Rounds",
        hero: "Gwendolin",
        wingmonkeyMK: false,

        startRound: 3,
        endRound: 80,
    }

    global TowerSetup := Map(
        "Druid A", {
            type: "Druid",
            x: 631,
            y: 506,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden A", {
            type: "Skywarden",
            x: 899,
            y: 462,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Hero", {
            type: "Hero",
            x: 495,
            y: 509,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja A", {
            type: "Ninja",
            x: 634,
            y: 397,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard A", {
            type: "Wizard",
            x: 711,
            y: 394,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super A", {
            type: "Super",
            x: 471,
            y: 387,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 373,
            y: 396,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super B", {
            type: "Super",
            x: 389,
            y: 532,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist B", {
            type: "Alchemist",
            x: 294,
            y: 537,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super C", {
            type: "Super",
            x: 662,
            y: 311,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist C", {
            type: "Alchemist",
            x: 651,
            y: 136,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Druid A"])],
        [4, 0, () => PlaceTower(TowerSetup["Skywarden A"])],
        [4, 0, () => UpgradeTower(TowerSetup["Skywarden A"], "200")],
        [7, 0, () => UpgradeTower(TowerSetup["Druid A"], "110")],
        [13, 0, () => PlaceTower(TowerSetup["Hero"])],
        [15, 0, () => PlaceTower(TowerSetup["Ninja A"])],
        [15, 0, () => UpgradeTower(TowerSetup["Ninja A"], "301")],
        [24, 0, () => PlaceTower(TowerSetup["Wizard A"])],
        [24, 0, () => UpgradeTower(TowerSetup["Wizard A"], "002")],
        [26, 0, () => UpgradeTower(TowerSetup["Wizard A"], "032")],
        [38, 0, () => PlaceTower(TowerSetup["Super A"])],
        [38, 0, () => UpgradeTower(TowerSetup["Super A"], "100")],
        [39, 0, () => UpgradeTower(TowerSetup["Druid A"], "210")],
        [40, 0, () => UpgradeTower(TowerSetup["Super A"], "200")],
        [42, 0, () => UpgradeTower(TowerSetup["Ninja A"], "401")],
        [44, 0, () => UpgradeTower(TowerSetup["Super A"], "203")],
        [50, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [50, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "401")],
        [55, 0, () => PlaceTower(TowerSetup["Super B"])],
        [55, 0, () => UpgradeTower(TowerSetup["Super B"], "203")],
        [64, 0, () => PlaceTower(TowerSetup["Alchemist B"])],
        [64, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "401")],
        [71, 0, () => PlaceTower(TowerSetup["Super C"])],
        [71, 0, () => UpgradeTower(TowerSetup["Super C"], "230")],
        [78, 0, () => PlaceTower(TowerSetup["Alchemist C"])],
        [78, 0, () => UpgradeTower(TowerSetup["Alchemist C"], "401")],
        [79, 0, () => UpgradeTower(TowerSetup["Druid A"], "320")]
    ]

    return RunMapStrategy(strategy)
}

MonkeyMeadowAlternateBloonsRounds()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

InTheLoopHard() {
    global RunConfig := {
        category: "Beginner",
        map: "In The Loop",
        difficulty: "Hard",
        gameMode: "Standard",
        hero: "Gwendolin",
        wingmonkeyMK: false
    }

    global TowerSetup := Map(
        "Druid A", {
            type: "Druid",
            x: 485,
            y: 848,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Skywarden A", {
            type: "Skywarden",
            x: 1215,
            y: 891,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Hero", {
            type: "Hero",
            x: 1021,
            y: 847,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja A", {
            type: "Ninja",
            x: 1154,
            y: 736,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard A", {
            type: "Wizard",
            x: 1081,
            y: 760,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super A", {
            type: "Super",
            x: 919,
            y: 834,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 887,
            y: 752,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super B", {
            type: "Super",
            x: 1014,
            y: 697,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist B", {
            type: "Alchemist",
            x: 872,
            y: 693,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Super C", {
            type: "Super",
            x: 1216,
            y: 567,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist C", {
            type: "Alchemist",
            x: 1066,
            y: 628,
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

InTheLoopHard()

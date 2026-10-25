#Requires AutoHotkey v2.0

#Include "..\..\..\..\Scripts\IncludeAll.ahk"
; Credits to sYnce on YT for the help on rounds 6-90.
WorkshopImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Workshop",
        difficulty: "Hard",
        gameMode: "Impoppable",
        hero: "Benjamin",
        wingmonkeyMK: false,
        startRound: 6,
        endRound: 100
    }

    global TowerSetup := Map(
        "Dart A", {
            type: "Dart",
            x: 219,
            y: 623,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 604,
            y: 502,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 669,
            y: 501,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey A", {
            type: "Mermonkey",
            x: 1015,
            y: 495,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "SpikeFactory A", {
            type: "SpikeFactory",
            x: 1192,
            y: 421,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Normal"
        },
        "Hero", {
            type: "Hero",
            x: 1396,
            y: 333,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey B", {
            type: "Mermonkey",
            x: 144,
            y: 632,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey C", {
            type: "Mermonkey",
            x: 744,
            y: 493,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard A", {
            type: "Wizard",
            x: 1450,
            y: 626,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 1002,
            y: 335,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 1186,
            y: 354,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Desperado A", {
            type: "Desperado",
            x: 1017,
            y: 424,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue A", {
            type: "Glue",
            x: 1187,
            y: 297,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village B", {
            type: "Village",
            x: 765,
            y: 462,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Bomb A", {
            type: "Bomb",
            x: 931,
            y: 497,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village C", {
            type: "Village",
            x: 964,
            y: 639,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Dart A"])],
        [0, 0, () => PlaceTower(TowerSetup["Dart B"])],
        [0, 0, () => PlaceTower(TowerSetup["Dart C"])],
        [0, 0, () => PlaceTower(TowerSetup["Mermonkey A"])],
        [0, 0, () => SetTargeting(TowerSetup["Dart A"], "Strong")],
        [0, 0, () => SetTargeting(TowerSetup["Dart B"], "Strong")],
        [0, 0, () => SetTargeting(TowerSetup["Dart C"], "Strong")],
        [11, 0, () => PlaceTower(TowerSetup["SpikeFactory A"])],
        [11, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "002")],
        [14, 0, () => SetSpikeFactoryTarget(TowerSetup["SpikeFactory A"], 1342, 556)],
        [19, 0, () => PlaceTower(TowerSetup["Hero"])],
        [20, 0, () => PlaceTower(TowerSetup["Mermonkey B"])],
        [21, 0, () => PlaceTower(TowerSetup["Mermonkey C"])],
        [22, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "202")],
        [26, 0, () => PlaceTower(TowerSetup["Wizard A"])],
        [26, 0, () => UpgradeTower(TowerSetup["Wizard A"], "120")],
        [31, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "204")],
        [38, 0, () => PlaceTower(TowerSetup["Village A"])],
        [38, 0, () => UpgradeTower(TowerSetup["Village A"], "200")],
        [39, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "201")],
        [41, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "401")],
        [45, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [45, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "320")],
        [58, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "502")],
        [63, 0, () => UpgradeTower(TowerSetup["Village A"], "203")],
        [74, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "205")],
        [76, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "420")],
        [77, 0, () => PlaceTower(TowerSetup["Desperado A"])],
        [77, 0, () => UpgradeTower(TowerSetup["Desperado A"], "025")],
        [88, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "520")],
        [90, 0, () => PlaceTower(TowerSetup["Glue A"])],
        [90, 0, () => UpgradeTower(TowerSetup["Glue A"], "024")],
        [91, 0, () => SellTower(TowerSetup["Mermonkey C"])],
        [92, 0, () => PlaceTower(TowerSetup["Village B"])],
        [92, 0, () => UpgradeTower(TowerSetup["Village B"], "130")],
        [94, 0, () => PlaceTower(TowerSetup["Bomb A"])],
        [94, 0, () => UpgradeTower(TowerSetup["Bomb A"], "025")],
        [96, 0, () => UpgradeTower(TowerSetup["Glue A"], "025")],
        [98, 0, () => PlaceTower(TowerSetup["Village C"])],
        [98, 0, () => UpgradeTower(TowerSetup["Village C"], "400")]
    ]

    return RunMapStrategy(strategy)
}

WorkshopImpoppable()

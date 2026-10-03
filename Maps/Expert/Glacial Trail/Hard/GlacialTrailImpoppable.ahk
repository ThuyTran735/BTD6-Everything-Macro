#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk
; Credits to sYnce on YT for the help on rounds 6-93.
GlacialTrailImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Glacial Trail",
        difficulty: "Hard",
        gameMode: "Impoppable",
        hero: "Benjamin",
        wingmonkeyMK: false,
        startRound: 6,
        endRound: 100,
    }

    global TowerSetup := Map(
        "Dart A", {
            type: "Dart",
            x: 208,
            y: 408,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja A", {
            type: "Ninja",
            x: 318,
            y: 536,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 251,
            y: 546,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Hero", {
            type: "Hero",
            x: 1255,
            y: 1023,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard A", {
            type: "Wizard",
            x: 1147,
            y: 583,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 245,
            y: 868,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "SpikeFactory A", {
            type: "SpikeFactory",
            x: 1442,
            y: 755,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Normal"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 1515,
            y: 946,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice A", {
            type: "Ice",
            x: 1364,
            y: 663,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice B", {
            type: "Ice",
            x: 1364,
            y: 721,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice C", {
            type: "Ice",
            x: 1430,
            y: 666,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist B", {
            type: "Alchemist",
            x: 1301,
            y: 333,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist C", {
            type: "Alchemist",
            x: 196,
            y: 404,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist D", {
            type: "Alchemist",
            x: 315,
            y: 534,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist E", {
            type: "Alchemist",
            x: 174,
            y: 888,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Dart A"])],
        [0, 0, () => PlaceTower(TowerSetup["Ninja A"])],
        [8, 0, () => PlaceTower(TowerSetup["Dart B"])],
        [12, 0, () => PlaceTower(TowerSetup["Hero"])],
        [14, 0, () => PlaceTower(TowerSetup["Wizard A"])],
        [14, 0, () => UpgradeTower(TowerSetup["Dart B"], "301")],
        [16, 0, () => UpgradeTower(TowerSetup["Wizard A"], "010")],
        [17, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [17, 0, () => SetTargeting(TowerSetup["Sniper A"], "Strong")],
        [19, 0, () => UpgradeTower(TowerSetup["Wizard A"], "020")],
        [22, 0, () => PlaceTower(TowerSetup["SpikeFactory A"])],
        [22, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "002")],
        [23, 0, () => SetSpikeFactoryTargeting(TowerSetup["SpikeFactory A"], "Smart")],
        [27, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "003")],
        [28, 0, () => SetTargeting(TowerSetup["Wizard A"], "Strong")],
        [28, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "103")],
        [29, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "203")],
        [33, 0, () => UpgradeTower(TowerSetup["Dart B"], "402")],
        [37, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "204")],
        [38, 0, () => UpgradeTower(TowerSetup["Wizard A"], "022")],
        [41, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [41, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "300")],
        [42, 0, () => UpgradeTower(TowerSetup["Wizard A"], "032")],
        [46, 0, () => PlaceTower(TowerSetup["Ice A"])],
        [46, 0, () => UpgradeTower(TowerSetup["Ice A"], "410")],
        [47, 0, () => PlaceTower(TowerSetup["Ice B"])],
        [47, 0, () => UpgradeTower(TowerSetup["Ice B"], "024")],
        [51, 0, () => PlaceTower(TowerSetup["Ice C"])],
        [51, 0, () => UpgradeTower(TowerSetup["Ice C"], "240")],
        [67, 0, () => UpgradeTower(TowerSetup["Ice A"], "510")],
        [79, 0, () => UpgradeTower(TowerSetup["Ice B"], "025")],
        [82, 0, () => UpgradeTower(TowerSetup["Ice C"], "250")],
        [87, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "205")],
        [88, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "401")],
        [92, 0, () => PlaceTower(TowerSetup["Alchemist B"])],
        [92, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "130")],
        [92, 0, () => SetTargeting(TowerSetup["Alchemist B"], "Strong")],
        [93, 0, () => SellTower(TowerSetup["Dart A"])],
        [93, 0, () => SellTower(TowerSetup["Ninja A"])],
        [93, 0, () => PlaceTower(TowerSetup["Alchemist C"])],
        [93, 0, () => UpgradeTower(TowerSetup["Dart B"], "502")],
        [93, 0, () => UpgradeTower(TowerSetup["Alchemist C"], "420")],
        [94, 0, () => PlaceTower(TowerSetup["Alchemist D"])],
        [94, 0, () => UpgradeTower(TowerSetup["Alchemist D"], "130")],
        [94, 0, () => SetTargeting(TowerSetup["Alchemist D"], "Strong")],
        [98, 0, () => UpgradeTower(TowerSetup["Sniper A"], "520")],
        [99, 0, () => PlaceTower(TowerSetup["Alchemist E"])],
        [99, 0, () => UpgradeTower(TowerSetup["Alchemist E"], "420")]
    ]

    return RunMapStrategy(strategy)
}

GlacialTrailImpoppable()
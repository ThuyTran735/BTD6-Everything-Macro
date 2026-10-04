#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk
; Credits to sYnce on YT for the help on rounds 6-100.
DarkDungeonsImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Dark Dungeons",
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
            x: 285,
            y: 818,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 797,
            y: 947,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 1370,
            y: 1037,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart D", {
            type: "Dart",
            x: 1548,
            y: 431,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart E", {
            type: "Dart",
            x: 797,
            y: 889,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sub A", {
            type: "Sub",
            x: 1398,
            y: 870,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Hero", {
            type: "Hero",
            x: 567,
            y: 252,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sub B", {
            type: "Sub",
            x: 1473,
            y: 864,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Glue A", {
            type: "Glue",
            x: 262,
            y: 905,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue B", {
            type: "Glue",
            x: 1560,
            y: 877,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 1057,
            y: 889,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "SpikeFactory A", {
            type: "SpikeFactory",
            x: 1582,
            y: 167,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Normal"
        },
        "SpikeFactory B", {
            type: "SpikeFactory",
            x: 188,
            y: 168,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Normal"
        },
        "Tack A", {
            type: "Tack",
            x: 927,
            y: 940,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja A", {
            type: "Ninja",
            x: 795,
            y: 1003,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 331,
            y: 272,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart F", {
            type: "Dart",
            x: 194,
            y: 379,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart G", {
            type: "Dart",
            x: 1549,
            y: 487,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village B", {
            type: "Village",
            x: 931,
            y: 1022,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist B", {
            type: "Alchemist",
            x: 111,
            y: 174,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Tack B", {
            type: "Tack",
            x: 299,
            y: 380,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice A", {
            type: "Ice",
            x: 784,
            y: 1002,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice B", {
            type: "Ice",
            x: 128,
            y: 384,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist C", {
            type: "Alchemist",
            x: 298,
            y: 463,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Tack C", {
            type: "Tack",
            x: 364,
            y: 379,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist D", {
            type: "Alchemist",
            x: 359,
            y: 436,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue C", {
            type: "Glue",
            x: 77,
            y: 291,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist E", {
            type: "Alchemist",
            x: 732,
            y: 887,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice C", {
            type: "Ice",
            x: 299,
            y: 196,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice D", {
            type: "Ice",
            x: 1444,
            y: 1039,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue D", {
            type: "Glue",
            x: 364,
            y: 198,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue E", {
            type: "Glue",
            x: 1057,
            y: 1050,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ninja B", {
            type: "Ninja",
            x: 142,
            y: 290,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Dart A"])],
        [0, 0, () => PlaceTower(TowerSetup["Dart B"])],
        [0, 0, () => PlaceTower(TowerSetup["Dart C"])],
        [0, 0, () => PlaceTower(TowerSetup["Dart D"])],
        [6, 0, () => UpgradeTower(TowerSetup["Dart A"], "010")],
        [8, 0, () => PlaceTower(TowerSetup["Dart E"])],
        [9, 0, () => UpgradeTower(TowerSetup["Dart A"], "030")],
        [12, 0, () => PlaceTower(TowerSetup["Sub A"])],
        [13, 0, () => UpgradeTower(TowerSetup["Dart B"], "030")],
        [21, 0, () => PlaceTower(TowerSetup["Hero"])],
        [22, 0, () => PlaceTower(TowerSetup["Sub B"])],
        [23, 0, () => PlaceTower(TowerSetup["Glue A"])],
        [23, 0, () => UpgradeTower(TowerSetup["Glue A"], "210")],
        [23, 0, () => SetTargeting(TowerSetup["Glue A"], "Strong")],
        [25, 0, () => PlaceTower(TowerSetup["Glue B"])],
        [25, 0, () => UpgradeTower(TowerSetup["Glue B"], "210")],
        [25, 0, () => SetTargeting(TowerSetup["Glue B"], "Strong")],
        [28, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [28, 0, () => SetTargeting(TowerSetup["Alchemist A"], "Strong")],
        [30, 0, () => PlaceTower(TowerSetup["SpikeFactory A"])],
        [32, 0, () => PlaceTower(TowerSetup["SpikeFactory B"])],
        [33, 0, () => UpgradeTower(TowerSetup["Dart B"], "032")],
        [34, 0, () => UpgradeTower(TowerSetup["Dart D"], "300")],
        [35, 0, () => PlaceTower(TowerSetup["Tack A"])],
        [35, 0, () => UpgradeTower(TowerSetup["Tack A"], "204")],
        [39, 12000, () => SetGameSpeed("Normal")],
        [40, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "300")],
        [40, 0, () => UseAbility("1")],
        [41, 0, () => SetGameSpeed("Fast")],
        [41, 0, () => PlaceTower(TowerSetup["Ninja A"])],
        [41, 0, () => UpgradeTower(TowerSetup["Ninja A"], "020")],
        [42, 0, () => UpgradeTower(TowerSetup["SpikeFactory B"], "102")],
        [42, 0, () => SetSpikeFactoryTarget(TowerSetup["SpikeFactory B"], 246, 126)],
        [42, 0, () => UpgradeTower(TowerSetup["Dart D"], "302")],
        [43, 0, () => UseAbility("1")],
        [43, 0, () => UpgradeTower(TowerSetup["SpikeFactory B"], "202")],
        [43, 0, () => UpgradeTower(TowerSetup["Dart D"], "402")],
        [45, 0, () => PlaceTower(TowerSetup["Village A"])],
        [45, 0, () => UpgradeTower(TowerSetup["Village A"], "002")],
        [46, 0, () => PlaceTower(TowerSetup["Dart F"])],
        [46, 0, () => UpgradeTower(TowerSetup["Dart F"], "402")],
        [48, 0, () => PlaceTower(TowerSetup["Dart G"])],
        [48, 0, () => UpgradeTower(TowerSetup["SpikeFactory B"], "302")],
        [48, 0, () => SetSpikeFactoryTarget(TowerSetup["SpikeFactory B"], 243, 335)],
        [49, 0, () => UpgradeTower(TowerSetup["Dart G"], "402")],
        [50, 0, () => PlaceTower(TowerSetup["Village B"])],
        [50, 0, () => UpgradeTower(TowerSetup["Village B"], "200")],
        [50, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "320")],
        [51, 0, () => PlaceTower(TowerSetup["Alchemist B"])],
        [51, 0, () => UpgradeTower(TowerSetup["Village A"], "102")],
        [51, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "300")],
        [52, 0, () => UpgradeTower(TowerSetup["Village B"], "300")],
        [52, 0, () => UpgradeTower(TowerSetup["Village A"], "202")],
        [53, 0, () => PlaceTower(TowerSetup["Tack B"])],
        [53, 0, () => UpgradeTower(TowerSetup["Tack B"], "204")],
        [55, 0, () => SellTower(TowerSetup["Ninja A"])],
        [55, 0, () => SellTower(TowerSetup["Dart A"])],
        [55, 0, () => SellTower(TowerSetup["Dart C"])],
        [56, 0, () => UpgradeTower(TowerSetup["Village B"], "320")],
        [56, 0, () => UpgradeTower(TowerSetup["Dart E"], "420")],
        [58, 0, () => PlaceTower(TowerSetup["Ice A"])],
        [58, 0, () => UpgradeTower(TowerSetup["Ice A"], "310")],
        [60, 0, () => PlaceTower(TowerSetup["Ice B"])],
        [60, 0, () => UpgradeTower(TowerSetup["Ice B"], "024")],
        [63, 0, () => UpgradeTower(TowerSetup["Village A"], "302")],
        [64, 0, () => PlaceTower(TowerSetup["Alchemist C"])],
        [64, 0, () => UpgradeTower(TowerSetup["Alchemist C"], "320")],
        [65, 0, () => UpgradeTower(TowerSetup["Ice A"], "410")],
        [66, 0, () => PlaceTower(TowerSetup["Tack C"])],
        [66, 0, () => UpgradeTower(TowerSetup["Tack C"], "204")],
        [68, 0, () => PlaceTower(TowerSetup["Alchemist D"])],
        [68, 0, () => UpgradeTower(TowerSetup["Alchemist D"], "320")],
        [69, 0, () => PlaceTower(TowerSetup["Glue C"])],
        [69, 0, () => UpgradeTower(TowerSetup["Glue C"], "240")],
        [76, 500, () => UseAbility("3")],
        [77, 0, () => UpgradeTower(TowerSetup["Dart E"], "520")],
        [78, 3250, () => UseAbility("3")],
        [78, 20000, () => UseAbility("2")],
        [78, 25500, () => UseAbility("3")],
        [79, 0, () => PlaceTower(TowerSetup["Alchemist E"])],
        [79, 0, () => PlaceTower(TowerSetup["Ice C"])],
        [79, 0, () => UpgradeTower(TowerSetup["Alchemist E"], "320")],
        [79, 0, () => UpgradeTower(TowerSetup["Ice C"], "410")],
        [82, 0, () => PlaceTower(TowerSetup["Ice D"])],
        [82, 0, () => UpgradeTower(TowerSetup["Ice D"], "120")],
        [83, 0, () => UpgradeTower(TowerSetup["Ice C"], "510")],
        [84, 0, () => PlaceTower(TowerSetup["Glue D"])],
        [84, 0, () => UpgradeTower(TowerSetup["Glue D"], "013")],
        [84, 0, () => SetTargeting(TowerSetup["Glue D"], "Strong")],
        [85, 0, () => UpgradeTower(TowerSetup["Glue D"], "024")],
        [86, 0, () => PlaceTower(TowerSetup["Glue E"])],
        [86, 0, () => SetTargeting(TowerSetup["Glue E"], "Strong")],
        [86, 0, () => UpgradeTower(TowerSetup["Glue E"], "024")],
        [91, 0, () => UpgradeTower(TowerSetup["Tack A"], "205")],
        [91, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "320")],
        [92, 0, () => PlaceTower(TowerSetup["Ninja B"])],
        [92, 0, () => UpgradeTower(TowerSetup["Ninja B"], "040")],
        [93, 1500, () => UseAbility("4")],
        [94, 0, () => UpgradeTower(TowerSetup["Sub A"], "240")],
        [95, 9500, () => UseAbility("4")],
        [96, 0, () => UpgradeTower(TowerSetup["Sub B"], "240")],
        [96, 0, () => SetTargeting(TowerSetup["Sub A"], "Strong")],
        [96, 0, () => SetTargeting(TowerSetup["Sub B"], "Strong")],
        [98, 14500, () => UseAbility("3")],
        [99, 100, () => UseAbility("4")],
        [100, 100, () => UseAbility("5")],
        [100, 200, () => UseAbility("5")],
        [100, 300, () => UseAbility("5")],
        [100, 400, () => UseAbility("5")],
    ]

    return RunMapStrategy(strategy)
}

DarkDungeonsImpoppable()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

FloodedValleyImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Flooded Valley",
        difficulty: "Hard",
        gameMode: "Impoppable",
        hero: "Benjamin",
        wingmonkeyMK: false,
        startRound: 6,
        endRound: 100
    }

    global TowerSetup := Map(
        "Sub A", {
            type: "Sub",
            x: 1080,
            y: 868,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Sub B", {
            type: "Sub",
            x: 966,
            y: 191,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Hero", {
            type: "Hero",
            x: 251,
            y: 126,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 263,
            y: 731,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey A", {
            type: "Mermonkey",
            x: 1002,
            y: 778,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer A", {
            type: "Buccaneer",
            x: 1042,
            y: 710,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey B", {
            type: "Mermonkey",
            x: 980,
            y: 198,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice A", {
            type: "Ice",
            x: 1170,
            y: 760,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 1263,
            y: 753,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village B", {
            type: "Village",
            x: 1181,
            y: 677,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice B", {
            type: "Ice",
            x: 1098,
            y: 767,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 1266,
            y: 647,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer B", {
            type: "Buccaneer",
            x: 1085,
            y: 644,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer C", {
            type: "Buccaneer",
            x: 1111,
            y: 832,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer D", {
            type: "Buccaneer",
            x: 1198,
            y: 835,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer E", {
            type: "Buccaneer",
            x: 1284,
            y: 842,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer F", {
            type: "Buccaneer",
            x: 1140,
            y: 586,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer G", {
            type: "Buccaneer",
            x: 1230,
            y: 574,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Buccaneer H", {
            type: "Buccaneer",
            x: 1114,
            y: 512,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey C", {
            type: "Mermonkey",
            x: 1560,
            y: 876,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey D", {
            type: "Mermonkey",
            x: 1466,
            y: 878,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey E", {
            type: "Mermonkey",
            x: 1597,
            y: 803,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey F", {
            type: "Mermonkey",
            x: 1502,
            y: 795,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey G", {
            type: "Mermonkey",
            x: 1415,
            y: 796,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey H", {
            type: "Mermonkey",
            x: 1593,
            y: 719,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey I", {
            type: "Mermonkey",
            x: 1510,
            y: 690,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey J", {
            type: "Mermonkey",
            x: 1416,
            y: 689,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey K", {
            type: "Mermonkey",
            x: 1368,
            y: 870,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue A", {
            type: "Glue",
            x: 1048,
            y: 564,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Sub A"])],
        [0, 0, () => PlaceTower(TowerSetup["Sub B"])],
        [11, 2500, () => PlaceTower(TowerSetup["Hero"])],
        [13, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [13, 0, () => SetTargeting(TowerSetup["Sniper A"], "Strong")],
        [14, 0, () => PlaceTower(TowerSetup["Mermonkey A"])],
        [15, 0, () => PlaceTower(TowerSetup["Buccaneer A"])],
        [15, 0, () => UpgradeTower(TowerSetup["Buccaneer A"], "210")],
        [19, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "201")],
        [25, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "301")],
        [26, 0, () => UpgradeTower(TowerSetup["Sniper A"], "100")],
        [27, 0, () => UpgradeTower(TowerSetup["Buccaneer A"], "220")],
        [33, 0, () => UpgradeTower(TowerSetup["Buccaneer A"], "320")],
        [35, 0, () => UpgradeTower(TowerSetup["Sniper A"], "110")],
        [36, 0, () => SellTower(TowerSetup["Sub B"])],
        [36, 500, () => PlaceTower(TowerSetup["Mermonkey B"])],
        [36, 750, () => UpgradeTower(TowerSetup["Mermonkey B"], "201")],
        [38, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "401")],
        [39, 0, () => PlaceTower(TowerSetup["Ice A"])],
        [39, 0, () => UpgradeTower(TowerSetup["Ice A"], "030")],
        [43, 0, () => PlaceTower(TowerSetup["Village A"])],
        [43, 0, () => UpgradeTower(TowerSetup["Village A"], "002")],
        [45, 0, () => PlaceTower(TowerSetup["Village B"])],
        [45, 0, () => UpgradeTower(TowerSetup["Village B"], "022")],
        [46, 0, () => UpgradeTower(TowerSetup["Village A"], "202")],
        [48, 0, () => PlaceTower(TowerSetup["Ice B"])],
        [48, 0, () => UpgradeTower(TowerSetup["Ice B"], "024")],
        [53, 0, () => UpgradeTower(TowerSetup["Village A"], "203")],
        [58, 0, () => SellTower(TowerSetup["Mermonkey B"])],
        [58, 0, () => SellTower(TowerSetup["Sniper A"])],
        [58, 0, () => SellTower(TowerSetup["Sub A"])],
        [62, 0, () => UseAbility("2")],
        [62, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "501")],
        [63, 0, () => UpgradeTower(TowerSetup["Ice A"], "031")],
        [64, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [64, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "400")],
        [64, 0, () => UseAbility("2")],
        [65, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "502")],
        [78, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "500")],
        [79, 0, () => PlaceTower(TowerSetup["Buccaneer B"])],
        [79, 0, () => UpgradeTower(TowerSetup["Buccaneer B"], "310")],
        [80, 0, () => PlaceTower(TowerSetup["Buccaneer C"])],
        [80, 0, () => PlaceTower(TowerSetup["Buccaneer D"])],
        [80, 0, () => UpgradeTower(TowerSetup["Buccaneer C"], "310")],
        [80, 0, () => UpgradeTower(TowerSetup["Buccaneer D"], "310")],
        [81, 0, () => PlaceTower(TowerSetup["Buccaneer E"])],
        [81, 0, () => UpgradeTower(TowerSetup["Buccaneer E"], "310")],
        [82, 0, () => PlaceTower(TowerSetup["Buccaneer F"])],
        [82, 0, () => PlaceTower(TowerSetup["Buccaneer G"])],
        [82, 0, () => UpgradeTower(TowerSetup["Buccaneer F"], "310")],
        [82, 0, () => UpgradeTower(TowerSetup["Buccaneer G"], "310")],
        [82, 0, () => UpgradeTower(TowerSetup["Village A"], "204")],
        [83, 0, () => PlaceTower(TowerSetup["Buccaneer H"])],
        [83, 0, () => UpgradeTower(TowerSetup["Buccaneer H"], "310")],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey C"])],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey D"])],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey E"])],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey F"])],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey G"])],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey H"])],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey I"])],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey J"])],
        [84, 0, () => PlaceTower(TowerSetup["Mermonkey K"])],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey C"], "002")],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey D"], "002")],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey E"], "002")],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey F"], "002")],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey G"], "002")],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey H"], "002")],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey I"], "002")],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey J"], "002")],
        [84, 0, () => UpgradeTower(TowerSetup["Mermonkey K"], "002")],
        [85, 0, () => UpgradeTower(TowerSetup["Village B"], "032")],
        [87, 0, () => UpgradeTower(TowerSetup["Ice B"], "025")],
        [89, 0, () => UpgradeTower(TowerSetup["Buccaneer A"], "520")],
        [93, 0, () => PlaceTower(TowerSetup["Glue A"])],
        [93, 0, () => SetTargeting(TowerSetup["Glue A"], "Strong")],
        [93, 0, () => UpgradeTower(TowerSetup["Glue A"], "025")],
        [97, 0, () => UpgradeTower(TowerSetup["Buccaneer H"], "410")],
        [97, 0, () => UpgradeTower(TowerSetup["Buccaneer F"], "410")],
        [97, 0, () => UpgradeTower(TowerSetup["Buccaneer G"], "410")],
        [98, 0, () => UpgradeTower(TowerSetup["Buccaneer E"], "410")],
        [98, 0, () => UpgradeTower(TowerSetup["Buccaneer B"], "410")]
    ]

    return RunMapStrategy(strategy)
}

FloodedValleyImpoppable()

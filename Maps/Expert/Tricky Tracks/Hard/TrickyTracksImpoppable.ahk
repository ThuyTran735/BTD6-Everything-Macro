#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk
; Credits to sYnce on YT for the help on rounds 6-90.
TrickyTracksImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Tricky Tracks",
        difficulty: "Hard",
        gameMode: "Impoppable",
        hero: "Benjamin",
        wingmonkeyMK: false
    }

    global TowerSetup := Map(
        "Dart A", {
            type: "Dart",
            x: 634,
            y: 237,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 817,
            y: 428,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 1036,
            y: 603,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey A", {
            type: "Mermonkey",
            x: 985,
            y: 553,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey B", {
            type: "Mermonkey",
            x: 567,
            y: 274,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey C", {
            type: "Mermonkey",
            x: 751,
            y: 461,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey D", {
            type: "Mermonkey",
            x: 1167,
            y: 731,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Hero", {
            type: "Hero",
            x: 1321,
            y: 756,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey E", {
            type: "Mermonkey",
            x: 969,
            y: 638,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey F", {
            type: "Mermonkey",
            x: 498,
            y: 319,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Mermonkey G", {
            type: "Mermonkey",
            x: 1097,
            y: 776,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Boomerang A", {
            type: "Boomerang",
            x: 871,
            y: 389,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 1603,
            y: 579,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Bomb A", {
            type: "Bomb",
            x: 1036,
            y: 497,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 901,
            y: 604,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Bomb B", {
            type: "Bomb",
            x: 816,
            y: 645,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 757,
            y: 678,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice A", {
            type: "Ice",
            x: 808,
            y: 362,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Tack A", {
            type: "Tack",
            x: 749,
            y: 388,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Tack B", {
            type: "Tack",
            x: 993,
            y: 620,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice B", {
            type: "Ice",
            x: 1053,
            y: 586,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist B", {
            type: "Alchemist",
            x: 684,
            y: 431,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist C", {
            type: "Alchemist",
            x: 911,
            y: 685,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village B", {
            type: "Village",
            x: 689,
            y: 745,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue A", {
            type: "Glue",
            x: 783,
            y: 772,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue B", {
            type: "Glue",
            x: 693,
            y: 505,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Tack C", {
            type: "Tack",
            x: 1031,
            y: 811,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist D", {
            type: "Alchemist",
            x: 979,
            y: 846,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper B", {
            type: "Sniper",
            x: 699,
            y: 824,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist E", {
            type: "Alchemist",
            x: 609,
            y: 802,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist F", {
            type: "Alchemist",
            x: 991,
            y: 285,
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
        [8, 2000, () => PlaceTower(TowerSetup["Mermonkey B"])],
        [10, 0, () => PlaceTower(TowerSetup["Mermonkey C"])],
        [11, 2000, () => PlaceTower(TowerSetup["Mermonkey D"])],
        [17, 0, () => PlaceTower(TowerSetup["Hero"])],
        [18, 0, () => PlaceTower(TowerSetup["Mermonkey E"])],
        [19, 0, () => PlaceTower(TowerSetup["Mermonkey F"])],
        [20, 0, () => PlaceTower(TowerSetup["Mermonkey G"])],
        [21, 0, () => PlaceTower(TowerSetup["Boomerang A"])],
        [21, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "002")],
        [22, 0, () => UpgradeTower(TowerSetup["Mermonkey C"], "001")],
        [23, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "302")],
        [26, 1000, () => PlaceTower(TowerSetup["Sniper A"])],
        [27, 0, () => UpgradeTower(TowerSetup["Sniper A"], "100")],
        [27, 50, () => SetTargeting(TowerSetup["Sniper A"], "Strong")],
        [28, 0, () => UpgradeTower(TowerSetup["Mermonkey B"], "001")],
        [28, 50, () => UpgradeTower(TowerSetup["Mermonkey E"], "001")],
        [28, 100, () => UpgradeTower(TowerSetup["Mermonkey G"], "001")],
        [31, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "402")],
        [32, 0, () => UpgradeTower(TowerSetup["Mermonkey F"], "001")],
        [32, 50, () => UpgradeTower(TowerSetup["Mermonkey A"], "001")],
        [32, 100, () => UpgradeTower(TowerSetup["Mermonkey D"], "001")],
        [33, 0, () => UpgradeTower(TowerSetup["Mermonkey G"], "002")],
        [34, 0, () => UpgradeTower(TowerSetup["Sniper A"], "110")],
        [35, 0, () => PlaceTower(TowerSetup["Bomb A"])],
        [35, 0, () => UpgradeTower(TowerSetup["Bomb A"], "040")],
        [40, 100, () => UseAbility("2")],
        [41, 0, () => SellTower(TowerSetup["Bomb A"])],
        [41, 50, () => SellTower(TowerSetup["Mermonkey E"])],
        [41, 100, () => PlaceTower(TowerSetup["Village A"])],
        [41, 150, () => UpgradeTower(TowerSetup["Village A"], "220")],
        [41, 200, () => UpgradeTower(TowerSetup["Village A"], "420")],
        [44, 0, () => PlaceTower(TowerSetup["Bomb B"])],
        [44, 0, () => UpgradeTower(TowerSetup["Bomb B"], "023")],
        [45, 0, () => UpgradeTower(TowerSetup["Bomb B"], "024")],
        [46, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [46, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "320")],
        [48, 0, () => PlaceTower(TowerSetup["Ice A"])],
        [48, 0, () => UpgradeTower(TowerSetup["Ice A"], "410")],
        [50, 0, () => PlaceTower(TowerSetup["Tack A"])],
        [50, 0, () => UpgradeTower(TowerSetup["Tack A"], "204")],
        [51, 0, () => SellTower(TowerSetup["Dart C"])],
        [51, 50, () => PlaceTower(TowerSetup["Tack B"])],
        [51, 100, () => UpgradeTower(TowerSetup["Tack B"], "204")],
        [55, 0, () => UpgradeTower(TowerSetup["Mermonkey C"], "402")],
        [58, 0, () => UpgradeTower(TowerSetup["Mermonkey A"], "402")],
        [62, 0, () => SellTower(TowerSetup["Sniper A"])],
        [63, 0, () => UpgradeTower(TowerSetup["Mermonkey B"], "002")],
        [63, 50, () => UpgradeTower(TowerSetup["Mermonkey D"], "002")],
        [63, 100, () => UpgradeTower(TowerSetup["Mermonkey F"], "002")],
        [64, 0, () => PlaceTower(TowerSetup["Ice B"])],
        [64, 0, () => UpgradeTower(TowerSetup["Ice B"], "410")],
        [66, 0, () => PlaceTower(TowerSetup["Alchemist B"])],
        [66, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "320")],
        [67, 0, () => PlaceTower(TowerSetup["Alchemist C"])],
        [67, 0, () => UpgradeTower(TowerSetup["Alchemist C"], "320")],
        [78, 0, () => UpgradeTower(TowerSetup["Bomb B"], "025")],
        [83, 0, () => UpgradeTower(TowerSetup["Ice A"], "510")],
        [84, 0, () => PlaceTower(TowerSetup["Village B"])],
        [84, 0, () => UpgradeTower(TowerSetup["Village B"], "030")],
        [86, 0, () => PlaceTower(TowerSetup["Glue A"])],
        [86, 0, () => UpgradeTower(TowerSetup["Glue A"], "024")],
        [88, 0, () => PlaceTower(TowerSetup["Glue B"])],
        [88, 0, () => UpgradeTower(TowerSetup["Glue B"], "024")],
        [90, 0, () => PlaceTower(TowerSetup["Tack C"])],
        [90, 0, () => UpgradeTower(TowerSetup["Tack C"], "204")],
        [90, 50, () => PlaceTower(TowerSetup["Alchemist D"])],
        [90, 50, () => UpgradeTower(TowerSetup["Alchemist D"], "320")],
        [94, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "502")],
        [96, 0, () => UpgradeTower(TowerSetup["Tack A"], "205")],
        [97, 0, () => PlaceTower(TowerSetup["Sniper B"])],
        [97, 0, () => UpgradeTower(TowerSetup["Sniper B"], "420")],
        [97, 0, () => SetTargeting(TowerSetup["Sniper B"], "Strong")],
        [98, 0, () => PlaceTower(TowerSetup["Alchemist E"])],
        [98, 0, () => UpgradeTower(TowerSetup["Alchemist E"], "320")],
        [99, 0, () => PlaceTower(TowerSetup["Alchemist F"])],
        [99, 0, () => UpgradeTower(TowerSetup["Alchemist F"], "420")],
        [99, 100, () => UpgradeTower(TowerSetup["Alchemist E"], "420")]
    ]

    return RunMapStrategy(strategy)
}

TrickyTracksImpoppable()

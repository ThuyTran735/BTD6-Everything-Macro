#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

SanctuaryImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Sanctuary",
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
            x: 1028,
            y: 279,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Desperado A", {
            type: "Desperado",
            x: 1442,
            y: 171,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Desperado B", {
            type: "Desperado",
            x: 320,
            y: 400,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 930,
            y: 1048,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Hero", {
            type: "Hero",
            x: 392,
            y: 874,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper B", {
            type: "Sniper",
            x: 707,
            y: 1032,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sub A", {
            type: "Sub",
            x: 788,
            y: 173,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Village A", {
            type: "Village",
            x: 882,
            y: 949,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 826,
            y: 1015,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue A", {
            type: "Glue",
            x: 937,
            y: 254,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue B", {
            type: "Glue",
            x: 899,
            y: 252,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper C", {
            type: "Sniper",
            x: 975,
            y: 955,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue C", {
            type: "Glue",
            x: 812,
            y: 296,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village B", {
            type: "Village",
            x: 827,
            y: 208,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper D", {
            type: "Sniper",
            x: 1493,
            y: 923,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper E", {
            type: "Sniper",
            x: 1361,
            y: 927,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper F", {
            type: "Sniper",
            x: 1223,
            y: 936,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper G", {
            type: "Sniper",
            x: 1271,
            y: 841,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper H", {
            type: "Sniper",
            x: 1297,
            y: 917,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper I", {
            type: "Sniper",
            x: 1218,
            y: 523,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper J", {
            type: "Sniper",
            x: 1434,
            y: 486,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Dart A"])],
        [0, 0, () => PlaceTower(TowerSetup["Desperado A"])],
        [0, 0, () => PlaceTower(TowerSetup["Desperado B"])],
        [7, 500, () => PlaceTower(TowerSetup["Sniper A"])],
        [7, 750, () => SetTargeting(TowerSetup["Sniper A"], "Strong")],
        [13, 2500, () => PlaceTower(TowerSetup["Hero"])],
        [14, 500, () => PlaceTower(TowerSetup["Sniper B"])],
        [14, 750, () => SetTargeting(TowerSetup["Sniper B"], "Strong")],
        [15, 500, () => PlaceTower(TowerSetup["Sub A"])],
        [15, 750, () => UpgradeTower(TowerSetup["Sub A"], "202")],
        [22, 500, () => UpgradeTower(TowerSetup["Desperado B"], "010", 454, 448)],
        [23, 500, () => UpgradeTower(TowerSetup["Desperado A"], "010", 1356, 384)],
        [24, 500, () => UpgradeTower(TowerSetup["Sniper B"], "100", 697, 1016)],
        [27, 500, () => PlaceTower(TowerSetup["Village A"])],
        [28, 500, () => UpgradeTower(TowerSetup["Village A"], "002", 719, 938)],
        [29, 500, () => UpgradeTower(TowerSetup["Sniper B"], "120", 869, 1014)],
        [30, 500, () => UpgradeTower(TowerSetup["Sniper A"], "022", 775, 1027)],
        [34, 500, () => SetTargeting(TowerSetup["Sniper A"], "First", 763, 1029)],
        [34, 500, () => UpgradeTower(TowerSetup["Sniper A"], "032", 763, 1029)],
        [36, 500, () => UpgradeTower(TowerSetup["Sniper B"], "320", 703, 1016)],
        [38, 500, () => UpgradeTower(TowerSetup["Village A"], "202", 717, 934)],
        [40, 500, () => PlaceTower(TowerSetup["Alchemist A"])],
        [40, 550, () => UseAbility("1")],
        [41, 500, () => UpgradeTower(TowerSetup["Alchemist A"], "401", 984, 993)],
        [47, 500, () => UpgradeTower(TowerSetup["Sniper B"], "420", 866, 1012)],
        [48, 500, () => PlaceTower(TowerSetup["Glue A"])],
        [48, 750, () => SetTargeting(TowerSetup["Glue A"], "Strong")],
        [48, 1000, () => UpgradeTower(TowerSetup["Glue A"], "110")],
        [49, 500, () => PlaceTower(TowerSetup["Glue B"])],
        [49, 750, () => SetTargeting(TowerSetup["Glue B"], "Strong")],
        [49, 1000, () => UpgradeTower(TowerSetup["Glue B"], "110")],
        [50, 500, () => UpgradeTower(TowerSetup["Sniper A"], "042", 774, 1026)],
        [56, 500, () => UpgradeTower(TowerSetup["Sniper A"], "052", 767, 1022)],
        [59, 500, () => SetTargeting(TowerSetup["Sniper A"], "First", 931, 1036)],
        [60, 500, () => SetTargeting(TowerSetup["Sniper B"], "First", 710, 1021)],
        [63, 500, () => UpgradeTower(TowerSetup["Village A"], "203", 882, 940)],
        [76, 0, () => UseAbility("3")],
        [78, 500, () => UpgradeTower(TowerSetup["Alchemist A"], "501", 830, 987)],
        [79, 500, () => PlaceTower(TowerSetup["Sniper C"])],
        [80, 500, () => UpgradeTower(TowerSetup["Sniper C"], "025", 821, 935)],
        [85, 500, () => UpgradeTower(TowerSetup["Sniper B"], "520", 872, 1013)],
        [86, 500, () => PlaceTower(TowerSetup["Glue C"])],
        [86, 750, () => SetTargeting(TowerSetup["Glue C"], "Strong")],
        [86, 1000, () => UpgradeTower(TowerSetup["Glue C"], "024")],
        [88, 500, () => PlaceTower(TowerSetup["Village B"])],
        [88, 750, () => UpgradeTower(TowerSetup["Village B"], "320")],
        [91, 500, () => UpgradeTower(TowerSetup["Glue C"], "025", 673, 243)],
        [92, 500, () => UpgradeTower(TowerSetup["Village B"], "420", 824, 194)],
        [93, 500, () => PlaceTower(TowerSetup["Sniper D"])],
        [93, 750, () => UpgradeTower(TowerSetup["Sniper D"], "420")],
        [94, 500, () => PlaceTower(TowerSetup["Sniper E"])],
        [94, 750, () => UpgradeTower(TowerSetup["Sniper E"], "420")],
        [95, 500, () => PlaceTower(TowerSetup["Sniper F"])],
        [95, 750, () => UpgradeTower(TowerSetup["Sniper F"], "420")],
        [96, 500, () => PlaceTower(TowerSetup["Sniper G"])],
        [96, 750, () => UpgradeTower(TowerSetup["Sniper G"], "420")],
        [97, 500, () => PlaceTower(TowerSetup["Sniper H"])],
        [97, 750, () => UpgradeTower(TowerSetup["Sniper H"], "420")],
        [98, 500, () => PlaceTower(TowerSetup["Sniper I"])],
        [98, 750, () => UpgradeTower(TowerSetup["Sniper I"], "420")],
        [99, 500, () => PlaceTower(TowerSetup["Sniper J"])],
        [99, 750, () => UpgradeTower(TowerSetup["Sniper J"], "420")]
    ]

    return RunMapStrategy(strategy)
}

SanctuaryImpoppable()

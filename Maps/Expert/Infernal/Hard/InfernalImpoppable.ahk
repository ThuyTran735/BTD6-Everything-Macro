#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk
; Credits to sYnce on YT for the help on rounds 6-84.
InfernalImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Infernal",
        difficulty: "Hard",
        gameMode: "Impoppable",
        hero: "Benjamin",
        wingmonkeyMK: false,
        startRound: 6,
        endRound: 100
    }

    global TowerSetup := Map(
        "Boomerang A", {
            type: "Boomerang",
            x: 836,
            y: 696,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart A", {
            type: "Dart",
            x: 481,
            y: 279,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Hero", {
            type: "Hero",
            x: 833,
            y: 382,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 1609,
            y: 698,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper B", {
            type: "Sniper",
            x: 1552,
            y: 671,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 1534,
            y: 593,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 1604,
            y: 542,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper C", {
            type: "Sniper",
            x: 1594,
            y: 463,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper D", {
            type: "Sniper",
            x: 1199,
            y: 795,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper E", {
            type: "Sniper",
            x: 1535,
            y: 507,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper F", {
            type: "Sniper",
            x: 1252,
            y: 834,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper G", {
            type: "Sniper",
            x: 1156,
            y: 846,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist B", {
            type: "Alchemist",
            x: 1223,
            y: 884,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper H", {
            type: "Sniper",
            x: 836,
            y: 695,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper I", {
            type: "Sniper",
            x: 875,
            y: 750,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper J", {
            type: "Sniper",
            x: 791,
            y: 737,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist C", {
            type: "Alchemist",
            x: 825,
            y: 788,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Heli A", {
            type: "Heli",
            x: 473,
            y: 232,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Follow Mouse"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Boomerang A"])],
        [0, 0, () => PlaceTower(TowerSetup["Dart A"])],
        [0, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "011")],
        [7, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "012")],
        [9, 0, () => UpgradeTower(TowerSetup["Boomerang A"], "022")],
        [15, 0, () => PlaceTower(TowerSetup["Hero"])],
        [16, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [17, 0, () => PlaceTower(TowerSetup["Sniper B"])],
        [17, 0, () => SetTargeting(TowerSetup["Sniper B"], "Strong")],
        [18, 0, () => UpgradeTower(TowerSetup["Sniper B"], "100")],
        [19, 0, () => UpgradeTower(TowerSetup["Sniper A"], "022")],
        [27, 0, () => UpgradeTower(TowerSetup["Sniper A"], "032")],
        [31, 0, () => PlaceTower(TowerSetup["Village A"])],
        [31, 0, () => UpgradeTower(TowerSetup["Village A"], "002")],
        [33, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [34, 0, () => UpgradeTower(TowerSetup["Sniper B"], "220")],
        [37, 0, () => UpgradeTower(TowerSetup["Sniper B"], "320")],
        [37, 0, () => SetTargeting(TowerSetup["Sniper B"], "First")],
        [38, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "401")],
        [48, 0, () => UpgradeTower(TowerSetup["Village A"], "003")],
        [49, 0, () => UpgradeTower(TowerSetup["Village A"], "203")],
        [50, 0, () => UpgradeTower(TowerSetup["Sniper B"], "420")],
        [52, 0, () => UpgradeTower(TowerSetup["Sniper A"], "042")],
        [58, 0, () => UpgradeTower(TowerSetup["Sniper A"], "052")],
        [58, 0, () => SetTargeting(TowerSetup["Sniper A"], "First")],
        [75, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "501")],
        [76, 0, () => PlaceTower(TowerSetup["Sniper C"])],
        [76, 0, () => UpgradeTower(TowerSetup["Sniper C"], "025")],
        [84, 0, () => UpgradeTower(TowerSetup["Sniper B"], "520")],
        [85, 0, () => SellTower(TowerSetup["Boomerang A"])],
        [85, 0, () => SellTower(TowerSetup["Dart A"])],
        [86, 0, () => PlaceTower(TowerSetup["Sniper D"])],
        [86, 0, () => UpgradeTower(TowerSetup["Sniper D"], "420")],
        [87, 0, () => PlaceTower(TowerSetup["Sniper E"])],
        [87, 0, () => UpgradeTower(TowerSetup["Sniper E"], "420")],
        [88, 0, () => PlaceTower(TowerSetup["Sniper F"])],
        [88, 0, () => UpgradeTower(TowerSetup["Sniper F"], "420")],
        [89, 0, () => PlaceTower(TowerSetup["Sniper G"])],
        [89, 0, () => UpgradeTower(TowerSetup["Sniper G"], "420")],
        [90, 0, () => PlaceTower(TowerSetup["Alchemist B"])],
        [90, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "401")],
        [91, 0, () => PlaceTower(TowerSetup["Sniper H"])],
        [91, 0, () => UpgradeTower(TowerSetup["Sniper H"], "420")],
        [92, 0, () => PlaceTower(TowerSetup["Sniper I"])],
        [92, 0, () => UpgradeTower(TowerSetup["Sniper I"], "420")],
        [93, 0, () => PlaceTower(TowerSetup["Sniper J"])],
        [93, 0, () => UpgradeTower(TowerSetup["Sniper J"], "420")],
        [95, 0, () => PlaceTower(TowerSetup["Alchemist C"])],
        [95, 0, () => UpgradeTower(TowerSetup["Alchemist C"], "401")],
        [96, 0, () => PlaceTower(TowerSetup["Heli A"])],
        [96, 0, () => UpgradeTower(TowerSetup["Heli A"], "420")]
    ]

    return RunMapStrategy(strategy)
}

InfernalImpoppable()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk
; Credits to sYnce on YT for the help on rounds 6-88.
BloodyPuddlesImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Bloody Puddles",
        difficulty: "Hard",
        gameMode: "Impoppable",
        hero: "Benjamin",
        wingmonkeyMK: false,
        startRound: 6,
        endRound: 100
    }

    global TowerSetup := Map(
        "Desperado A", {
            type: "Desperado",
            x: 588,
            y: 812,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Desperado B", {
            type: "Desperado",
            x: 1136,
            y: 400,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart A", {
            type: "Dart",
            x: 391,
            y: 372,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 1311,
            y: 938,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 701,
            y: 96,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper B", {
            type: "Sniper",
            x: 524,
            y: 98,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sub A", {
            type: "Sub",
            x: 1000,
            y: 942,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Sniper C", {
            type: "Sniper",
            x: 281,
            y: 97,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 920,
            y: 566,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sub B", {
            type: "Sub",
            x: 1199,
            y: 191,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        },
        "Druid A", {
            type: "Druid",
            x: 978,
            y: 601,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Hero", {
            type: "Hero",
            x: 371,
            y: 588,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Village A", {
            type: "Village",
            x: 564,
            y: 238,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 616,
            y: 172,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper D", {
            type: "Sniper",
            x: 623,
            y: 108,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace A", {
            type: "Ace",
            x: 685,
            y: 315,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Village B", {
            type: "Village",
            x: 855,
            y: 205,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Desperado A"])],
        [0, 0, () => PlaceTower(TowerSetup["Desperado B"])],
        [0, 0, () => PlaceTower(TowerSetup["Dart A"])],
        [7, 0, () => PlaceTower(TowerSetup["Dart B"])],
        [8, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [8, 0, () => SetTargeting(TowerSetup["Sniper A"], "Strong")],
        [11, 0, () => PlaceTower(TowerSetup["Sniper B"])],
        [11, 0, () => SetTargeting(TowerSetup["Sniper B"], "Strong")],
        [12, 0, () => PlaceTower(TowerSetup["Sub A"])],
        [14, 0, () => PlaceTower(TowerSetup["Sniper C"])],
        [14, 0, () => SetTargeting(TowerSetup["Sniper C"], "Strong")],
        [15, 0, () => PlaceTower(TowerSetup["Dart C"])],
        [16, 0, () => PlaceTower(TowerSetup["Sub B"])],
        [16, 0, () => UpgradeTower(TowerSetup["Sub B"], "201")],
        [22, 0, () => UpgradeTower(TowerSetup["Sniper A"], "100")],
        [23, 0, () => UpgradeTower(TowerSetup["Sniper B"], "010")],
        [26, 0, () => PlaceTower(TowerSetup["Druid A"])],
        [29, 0, () => PlaceTower(TowerSetup["Hero"])],
        [30, 0, () => UpgradeTower(TowerSetup["Sub B"], "202")],
        [31, 0, () => UpgradeTower(TowerSetup["Dart B"], "002")],
        [32, 0, () => UpgradeTower(TowerSetup["Druid A"], "030")],
        [34, 0, () => SetTargeting(TowerSetup["Druid A"], "Strong")],
        [35, 0, () => SetTargeting(TowerSetup["Sniper B"], "First")],
        [35, 0, () => UpgradeTower(TowerSetup["Sniper B"], "022")],
        [36, 0, () => UpgradeTower(TowerSetup["Druid A"], "130")],
        [37, 0, () => UpgradeTower(TowerSetup["Sniper A"], "300")],
        [41, 0, () => UpgradeTower(TowerSetup["Sniper B"], "032")],
        [42, 0, () => UpgradeTower(TowerSetup["Sniper A"], "320")],
        [43, 0, () => PlaceTower(TowerSetup["Village A"])],
        [43, 0, () => UpgradeTower(TowerSetup["Village A"], "200")],
        [45, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [45, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "401")],
        [49, 0, () => UpgradeTower(TowerSetup["Sniper A"], "420")],
        [54, 0, () => UpgradeTower(TowerSetup["Sniper B"], "042")],
        [58, 0, () => SetTargeting(TowerSetup["Sniper A"], "First")],
        [62, 0, () => UpgradeTower(TowerSetup["Sniper B"], "052")],
        [62, 0, () => SetTargeting(TowerSetup["Sniper B"], "First")],
        [65, 0, () => UpgradeTower(TowerSetup["Village A"], "203")],
        [80, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "501")],
        [81, 0, () => PlaceTower(TowerSetup["Sniper D"])],
        [81, 0, () => UpgradeTower(TowerSetup["Sniper D"], "025")],
        [87, 0, () => UpgradeTower(TowerSetup["Sniper A"], "520")],
        [89, 0, () => PlaceTower(TowerSetup["Ace A"])],
        [89, 0, () => UpgradeTower(TowerSetup["Ace A"], "204")],
        [92, 0, () => PlaceTower(TowerSetup["Village B"])],
        [92, 0, () => UpgradeTower(TowerSetup["Village B"], "130")]
    ]

    return RunMapStrategy(strategy)
}

BloodyPuddlesImpoppable()

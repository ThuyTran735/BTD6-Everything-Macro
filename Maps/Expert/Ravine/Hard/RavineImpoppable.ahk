#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk
; Credits to sYnce on YT for the help on rounds 6-95.
RavineImpoppable() {
    global RunConfig := {
        category: "Expert",
        map: "Ravine",
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
            x: 1019,
            y: 185,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart B", {
            type: "Dart",
            x: 289,
            y: 667,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart C", {
            type: "Dart",
            x: 873,
            y: 990,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart D", {
            type: "Dart",
            x: 218,
            y: 489,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart E", {
            type: "Dart",
            x: 1072,
            y: 1026,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart F", {
            type: "Dart",
            x: 265,
            y: 724,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Dart G", {
            type: "Dart",
            x: 812,
            y: 966,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Hero", {
            type: "Hero",
            x: 1337,
            y: 280,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "SpikeFactory A", {
            type: "SpikeFactory",
            x: 670,
            y: 820,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Normal"
        },
        "Druid A", {
            type: "Druid",
            x: 704,
            y: 113,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue A", {
            type: "Glue",
            x: 1067,
            y: 338,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "SpikeFactory B", {
            type: "SpikeFactory",
            x: 334,
            y: 829,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Normal"
        },
        "Village A", {
            type: "Village",
            x: 539,
            y: 853,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist A", {
            type: "Alchemist",
            x: 342,
            y: 982,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Alchemist B", {
            type: "Alchemist",
            x: 505,
            y: 774,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Wizard A", {
            type: "Wizard",
            x: 451,
            y: 814,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice A", {
            type: "Ice",
            x: 742,
            y: 801,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ice B", {
            type: "Ice",
            x: 328,
            y: 764,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Ace A", {
            type: "Ace",
            x: 374,
            y: 911,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },
        "Village B", {
            type: "Village",
            x: 230,
            y: 847,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Glue B", {
            type: "Glue",
            x: 748,
            y: 167,
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
        [0, 0, () => SetTargeting(TowerSetup["Dart A"], "Last")],
        [0, 0, () => SetTargeting(TowerSetup["Dart B"], "Strong")],
        [7, 0, () => PlaceTower(TowerSetup["Dart E"])],
        [9, 0, () => PlaceTower(TowerSetup["Dart F"])],
        [10, 0, () => PlaceTower(TowerSetup["Dart G"])],
        [10, 750, () => UpgradeTower(TowerSetup["Dart B"], "020")],
        [11, 0, () => UpgradeTower(TowerSetup["Dart C"], "020")],
        [14, 0, () => UpgradeTower(TowerSetup["Dart B"], "030")],
        [16, 0, () => UpgradeTower(TowerSetup["Dart C"], "030")],
        [22, 0, () => PlaceTower(TowerSetup["Hero"])],
        [25, 0, () => PlaceTower(TowerSetup["SpikeFactory A"])],
        [25, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "002")],
        [26, 0, () => SetSpikeFactoryTargeting(TowerSetup["SpikeFactory A"], "Smart")],
        [27, 0, () => PlaceTower(TowerSetup["Druid A"])],
        [27, 0, () => SetTargeting(TowerSetup["Druid A"], "Strong")],
        [27, 0, () => UpgradeTower(TowerSetup["Druid A"], "100")],
        [28, 0, () => PlaceTower(TowerSetup["Glue A"])],
        [28, 0, () => SetTargeting(TowerSetup["Glue A"], "Last")],
        [28, 0, () => UpgradeTower(TowerSetup["Glue A"], "110")],
        [30, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "102")],
        [32, 0, () => UpgradeTower(TowerSetup["Druid A"], "130")],
        [35, 0, () => PlaceTower(TowerSetup["SpikeFactory B"])],
        [35, 0, () => UpgradeTower(TowerSetup["SpikeFactory B"], "002")],
        [35, 0, () => SetSpikeFactoryTargeting(TowerSetup["SpikeFactory B"], "Smart")],
        [37, 0, () => PlaceTower(TowerSetup["Village A"])],
        [37, 0, () => UpgradeTower(TowerSetup["Village A"], "002")],
        [38, 0, () => UpgradeTower(TowerSetup["SpikeFactory B"], "102")],
        [38, 0, () => UpgradeTower(TowerSetup["SpikeFactory A"], "302")],
        [40, 0, () => UpgradeTower(TowerSetup["SpikeFactory B"], "302")],
        [42, 0, () => UpgradeTower(TowerSetup["Village A"], "202")],
        [45, 0, () => PlaceTower(TowerSetup["Alchemist A"])],
        [45, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "300")],
        [46, 0, () => PlaceTower(TowerSetup["Alchemist B"])],
        [46, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "320")],
        [48, 0, () => PlaceTower(TowerSetup["Wizard A"])],
        [48, 0, () => UpgradeTower(TowerSetup["Wizard A"], "202")],
        [49, 0, () => UpgradeTower(TowerSetup["Wizard A"], "402")],
        [54, 0, () => PlaceTower(TowerSetup["Ice A"])],
        [54, 0, () => UpgradeTower(TowerSetup["Ice A"], "024")],
        [57, 0, () => PlaceTower(TowerSetup["Ice B"])],
        [57, 0, () => UpgradeTower(TowerSetup["Ice B"], "024")],
        [64, 0, () => UpgradeTower(TowerSetup["Village A"], "203")],
        [75, 0, () => UpgradeTower(TowerSetup["Wizard A"], "502")],
        [78, 0, () => PlaceTower(TowerSetup["Ace A"])],
        [78, 0, () => UpgradeTower(TowerSetup["Ace A"], "204")],
        [81, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "320")],
        [92, 0, () => UpgradeTower(TowerSetup["Ace A"], "205")],
        [93, 0, () => PlaceTower(TowerSetup["Village B"])],
        [93, 0, () => UpgradeTower(TowerSetup["Village B"], "020")],
        [94, 0, () => PlaceTower(TowerSetup["Glue B"])],
        [94, 0, () => UpgradeTower(TowerSetup["Glue B"], "024")],
        [94, 0, () => SetTargeting(TowerSetup["Glue B"], "Strong")],
        [95, 0, () => UpgradeTower(TowerSetup["Alchemist B"], "520")],
        [99, 0, () => UpgradeTower(TowerSetup["Alchemist A"], "420")]
    ]

    return RunMapStrategy(strategy)
}

RavineImpoppable()

#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk

ScrapyardReverse() {
    ; Navigation and round bounds for this saved strategy.
    global RunConfig := {
        category: "Beginner",
        map: "Scrapyard",
        difficulty: "Medium",
        gameMode: "Reverse",
        hero: "Quincy",
        wingmonkeyMK: false
    }

    ; Named placement records. Helpers update placed, upgrades, and targeting during the run.
    ; The X/Y values here remain the original placement points.
    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 219,
            y: 883,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper A", {
            type: "Sniper",
            x: 1019,
            y: 370,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper B", {
            type: "Sniper",
            x: 800,
            y: 651,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper C", {
            type: "Sniper",
            x: 526,
            y: 494,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper D", {
            type: "Sniper",
            x: 528,
            y: 348,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },
        "Sniper E", {
            type: "Sniper",
            x: 848,
            y: 700,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )

    ; Entries are [round, delay in milliseconds, action] and run in the written order.
    ; Round 0 is the setup before the match starts.
    strategy := [
        [0, 0, () => PlaceTower(TowerSetup["Hero"])],
        [3, 0, () => PlaceTower(TowerSetup["Sniper A"])],
        [3, 0, () => SetTargeting(TowerSetup["Sniper A"], "Strong")],
        [6, 0, () => PlaceTower(TowerSetup["Sniper B"])],
        [7, 0, () => UpgradeTower(TowerSetup["Sniper A"], "110")],
        [10, 0, () => UpgradeTower(TowerSetup["Sniper B"], "022")],
        [17, 0, () => UpgradeTower(TowerSetup["Sniper A"], "220")],
        [24, 0, () => PlaceTower(TowerSetup["Sniper C"])],
        [24, 0, () => UpgradeTower(TowerSetup["Sniper C"], "022")],
        [34, 0, () => UpgradeTower(TowerSetup["Sniper B"], "024")],
        [39, 0, () => UpgradeTower(TowerSetup["Sniper A"], "320")],
        [41, 0, () => UpgradeTower(TowerSetup["Sniper C"], "024")],
        [48, 0, () => UpgradeTower(TowerSetup["Sniper A"], "420")],
        [49, 0, () => PlaceTower(TowerSetup["Sniper D"])],
        [49, 0, () => UpgradeTower(TowerSetup["Sniper D"], "204")],
        [52, 0, () => PlaceTower(TowerSetup["Sniper E"])],
        [52, 0, () => SetTargeting(TowerSetup["Sniper E"], "Strong")],
        [52, 0, () => UpgradeTower(TowerSetup["Sniper E"], "420")]
    ]

    return RunMapStrategy(strategy)
}

ScrapyardReverse()

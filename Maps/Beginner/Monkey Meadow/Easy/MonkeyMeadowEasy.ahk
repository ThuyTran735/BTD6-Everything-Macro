#Requires AutoHotkey v2.0
#Include ..\..\..\..\Scripts\IncludeAll.ahk


MonkeyMeadowEasy() {
    global RunConfig := {
        category: "Beginner",
        map: "Monkey Meadow",
        difficulty: "Easy",
        gameMode: "Standard",
        hero: "Quincy"
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 800,
            y: 500,
            placed: false,
            upgrades: [0, 0, 0]
        },

        "Dart A", {
            type: "Dart",
            x: 700,
            y: 550,
            placed: false,
            upgrades: [0, 0, 0]
        }
    )


    strategy := [
        ; Place Hero on Round 1
        [1, 0, () => PlaceTower(TowerSetup["Hero"])],

        ; Place Dart on Round 3
        [3, 0, () => PlaceTower(TowerSetup["Dart A"])],

        ; Upgrade Dart to 2-0-0 on Round 8
        [8, 0, () => UpgradeTower(TowerSetup["Dart A"], "200")],

        ; Upgrade Dart to 2-0-3 on Round 15
        [15, 0, () => UpgradeTower(TowerSetup["Dart A"], "203")]
    ]


    ; Navigate:
    ; Play -> Hero -> Beginner -> Monkey Meadow -> Easy -> Standard
    if !NavigateToMap(
        RunConfig.category,
        RunConfig.map,
        RunConfig.difficulty,
        RunConfig.gameMode,
        RunConfig.hero
    ) {
        return false
    }


    ; Wait until the map has actually loaded.
    if !WaitForGameLoad()
        return false


    ; Clear any previous round tracking.
    ResetRoundTracking()


    ; Enable auto-start and begin the game.
    if !StartGame()
        return false


    ; Run all scheduled placements/upgrades/abilities.
    if !RunStrategy(strategy)
        return false


    return true
}


MonkeyMeadowEasy()
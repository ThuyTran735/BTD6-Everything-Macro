#Requires AutoHotkey v2.0

#Include ..\Scripts\IncludeAll.ahk
; Delete this ^^^ Only here to stop error messages

; #Include Location Of InlcudeAll.ahk

MapNameDifficultyMode() {
    global RunConfig := {
        category: "Beginner",
        map: "MAP NAME",
        difficulty: "Easy",
        gameMode: "Standard",
        hero: false
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 0,
            y: 0,
            placed: false,
            upgrades: [0, 0, 0]
        },

        "Tower A", {
            type: "Dart",
            x: 0,
            y: 0,
            placed: false,
            upgrades: [0, 0, 0]
        }
    )


    strategy := [
        ; Pregame
        [0, 0, () => PlaceTower(TowerSetup["Tower A"])],

        ; During game
        [3, 0, () => UpgradeTower(TowerSetup["Tower A"], "002")],
        [7, 0, () => UpgradeTower(TowerSetup["Tower A"], "022")],

        ; Mid-round example
        [20, 5000, () => UseAbility("1")]
    ]


    if !NavigateToMap(
        RunConfig.category,
        RunConfig.map,
        RunConfig.difficulty,
        RunConfig.gameMode,
        RunConfig.hero
    ) {
        return false
    }


    if !WaitForGameLoad()
        return false


    maxAttempts := 3

    Loop maxAttempts {
        attempt := A_Index

        ResetRoundTracking()
        ResetTowerSetup()


        ; Place hero before Round 1.
        heroResult := PlaceTower(TowerSetup["Hero"])

        if heroResult = "Victory" {
            if !HandleVictory()
                return false

            return true
        }

        if heroResult = "Defeat" {
            if attempt >= maxAttempts
                return false

            if !HandleDefeat()
                return false

            if !WaitForGameLoad()
                return false

            continue
        }

        if heroResult = false
            return false


        ; Execute Round 0 actions.
        pregameResult := RunPregameStrategy(strategy)

        if pregameResult = "Victory" {
            if !HandleVictory()
                return false

            return true
        }

        if pregameResult = "Defeat" {
            if attempt >= maxAttempts
                return false

            if !HandleDefeat()
                return false

            if !WaitForGameLoad()
                return false

            continue
        }

        if pregameResult = false
            return false


        ; Start fresh round tracking immediately before Round 1.
        ResetRoundTracking()


        if !StartGame()
            return false


        result := RunStrategy(strategy)


        if result = "Victory" {
            if !HandleVictory()
                return false

            return true
        }


        if result = "Defeat" {
            if attempt >= maxAttempts {
                ToolTip("Maximum attempts reached.")
                Sleep(2000)
                ToolTip()

                return false
            }

            if !HandleDefeat()
                return false

            if !WaitForGameLoad()
                return false

            continue
        }


        return false
    }


    return false
}


MapNameDifficultyMode()
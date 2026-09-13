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
        ; your towers...
    )

    strategy := [
        ; your strategy...
    ]


    ; Navigate to the game.
    if !NavigateToMap(
        RunConfig.category,
        RunConfig.map,
        RunConfig.difficulty,
        RunConfig.gameMode,
        RunConfig.hero
    ) {
        return false
    }


    ; Wait until the map loads.
    if !WaitForGameLoad()
        return false


    ; Retry the strategy if we lose.
    maxAttempts := 3

    Loop maxAttempts {
        attempt := A_Index

        ResetRoundTracking()
        ResetTowerSetup()

        if !StartGame()
            return false

        result := RunStrategy(strategy)

        if result = "Victory" {
            HandleVictory()
            return true
        }

        if result = "Defeat" {
            if attempt >= maxAttempts {
                ToolTip("Maximum attempts reached.")
                Sleep(2000)
                return false
            }

            if !HandleDefeat()
                return false

            continue
        }

        ToolTip("Strategy stopped unexpectedly.")
        return false
    }

    return false
}

MonkeyMeadowEasy()
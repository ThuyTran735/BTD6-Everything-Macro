RunMapStrategy(strategy) {
    global RunConfig

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

    maxAttempts := HasProp(RunConfig, "maxAttempts")
        ? RunConfig.maxAttempts
        : 3

    Loop maxAttempts {
        attempt := A_Index

        ResetRoundTracking()
        ResetTowerSetup()

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
                ToolTip(
                    "Maximum attempts reached."
                    "`nAttempts: " attempt
                )

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
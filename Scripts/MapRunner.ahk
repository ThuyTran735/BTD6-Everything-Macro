#Requires AutoHotkey v2.0


RunMapStrategy(strategy) {
    global RunConfig


    navigationResult := NavigateToMap(
        RunConfig.category,
        RunConfig.map,
        RunConfig.difficulty,
        RunConfig.gameMode,
        RunConfig.hero
    )


    if navigationResult = "Locked" {
        prerequisite := GetGameModePrerequisite(
            RunConfig.gameMode
        )


        if !prerequisite {
            ToolTip(
                "Game mode is locked."
                "`nMode: " RunConfig.gameMode
                "`nNo automatic prerequisite exists."
            )

            Sleep(3000)
            ToolTip()

            return false
        }


        ; Return to a known menu before starting
        ; the separate prerequisite strategy.
        Send("{Esc}")

        Sleep(500)


        if !TryRunPrerequisiteMode(
            RunConfig.gameMode
        ) {
            return false
        }


        ; The prerequisite script should have
        ; completed and returned to Home.
        ;
        ; Try the originally requested mode again.
        navigationResult := NavigateToMap(
            RunConfig.category,
            RunConfig.map,
            RunConfig.difficulty,
            RunConfig.gameMode,
            RunConfig.hero
        )


        if navigationResult = "Locked" {
            ToolTip(
                "Game mode is still locked."
                "`nRequested: " RunConfig.gameMode
                "`nCompleted prerequisite: "
                prerequisite
            )

            Sleep(3000)
            ToolTip()

            return false
        }


        if navigationResult = false
            return false
    }


    if navigationResult = false
        return false


    if !WaitForGameLoad()
        return false


    maxAttempts := HasProp(
        RunConfig,
        "maxAttempts"
    )
        ? RunConfig.maxAttempts
        : 3


    Loop maxAttempts {
        attempt := A_Index


        ResetRoundTracking()
        ResetTowerSetup()


        pregameResult := RunPregameStrategy(
            strategy
        )


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


        result := RunStrategy(
            strategy
        )


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
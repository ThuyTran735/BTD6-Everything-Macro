#Requires AutoHotkey v2.0


GetCurrentLauncherCycle() {
    cyclePrefix :=
        "--btd6-cycle="


    for argument in A_Args {

        if InStr(
            argument,
            cyclePrefix
        ) != 1 {
            continue
        }


        cycleText :=
            SubStr(
                argument,
                StrLen(cyclePrefix) + 1
            )


        if RegExMatch(
            cycleText,
            "^\d+$"
        ) {
            cycleNumber :=
                cycleText + 0


            if cycleNumber >= 1 {
                return cycleNumber
            }
        }
    }


    ; Scripts launched directly should behave exactly
    ; like a normal first cycle and select the hero.
    return 1
}


ShouldSelectHeroForCurrentCycle() {
    return GetCurrentLauncherCycle() = 1
}


RunMapStrategy(strategy) {
    global RunConfig

    ; Every new cycle starts with completely fresh
    ; internal tower and round tracking state.
    ResetRoundTracking()
    ResetTowerSetup()

    if !SwitchToFullscreen()
        return false


    navigationHero :=
        ShouldSelectHeroForCurrentCycle()
            ? RunConfig.hero
            : false


    navigationResult := NavigateToMap(
        RunConfig.category,
        RunConfig.map,
        RunConfig.difficulty,
        RunConfig.gameMode,
        navigationHero
    )


    if navigationResult = "Locked" {
        prerequisite := GetGameModePrerequisite(
            RunConfig.gameMode
        )


        if !prerequisite {
            ToolTip(
                "Game mode is locked."
                "`nMode: "
                RunConfig.gameMode
                "`nNo automatic prerequisite exists."
            )

            Sleep(3000)
            ToolTip()

            return false
        }


        ; Back out of the locked game mode screen.
        Send("{Esc}")

        Sleep(500)


        ; Back out of the Easy / Medium / Hard screen
        ; so the prerequisite starts from map selection.
        Send("{Esc}")

        Sleep(700)


        if !TryRunPrerequisiteMode(
            RunConfig.gameMode
        ) {
            return false
        }


        navigationResult := NavigateToMap(
            RunConfig.category,
            RunConfig.map,
            RunConfig.difficulty,
            RunConfig.gameMode,
            navigationHero
        )


        if navigationResult = "Locked" {
            ToolTip(
                "Game mode is still locked."
                "`nRequested: "
                RunConfig.gameMode
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


    ; First load into the selected game.
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
            if attempt >= maxAttempts {
                ToolTip(
                    "Maximum attempts reached."
                    "`nAttempts: "
                    attempt
                )

                Sleep(2000)
                ToolTip()

                return false
            }


            if !HandleDefeat()
                return false


            ; No CHIMPS OK after restarting.
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
                    "`nAttempts: "
                    attempt
                )

                Sleep(2000)
                ToolTip()

                return false
            }


            if !HandleDefeat()
                return false


            ; Restart goes directly back into CHIMPS.
            ; Do not search for CHIMPS OK again.
            if !WaitForGameLoad()
                return false


            continue
        }


        return false
    }


    return false
}
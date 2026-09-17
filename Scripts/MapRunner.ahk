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


GetLauncherRunToken() {
    tokenPrefix := "--btd6-run-token="

    for argument in A_Args {
        if InStr(argument, tokenPrefix) != 1
            continue

        token := SubStr(argument, StrLen(tokenPrefix) + 1)
        if RegExMatch(token, "^[A-Za-z0-9_-]+$")
            return token
    }

    return ""
}


GetLauncherRunResultPath(token := "") {
    if token = ""
        token := GetLauncherRunToken()

    if token = ""
        return ""

    return A_Temp . "\\BTD6EverythingMacro_RunResult_" . token . ".ini"
}


WriteLauncherRunResult(status, reason := "") {
    path := GetLauncherRunResultPath()
    if path = ""
        return false

    try {
        IniWrite(status, path, "Result", "Status")
        IniWrite(reason, path, "Result", "Reason")
        return true
    }
    catch {
        return false
    }
}

RunMapStrategy(strategy) {
    InitializeRunLog("Map strategy")
    LogRunConfig()

    try {
        result := RunMapStrategyCore(strategy)
    }
    catch Error as err {
        LogException(err)
        reason := GetRunFailureReason("UNHANDLED ERROR: " . err.Message)
        FinishRunLog("Failed", reason)
        WriteLauncherRunResult("Failed", reason)
        throw
    }

    if result {
        FinishRunLog("Success")
        WriteLauncherRunResult("Success")
    }
    else {
        reason := GetRunFailureReason("SCRIPT RETURNED FAILURE")
        FinishRunLog("Failed", reason)
        WriteLauncherRunResult("Failed", reason)
    }

    return result
}


RunMapStrategyCore(strategy) {
    global RunConfig

    ; Every new cycle starts with completely fresh
    ; internal tower and round tracking state.
    ResetRoundTracking()
    ResetTowerSetup()

    LogMessage("INFO", "Preparing BTD6 fullscreen state")

    if !SwitchToFullscreen()
        return SetRunFailureReason("FAILED TO ENTER FULLSCREEN")


    LogMessage("INFO", "Navigating to configured map and mode")

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

            return SetRunFailureReason("GAME MODE LOCKED - NO PREREQUISITE", RunConfig.gameMode)
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
            return EnsureRunFailureReason("FAILED TO COMPLETE PREREQUISITE MODE")
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

            return SetRunFailureReason("GAME MODE STILL LOCKED", RunConfig.gameMode)
        }


        if navigationResult = false
            return EnsureRunFailureReason("FAILED TO ENTER MODE")
    }


    if navigationResult = false
        return EnsureRunFailureReason("MAP NAVIGATION FAILED")


    ; First load into the selected game.
    LogMessage("INFO", "Waiting for game load")

    if !WaitForGameLoad()
        return SetRunFailureReason("GAME LOAD FAILED")

    ResetRoundTracking()
    ResetTowerSetup()


    LogMessage("INFO", "Running pregame strategy actions")

    pregameResult := RunPregameStrategy(
        strategy
    )


    if pregameResult = "Victory" {
        if !HandleVictory()
            return SetRunFailureReason("VICTORY SCREEN HANDLING FAILED")

        return true
    }


    if pregameResult = "Defeat" {
        return SetRunFailureReason("DEFEAT DURING PREGAME")
    }


    if pregameResult = false
        return EnsureRunFailureReason("PREGAME STRATEGY FAILED")


    ResetRoundTracking()


    LogMessage("INFO", "Starting game rounds")

    if !StartGame()
        return SetRunFailureReason("FAILED TO START GAME")


    LogMessage("INFO", "Running round strategy")

    result := RunStrategy(
        strategy
    )


    if result = "Victory" {
        if !HandleVictory()
            return SetRunFailureReason("VICTORY SCREEN HANDLING FAILED")

        return true
    }


    if result = "Defeat"
        return SetRunFailureReason("DEFEAT")


    return EnsureRunFailureReason("STRATEGY FAILED")
}
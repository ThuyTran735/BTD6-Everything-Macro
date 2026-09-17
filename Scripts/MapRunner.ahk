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

    return false
}


RunMapStrategy(strategy) {
    try {
        result := RunMapStrategyCore(strategy)
    }
    catch Error as err {
        WriteLauncherRunResult("Failed", "UNHANDLED ERROR: " . err.Message)
        throw
    }

    if result {
        WriteLauncherRunResult("Success")
    }
    else {
        WriteLauncherRunResult("Failed", "SCRIPT RETURNED FAILURE")
    }

    return result
}


RunMapStrategyCore(strategy) {
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
        return false
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


    return false
}
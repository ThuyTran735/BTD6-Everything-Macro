#Requires AutoHotkey v2.0

; v3 file note: Prompts for run count and starts a selected map script.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

PromptForRunCount(context := "run") {
    return ShowCycleInputPrompt(context)
}


LaunchMapScript(
    scriptPath
) {
    global MacroRunning
    global MacroJobQueue
    global LauncherGui

    global RepeatScriptPath
    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted

    global ForceLauncherVisible

    global UIColorError


    if MacroRunning {

        return false
    }


    ; Defensive guard for picker/hotkey edge cases. If a queue was
    ; populated after a picker opened, running the selected script
    ; still starts the queue instead of creating a separate run.
    if MacroJobQueue.Length > 0 {

        return StartMacroQueue()
    }


    if !FileExist(
        scriptPath
    ) {

        UpdateStatus(
            "SCRIPT NOT FOUND",
            UIColorError
        )


        return false
    }


    ; Keep the main launcher visible while the user chooses the run count.
    ; It is only hidden after a valid run is confirmed and startup begins.
    ClearLauncherReturnPending()
    SetLauncherRunSuppressed(false)
    ShowLauncher(true)


    runCount :=
        PromptForRunCount()


    if runCount = 0 {

        ShowLauncher(true)

        return false
    }


    ForceLauncherVisible :=
        false


    SetLauncherRunSuppressed(true)


    SetRunHistoryCurrentSource(
        "MANUAL RUN"
    )


    ClearQueueExecutionState()
    ClearCycleStopRequest()


    RepeatScriptPath :=
        scriptPath


    RepeatRunTotal :=
        runCount


    RepeatRunRemaining :=
        runCount


    RepeatRunCompleted :=
        0


    CloseAllDarkDropdowns()
    CloseModePicker()
    CloseScriptPicker()
    CloseQueueManager()


    ; Mark the run active BEFORE the loading UI starts.
    ;
    ; Main.ahk checks MonitorLauncherState every 500 ms.
    ; Setting this first prevents the launcher from
    ; flashing back on-screen while the loading UI is
    ; transitioning into the strategy process.
    MacroRunning :=
        true


    LauncherGui.Hide()


    RunStartupLoadingAnimation()


    ; Keep the launcher hidden after the loading GUI
    ; closes and before the child strategy starts.
    LauncherGui.Hide()


    ShowCycleStatusUI()


    return StartNextQueuedRun()
}



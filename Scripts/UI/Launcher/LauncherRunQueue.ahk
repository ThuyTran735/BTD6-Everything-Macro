#Requires AutoHotkey v2.0

; v3 file note: Runs repeat/queued jobs and clears the repeat-run state afterward.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

StartNextQueuedRun(isRetry := false, defeatRestart := false) {
    global MacroRunning
    global RunningPid
    global ActiveRunToken
    global LauncherGui

    global RepeatScriptPath
    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted

    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs

    global UIColorWarning
    global UIColorError


    if !MacroRunning {

        return false
    }


    if (
        !isRetry
        && RepeatRunRemaining < 1
    ) {

        return false
    }


    if !FileExist(
        RepeatScriptPath
    ) {

        MacroRunning :=
            false


        RunningPid :=
            0


        ClearChildRunResult(ActiveRunToken)
        ActiveRunToken := ""


        HideCycleStatusUI()


        ClearRepeatRunState()
        ClearQueueExecutionState()


        UpdateStatus(
            "SCRIPT NOT FOUND",
            UIColorError
        )


        RecordRunHistoryFailure(
            "SCRIPT NOT FOUND"
        )


        ClearLauncherReturnPending()
        SetLauncherRunSuppressed(false)


        ShowLauncher(
            true
        )


        return false
    }


    currentRun :=
        RepeatRunCompleted
        + 1


    if QueueRunning {

        UpdateStatus(
            "JOB "
            . QueueActiveJobIndex
            . " / "
            . QueueTotalJobs
            . " - RUN "
            . currentRun
            . " / "
            . RepeatRunTotal,
            UIColorWarning
        )
    }
    else {

        UpdateStatus(
            "STARTING RUN "
            . currentRun
            . " OF "
            . RepeatRunTotal
            . "...",
            UIColorWarning
        )
    }


    UpdateCycleStatusUI()


    LauncherGui.Hide()


    ; Optional Daily Chest check runs before normal map launches.
    ; A defeat-restart retry is already inside the restarted map, so
    ; do not click Home-screen Daily Chest coordinates during recovery.
    if !defeatRestart
        RunPreMapDailyChestIfEnabled()


    ActiveRunToken := CreateChildRunToken()
    ClearChildRunResult(ActiveRunToken)


    command :=
        Chr(34)
        . A_AhkPath
        . Chr(34)
        . " "
        . Chr(34)
        . RepeatScriptPath
        . Chr(34)
        . " "
        . Chr(34)
        . "--btd6-cycle="
        . currentRun
        . Chr(34)
        . " "
        . Chr(34)
        . "--btd6-run-token="
        . ActiveRunToken
        . Chr(34)


    if defeatRestart {
        command .=
            " "
            . Chr(34)
            . "--btd6-defeat-restart=1"
            . Chr(34)
    }


    try {

        ; Clean modifier state before a new strategy
        ; process is started.
        SendEvent(
            "{LAlt Up}"
            . "{RAlt Up}"
            . "{LCtrl Up}"
            . "{RCtrl Up}"
            . "{LShift Up}"
            . "{RShift Up}"
            . "{LWin Up}"
            . "{RWin Up}"
        )


        Sleep(
            50
        )

        Run(
            command,
            A_ScriptDir,
            ,
            &RunningPid
        )


        if !isRetry {
            RepeatRunRemaining--
        }


        return true
    }
    catch Error as err {

        MacroRunning :=
            false


        RunningPid :=
            0


        ClearChildRunResult(ActiveRunToken)
        ActiveRunToken := ""


        HideCycleStatusUI()


        ClearRepeatRunState()
        ClearQueueExecutionState()
        ClearCycleStopRequest()


        UpdateStatus(
            "FAILED TO START",
            UIColorError
        )


        RecordRunHistoryFailure(
            "FAILED TO START"
        )


        ClearLauncherReturnPending()
        SetLauncherRunSuppressed(false)


        ShowLauncher(
            true
        )


        MsgBox(
            "Could not start the selected macro.`n`n"
            . err.Message,
            "BTD6 Macro"
        )


        return false
    }
}


ClearRepeatRunState() {
    global RepeatScriptPath
    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted


    RepeatScriptPath :=
        ""


    RepeatRunTotal :=
        0


    RepeatRunRemaining :=
        0


    RepeatRunCompleted :=
        0
}
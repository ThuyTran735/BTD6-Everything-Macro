#Requires AutoHotkey v2.0

; Launch one strategy process per cycle, with a fresh token for its completion result.

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
    global CycleStatusClosing
    global CollectionEventRunActive
    global CollectionEventRunGeneration


    if !MacroRunning || CycleStatusClosing {

        return false
    }


    if (
        !isRetry
        && RepeatRunRemaining < 1
    ) {

        return false
    }


    ; Keep the event session separate from the selected launcher mode. A queue
    ; started while that mode is selected must still run its own fixed scripts.
    eventGeneration := CollectionEventRunActive ? CollectionEventRunGeneration : 0
    if eventGeneration && !PrepareCollectionEventCycle(eventGeneration, isRetry, defeatRestart)
        return false

    if !MacroRunning || CycleStatusClosing
        return false
    if eventGeneration && !IsCurrentCollectionEventRun(eventGeneration)
        return false

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
    else if eventGeneration {

        UpdateStatus("STARTING EVENT RUN " . currentRun . "...", UIColorWarning)
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
    if !defeatRestart && !eventGeneration
        RunPreMapDailyChestIfEnabled()

    ; A chest animation or event scan can yield to the emergency-stop hotkey.
    if !MacroRunning || CycleStatusClosing
        return false
    if eventGeneration && !IsCurrentCollectionEventRun(eventGeneration)
        return false

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

    if eventGeneration {
        command .= " " . Chr(34) . "--btd6-collection-event=1" . Chr(34)
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

        if !MacroRunning || CycleStatusClosing
            return false
        if eventGeneration && !IsCurrentCollectionEventRun(eventGeneration)
            return false

        ; Publish the child PID and consume the cycle together. A stop arriving
        ; during Run() must see the new PID rather than leave an orphan process.
        Critical("On")
        try {
            if !MacroRunning || CycleStatusClosing
                return false
            if eventGeneration && !IsCurrentCollectionEventRun(eventGeneration)
                return false

            Run(
                command,
                A_ScriptDir,
                ,
                &RunningPid
            )

            ; Event mode stays open-ended. Finite retries repeat their current
            ; cycle without consuming another requested run.
            if !isRetry && !eventGeneration {
                RepeatRunRemaining--
            }
        }
        finally {
            Critical("Off")
        }


        return true
    }
    catch Error as err {

        if !MacroRunning || CycleStatusClosing
            return false
        if eventGeneration && !IsCurrentCollectionEventRun(eventGeneration)
            return false

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

    ClearCollectionEventRunState()

    RepeatScriptPath :=
        ""


    RepeatRunTotal :=
        0


    RepeatRunRemaining :=
        0


    RepeatRunCompleted :=
        0
}

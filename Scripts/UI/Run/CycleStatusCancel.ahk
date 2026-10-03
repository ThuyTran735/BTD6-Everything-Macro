#Requires AutoHotkey v2.0

; v3 file note: Completes/hides the HUD and handles stopping active cycles.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

CompleteCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText

    global CycleProgressText
    global CycleProgressBar

    global RepeatRunTotal

    global QueueRunning
    global QueueTotalRuns


    if !CycleStatusGui {
        return
    }


    if RepeatRunTotal < 1 {
        return
    }


    if QueueRunning {

        CycleStatusText.Text :=
            "QUEUE COMPLETE"


        CycleProgressText.Text :=
            QueueTotalRuns
            . " RUN"
            . (
                QueueTotalRuns = 1
                ? ""
                : "S"
            )
            . " COMPLETE"
    }
    else {

        CycleStatusText.Text :=
            "CYCLE "
            . RepeatRunTotal
            . " / "
            . RepeatRunTotal


        CycleProgressText.Text :=
            "COMPLETE"
    }


    ; Always visibly finish the bar before
    ; the cycle tracker closes.
    CycleProgressBar.Value :=
        100
}


HideCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusLastX
    global CycleStatusLastY
    global CycleStatusRightPanelOpen
    global CycleStatusRightPanelMisses


    SetTimer(
        UpdateCycleStatusPosition,
        0
    )


    CycleStatusLastX :=
        ""


    CycleStatusLastY :=
        ""


    CycleStatusRightPanelOpen := false
    CycleStatusRightPanelMisses := 0


    if !CycleStatusGui {
        return
    }


    try {
        CycleStatusGui.Hide()
    }
}


RequestCancelMacroCyclesIfStillActive(*) {
    global MacroRunning
    global RunningPid
    global QueueRunning


    if !MacroRunning && !QueueRunning && !RunningPid {
        return
    }


    CancelMacroCycles()
}


RequestCancelMacroCycles(*) {
    global MacroRunning
    global RunningPid
    global QueueRunning
    global CycleStatusGui


    if !MacroRunning && !QueueRunning && !RunningPid {
        return
    }


    actionText :=
        QueueRunning
        ? "the entire active queue"
        : "the active run"


    ShowThemedConfirmation(
        "CLOSE ACTIVE RUN?",
        "Stop " . actionText . " now?`n`nCurrent progress will stop and later queued runs will not start automatically.",
        "CLOSE RUN",
        RequestCancelMacroCyclesIfStillActive,
        CycleStatusGui,
        "Stops the current run.`n`nIf a queue is active, the whole queue stops and later jobs will not start."
    )
}


CancelMacroCycles(*) {
    global MacroRunning
    global RunningPid
    global ActiveRunToken

    global CycleStatusGui
    global CycleStatusText
    global CycleProgressText

    global RepeatRunRemaining
    global ForceLauncherVisible

    global QueueRunning

    global UIColorWarning


    ; Cancel any queued next cycle.
    SetTimer(
        StartNextQueuedRun,
        0
    )


    SetTimer(
        StartNextQueueJob,
        0
    )


    ClearMacroContinuation()


    queueWasRunning :=
        QueueRunning


    RepeatRunRemaining :=
        0


    MacroRunning :=
        false


    if RunningPid {

        ; Record the user's explicit stop request in the child run log
        ; before terminating the strategy process.
        LogManualRunStopByPid(
            RunningPid,
            "USER CLOSED RUN MANUALLY"
        )


        try {
            if ProcessExist(
                RunningPid
            ) {

                ProcessClose(
                    RunningPid
                )
            }
        }
    }


    RunningPid :=
        0


    ClearChildRunResult(ActiveRunToken)
    ActiveRunToken := ""


    if CycleStatusGui {

        CycleStatusText.Text :=
            queueWasRunning
            ? "QUEUE CANCELLED"
            : "CYCLES CANCELLED"


        CycleProgressText.Text :=
            "STOPPED"
    }


    Sleep(
        250
    )


    HideCycleStatusUI()


    ClearRepeatRunState()
    ClearQueueExecutionState()


    try {
        ClearCycleStopRequest()
    }


    ForceLauncherVisible :=
        true


    ClearLauncherReturnPending()
    SetLauncherRunSuppressed(false)


    UpdateStatus(
        queueWasRunning
        ? "QUEUE CANCELLED"
        : "CYCLES CANCELLED",
        UIColorWarning
    )


    ShowLauncher(
        true
    )
}



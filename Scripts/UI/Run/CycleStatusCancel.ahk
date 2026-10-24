#Requires AutoHotkey v2.0

; Stops active work and retires the HUD without allowing old timers to revive it.
; The emergency hotkey bypasses confirmation but follows the same shutdown path.

CompleteCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText

    global CycleProgressText
    global CycleProgressBar

    global RepeatRunTotal

    global QueueRunning
    global QueueTotalRuns
    global CycleStatusClosing


    if CycleStatusClosing {
        return
    }


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
    global CycleStatusHudEnabled
    global CycleStatusSuppressedForMapClick


    CycleStatusHudEnabled := false


    SetTimer(
        UpdateCycleStatusPosition,
        0
    )


    SetTimer(
        MonitorCycleStatusClickGuard,
        0
    )


    SetCycleStatusClickGuardActive(false)
    ClearCycleStatusClickGuardRequest()
    CycleStatusSuppressedForMapClick := false


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


DestroyCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText
    global CycleCancelButton
    global CycleProgressText
    global CycleProgressBar
    global CycleProgressBackground
    global CycleStatusClosing


    ; Block every HUD timer/update before hiding or destroying the window.
    ; This is important between repeated cycles, where continuation timers can
    ; otherwise overlap the cancellation for a moment.
    CycleStatusClosing := true


    ; A cancelled run should remove the HUD completely. Destroying it avoids
    ; any pending UI/timer work making a previously hidden HUD visible again.
    HideCycleStatusUI()


    if CycleStatusGui {
        try CycleStatusGui.Destroy()
    }


    CycleStatusGui := ""
    CycleStatusText := ""
    CycleCancelButton := ""
    CycleProgressText := ""
    CycleProgressBar := ""
    CycleProgressBackground := ""
}


EmergencyStopMacro(*) {
    global MacroRunning
    global RunningPid
    global QueueRunning


    if !MacroRunning && !QueueRunning && !RunningPid {
        return
    }


    ; The emergency hotkey intentionally skips the normal CLOSE RUN
    ; confirmation so the active strategy/queue can be stopped at once.
    try CloseThemedConfirmation()


    CancelMacroCycles()
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
    global CycleStatusClosing

    global UIColorWarning


    ; Freeze the HUD first. A multi-cycle run can be between child processes
    ; when the stop hotkey is pressed, so stale position/click-guard timers
    ; must be prevented from drawing it again during cancellation.
    CycleStatusClosing := true


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
        stoppedPid := RunningPid

        ; Record the user's explicit stop request in the child run log
        ; before terminating the strategy process.
        LogManualRunStopByPid(
            stoppedPid,
            "USER CLOSED RUN MANUALLY"
        )


        try {
            if ProcessExist(
                stoppedPid
            ) {

                ProcessClose(
                    stoppedPid
                )
                ProcessWaitClose(stoppedPid, 1)
            }
        }

        ; A killed child cannot send the Up half of a held input. Wait for its
        ; exit first, and do not release keys owned by a newly started run.
        if !ProcessExist(stoppedPid) && !MacroRunning && RunningPid = stoppedPid
            ReleaseMacroModifierKeys(true)
    }


    RunningPid :=
        0


    ClearChildRunResult(ActiveRunToken)
    ActiveRunToken := ""


    ; Remove the cancelled HUD immediately. The launcher already shows the
    ; cancellation status, so the run HUD does not need to linger.
    DestroyCycleStatusUI()


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

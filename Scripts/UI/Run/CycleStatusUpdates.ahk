#Requires AutoHotkey v2.0

; Refreshes cycle text and progress for individual runs and queued jobs.
; The shutdown guard keeps late progress updates from redrawing a cancelled HUD.

UpdateCycleStatusUI() {
    global CycleStatusGui
    updatingGui := CycleStatusGui
    ; The click-guard timer may hide this window. Finish this small paint
    ; transaction before yielding so restoring redraw cannot undo its hide.
    previousCritical := A_IsCritical
    Critical("On")
    try {
        BeginUIUpdate(updatingGui)
        try UpdateCycleStatusControls()
        finally EndUIUpdate(updatingGui)
    }
    finally Critical(previousCritical)
}

UpdateCycleStatusControls() {
    global CycleStatusGui
    global CycleStatusText

    global CycleProgressText
    global CycleProgressBar
    global CycleProgressBackground

    global RepeatRunTotal
    global RepeatRunCompleted

    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs
    global QueueTotalRuns
    global QueueCompletedRuns
    global QueueCurrentRetryCount
    global CycleStatusClosing
    global CollectionEventRunActive


    ; Once cancellation starts, stale monitor/timer work must not redraw the
    ; HUD while it is being removed.
    if CycleStatusClosing {
        return
    }


    if !CycleStatusGui {
        return
    }


    ; Open-ended runs share the same themed HUD as counted runs. A completed
    ; counter is useful here; a percentage would imply an end that does not exist.
    if (CollectionEventRunActive && !QueueRunning) || RepeatRunTotal = -1 {
        CycleStatusText.Text := QueueRunning
            ? "JOB " . QueueActiveJobIndex . " / " . QueueTotalJobs . " - CONTINUOUS"
            : "CONTINUOUS"
        CycleProgressText.Text := RepeatRunCompleted . " RUN"
            . (RepeatRunCompleted = 1 ? "" : "S") . " COMPLETED"
        if QueueCurrentRetryCount > 0
            CycleProgressText.Text .= " | RETRY " . QueueCurrentRetryCount . " / " . GetQueueRetryLimit()
        CycleProgressBar.Visible := false
        CycleProgressBackground.Visible := false
        return
    }

    CycleProgressBar.Visible := true
    CycleProgressBackground.Visible := true

    if RepeatRunTotal < 1 {
        return
    }


    currentCycle :=
        RepeatRunCompleted
        + 1


    if currentCycle > RepeatRunTotal {

        currentCycle :=
            RepeatRunTotal
    }


    if currentCycle < 1 {

        currentCycle :=
            1
    }


    if QueueRunning {

        ; A later infinite job makes the queue total open-ended. While this
        ; job is finite, show its own remaining runs and progress instead.
        runsLeft := QueueTotalRuns = -1
            ? RepeatRunTotal - RepeatRunCompleted
            : QueueTotalRuns - QueueCompletedRuns


        if runsLeft < 0 {
            runsLeft := 0
        }


        if QueueTotalRuns = -1 {
            progress := Floor(RepeatRunCompleted / RepeatRunTotal * 100)
        }
        else if QueueTotalRuns > 0 {

            progress :=
                Floor(
                    (
                        QueueCompletedRuns
                        / QueueTotalRuns
                    )
                    * 100
                )
        }
        else {

            progress := 0
        }


        CycleStatusText.Text :=
            "JOB "
            . QueueActiveJobIndex
            . " / "
            . QueueTotalJobs
            . "  -  CYCLE "
            . currentCycle
            . " / "
            . RepeatRunTotal




        if QueueTotalRuns = -1 {
            CycleProgressText.Text := runsLeft . " RUN"
                . (runsLeft = 1 ? "" : "S") . " LEFT IN JOB"
        }
        else if runsLeft = 1 {

            CycleProgressText.Text :=
                "1 TOTAL RUN LEFT"
        }
        else {

            CycleProgressText.Text :=
                runsLeft
                . " TOTAL RUNS LEFT"
        }
    }
    else {

        cyclesLeft :=
            RepeatRunTotal
            - RepeatRunCompleted


        if cyclesLeft < 0 {

            cyclesLeft :=
                0
        }


        progress :=
            Floor(
                (
                    RepeatRunCompleted
                    / RepeatRunTotal
                )
                * 100
            )


        CycleStatusText.Text :=
            "CYCLE "
            . currentCycle
            . " / "
            . RepeatRunTotal




        if cyclesLeft = 1 {

            CycleProgressText.Text :=
                "1 CYCLE LEFT"
        }
        else {

            CycleProgressText.Text :=
                cyclesLeft
                . " CYCLES LEFT"
        }
    }


    ; Keep retry details on the body line so long queue/cycle counts do not
    ; wrap the compact heading into a clipped second line.
    if QueueCurrentRetryCount > 0
        CycleProgressText.Text .= " | RETRY " . QueueCurrentRetryCount . " / " . GetQueueRetryLimit()

    if progress < 0 {

        progress :=
            0
    }


    if progress > 100 {

        progress :=
            100
    }


    CycleProgressBar.Value :=
        progress
}

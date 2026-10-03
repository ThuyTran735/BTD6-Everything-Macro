#Requires AutoHotkey v2.0

; v3 file note: Refreshes the HUD text and progress while a run is active.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

UpdateCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText

    global CycleProgressText
    global CycleProgressBar

    global RepeatRunTotal
    global RepeatRunCompleted

    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs
    global QueueTotalRuns
    global QueueCompletedRuns
    global QueueCurrentRetryCount


    if !CycleStatusGui {
        return
    }


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

        runsLeft :=
            QueueTotalRuns
            - QueueCompletedRuns


        if runsLeft < 0 {
            runsLeft := 0
        }


        if QueueTotalRuns > 0 {

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


        if QueueCurrentRetryCount > 0 {
            CycleStatusText.Text .=
                "  -  RETRY "
                . QueueCurrentRetryCount
                . " / "
                . GetQueueRetryLimit()
        }


        if runsLeft = 1 {

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


        if QueueCurrentRetryCount > 0 {
            CycleStatusText.Text .=
                "  -  RETRY "
                . QueueCurrentRetryCount
                . " / "
                . GetQueueRetryLimit()
        }


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



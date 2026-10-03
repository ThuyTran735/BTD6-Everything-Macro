#Requires AutoHotkey v2.0

; v3 file note: Loads individual queue jobs, advances the queue, and clears execution state.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

LoadQueueJob(
    jobIndex
) {
    global MacroJobQueue

    global QueueCurrentJobLabel
    global QueueCurrentRetryCount

    global RepeatScriptPath
    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted


    if (
        jobIndex < 1
        || jobIndex > MacroJobQueue.Length
    ) {
        return false
    }


    job :=
        MacroJobQueue[
            jobIndex
        ]


    if !FileExist(
        job.path
    ) {
        return false
    }


    RepeatScriptPath :=
        job.path


    RepeatRunTotal :=
        job.runs


    RepeatRunRemaining :=
        job.runs


    RepeatRunCompleted :=
        0


    QueueCurrentJobLabel :=
        job.label


    QueueCurrentRetryCount := 0


    return true
}


StartNextQueueJob() {
    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs
    global QueueCompletedJobs

    global MacroRunning

    global UIColorWarning
    global UIColorError


    if !QueueRunning {
        return false
    }


    if !MacroRunning {
        return false
    }


    QueueCompletedJobs :=
        QueueActiveJobIndex


    if QueueActiveJobIndex >= QueueTotalJobs {
        return false
    }


    QueueActiveJobIndex++


    if !LoadQueueJob(
        QueueActiveJobIndex
    ) {

        MacroRunning := false


        ClearQueueExecutionState()


        HideCycleStatusUI()
        ClearRepeatRunState()


        ClearLauncherReturnPending()
        SetLauncherRunSuppressed(false)


        UpdateStatus(
            "QUEUE SCRIPT NOT FOUND",
            UIColorError
        )


        RecordRunHistoryFailure(
            "QUEUE SCRIPT NOT FOUND"
        )


        ShowLauncher(
            true
        )


        return false
    }


    UpdateStatus(
        "STARTING JOB "
        . QueueActiveJobIndex
        . " OF "
        . QueueTotalJobs
        . "...",
        UIColorWarning
    )


    UpdateCycleStatusUI()


    return StartNextQueuedRun()
}


ClearQueueExecutionState() {
    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs
    global QueueCompletedJobs
    global QueueTotalRuns
    global QueueCompletedRuns
    global QueueCurrentJobLabel
    global QueueCurrentRetryCount


    QueueRunning := false
    QueueActiveJobIndex := 0
    QueueTotalJobs := 0
    QueueCompletedJobs := 0
    QueueTotalRuns := 0
    QueueCompletedRuns := 0
    QueueCurrentJobLabel := ""
    QueueCurrentRetryCount := 0
}
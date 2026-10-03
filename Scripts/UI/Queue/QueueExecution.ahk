#Requires AutoHotkey v2.0

; v3 file note: Starts queue execution and sets up the current queue run.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

StartMacroQueue(*) {
    global MacroJobQueue

    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs
    global QueueCompletedJobs
    global QueueTotalRuns
    global QueueCompletedRuns
    global QueueCurrentJobLabel
    global QueueCurrentRetryCount

    global MacroRunning
    global LauncherGui
    global ForceLauncherVisible

    global UIColorError


    if MacroRunning {
        return false
    }


    if MacroJobQueue.Length = 0 {
        return false
    }


    SetRunHistoryCurrentSource(
        QueueHistorySource
    )


    totalRuns := 0


    for job in MacroJobQueue {

        if !FileExist(
            job.path
        ) {

            UpdateStatus(
                "QUEUE SCRIPT NOT FOUND",
                UIColorError
            )


            RecordRunHistoryFailure(
                "QUEUE SCRIPT NOT FOUND"
            )


            return false
        }


        totalRuns +=
            job.runs
    }


    CloseQueueManager()
    CloseQueueJobBuilder()
    CloseContextHelp()
    CloseAllDarkDropdowns()
    HideLauncher()
    CloseModePicker()
    CloseScriptPicker()


    ClearMacroContinuation()
    ClearCycleStopRequest()


    QueueRunning := true
    QueueActiveJobIndex := 1
    QueueTotalJobs := MacroJobQueue.Length
    QueueCompletedJobs := 0
    QueueTotalRuns := totalRuns
    QueueCompletedRuns := 0
    QueueCurrentJobLabel := ""
    QueueCurrentRetryCount := 0


    if !LoadQueueJob(
        QueueActiveJobIndex
    ) {

        RecordRunHistoryFailure(
            "QUEUE JOB COULD NOT LOAD"
        )

        ClearQueueExecutionState()

        return false
    }


    ForceLauncherVisible := false


    ClearLauncherReturnPending()
    SetLauncherRunSuppressed(true)


    MacroRunning := true


    LauncherGui.Hide()


    RunStartupLoadingAnimation()


    LauncherGui.Hide()


    ShowCycleStatusUI()


    return StartNextQueuedRun()
}



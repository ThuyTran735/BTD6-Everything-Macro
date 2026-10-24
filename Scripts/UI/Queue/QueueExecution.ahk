#Requires AutoHotkey v2.0

; Validates the whole queue before handing its first job to the run loop.
; Queue totals are initialized once here so the HUD can report overall progress.

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


    totalRuns := 0


    ; Catch missing scripts before changing run state or hiding the launcher.
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


        totalRuns := CombineRunCounts(totalRuns, job.runs)
    }


    ; Show the Monkey Knowledge warning before an unattended queue begins.
    ; One warning covers every Expert Impoppable job in this queue.
    if (
        QueueContainsExpertImpoppableScript(MacroJobQueue)
        && !ShowExpertImpoppableWarningIfNeeded()
    ) {
        return false
    }


    SetRunHistoryCurrentSource(
        QueueHistorySource
    )


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

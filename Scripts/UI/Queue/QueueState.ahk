#Requires AutoHotkey v2.0

; v3 file note: Keeps queue globals and the add-job/history-source helpers together.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.


global MacroJobQueue := []

global QueueGui := ""
global QueueList := ""
global QueueCountText := ""
global QueueStartButton := ""

global QueueRunning := false
global QueueActiveJobIndex := 0
global QueueTotalJobs := 0
global QueueCompletedJobs := 0
global QueueTotalRuns := 0
global QueueCompletedRuns := 0
global QueueCurrentJobLabel := ""
global QueueCurrentRetryCount := 0
global QueueHistorySource := "CUSTOM QUEUE"


SetQueueHistorySource(source := "CUSTOM QUEUE") {
    global QueueHistorySource

    source := Trim(source)
    QueueHistorySource := source != "" ? source : "CUSTOM QUEUE"
}


AddJobToQueue(
    scriptPath,
    label,
    modeName := "",
    runCount := 0
) {
    global MacroJobQueue
    global MacroRunning

    global UIColorSuccess
    global UIColorError


    if MacroRunning {

        UpdateStatus(
            "MACRO ALREADY RUNNING",
            UIColorError
        )


        return false
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


    if runCount < 1 {

        runCount :=
            PromptForRunCount("queue")
    }


    if runCount < 1 {
        return false
    }


    MacroJobQueue.Push(
        {
            path: scriptPath,
            label: label,
            mode: modeName,
            runs: runCount
        }
    )


    SetQueueHistorySource()


    RefreshQueueManager()
    UpdateQueueLauncherButton()


    UpdateStatus(
        "ADDED TO QUEUE - "
        . MacroJobQueue.Length
        . " JOB"
        . (
            MacroJobQueue.Length = 1
            ? ""
            : "S"
        ),
        UIColorSuccess
    )


    return true
}



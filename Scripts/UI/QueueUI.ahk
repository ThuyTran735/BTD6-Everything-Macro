#Requires AutoHotkey v2.0


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


ShowQueueManager(*) {
    global QueueGui
    global QueueList
    global QueueCountText
    global QueueStartButton

    global MacroRunning

    global UIColorBackground
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorMutedText
    global UIColorAccent


    if MacroRunning {
        return
    }


    CloseAllDarkDropdowns()
    CloseModePicker()
    CloseScriptPicker()
    CloseQueueJobBuilder()
    CloseContextHelp()


    try {
        if QueueGui
            QueueGui.Destroy()
    }


    QueueGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Macro Queue"
    )


    QueueGui.BackColor :=
        UIColorBackground


    QueueGui.Add(
        "Progress",
        "x0 y0 w620 h4 c"
        . UIColorAccent
        . " Background"
        . UIColorAccent
        . " Disabled",
        100
    )


    AddUIOutlinedText(
        QueueGui,
        "MACRO QUEUE",
        20,
        18,
        580,
        34,
        13,
        "Center"
    )


    CreateHelpBadgeForHeader(
        QueueGui,
        620,
        "MACRO QUEUE",
        "The queue runs jobs from top to bottom. Each job keeps its own script and run count. When one job finishes, the next job starts automatically after BTD6 is ready at the Home screen."
    )


    SetUIBodyFont(
        QueueGui,
        9,
        UIColorSecondaryText
    )


    QueueGui.Add(
        "Text",
        "x20 y55 w580 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Jobs run from top to bottom and automatically continue to the next job"
    )


    SetUIBodyBoldFont(
        QueueGui,
        8,
        UIColorMutedText
    )


    QueueCountText :=
        QueueGui.Add(
            "Text",
            "x20 y82 w580 h18 Center c"
            . UIColorMutedText
            . " BackgroundTrans",
            "0 JOBS  -  0 TOTAL RUNS"
        )


    QueueList :=
        CreateDarkList(
            QueueGui,
            20,
            110,
            580,
            252,
            [],
            36
        )


    moveUpButton :=
        CreateDarkButton(
            QueueGui,
            20,
            382,
            135,
            38,
            "MOVE UP",
            8
        )


    moveDownButton :=
        CreateDarkButton(
            QueueGui,
            165,
            382,
            135,
            38,
            "MOVE DOWN",
            8
        )


    removeButton :=
        CreateDarkButton(
            QueueGui,
            310,
            382,
            135,
            38,
            "REMOVE",
            8
        )


    clearButton :=
        CreateDarkButton(
            QueueGui,
            455,
            382,
            145,
            38,
            "CLEAR ALL",
            8
        )


    QueueStartButton :=
        CreateDarkButton(
            QueueGui,
            20,
            436,
            250,
            44,
            "START QUEUE",
            9
        )


    profilesButton :=
        CreateDarkButton(
            QueueGui,
            280,
            436,
            150,
            44,
            "PROFILES",
            9
        )


    closeButton :=
        CreateDarkButton(
            QueueGui,
            440,
            436,
            160,
            44,
            "CLOSE",
            9
        )


    CreateHelpBadgeForButton(
        QueueGui,
        moveUpButton,
        "MOVE UP",
        "Moves the selected queue job one position earlier. Use this to control which jobs run first."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        moveDownButton,
        "MOVE DOWN",
        "Moves the selected queue job one position later. The queue always runs from top to bottom."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        removeButton,
        "REMOVE",
        "Removes only the currently selected job from the queue. Other queued jobs are left unchanged."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        clearButton,
        "CLEAR ALL",
        "Removes every job from the queue. This does not delete any .ahk files from your project."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        QueueStartButton,
        "START QUEUE",
        "Starts the complete queue from the first job. Each job runs for its configured number of cycles before the next job begins."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        profilesButton,
        "QUEUE PROFILES",
        "Opens saved Queue Profiles. Save the current queue with a name, load it later, update or rename it, delete it, and favorite profiles so they stay at the top."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        closeButton,
        "CLOSE",
        "Closes the Queue Manager. Your queued jobs stay saved in the launcher until you remove them or exit the macro."
    )


    moveUpButton.OnEvent(
        "Click",
        (*) => MoveQueueJob(-1)
    )


    moveDownButton.OnEvent(
        "Click",
        (*) => MoveQueueJob(1)
    )


    removeButton.OnEvent(
        "Click",
        RemoveSelectedQueueJob
    )


    clearButton.OnEvent(
        "Click",
        ClearMacroQueue
    )


    QueueStartButton.OnEvent(
        "Click",
        StartMacroQueue
    )


    profilesButton.OnEvent(
        "Click",
        ShowQueueProfilesManager
    )


    closeButton.OnEvent(
        "Click",
        CloseQueueManager
    )


    QueueGui.OnEvent(
        "Close",
        CloseQueueManager
    )


    QueueGui.OnEvent(
        "Escape",
        CloseQueueManager
    )


    QueueGui.Show(
        "Hide w620 h500"
    )


    ApplyDarkWindowStyle(
        QueueGui
    )


    RefreshQueueManager()


    QueueGui.Show(
        "w620 h500 Center"
    )
}


RefreshQueueManager() {
    global MacroJobQueue
    global QueueGui
    global QueueList
    global QueueCountText
    global QueueStartButton


    if !QueueGui {
        return
    }


    if !QueueList {
        return
    }


    selectedIndex :=
        QueueList.Value


    rows := []
    totalRuns := 0


    for index, job in MacroJobQueue {

        totalRuns +=
            job.runs


        rows.Push(
            index
            . ".  "
            . job.label
            . "    x"
            . job.runs
        )
    }


    QueueList.Delete()


    if rows.Length > 0 {

        QueueList.Add(
            rows
        )


        if selectedIndex < 1 {
            selectedIndex := 1
        }


        if selectedIndex > rows.Length {
            selectedIndex := rows.Length
        }


        QueueList.Choose(
            selectedIndex
        )
    }


    if QueueCountText {

        QueueCountText.Text :=
            MacroJobQueue.Length
            . " JOB"
            . (
                MacroJobQueue.Length = 1
                ? ""
                : "S"
            )
            . "  -  "
            . totalRuns
            . " TOTAL RUN"
            . (
                totalRuns = 1
                ? ""
                : "S"
            )
    }


    if QueueStartButton {

        QueueStartButton.Enabled :=
            MacroJobQueue.Length > 0
    }
}


UpdateQueueLauncherButton() {
    global MacroJobQueue
    global QueueButton
    global RunButton
    global CurrentMode
    global MonkeyExpTypeDropdown


    if QueueButton {

        QueueButton.Text :=
            "QUEUE ("
            . MacroJobQueue.Length
            . ")"
    }


    if !RunButton {
        return
    }


    ; A populated queue always owns the primary Run action, even
    ; if the launcher is currently displaying a mode that cannot
    ; run by itself yet.
    if MacroJobQueue.Length > 0 {

        RunButton.Text :=
            "RUN QUEUE"


        RunButton.Enabled :=
            true


        return
    }


    RunButton.Text :=
        "RUN MACRO"


    if CurrentMode = "Monkey Money Grind" {

        RunButton.Enabled :=
            false


        return
    }


    if CurrentMode = "Monkey EXP Grind" {

        if MonkeyExpTypeDropdown {
            RunButton.Enabled :=
                GetMonkeyExpScripts(
                    MonkeyExpTypeDropdown.Text
                ).Length > 0
        }
        else {
            RunButton.Enabled := false
        }


        return
    }


    RunButton.Enabled :=
        true
}


MoveQueueJob(
    direction
) {
    global MacroJobQueue
    global QueueList


    if !QueueList {
        return
    }


    selectedIndex :=
        QueueList.Value


    if selectedIndex < 1 {
        return
    }


    targetIndex :=
        selectedIndex
        + direction


    if (
        targetIndex < 1
        || targetIndex > MacroJobQueue.Length
    ) {
        return
    }


    temp :=
        MacroJobQueue[
            selectedIndex
        ]


    MacroJobQueue[
        selectedIndex
    ] :=
        MacroJobQueue[
            targetIndex
        ]


    MacroJobQueue[
        targetIndex
    ] :=
        temp


    RefreshQueueManager()


    QueueList.Choose(
        targetIndex
    )
}


RemoveSelectedQueueJob(*) {
    global MacroJobQueue
    global QueueList


    if !QueueList {
        return
    }


    selectedIndex :=
        QueueList.Value


    if (
        selectedIndex < 1
        || selectedIndex > MacroJobQueue.Length
    ) {
        return
    }


    MacroJobQueue.RemoveAt(
        selectedIndex
    )


    RefreshQueueManager()
    UpdateQueueLauncherButton()
}


ClearMacroQueue(*) {
    global MacroJobQueue


    MacroJobQueue := []


    RefreshQueueManager()
    UpdateQueueLauncherButton()
}


CloseQueueManager(*) {
    global QueueGui
    global QueueList
    global QueueCountText
    global QueueStartButton


    try {
        if QueueGui
            QueueGui.Destroy()
    }


    QueueGui := ""
    QueueList := ""
    QueueCountText := ""
    QueueStartButton := ""
}


StartMacroQueue(*) {
    global MacroJobQueue

    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs
    global QueueCompletedJobs
    global QueueTotalRuns
    global QueueCompletedRuns
    global QueueCurrentJobLabel

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


    for job in MacroJobQueue {

        if !FileExist(
            job.path
        ) {

            UpdateStatus(
                "QUEUE SCRIPT NOT FOUND",
                UIColorError
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


    if !LoadQueueJob(
        QueueActiveJobIndex
    ) {

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


LoadQueueJob(
    jobIndex
) {
    global MacroJobQueue

    global QueueCurrentJobLabel

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


    QueueRunning := false
    QueueActiveJobIndex := 0
    QueueTotalJobs := 0
    QueueCompletedJobs := 0
    QueueTotalRuns := 0
    QueueCompletedRuns := 0
    QueueCurrentJobLabel := ""
}
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
    CloseAllSecondaryMenus()
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


    EnableCustomWindowChrome(QueueGui)
    AddCustomWindowBorder(QueueGui, 620, 500)


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
        "Your queue runs from top to bottom.`n`nEach job keeps its own script and run count. After one job finishes, the next starts when BTD6 is back at the Home screen."
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
            108,
            38,
            "MOVE UP",
            8
        )


    moveDownButton :=
        CreateDarkButton(
            QueueGui,
            138,
            382,
            108,
            38,
            "MOVE DOWN",
            8
        )


    editButton :=
        CreateDarkButton(
            QueueGui,
            256,
            382,
            108,
            38,
            "EDIT JOB",
            8
        )


    removeButton :=
        CreateDarkButton(
            QueueGui,
            374,
            382,
            108,
            38,
            "REMOVE",
            8
        )


    clearButton :=
        CreateDarkButton(
            QueueGui,
            492,
            382,
            108,
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
            "BACK",
            9
        )


    CreateHelpBadgeForButton(
        QueueGui,
        moveUpButton,
        "MOVE UP",
        "Moves the selected job up one spot.`n`nJobs closer to the top run sooner."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        moveDownButton,
        "MOVE DOWN",
        "Moves the selected job down one spot.`n`nJobs closer to the bottom run later."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        editButton,
        "EDIT JOB",
        "Edits the selected job without removing it.`n`nYou can change its type, map or script, and run count."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        removeButton,
        "REMOVE",
        "Removes only the selected job.`n`nThe rest of the queue stays unchanged."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        clearButton,
        "CLEAR ALL",
        "Removes every job from the current queue.`n`nYour scripts and saved Queue Profiles are not deleted."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        QueueStartButton,
        "START QUEUE",
        "Starts the queue from the first job.`n`nEach job finishes its configured runs before the next job begins."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        profilesButton,
        "QUEUE PROFILES",
        "Opens Queue Profiles.`n`nUse profiles to save a queue, load it later, update it, rename it, export it, or favorite it."
    )


    CreateHelpBadgeForButton(
        QueueGui,
        closeButton,
        "BACK",
        "Returns to the launcher.`n`nYour current queue stays loaded until you clear it or close the macro."
    )


    moveUpButton.OnEvent(
        "Click",
        (*) => MoveQueueJob(-1)
    )


    moveDownButton.OnEvent(
        "Click",
        (*) => MoveQueueJob(1)
    )


    editButton.OnEvent(
        "Click",
        EditSelectedQueueJob
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
        OpenQueueProfilesFromQueue
    )


    closeButton.OnEvent(
        "Click",
        CloseQueueManagerAndReturnToLauncher
    )


    QueueGui.OnEvent(
        "Close",
        CloseQueueManagerAndReturnToLauncher
    )


    QueueGui.OnEvent(
        "Escape",
        CloseQueueManagerAndReturnToLauncher
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
            "START QUEUE"


        RunButton.Enabled :=
            true


        return
    }


    if CurrentMode = "Default" {

        RunButton.Text :=
            "SELECT SCRIPT"
    }
    else if CurrentMode = "Monkey EXP Grind" {

        RunButton.Text :=
            "START EXP GRIND"
    }
    else {

        RunButton.Text :=
            "MODE UNAVAILABLE"
    }


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


    SetQueueHistorySource()


    RefreshQueueManager()


    QueueList.Choose(
        targetIndex
    )
}


EditSelectedQueueJob(*) {
    global MacroJobQueue
    global QueueList

    if !QueueList {
        return
    }

    selectedIndex := QueueList.Value

    if (
        selectedIndex < 1
        || selectedIndex > MacroJobQueue.Length
    ) {
        return
    }

    OpenQueueJobBuilderForEdit(
        selectedIndex
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


    SetQueueHistorySource()


    RefreshQueueManager()
    UpdateQueueLauncherButton()
}


ClearMacroQueue(*) {
    global MacroJobQueue
    global QueueGui


    if MacroJobQueue.Length = 0 {
        return
    }


    ShowThemedConfirmation(
        "CLEAR QUEUE?",
        "Remove all " . MacroJobQueue.Length . " queued job(s)?`n`nThis only clears the current queue. Saved Queue Profiles are not deleted.",
        "CLEAR QUEUE",
        ClearMacroQueueConfirmed,
        QueueGui,
        "Removes every job from the current queue. Saved Queue Profiles and .ahk files remain unchanged."
    )
}


ClearMacroQueueConfirmed(*) {
    global MacroJobQueue


    MacroJobQueue := []


    SetQueueHistorySource()


    RefreshQueueManager()
    UpdateQueueLauncherButton()
}


OpenQueueProfilesFromQueue(*) {
    CloseQueueManager()
    ShowQueueProfilesManager()
}


CloseQueueManagerAndReturnToLauncher(*) {
    CloseQueueManager()
    ShowLauncher(true)
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
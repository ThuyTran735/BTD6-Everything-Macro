#Requires AutoHotkey v2.0

; v3 file note: Builds and shows the Queue Manager window.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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
    AddUICard(QueueGui, 14, 76, 592, 298)
    AddUICard(QueueGui, 14, 376, 592, 50)
    AddUICard(QueueGui, 14, 430, 592, 56)


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



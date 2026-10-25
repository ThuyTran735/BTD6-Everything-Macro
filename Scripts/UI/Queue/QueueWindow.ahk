#Requires AutoHotkey v2.0

; Builds the queue view. Job editing and execution stay in their own modules.

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


    if ActivateExistingUIWindow(QueueGui)
        return

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
    AddCustomWindowBorder(QueueGui, 620, 524)
    AddUICard(QueueGui, 24, 88, 572, 300)


    AddUIOutlinedText(
        QueueGui,
        "MACRO QUEUE",
        24,
        24,
        572,
        28,
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
        "x24 y60 w572 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Jobs run from top to bottom and automatically continue to the next job"
    )


    SetUIBodyFont(
        QueueGui,
        8,
        UIColorMutedText
    )


    QueueCountText :=
        QueueGui.Add(
            "Text",
            "x40 y100 w540 h16 Center c"
            . UIColorMutedText
            . " BackgroundTrans",
            "0 JOBS  -  0 TOTAL RUNS"
        )


    QueueList :=
        CreateDarkList(
            QueueGui,
            40,
            124,
            540,
            252,
            [],
            36
        )


    moveUpButton :=
        CreateDarkButton(
            QueueGui,
            24,
            404,
            104,
            36,
            "MOVE UP",
            8
        )


    moveDownButton :=
        CreateDarkButton(
            QueueGui,
            140,
            404,
            104,
            36,
            "MOVE DOWN",
            8
        )


    editButton :=
        CreateDarkButton(
            QueueGui,
            256,
            404,
            104,
            36,
            "EDIT JOB",
            8
        )


    removeButton :=
        CreateDarkButton(
            QueueGui,
            372,
            404,
            104,
            36,
            "REMOVE",
            8
        )


    clearButton :=
        CreateDarkButton(
            QueueGui,
            488,
            404,
            108,
            36,
            "CLEAR ALL",
            8
        )


    QueueStartButton :=
        CreateDarkButton(
            QueueGui,
            24,
            456,
            248,
            44,
            "START QUEUE",
            9
        )


    profilesButton :=
        CreateDarkButton(
            QueueGui,
            284,
            456,
            144,
            44,
            "PROFILES",
            9
        )


    closeButton :=
        CreateDarkButton(
            QueueGui,
            440,
            456,
            156,
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
        "Hide w620 h524"
    )


    ApplyDarkWindowStyle(
        QueueGui
    )


    RefreshQueueManager()


    QueueGui.Show(
        "w620 h524 Center"
    )
}



#Requires AutoHotkey v2.0


ShowScriptPicker(
    mapName,
    mapDirectory,
    scripts,
    action := "run"
) {
    global ScriptPickerGui
    global ScriptPickerState

    global UIColorBackground
    global UIColorSecondaryText


    CloseAllDarkDropdowns()
    CloseAllSecondaryMenus()


    try {
        if ScriptPickerGui
            ScriptPickerGui.Destroy()
    }


    availableDifficulties := []


    for difficulty in [
        "Easy",
        "Medium",
        "Hard"
    ] {

        if scripts[
            difficulty
        ].Length > 0 {

            availableDifficulties.Push(
                difficulty
            )
        }
    }


    if availableDifficulties.Length = 0 {
        return
    }


    ScriptPickerGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Select Strategy"
    )


    ScriptPickerGui.BackColor :=
        UIColorBackground


    AddUIOutlinedText(
        ScriptPickerGui,
        mapName,
        20,
        16,
        460,
        36,
        12
    )


    SetUIBodyFont(
        ScriptPickerGui,
        9,
        UIColorSecondaryText
    )


    ScriptPickerGui.Add(
        "Text",
        "x20 y50 w460 h20 c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Choose the strategy you want to run"
    )


    difficultyButtons :=
        Map()


    buttonGap := 14


    buttonCount :=
        availableDifficulties.Length


    difficultyWidth :=
        Floor(
            (
                460
                - (
                    buttonGap
                    * (
                        buttonCount - 1
                    )
                )
            )
            / buttonCount
        )


    buttonX := 20


    for difficulty in availableDifficulties {

        difficultyButton :=
            CreateDarkButton(
                ScriptPickerGui,
                buttonX,
                82,
                difficultyWidth,
                34,
                StrUpper(
                    difficulty
                ),
                9
            )


        CreateHelpBadgeForButton(
            ScriptPickerGui,
            difficultyButton,
            StrUpper(difficulty) . " STRATEGIES",
            "Shows only "
            . difficulty
            . " difficulty strategies for this map."
        )


        difficultyButton.OnEvent(
            "Click",
            SetStrategyDifficulty.Bind(
                difficulty
            )
        )


        difficultyButtons[
            difficulty
        ] :=
            difficultyButton


        buttonX +=
            difficultyWidth
            + buttonGap
    }


    strategyList :=
        CreateDarkList(
            ScriptPickerGui,
            20,
            130,
            460,
            180,
            [],
            36
        )


    strategyList.OnEvent(
        "DoubleClick",
        RunPickedScript
    )


    actionButtonText :=
        action = "queue"
        ? "ADD TO QUEUE"
        : "RUN SELECTED"


    runSelectedButton :=
        CreateDarkButton(
            ScriptPickerGui,
            20,
            328,
            220,
            42,
            actionButtonText,
            8
        )


    openFolderButton :=
        CreateDarkButton(
            ScriptPickerGui,
            260,
            328,
            220,
            42,
            "OPEN MAP FOLDER",
            8
        )


    cancelButton :=
        CreateDarkButton(
            ScriptPickerGui,
            20,
            382,
            460,
            38,
            "CLOSE",
            8
        )


    CreateHelpBadgeForButton(
        ScriptPickerGui,
        runSelectedButton,
        action = "queue" ? "ADD TO QUEUE" : "RUN SELECTED",
        action = "queue"
        ? "Adds the selected strategy to the queue.`n`nNext, choose how many times that job should run."
        : "Runs the selected strategy.`n`nNext, choose how many times it should repeat."
    )


    CreateHelpBadgeForButton(
        ScriptPickerGui,
        openFolderButton,
        "OPEN MAP FOLDER",
        "Opens this map's strategy folder in File Explorer.`n`nUse it to view or edit the .ahk strategy files."
    )


    CreateHelpBadgeForButton(
        ScriptPickerGui,
        cancelButton,
        "CLOSE",
        "Closes this window without running or adding a strategy."
    )


    ScriptPickerState := {
        gui: ScriptPickerGui,
        difficultyButtons: difficultyButtons,
        difficulties: availableDifficulties,
        difficulty: availableDifficulties[1],
        list: strategyList,
        scripts: scripts,
        mapDirectory: mapDirectory,
        mapName: mapName,
        action: action
    }


    runSelectedButton.OnEvent(
        "Click",
        RunPickedScript
    )


    openFolderButton.OnEvent(
        "Click",
        OpenSelectedMapFolder
    )


    cancelButton.OnEvent(
        "Click",
        CloseScriptPickerAndReturnToLauncher
    )


    ScriptPickerGui.OnEvent(
        "Close",
        CloseScriptPickerAndReturnToLauncher
    )


    SetStrategyDifficulty(
        availableDifficulties[1]
    )


    ScriptPickerGui.Show(
        "Hide w500 h438"
    )


    ApplyDarkWindowStyle(
        ScriptPickerGui
    )


    ScriptPickerGui.Show(
        "w500 h438 Center"
    )
}


SetStrategyDifficulty(
    difficulty,
    *
) {
    global ScriptPickerState


    if !IsObject(
        ScriptPickerState
    ) {
        return
    }


    if !ScriptPickerState.difficultyButtons.Has(
        difficulty
    ) {
        return
    }


    ScriptPickerState.difficulty :=
        difficulty


    names := []


    for script in ScriptPickerState.scripts[
        difficulty
    ] {

        names.Push(
            script.name
        )
    }


    strategyList :=
        ScriptPickerState.list


    strategyList.Delete()


    strategyList.Add(
        names
    )


    if names.Length > 0 {

        strategyList.Choose(
            1
        )
    }
}


RunPickedScript(*) {
    global ScriptPickerState


    if !IsObject(
        ScriptPickerState
    ) {
        return
    }


    difficulty :=
        ScriptPickerState.difficulty


    if difficulty = "" {
        return
    }


    listControl :=
        ScriptPickerState.list


    selectedIndex :=
        listControl.Value


    if (
        selectedIndex < 1
        || selectedIndex
            > ScriptPickerState.scripts[
                difficulty
            ].Length
    ) {

        ToolTip(
            "Select a script first."
        )


        SetTimer(
            () => ToolTip(),
            -1500
        )


        return
    }


    script :=
        ScriptPickerState.scripts[
            difficulty
        ][
            selectedIndex
        ]


    action :=
        ScriptPickerState.action


    mapName :=
        ScriptPickerState.mapName


    CloseScriptPicker()


    if action = "queue" {

        AddJobToQueue(
            script.path,
            mapName
            . " - "
            . script.name,
            "Default"
        )


        return
    }


    LaunchMapScript(
        script.path
    )
}


OpenSelectedMapFolder(*) {
    global ScriptPickerState


    if !IsObject(
        ScriptPickerState
    ) {
        return
    }


    mapDirectory :=
        ScriptPickerState.mapDirectory


    if !DirExist(
        mapDirectory
    ) {
        return
    }


    command :=
        "explorer.exe "
        . Chr(34)
        . mapDirectory
        . Chr(34)


    Run(
        command
    )
}


CloseScriptPickerAndReturnToLauncher(*) {
    CloseScriptPicker()
    ShowLauncher(true)
}


CloseScriptPicker(*) {
    global ScriptPickerGui
    global ScriptPickerState


    try {
        if ScriptPickerGui
            ScriptPickerGui.Destroy()
    }


    ScriptPickerGui := ""
    ScriptPickerState := ""
}
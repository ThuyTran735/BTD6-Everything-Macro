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


    availableDifficulties := [
        "Easy",
        "Medium",
        "Hard"
    ]


    windowWidth := 520
    windowHeight := 646


    ScriptPickerGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Select Strategy"
    )


    ScriptPickerGui.BackColor := UIColorBackground
    ScriptPickerGui.MarginX := 0
    ScriptPickerGui.MarginY := 0


    EnableCustomWindowChrome(ScriptPickerGui)
    AddCustomWindowBorder(ScriptPickerGui, windowWidth, windowHeight)


    AddUIOutlinedText(
        ScriptPickerGui,
        mapName,
        20,
        18,
        480,
        30,
        12,
        "Center"
    )


    SetUIBodyFont(ScriptPickerGui, 9, UIColorSecondaryText)
    ScriptPickerGui.Add(
        "Text",
        "x20 y52 w480 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Choose a difficulty, then select the strategy file to use"
    )


    ; Difficulty card.
    AddUICard(ScriptPickerGui, 16, 82, 488, 180)
    AddUIOutlinedText(
        ScriptPickerGui,
        "DIFFICULTY",
        30,
        92,
        460,
        20,
        9,
        "Center"
    )


    difficultyList := CreateDarkList(
        ScriptPickerGui,
        30,
        120,
        460,
        108,
        availableDifficulties,
        36
    )


    difficultyList.OnEvent(
        "Change",
        DifficultyListChanged
    )


    ; Strategy card.
    AddUICard(ScriptPickerGui, 16, 272, 488, 230)
    AddUIOutlinedText(
        ScriptPickerGui,
        "STRATEGY FILES",
        30,
        282,
        460,
        20,
        9,
        "Center"
    )


    strategyList := CreateDarkList(
        ScriptPickerGui,
        30,
        310,
        460,
        180,
        [],
        36
    )


    strategyList.OnEvent("DoubleClick", RunPickedScript)


    ; Actions card.
    AddUICard(ScriptPickerGui, 16, 512, 488, 118)


    actionButtonText := action = "queue"
        ? "ADD TO QUEUE"
        : "USE STRATEGY"


    runSelectedButton := CreateDarkButton(
        ScriptPickerGui,
        30,
        526,
        220,
        42,
        actionButtonText,
        8
    )


    openFolderButton := CreateDarkButton(
        ScriptPickerGui,
        270,
        526,
        220,
        42,
        "OPEN MAP FOLDER",
        8
    )


    cancelButton := CreateDarkButton(
        ScriptPickerGui,
        30,
        580,
        460,
        36,
        "CANCEL",
        8
    )


    CreateHelpBadgeForButton(
        ScriptPickerGui,
        runSelectedButton,
        action = "queue" ? "ADD TO QUEUE" : "USE STRATEGY",
        action = "queue"
        ? "Adds the selected strategy to the queue.`n`nNext, choose how many times that job should run."
        : "Uses the selected strategy for this run.`n`nNext, choose how many times it should repeat."
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
        "CANCEL",
        "Returns to the launcher without running or adding a strategy."
    )


    ScriptPickerState := {
        gui: ScriptPickerGui,
        difficultyList: difficultyList,
        difficulties: availableDifficulties,
        difficulty: availableDifficulties[1],
        list: strategyList,
        scripts: scripts,
        mapDirectory: mapDirectory,
        mapName: mapName,
        action: action
    }


    runSelectedButton.OnEvent("Click", RunPickedScript)
    openFolderButton.OnEvent("Click", OpenSelectedMapFolder)
    cancelButton.OnEvent("Click", CloseScriptPickerAndReturnToLauncher)
    ScriptPickerGui.OnEvent("Close", CloseScriptPickerAndReturnToLauncher)


    if !RestoreLastRunStrategySelection() {
        SetStrategyDifficulty(availableDifficulties[1])
    }


    ScriptPickerGui.Show(
        "Hide w"
        . windowWidth
        . " h"
        . windowHeight
    )


    ApplyDarkWindowStyle(ScriptPickerGui)


    ScriptPickerGui.Show(
        "w"
        . windowWidth
        . " h"
        . windowHeight
        . " Center"
    )
}

DifficultyListChanged(listControl, *) {
    global ScriptPickerState


    if !IsObject(ScriptPickerState) {
        return
    }


    selectedIndex := listControl.Value


    if (
        selectedIndex < 1
        || selectedIndex > ScriptPickerState.difficulties.Length
    ) {
        return
    }


    SetStrategyDifficulty(
        ScriptPickerState.difficulties[selectedIndex]
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


    difficultyIndex := 0


    for index, availableDifficulty in ScriptPickerState.difficulties {
        if availableDifficulty = difficulty {
            difficultyIndex := index
            break
        }
    }


    if difficultyIndex = 0 {
        return
    }


    ScriptPickerState.difficulty :=
        difficulty


    difficultyList :=
        ScriptPickerState.difficultyList


    if difficultyList.Value != difficultyIndex {
        difficultyList.Choose(difficultyIndex)
    }


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


RestoreLastRunStrategySelection() {
    global ScriptPickerState

    if !IsObject(ScriptPickerState) {
        return false
    }

    if !IsRememberLauncherStateEnabled() {
        return false
    }

    for difficulty in ScriptPickerState.difficulties {
        scripts := ScriptPickerState.scripts[difficulty]

        for index, script in scripts {
            if !IsRememberedRunStrategy(script.path) {
                continue
            }

            SetStrategyDifficulty(difficulty)
            ScriptPickerState.list.Choose(index)
            return true
        }
    }

    return false
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


    if LaunchMapScript(
        script.path
    ) {
        RememberLastRunStrategy(
            script.path
        )
    }
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
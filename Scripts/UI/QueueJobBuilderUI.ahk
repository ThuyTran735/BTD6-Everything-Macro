#Requires AutoHotkey v2.0


global QueueBuilderGui := ""
global QueueBuilderJobTypeDropdown := ""
global QueueBuilderCategoryDropdown := ""
global QueueBuilderMapDropdown := ""
global QueueBuilderStrategyDropdown := ""
global QueueBuilderExpTypeDropdown := ""
global QueueBuilderExpScriptDropdown := ""
global QueueBuilderMapStrategies := []
global QueueBuilderExpScripts := []

global QueueBuilderCategoryLabel := ""
global QueueBuilderMapLabel := ""
global QueueBuilderStrategyLabel := ""
global QueueBuilderExpTypeLabel := ""
global QueueBuilderExpScriptLabel := ""

global QueueBuilderCategoryHelp := ""
global QueueBuilderMapHelp := ""
global QueueBuilderMapFavoriteHelp := ""
global QueueBuilderStrategyHelp := ""
global QueueBuilderExpTypeHelp := ""
global QueueBuilderExpScriptHelp := ""
global QueueBuilderExpFavoriteHelp := ""

global QueueBuilderMapFavoriteButton := ""
global QueueBuilderExpFavoriteButton := ""

global QueueBuilderEditIndex := 0
global QueueBuilderIsEditing := false


ShowQueueJobBuilder(*) {
    OpenQueueJobBuilder(0)
}


OpenQueueJobBuilderForEdit(editIndex) {
    OpenQueueJobBuilder(editIndex)
}


OpenQueueJobBuilder(editIndex := 0) {
    global QueueBuilderGui
    global QueueBuilderJobTypeDropdown
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyDropdown
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown

    global QueueBuilderCategoryLabel
    global QueueBuilderMapLabel
    global QueueBuilderStrategyLabel
    global QueueBuilderExpTypeLabel
    global QueueBuilderExpScriptLabel

    global QueueBuilderCategoryHelp
    global QueueBuilderMapHelp
    global QueueBuilderMapFavoriteHelp
    global QueueBuilderStrategyHelp
    global QueueBuilderExpTypeHelp
    global QueueBuilderExpScriptHelp
    global QueueBuilderExpFavoriteHelp

    global QueueBuilderMapFavoriteButton
    global QueueBuilderExpFavoriteButton

    global CurrentMode
    global MacroRunning
    global MacroJobQueue
    global QueueBuilderEditIndex
    global QueueBuilderIsEditing

    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText


    if MacroRunning {
        return
    }


    CloseAllSecondaryMenus()

    QueueBuilderEditIndex := editIndex
    QueueBuilderIsEditing := (
        editIndex >= 1
        && editIndex <= MacroJobQueue.Length
    )


    CloseAllDarkDropdowns()
    CloseModePicker()
    CloseScriptPicker()
    CloseQueueManager()
    CloseContextHelp()


    categories :=
        GetConfiguredCategories()


    firstMaps := []


    if (
        categories.Length > 0
        && categories[1] != "No configured categories"
    ) {
        firstMaps :=
            GetMapNamesForCategory(
                categories[1]
            )
    }


    if firstMaps.Length = 0 {
        firstMaps := [
            "No configured maps"
        ]
    }


    QueueBuilderGui :=
        Gui(
            "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
            QueueBuilderIsEditing ? "Edit Queue Job" : "Add Queue Job"
        )


    QueueBuilderGui.BackColor :=
        UIColorBackground


    QueueBuilderGui.Add(
        "Progress",
        "x0 y0 w520 h4 c"
        . UIColorAccent
        . " Background"
        . UIColorAccent
        . " Disabled",
        100
    )


    AddUIOutlinedText(
        QueueBuilderGui,
        QueueBuilderIsEditing ? "EDIT QUEUE JOB" : "ADD QUEUE JOB",
        20,
        18,
        480,
        34,
        13,
        "Center"
    )


    SetUIBodyFont(
        QueueBuilderGui,
        9,
        UIColorSecondaryText
    )


    QueueBuilderGui.Add(
        "Text",
        "x20 y55 w480 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        QueueBuilderIsEditing
        ? "Update this queued job without changing its position"
        : "Choose exactly what should be added to the queue"
    )


    QueueBuilderJobTypeLabel :=
        AddUIOutlinedText(
        QueueBuilderGui,
        "SELECT JOB TYPE",
        30,
        88,
        460,
        22,
        9
    )


    QueueBuilderJobTypeDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            112,
            460,
            [
                "Map Script",
                "Monkey EXP Grind"
            ],
            QueueBuilderIsEditing
            && MacroJobQueue[QueueBuilderEditIndex].mode = "Monkey EXP Grind"
            ? 2
            : (CurrentMode = "Monkey EXP Grind" ? 2 : 1),
            5
        )


    CreateHelpBadgeForField(
        QueueBuilderGui,
        QueueBuilderJobTypeDropdown,
        QueueBuilderJobTypeLabel,
        "JOB TYPE",
        "Choose what kind of job this is.`n`nMAP SCRIPT: choose a map and strategy.`n`nMONKEY EXP GRIND: choose a tower group and EXP script."
    )


    QueueBuilderCategoryLabel :=
        AddUIOutlinedText(
            QueueBuilderGui,
            "SELECT CATEGORY",
            30,
            162,
            460,
            22,
            9
        )


    QueueBuilderCategoryDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            186,
            460,
            categories,
            1,
            5
        )


    QueueBuilderCategoryHelp :=
        CreateHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderCategoryDropdown,
            QueueBuilderCategoryLabel,
            "MAP CATEGORY",
            "Choose the map category for this job.`n`nThe Map list updates automatically to show maps from that category."
        )


    QueueBuilderMapLabel :=
        AddUIOutlinedText(
            QueueBuilderGui,
            "SELECT MAP",
            30,
            236,
            460,
            22,
            9
        )


    QueueBuilderMapDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            260,
            460,
            firstMaps,
            1,
            5
        )


    QueueBuilderMapHelp :=
        CreateHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderMapDropdown,
            QueueBuilderMapLabel,
            "MAP",
            "Choose the map for this job.`n`nOnly maps with a usable strategy are shown. Changing the map also updates the Strategy list."
        )


    QueueBuilderStrategyLabel :=
        AddUIOutlinedText(
            QueueBuilderGui,
            "SELECT STRATEGY",
            30,
            310,
            460,
            22,
            9
        )


    QueueBuilderStrategyDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            334,
            460,
            [
                "No strategies found"
            ],
            1,
            5
        )


    QueueBuilderStrategyHelp :=
        CreateHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderStrategyDropdown,
            QueueBuilderStrategyLabel,
            "STRATEGY",
            "Choose the strategy this job should run.`n`nThe difficulty appears before the filename to make similar scripts easier to tell apart."
        )


    QueueBuilderExpTypeLabel :=
        AddUIOutlinedText(
            QueueBuilderGui,
            "SELECT TOWER TYPE",
            30,
            162,
            460,
            22,
            9,
            "Left",
            false
        )


    QueueBuilderExpTypeDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            186,
            460,
            GetMonkeyExpTowerTypes(),
            1,
            5
        )


    QueueBuilderExpTypeDropdown.Visible :=
        false


    QueueBuilderExpTypeHelp :=
        CreateHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderExpTypeDropdown,
            QueueBuilderExpTypeLabel,
            "TOWER TYPE",
            "Choose Primary, Military, Magic, or Support.`n`nThe Tower Script list updates to show scripts from that group."
        )


    QueueBuilderExpTypeHelp.Visible :=
        false


    QueueBuilderExpScriptLabel :=
        AddUIOutlinedText(
            QueueBuilderGui,
            "SELECT TOWER",
            30,
            236,
            460,
            22,
            9,
            "Left",
            false
        )


    QueueBuilderExpScriptDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            260,
            460,
            [
                "No Monkey EXP scripts found"
            ],
            1,
            5
        )


    QueueBuilderExpScriptDropdown.Visible :=
        false


    QueueBuilderExpScriptHelp :=
        CreateHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderExpScriptDropdown,
            QueueBuilderExpScriptLabel,
            "TOWER SCRIPT",
            "Choose the exact Monkey EXP Grind script for this job.`n`nThe .ahk extension stays visible so you know exactly which file will run."
        )


    QueueBuilderExpScriptHelp.Visible :=
        false


    QueueBuilderMapFavoriteButton :=
        CreateFavoriteButtonForField(
            QueueBuilderGui,
            QueueBuilderMapDropdown
        )


    QueueBuilderMapFavoriteButton.OnEvent(
        "Click",
        ToggleQueueBuilderMapFavorite
    )


    QueueBuilderMapFavoriteHelp :=
        CreateFavoriteHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderMapDropdown,
            "FAVORITES",
            "Click ☆ to favorite the selected map.`n`n★ means it is already a favorite. Favorites move to the top of map lists."
        )


    QueueBuilderExpFavoriteButton :=
        CreateFavoriteButtonForField(
            QueueBuilderGui,
            QueueBuilderExpScriptDropdown
        )


    QueueBuilderExpFavoriteButton.OnEvent(
        "Click",
        ToggleQueueBuilderExpFavorite
    )


    QueueBuilderExpFavoriteHelp :=
        CreateFavoriteHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderExpScriptDropdown,
            "FAVORITES",
            "Click ☆ to favorite the selected EXP script.`n`n★ means it is already a favorite. Favorites move to the top of EXP script lists."
        )


    QueueBuilderExpFavoriteButton.Visible := false
    QueueBuilderExpFavoriteHelp.Visible := false


    addButton :=
        CreateDarkButton(
            QueueBuilderGui,
            30,
            404,
            290,
            46,
            QueueBuilderIsEditing ? "SAVE CHANGES" : "ADD TO QUEUE",
            9
        )


    cancelButton :=
        CreateDarkButton(
            QueueBuilderGui,
            335,
            404,
            155,
            46,
            "CLOSE",
            9
        )


    CreateHelpBadgeForButton(
        QueueBuilderGui,
        addButton,
        QueueBuilderIsEditing ? "SAVE CHANGES" : "ADD TO QUEUE",
        QueueBuilderIsEditing
        ? "Saves your changes to this queue job.`n`nThe job stays in the same position in the queue."
        : "Adds this as a new job at the bottom of the queue.`n`nNext, choose how many times it should run. You can edit or move it later."
    )


    CreateHelpBadgeForButton(
        QueueBuilderGui,
        cancelButton,
        "CLOSE",
        "Closes this window without changing the queue."
    )


    QueueBuilderJobTypeDropdown.OnEvent(
        "Change",
        QueueBuilderJobTypeChanged
    )


    QueueBuilderCategoryDropdown.OnEvent(
        "Change",
        QueueBuilderCategoryChanged
    )


    QueueBuilderMapDropdown.OnEvent(
        "Change",
        QueueBuilderMapChanged
    )


    QueueBuilderExpTypeDropdown.OnEvent(
        "Change",
        QueueBuilderExpTypeChanged
    )


    QueueBuilderExpScriptDropdown.OnEvent(
        "Change",
        UpdateQueueBuilderExpFavoriteButton
    )


    addButton.OnEvent(
        "Click",
        AddQueueBuilderSelection
    )


    cancelButton.OnEvent(
        "Click",
        CloseQueueJobBuilder
    )


    QueueBuilderGui.OnEvent(
        "Close",
        CloseQueueJobBuilder
    )


    QueueBuilderGui.OnEvent(
        "Escape",
        CloseQueueJobBuilder
    )


    QueueBuilderGui.Show(
        "Hide w520 h475"
    )


    ApplyDarkWindowStyle(
        QueueBuilderGui
    )


    RefreshQueueBuilderMapStrategies()
    RefreshQueueBuilderExpScripts()
    QueueBuilderJobTypeChanged()

    if QueueBuilderIsEditing {
        InitializeQueueBuilderEditSelection()
    }


    QueueBuilderGui.Show(
        "w520 h475 Center"
    )
}


QueueBuilderJobTypeChanged(*) {
    global QueueBuilderJobTypeDropdown

    global QueueBuilderCategoryLabel
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapLabel
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyLabel
    global QueueBuilderStrategyDropdown

    global QueueBuilderExpTypeLabel
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptLabel
    global QueueBuilderExpScriptDropdown

    global QueueBuilderCategoryHelp
    global QueueBuilderMapHelp
    global QueueBuilderStrategyHelp
    global QueueBuilderExpTypeHelp
    global QueueBuilderExpScriptHelp
    global QueueBuilderMapFavoriteButton
    global QueueBuilderExpFavoriteButton
    global QueueBuilderMapFavoriteHelp
    global QueueBuilderExpFavoriteHelp


    isMap :=
        QueueBuilderJobTypeDropdown.Text
        = "Map Script"


    QueueBuilderCategoryLabel.Visible := isMap
    QueueBuilderCategoryDropdown.Visible := isMap
    QueueBuilderMapLabel.Visible := isMap
    QueueBuilderMapDropdown.Visible := isMap
    QueueBuilderStrategyLabel.Visible := isMap
    QueueBuilderStrategyDropdown.Visible := isMap

    QueueBuilderCategoryHelp.Visible := isMap
    QueueBuilderMapHelp.Visible := isMap
    QueueBuilderMapFavoriteHelp.Visible := isMap
    QueueBuilderStrategyHelp.Visible := isMap
    QueueBuilderMapFavoriteButton.Visible := isMap


    QueueBuilderExpTypeLabel.Visible := !isMap
    QueueBuilderExpTypeDropdown.Visible := !isMap
    QueueBuilderExpScriptLabel.Visible := !isMap
    QueueBuilderExpScriptDropdown.Visible := !isMap

    QueueBuilderExpTypeHelp.Visible := !isMap
    QueueBuilderExpScriptHelp.Visible := !isMap
    QueueBuilderExpFavoriteHelp.Visible := !isMap
    QueueBuilderExpFavoriteButton.Visible := !isMap


    if isMap {
        UpdateQueueBuilderMapFavoriteButton()
    }
    else {
        UpdateQueueBuilderExpFavoriteButton()
    }


    CloseAllDarkDropdowns()
}


QueueBuilderCategoryChanged(*) {
    RefreshQueueBuilderMapFavorites(false)
}


QueueBuilderMapChanged(*) {
    UpdateQueueBuilderMapFavoriteButton()
    RefreshQueueBuilderMapStrategies()
}


RefreshQueueBuilderMapStrategies() {
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyDropdown
    global QueueBuilderMapStrategies
    global CategoryData


    QueueBuilderMapStrategies := []


    categoryName :=
        QueueBuilderCategoryDropdown.Text


    mapName :=
        QueueBuilderMapDropdown.Text


    GetConfiguredCategories()


    if !CategoryData.Has(
        categoryName
    ) {
        return SetQueueBuilderStrategyPlaceholder()
    }


    category :=
        CategoryData[
            categoryName
        ]


    if !category.directories.Has(
        mapName
    ) {
        return SetQueueBuilderStrategyPlaceholder()
    }


    mapDirectory :=
        category.directories[
            mapName
        ]


    scripts :=
        GetMapScripts(
            mapDirectory
        )


    names := []


    for difficulty in [
        "Easy",
        "Medium",
        "Hard"
    ] {
        for script in scripts[
            difficulty
        ] {
            displayName :=
                difficulty
                . " - "
                . script.name


            QueueBuilderMapStrategies.Push(
                {
                    name: displayName,
                    path: script.path,
                    label: mapName
                        . " - "
                        . script.name
                }
            )


            names.Push(
                displayName
            )
        }
    }


    QueueBuilderStrategyDropdown.Delete()


    if names.Length = 0 {
        QueueBuilderStrategyDropdown.Add(
            [
                "No strategies found"
            ]
        )
    }
    else {
        QueueBuilderStrategyDropdown.Add(
            names
        )
    }


    QueueBuilderStrategyDropdown.Choose(
        1
    )


    return names.Length
}


SetQueueBuilderStrategyPlaceholder() {
    global QueueBuilderStrategyDropdown


    QueueBuilderStrategyDropdown.Delete()


    QueueBuilderStrategyDropdown.Add(
        [
            "No strategies found"
        ]
    )


    QueueBuilderStrategyDropdown.Choose(
        1
    )


    return 0
}


QueueBuilderExpTypeChanged(*) {
    RefreshQueueBuilderExpFavorites(false)
}


RefreshQueueBuilderExpScripts() {
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global QueueBuilderExpScripts


    towerType :=
        QueueBuilderExpTypeDropdown.Text


    QueueBuilderExpScripts :=
        GetMonkeyExpScripts(
            towerType
        )


    names := []


    for script in QueueBuilderExpScripts {
        names.Push(
            script.name
        )
    }


    QueueBuilderExpScriptDropdown.Delete()


    if names.Length = 0 {
        QueueBuilderExpScriptDropdown.Add(
            [
                "No "
                . towerType
                . " scripts found"
            ]
        )
    }
    else {
        QueueBuilderExpScriptDropdown.Add(
            names
        )
    }


    QueueBuilderExpScriptDropdown.Choose(
        1
    )


    UpdateQueueBuilderExpFavoriteButton()


    return names.Length
}


QueueBuilderPathsMatch(pathA, pathB) {
    return StrLower(StrReplace(pathA, "/", "\"))
        = StrLower(StrReplace(pathB, "/", "\"))
}


InitializeQueueBuilderEditSelection() {
    global QueueBuilderEditIndex
    global MacroJobQueue
    global QueueBuilderJobTypeDropdown
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyDropdown
    global QueueBuilderMapStrategies
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global CategoryData

    if (
        QueueBuilderEditIndex < 1
        || QueueBuilderEditIndex > MacroJobQueue.Length
    ) {
        return false
    }

    job := MacroJobQueue[QueueBuilderEditIndex]

    if job.mode = "Monkey EXP Grind" {
        QueueBuilderJobTypeDropdown.Choose(2)
        QueueBuilderJobTypeChanged()

        towerTypes := GetMonkeyExpTowerTypes()

        for typeIndex, towerType in towerTypes {
            scripts := GetMonkeyExpScripts(towerType)

            for scriptIndex, script in scripts {
                if QueueBuilderPathsMatch(script.path, job.path) {
                    QueueBuilderExpTypeDropdown.Choose(typeIndex)
                    RefreshQueueBuilderExpScripts()
                    QueueBuilderExpScriptDropdown.Choose(scriptIndex)
                    UpdateQueueBuilderExpFavoriteButton()
                    return true
                }
            }
        }

        return false
    }

    QueueBuilderJobTypeDropdown.Choose(1)
    QueueBuilderJobTypeChanged()
    categories := GetConfiguredCategories()

    for categoryIndex, categoryName in categories {
        maps := GetMapNamesForCategory(categoryName)

        for mapIndex, mapName in maps {
            if !CategoryData.Has(categoryName) {
                continue
            }

            category := CategoryData[categoryName]

            if !category.directories.Has(mapName) {
                continue
            }

            scripts := GetMapScripts(category.directories[mapName])

            for difficulty in ["Easy", "Medium", "Hard"] {
                for candidate in scripts[difficulty] {
                    if QueueBuilderPathsMatch(candidate.path, job.path) {
                        QueueBuilderCategoryDropdown.Choose(categoryIndex)
                        RefreshQueueBuilderMapFavorites(false)

                        currentMaps := GetMapNamesForCategory(categoryName)
                        chosenMapIndex := FindTextIndex(currentMaps, mapName)

                        if chosenMapIndex > 0 {
                            QueueBuilderMapDropdown.Choose(chosenMapIndex)
                        }

                        RefreshQueueBuilderMapStrategies()

                        for strategyIndex, strategy in QueueBuilderMapStrategies {
                            if QueueBuilderPathsMatch(strategy.path, job.path) {
                                QueueBuilderStrategyDropdown.Choose(strategyIndex)
                                break
                            }
                        }

                        UpdateQueueBuilderMapFavoriteButton()
                        return true
                    }
                }
            }
        }
    }

    return false
}


AddQueueBuilderSelection(*) {
    global QueueBuilderJobTypeDropdown
    global QueueBuilderIsEditing
    global QueueBuilderEditIndex
    global MacroJobQueue
    global QueueBuilderStrategyDropdown
    global QueueBuilderMapStrategies

    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global QueueBuilderExpScripts

    global UIColorError


    if QueueBuilderJobTypeDropdown.Text
        = "Map Script" {

        selectedName :=
            QueueBuilderStrategyDropdown.Text


        for strategy in QueueBuilderMapStrategies {
            if strategy.name = selectedName {
                path := strategy.path
                label := strategy.label


                if QueueBuilderIsEditing {
                    currentRuns := MacroJobQueue[QueueBuilderEditIndex].runs
                    editIndex := QueueBuilderEditIndex
                    DestroyQueueJobBuilder(false)
                    runCount := ShowCycleInputPrompt("editqueue", currentRuns)

                    if runCount < 1 {
                        ShowQueueManager()
                        return false
                    }

                    MacroJobQueue[editIndex] := {
                        path: path,
                        label: label,
                        mode: "Default",
                        runs: runCount
                    }

                    SetQueueHistorySource()
                    UpdateQueueLauncherButton()
                    ShowQueueManager()
                    return true
                }

                CloseQueueJobBuilder()


                return AddJobToQueue(
                    path,
                    label,
                    "Default"
                )
            }
        }


        UpdateStatus(
            "SELECT A VALID STRATEGY",
            UIColorError
        )


        return false
    }


    towerType :=
        QueueBuilderExpTypeDropdown.Text


    selectedName :=
        QueueBuilderExpScriptDropdown.Text


    for script in QueueBuilderExpScripts {
        if script.name = selectedName {
            path := script.path
            label :=
                towerType
                . " - "
                . script.name


            if QueueBuilderIsEditing {
                currentRuns := MacroJobQueue[QueueBuilderEditIndex].runs
                editIndex := QueueBuilderEditIndex
                DestroyQueueJobBuilder(false)
                runCount := ShowCycleInputPrompt("editqueue", currentRuns)

                if runCount < 1 {
                    ShowQueueManager()
                    return false
                }

                MacroJobQueue[editIndex] := {
                    path: path,
                    label: label,
                    mode: "Monkey EXP Grind",
                    runs: runCount
                }

                SetQueueHistorySource()
                UpdateQueueLauncherButton()
                ShowQueueManager()
                return true
            }

            CloseQueueJobBuilder()


            return AddJobToQueue(
                path,
                label,
                "Monkey EXP Grind"
            )
        }
    }


    UpdateStatus(
        "SELECT A VALID TOWER SCRIPT",
        UIColorError
    )


    return false
}


CloseQueueJobBuilder(*) {
    global QueueBuilderIsEditing

    returnToQueue := QueueBuilderIsEditing
    DestroyQueueJobBuilder(false)

    if returnToQueue {
        ShowQueueManager()
    } else {
        ShowLauncher(true)
    }
}


DestroyQueueJobBuilder(returnToQueue := false) {
    global QueueBuilderGui
    global QueueBuilderJobTypeDropdown
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyDropdown
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global QueueBuilderMapStrategies
    global QueueBuilderExpScripts
    global QueueBuilderMapFavoriteButton
    global QueueBuilderExpFavoriteButton
    global QueueBuilderMapFavoriteHelp
    global QueueBuilderExpFavoriteHelp
    global QueueBuilderEditIndex
    global QueueBuilderIsEditing

    CloseAllDarkDropdowns()

    try {
        if QueueBuilderGui
            QueueBuilderGui.Destroy()
    }

    QueueBuilderGui := ""
    QueueBuilderJobTypeDropdown := ""
    QueueBuilderCategoryDropdown := ""
    QueueBuilderMapDropdown := ""
    QueueBuilderStrategyDropdown := ""
    QueueBuilderExpTypeDropdown := ""
    QueueBuilderExpScriptDropdown := ""
    QueueBuilderMapStrategies := []
    QueueBuilderExpScripts := []
    QueueBuilderMapFavoriteButton := ""
    QueueBuilderExpFavoriteButton := ""
    QueueBuilderMapFavoriteHelp := ""
    QueueBuilderExpFavoriteHelp := ""
    QueueBuilderEditIndex := 0
    QueueBuilderIsEditing := false

    if returnToQueue {
        ShowQueueManager()
    }
}
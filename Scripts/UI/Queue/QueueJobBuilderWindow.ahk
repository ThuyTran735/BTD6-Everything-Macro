#Requires AutoHotkey v2.0

; v3 file note: Builds the Add/Edit Queue Job window.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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


    uiWidth := 540
    uiHeight := 500


    QueueBuilderGui :=
        Gui(
            "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
            QueueBuilderIsEditing ? "Edit Queue Job" : "Add Queue Job"
        )


    QueueBuilderGui.BackColor :=
        UIColorBackground


    EnableCustomWindowChrome(QueueBuilderGui)
    AddCustomWindowBorder(QueueBuilderGui, uiWidth, uiHeight)

    ; Match the launcher/settings visual hierarchy instead of leaving fields
    ; floating directly on the window background.
    AddUICard(QueueBuilderGui, 16, 82, 508, 80)
    AddUICard(QueueBuilderGui, 16, 170, 508, 238)
    AddUICard(QueueBuilderGui, 16, 418, 508, 66)


    AddUIOutlinedText(
        QueueBuilderGui,
        QueueBuilderIsEditing ? "EDIT QUEUE JOB" : "ADD QUEUE JOB",
        20,
        18,
        500,
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
        "x20 y55 w500 h20 Center c"
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
            92,
            480,
            22,
            9
        )


    QueueBuilderJobTypeDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            116,
            480,
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
            182,
            480,
            22,
            9
        )


    QueueBuilderCategoryDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            206,
            480,
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
            254,
            480,
            22,
            9
        )


    QueueBuilderMapDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            278,
            480,
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
            326,
            480,
            22,
            9
        )


    QueueBuilderStrategyDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            350,
            480,
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
            218,
            480,
            22,
            9,
            "Left",
            false
        )


    QueueBuilderExpTypeDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            242,
            480,
            GetMonkeyExpTowerTypes(),
            1,
            5
        )


    QueueBuilderExpTypeDropdown.Visible := false


    QueueBuilderExpTypeHelp :=
        CreateHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderExpTypeDropdown,
            QueueBuilderExpTypeLabel,
            "TOWER TYPE",
            "Choose Primary, Military, Magic, or Support.`n`nThe Tower Script list updates to show scripts from that group."
        )


    QueueBuilderExpTypeHelp.Visible := false


    QueueBuilderExpScriptLabel :=
        AddUIOutlinedText(
            QueueBuilderGui,
            "SELECT TOWER",
            30,
            298,
            480,
            22,
            9,
            "Left",
            false
        )


    QueueBuilderExpScriptDropdown :=
        CreateDarkDropdown(
            QueueBuilderGui,
            30,
            322,
            480,
            [
                "No Monkey EXP scripts found"
            ],
            1,
            5
        )


    QueueBuilderExpScriptDropdown.Visible := false


    QueueBuilderExpScriptHelp :=
        CreateHelpBadgeForField(
            QueueBuilderGui,
            QueueBuilderExpScriptDropdown,
            QueueBuilderExpScriptLabel,
            "TOWER SCRIPT",
            "Choose the exact Monkey EXP Grind script for this job.`n`nThe .ahk extension stays visible so you know exactly which file will run."
        )


    QueueBuilderExpScriptHelp.Visible := false


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
            430,
            310,
            44,
            QueueBuilderIsEditing ? "SAVE CHANGES" : "ADD TO QUEUE",
            9
        )


    cancelButton :=
        CreateDarkButton(
            QueueBuilderGui,
            350,
            430,
            160,
            44,
            "CANCEL",
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
        "CANCEL",
        "Returns without changing the queue."
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
        "Hide w" . uiWidth . " h" . uiHeight
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
        "w" . uiWidth . " h" . uiHeight . " Center"
    )
}



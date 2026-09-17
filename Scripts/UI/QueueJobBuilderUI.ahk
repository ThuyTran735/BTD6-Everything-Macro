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


ShowQueueJobBuilder(*) {
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

    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText


    if MacroRunning {
        return
    }


    CloseAllDarkDropdowns()
    CloseModePicker()
    CloseScriptPicker()
    CloseQueueManager()
    CloseContextHelp()
    CloseQueueJobBuilder()


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
            "Add Queue Job"
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
        "ADD QUEUE JOB",
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
        "Choose exactly what should be added to the queue"
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
            CurrentMode = "Monkey EXP Grind" ? 2 : 1,
            5
        )


    CreateHelpBadgeForField(
        QueueBuilderGui,
        QueueBuilderJobTypeDropdown,
        QueueBuilderJobTypeLabel,
        "JOB TYPE",
        "Choose the kind of queued job you want to add.`n`nMAP SCRIPT lets you choose a map category, map, and exact strategy.`n`nMONKEY EXP GRIND lets you choose a tower type and its .ahk script."
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
            "Choose the BTD6 map category for this queue job, such as Beginner, Intermediate, Advanced, or Expert.`n`nThe Map list below updates automatically to only show maps from the selected category."
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
            "Choose the map for this queued job.`n`nOnly maps that contain at least one runnable .ahk strategy are shown. Changing the map refreshes the Strategy list below."
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
            "Choose the exact .ahk strategy that the queue should run for the selected map.`n`nDifficulty is shown before the filename so strategies with similar names are easy to tell apart."
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
            "Choose Primary, Military, Magic, or Support.`n`nThe Tower Script list below reads only the .ahk files inside that type's Monkey EXP Grind folder."
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
            "Choose the exact Monkey EXP Grind .ahk file to queue.`n`nThe .ahk extension stays visible, and the list updates whenever you change Tower Type."
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
            "Click ☆ to favorite the selected map. ★ means it is already a favorite. Favorite maps move to the top everywhere map dropdowns are used."
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
            "Click ☆ to favorite the selected Monkey EXP script. ★ means it is already a favorite. Favorite EXP scripts move to the top everywhere EXP dropdowns are used."
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
            "ADD TO QUEUE",
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
        "ADD TO QUEUE",
        "Adds the selected script as a new job at the bottom of the queue.`n`nAfter clicking it, enter how many times that job should run. You can reorder or remove it later in the Queue Manager."
    )


    CreateHelpBadgeForButton(
        QueueBuilderGui,
        cancelButton,
        "CLOSE",
        "Closes the Add Queue Job window without changing the queue."
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


AddQueueBuilderSelection(*) {
    global QueueBuilderJobTypeDropdown
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
}
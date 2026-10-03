#Requires AutoHotkey v2.0

; v3 file note: Handles launcher close/run/queue actions and picks the active launcher mode.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

RequestCloseLauncher(*) {
    global LauncherGui

    SaveLauncherState()

    ShowThemedConfirmation(
        "CLOSE MACRO?",
        "Close BTD6 Everything Macro?`n`nAny queue that is not currently running will be discarded.",
        "CLOSE MACRO",
        ExitApp,
        LauncherGui,
        "Closes BTD6 Everything Macro completely.`n`nUnsaved queue jobs will be lost."
    )
}


RunCurrentMode(*) {
    global CurrentMode
    global MacroJobQueue
    global MacroRunning


    if MacroRunning {
        return
    }


    CloseAllDarkDropdowns()
    CloseQueueJobBuilder()


    ; A populated queue owns the main Run action. Do not open a
    ; strategy picker or prompt for an unrelated manual run when
    ; the user has already built a queue.
    if MacroJobQueue.Length > 0 {

        StartMacroQueue()

        return
    }


    if CurrentMode = "Default" {

        RunDefaultMode()

        return
    }


    if CurrentMode
        = "Monkey EXP Grind" {

        RunMonkeyExpGrindMode()

        return
    }


    if CurrentMode
        = "Monkey Money Grind" {

        RunMonkeyMoneyGrindMode()

        return
    }
}


QueueCurrentSelection(*) {
    global MacroRunning


    if MacroRunning {
        return
    }


    CloseAllDarkDropdowns()


    ShowQueueJobBuilder()
}


QueueMonkeyExpSelection() {
    global MonkeyExpTypeDropdown
    global MonkeyExpScriptDropdown
    global MonkeyExpScripts

    global UIColorError


    selectedType :=
        MonkeyExpTypeDropdown.Text


    selectedName :=
        MonkeyExpScriptDropdown.Text


    currentScripts :=
        GetMonkeyExpScripts(
            selectedType
        )


    for script in currentScripts {

        if script.name = selectedName {

            AddJobToQueue(
                script.path,
                selectedType
                . " - "
                . script.name,
                "Monkey EXP Grind"
            )


            return
        }
    }


    MonkeyExpScripts :=
        currentScripts


    UpdateStatus(
        "SELECTED TOWER SCRIPT NOT FOUND",
        UIColorError
    )
}


QueueDefaultModeSelection() {
    global CategoryDropdown
    global MapDropdown
    global CategoryData

    global UIColorError


    categoryName :=
        CategoryDropdown.Text


    mapName :=
        MapDropdown.Text


    if (
        categoryName = ""
        || categoryName = "No configured categories"
    ) {

        UpdateStatus(
            "NO CATEGORY SELECTED",
            UIColorError
        )


        return
    }


    if (
        mapName = ""
        || mapName = "No configured maps"
    ) {

        UpdateStatus(
            "NO MAP SELECTED",
            UIColorError
        )


        return
    }


    GetConfiguredCategories()


    if !CategoryData.Has(
        categoryName
    ) {

        UpdateStatus(
            "CATEGORY NOT FOUND",
            UIColorError
        )


        return
    }


    category :=
        CategoryData[
            categoryName
        ]


    if !category.directories.Has(
        mapName
    ) {

        UpdateStatus(
            "MAP FOLDER NOT FOUND",
            UIColorError
        )


        return
    }


    mapDirectory :=
        category.directories[
            mapName
        ]


    if !DirExist(
        mapDirectory
    ) {

        UpdateStatus(
            "MAP FOLDER NOT FOUND",
            UIColorError
        )


        return
    }


    scripts :=
        GetMapScripts(
            mapDirectory
        )


    scriptCount :=
        CountMapScripts(
            scripts
        )


    if scriptCount = 0 {

        UpdateStatus(
            "NO STRATEGIES FOUND",
            UIColorError
        )


        return
    }


    ; Always show the picker, even if this map only has one script.
    ; It keeps difficulty selection consistent instead of launching right away.
    ShowScriptPicker(
        mapName,
        mapDirectory,
        scripts,
        "queue"
    )
}


RunMonkeyExpGrindMode() {
    global MonkeyExpTypeDropdown
    global MonkeyExpScriptDropdown
    global MonkeyExpScripts

    global UIColorError


    selectedType :=
        MonkeyExpTypeDropdown.Text


    selectedName :=
        MonkeyExpScriptDropdown.Text


    ; Refresh only the selected tower-type folder when Run is
    ; pressed, so the launcher never relies on a stale path.
    currentScripts :=
        GetMonkeyExpScripts(
            selectedType
        )


    for script in currentScripts {

        if script.name = selectedName {

            LaunchMapScript(
                script.path
            )


            return
        }
    }


    MonkeyExpScripts :=
        currentScripts


    UpdateStatus(
        "SELECTED TOWER SCRIPT NOT FOUND",
        UIColorError
    )
}


RunMonkeyMoneyGrindMode() {
    global UIColorWarning


    UpdateStatus(
        "MONEY GRIND NOT SET UP YET",
        UIColorWarning
    )
}


RunDefaultMode() {
    global MacroRunning

    global CategoryDropdown
    global MapDropdown
    global CategoryData

    global UIColorError


    if MacroRunning {

        return
    }


    categoryName :=
        CategoryDropdown.Text


    mapName :=
        MapDropdown.Text


    if (
        categoryName = ""
        || categoryName
            = "No configured categories"
    ) {

        UpdateStatus(
            "NO CATEGORY SELECTED",
            UIColorError
        )


        return
    }


    if (
        mapName = ""
        || mapName
            = "No configured maps"
    ) {

        UpdateStatus(
            "NO MAP SELECTED",
            UIColorError
        )


        return
    }


    ; Refresh discovery every run so newly added
    ; strategy scripts are picked up automatically.
    GetConfiguredCategories()


    if !CategoryData.Has(
        categoryName
    ) {

        UpdateStatus(
            "CATEGORY NOT FOUND",
            UIColorError
        )


        return
    }


    category :=
        CategoryData[
            categoryName
        ]


    if !category.directories.Has(
        mapName
    ) {

        UpdateStatus(
            "MAP FOLDER NOT FOUND",
            UIColorError
        )


        return
    }


    mapDirectory :=
        category.directories[
            mapName
        ]


    if !DirExist(
        mapDirectory
    ) {

        UpdateStatus(
            "MAP FOLDER NOT FOUND",
            UIColorError
        )


        return
    }


    scripts :=
        GetMapScripts(
            mapDirectory
        )


    scriptCount :=
        CountMapScripts(
            scripts
        )


    if scriptCount = 0 {

        UpdateStatus(
            "NO STRATEGIES FOUND",
            UIColorError
        )


        ToolTip(
            "No .ahk strategies were found under:`n"
            . mapDirectory
        )


        SetTimer(
            () => ToolTip(),
            -2000
        )


        return
    }


    ; Always show the picker, even if this map only has one script.
    ; It keeps difficulty selection consistent instead of launching right away.
    ShowScriptPicker(
        mapName,
        mapDirectory,
        scripts
    )
}
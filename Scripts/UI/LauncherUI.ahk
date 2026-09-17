#Requires AutoHotkey v2.0


CreateLauncherUI() {
    global LauncherGui

    global SubtitleText

    global CategoryLabel
    global CategoryDropdown

    global MapLabel
    global MapDropdown

    global HotkeyText

    global MonkeyExpTitle
    global MonkeyExpDescription
    global MonkeyExpTypeLabel
    global MonkeyExpTypeDropdown
    global MonkeyExpScriptLabel
    global MonkeyExpScriptDropdown

    global StatusText

    global RunButton
    global AddQueueButton
    global QueueButton
    global ModeButton
    global LogsButton

    global CategoryHelpBadge
    global MapHelpBadge
    global MapFavoriteHelpBadge
    global MonkeyExpTypeHelpBadge
    global MonkeyExpScriptHelpBadge
    global MonkeyExpFavoriteHelpBadge

    global MapFavoriteButton
    global MonkeyExpFavoriteButton

    global GuiWidth
    global GuiHeight

    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText
    global UIColorMutedText
    global UIColorSuccess


    categories :=
        GetConfiguredCategories()


    initialMaps := []


    if (
        categories.Length > 0
        && categories[1]
            != "No configured categories"
    ) {

        initialMaps :=
            GetMapNamesForCategory(
                categories[1]
            )
    }


    if initialMaps.Length = 0 {

        initialMaps.Push(
            "No configured maps"
        )
    }


    LauncherGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "BTD6 Everything Macro - V1.12"
    )


    LauncherGui.BackColor :=
        UIColorBackground


    LauncherGui.Add(
        "Progress",
        "x0 y0 w"
        . GuiWidth
        . " h5 Background"
        . UIColorAccent
        . " c"
        . UIColorAccent,
        100
    )


    AddUIOutlinedText(
        LauncherGui,
        "BTD6 Everything Macro",
        20,
        18,
        350,
        35,
        14
    )


    SetUIBodyFont(
        LauncherGui,
        7,
        UIColorMutedText
    )


    LauncherGui.Add(
        "Text",
        "x21 y53 w145 h20 c"
        . UIColorMutedText
        . " BackgroundTrans",
        "Made By @Thuy_"
        . Chr(8202)
        . "_"
    )


    LauncherGui.Add(
        "Text",
        "x170 y53 w55 h20 Center c"
        . UIColorMutedText
        . " BackgroundTrans",
        "V1.12"
    )


    SetUIBodyFont(
        LauncherGui,
        8,
        UIColorMutedText
    )


    SubtitleText :=
        LauncherGui.Add(
            "Text",
            "x230 y53 w140 h20 Right c"
            . UIColorMutedText
            . " BackgroundTrans",
            "Default Mode"
        )


    LauncherGui.Add(
        "Text",
        "x20 y79 w350 h1 0x10"
    )


    CategoryLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT CATEGORY",
            20,
            94,
            350,
            22,
            9
        )


    MapLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT MAP",
            20,
            157,
            350,
            22,
            9
        )


    SetUIBodyFont(
        LauncherGui,
        9,
        UIColorSecondaryText
    )


    HotkeyText :=
        LauncherGui.Add(
            "Text",
            "x20 y221 w350 h20 Center c"
            . UIColorSecondaryText
            . " BackgroundTrans",
            "Run Hotkey   •   Ctrl + Shift + P"
        )


    MonkeyExpTitle :=
        AddUIOutlinedText(
            LauncherGui,
            "MONKEY EXP GRIND",
            20,
            89,
            350,
            30,
            13,
            "Center",
            false
        )


    SetUIBodyFont(
        LauncherGui,
        9,
        UIColorSecondaryText
    )


    MonkeyExpDescription :=
        LauncherGui.Add(
            "Text",
            "x35 y157 w320 h65 Center c"
            . UIColorSecondaryText
            . " BackgroundTrans Hidden",
            "Monkey EXP Grind controls will go here.`n"
            . "This mode is ready to be built next."
        )


    MonkeyExpTypeLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT TOWER TYPE",
            20,
            123,
            350,
            22,
            9,
            "Left",
            false
        )


    MonkeyExpScriptLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT TOWER",
            20,
            184,
            350,
            22,
            9,
            "Left",
            false
        )


    RunButton :=
        CreateDarkButton(
            LauncherGui,
            20,
            250,
            230,
            44,
            "RUN MACRO",
            9
        )


    AddQueueButton :=
        CreateDarkButton(
            LauncherGui,
            260,
            250,
            110,
            44,
            "ADD QUEUE",
            8
        )


    RunButton.OnEvent(
        "Click",
        RunCurrentMode
    )


    AddQueueButton.OnEvent(
        "Click",
        QueueCurrentSelection
    )


    QueueButton :=
        CreateDarkButton(
            LauncherGui,
            20,
            306,
            110,
            36,
            "QUEUE (0)",
            8
        )


    ModeButton :=
        CreateDarkButton(
            LauncherGui,
            140,
            306,
            110,
            36,
            "MODES",
            8
        )


    LogsButton :=
        CreateDarkButton(
            LauncherGui,
            260,
            306,
            110,
            36,
            "LOGS",
            8
        )


    QueueButton.OnEvent(
        "Click",
        ShowQueueManager
    )


    LogsButton.Enabled :=
        false


    CreateHelpBadgeForButton(
        LauncherGui,
        RunButton,
        "RUN",
        "Runs the current selection. If the queue contains jobs, this button changes to RUN QUEUE and starts the existing queue instead of opening another map selection."
    )


    CreateHelpBadgeForButton(
        LauncherGui,
        AddQueueButton,
        "ADD QUEUE",
        "Opens the Add Queue Job window. Choose a job type, category or tower type, exact script, then enter how many times that job should run."
    )


    CreateHelpBadgeForButton(
        LauncherGui,
        QueueButton,
        "QUEUE",
        "Opens the Queue Manager. Jobs run from top to bottom. You can reorder, remove, clear, or start the complete queue from there."
    )


    CreateHelpBadgeForButton(
        LauncherGui,
        ModeButton,
        "MODES",
        "Switches the launcher between available macro modes, including normal map scripts and Monkey EXP Grind."
    )


    CreateHelpBadgeForButton(
        LauncherGui,
        LogsButton,
        "LOGS",
        "This control is reserved for run logs and diagnostics. It is currently disabled until the logging feature is added."
    )


    ModeButton.OnEvent(
        "Click",
        ShowModePicker
    )


    SetUIBodyBoldFont(
        LauncherGui,
        9,
        UIColorSuccess
    )


    StatusText :=
        LauncherGui.Add(
            "Text",
            "x20 y356 w350 h20 Center c"
            . UIColorSuccess
            . " BackgroundTrans",
            "READY"
        )


    MapDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            20,
            181,
            350,
            initialMaps,
            1,
            5
        )


    CategoryDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            20,
            118,
            350,
            categories,
            1,
            5
        )


    MonkeyExpTypeDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            20,
            145,
            350,
            GetMonkeyExpTowerTypes(),
            1,
            5
        )


    MonkeyExpScriptDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            20,
            206,
            350,
            [
                "No Monkey EXP scripts found"
            ],
            1,
            5
        )


    MonkeyExpTypeDropdown.Visible :=
        false


    MonkeyExpScriptDropdown.Visible :=
        false


    MapFavoriteButton :=
        CreateFavoriteButtonForField(
            LauncherGui,
            MapDropdown
        )


    MapFavoriteButton.OnEvent(
        "Click",
        ToggleLauncherMapFavorite
    )


    MapFavoriteHelpBadge :=
        CreateFavoriteHelpBadgeForField(
            LauncherGui,
            MapDropdown,
            "FAVORITES",
            "Click ☆ to favorite the selected map. ★ means the map is already a favorite. Favorite maps automatically move to the top of map dropdowns."
        )


    MonkeyExpFavoriteButton :=
        CreateFavoriteButtonForField(
            LauncherGui,
            MonkeyExpScriptDropdown
        )


    MonkeyExpFavoriteButton.OnEvent(
        "Click",
        ToggleLauncherExpFavorite
    )


    MonkeyExpFavoriteHelpBadge :=
        CreateFavoriteHelpBadgeForField(
            LauncherGui,
            MonkeyExpScriptDropdown,
            "FAVORITES",
            "Click ☆ to favorite the selected Monkey EXP script. ★ means it is already a favorite. Favorite EXP scripts automatically move to the top of EXP script dropdowns."
        )


    MonkeyExpFavoriteButton.Visible := false
    MonkeyExpFavoriteHelpBadge.Visible := false


    CategoryHelpBadge :=
        CreateHelpBadgeForField(
            LauncherGui,
            CategoryDropdown,
            CategoryLabel,
            "CATEGORY",
            "Choose the map difficulty category. The Map dropdown updates automatically so it only shows configured maps from that category."
        )


    MapHelpBadge :=
        CreateHelpBadgeForField(
            LauncherGui,
            MapDropdown,
            MapLabel,
            "MAP",
            "Choose the map you want to run. Only maps with at least one runnable strategy are listed."
        )


    MonkeyExpTypeHelpBadge :=
        CreateHelpBadgeForField(
            LauncherGui,
            MonkeyExpTypeDropdown,
            MonkeyExpTypeLabel,
            "TOWER TYPE",
            "Choose Primary, Military, Magic, or Support. The Tower dropdown then shows only the .ahk scripts inside that tower type folder."
        )


    MonkeyExpScriptHelpBadge :=
        CreateHelpBadgeForField(
            LauncherGui,
            MonkeyExpScriptDropdown,
            MonkeyExpScriptLabel,
            "TOWER SCRIPT",
            "Choose the exact Monkey EXP Grind .ahk script to run. The filename is kept exactly as it appears in the folder."
        )


    MonkeyExpTypeHelpBadge.Visible := false
    MonkeyExpScriptHelpBadge.Visible := false


    CategoryDropdown.OnEvent(
        "Change",
        OnCategoryChanged
    )


    MapDropdown.OnEvent(
        "Change",
        UpdateLauncherMapFavoriteButton
    )


    MonkeyExpTypeDropdown.OnEvent(
        "Change",
        OnMonkeyExpTypeChanged
    )


    MonkeyExpScriptDropdown.OnEvent(
        "Change",
        UpdateLauncherExpFavoriteButton
    )


    LauncherGui.OnEvent(
        "Close",
        (*) => ExitApp()
    )


    LauncherGui.Show(
        "Hide w"
        . GuiWidth
        . " h"
        . GuiHeight
    )


    ApplyModernWindowStyle()


    UpdateLauncherMapFavoriteButton()
    UpdateLauncherExpFavoriteButton()


    ApplyLauncherMode()
    UpdateQueueLauncherButton()


    ShowLauncher(
        true
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


    if scriptCount = 1 {

        script :=
            GetOnlyMapScript(
                scripts
            )


        if script {

            AddJobToQueue(
                script.path,
                mapName
                . " - "
                . script.name,
                "Default"
            )
        }


        return
    }


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


    if scriptCount = 1 {

        script :=
            GetOnlyMapScript(
                scripts
            )


        if script {

            LaunchMapScript(
                script.path
            )
        }


        return
    }


    ShowScriptPicker(
        mapName,
        mapDirectory,
        scripts
    )
}


PromptForRunCount(context := "run") {
    return ShowCycleInputPrompt(context)
}


LaunchMapScript(
    scriptPath
) {
    global MacroRunning
    global MacroJobQueue
    global LauncherGui

    global RepeatScriptPath
    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted

    global ForceLauncherVisible

    global UIColorError


    if MacroRunning {

        return false
    }


    ; Defensive guard for picker/hotkey edge cases. If a queue was
    ; populated after a picker opened, running the selected script
    ; still starts the queue instead of creating a separate run.
    if MacroJobQueue.Length > 0 {

        return StartMacroQueue()
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


    runCount :=
        PromptForRunCount()


    if runCount = 0 {

        return false
    }


    ClearQueueExecutionState()
    ClearCycleStopRequest()


    RepeatScriptPath :=
        scriptPath


    RepeatRunTotal :=
        runCount


    RepeatRunRemaining :=
        runCount


    RepeatRunCompleted :=
        0


    ForceLauncherVisible :=
        false


    ClearLauncherReturnPending()
    SetLauncherRunSuppressed(true)


    CloseAllDarkDropdowns()
    CloseModePicker()
    CloseScriptPicker()
    CloseQueueManager()


    ; Mark the run active BEFORE the loading UI starts.
    ;
    ; Main.ahk checks MonitorLauncherState every 500 ms.
    ; Setting this first prevents the launcher from
    ; flashing back on-screen while the loading UI is
    ; transitioning into the strategy process.
    MacroRunning :=
        true


    LauncherGui.Hide()


    RunStartupLoadingAnimation()


    ; Keep the launcher hidden after the loading GUI
    ; closes and before the child strategy starts.
    LauncherGui.Hide()


    ShowCycleStatusUI()


    return StartNextQueuedRun()
}


StartNextQueuedRun() {
    global MacroRunning
    global RunningPid
    global LauncherGui

    global RepeatScriptPath
    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted

    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs

    global UIColorWarning
    global UIColorError


    if !MacroRunning {

        return false
    }


    if RepeatRunRemaining < 1 {

        return false
    }


    if !FileExist(
        RepeatScriptPath
    ) {

        MacroRunning :=
            false


        RunningPid :=
            0


        HideCycleStatusUI()


        ClearRepeatRunState()
        ClearQueueExecutionState()


        UpdateStatus(
            "SCRIPT NOT FOUND",
            UIColorError
        )


        ClearLauncherReturnPending()
        SetLauncherRunSuppressed(false)


        ShowLauncher(
            true
        )


        return false
    }


    currentRun :=
        RepeatRunCompleted
        + 1


    if QueueRunning {

        UpdateStatus(
            "JOB "
            . QueueActiveJobIndex
            . " / "
            . QueueTotalJobs
            . " - RUN "
            . currentRun
            . " / "
            . RepeatRunTotal,
            UIColorWarning
        )
    }
    else {

        UpdateStatus(
            "STARTING RUN "
            . currentRun
            . " OF "
            . RepeatRunTotal
            . "...",
            UIColorWarning
        )
    }


    UpdateCycleStatusUI()


    LauncherGui.Hide()


    command :=
        Chr(34)
        . A_AhkPath
        . Chr(34)
        . " "
        . Chr(34)
        . RepeatScriptPath
        . Chr(34)
        . " "
        . Chr(34)
        . "--btd6-cycle="
        . currentRun
        . Chr(34)


    try {

        ; Clean modifier state before a new strategy
        ; process is started.
        SendEvent(
            "{LAlt Up}"
            . "{RAlt Up}"
            . "{LCtrl Up}"
            . "{RCtrl Up}"
            . "{LShift Up}"
            . "{RShift Up}"
            . "{LWin Up}"
            . "{RWin Up}"
        )


        Sleep(
            50
        )

        Run(
            command,
            A_ScriptDir,
            ,
            &RunningPid
        )


        RepeatRunRemaining--


        return true
    }
    catch Error as err {

        MacroRunning :=
            false


        RunningPid :=
            0


        HideCycleStatusUI()


        ClearRepeatRunState()
        ClearQueueExecutionState()
        ClearCycleStopRequest()


        UpdateStatus(
            "FAILED TO START",
            UIColorError
        )


        ClearLauncherReturnPending()
        SetLauncherRunSuppressed(false)


        ShowLauncher(
            true
        )


        MsgBox(
            "Could not start the selected macro.`n`n"
            . err.Message,
            "BTD6 Macro"
        )


        return false
    }
}


ClearRepeatRunState() {
    global RepeatScriptPath
    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted


    RepeatScriptPath :=
        ""


    RepeatRunTotal :=
        0


    RepeatRunRemaining :=
        0


    RepeatRunCompleted :=
        0
}
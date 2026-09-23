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
    global StatusIndicator
    global UpdateCheckText
    global UpdateLinkText

    global RunButton
    global AddQueueButton
    global QueueButton
    global ModeButton
    global SettingsButton
    global CloseButton

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
    global UIColorPanelBorder


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
        GetVersionedTitle("BTD6 Everything Macro")
    )


    LauncherGui.BackColor :=
        UIColorBackground


    EnableCustomWindowChrome(LauncherGui, 72, 0)
    AddCustomWindowBorder(LauncherGui, GuiWidth, GuiHeight)

    AddUICard(LauncherGui, 16, 92, 398, 166)
    AddUICard(LauncherGui, 16, 270, 398, 106)
    AddUICard(LauncherGui, 16, 388, 398, 70)


    AddUIOutlinedText(
        LauncherGui,
        "BTD6 Everything Macro",
        24,
        18,
        300,
        34,
        14
    )


    SetUIBodyFont(
        LauncherGui,
        8,
        UIColorMutedText
    )


    LauncherGui.Add(
        "Text",
        "x24 y54 w150 h18 c"
        . UIColorMutedText
        . " BackgroundTrans",
        "Made By @Thuy_"
        . Chr(8202)
        . "_"
    )


    LauncherGui.Add(
        "Text",
        "x176 y54 w70 h18 Center c"
        . UIColorMutedText
        . " BackgroundTrans",
        GetAppVersionLabel()
    )


    SetUIBodyFont(
        LauncherGui,
        8,
        UIColorMutedText
    )


    SubtitleText :=
        LauncherGui.Add(
            "Text",
            "x254 y54 w152 h18 Right c"
            . UIColorMutedText
            . " BackgroundTrans",
            "Default Mode"
        )


    LauncherGui.Add(
        "Progress",
        "x24 y79 w382 h1 c" . UIColorPanelBorder
        . " Background" . UIColorPanelBorder . " Disabled",
        100
    )


    CategoryLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT CATEGORY",
            28,
            104,
            374,
            20,
            8
        )


    MapLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT MAP",
            28,
            171,
            374,
            20,
            8
        )


    SetUIBodyFont(
        LauncherGui,
        8,
        UIColorSecondaryText
    )


    HotkeyText :=
        LauncherGui.Add(
            "Text",
            "x28 y234 w374 h18 Center c"
            . UIColorSecondaryText
            . " BackgroundTrans",
            "Run Hotkey   •   Ctrl + Shift + P"
        )


    MonkeyExpTitle :=
        AddUIOutlinedText(
            LauncherGui,
            "MONKEY EXP GRIND",
            28,
            102,
            374,
            22,
            10,
            "Center",
            false
        )


    SetUIBodyFont(
        LauncherGui,
        8,
        UIColorSecondaryText
    )


    MonkeyExpDescription :=
        LauncherGui.Add(
            "Text",
            "x42 y158 w346 h62 Center c"
            . UIColorSecondaryText
            . " BackgroundTrans Hidden",
            "Monkey EXP Grind controls will go here.`n"
            . "This mode is ready to be built next."
        )


    MonkeyExpTypeLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT TOWER TYPE",
            28,
            128,
            374,
            20,
            8,
            "Left",
            false
        )


    MonkeyExpScriptLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT TOWER",
            28,
            191,
            374,
            20,
            8,
            "Left",
            false
        )


    queueButtonsEnabled := AreQueueLauncherButtonsEnabled()

    RunButton :=
        CreateDarkButton(
            LauncherGui,
            28,
            282,
            queueButtonsEnabled ? 240 : 374,
            38,
            "SELECT SCRIPT",
            8
        )


    if queueButtonsEnabled {
        AddQueueButton :=
            CreateDarkButton(
                LauncherGui,
                276,
                282,
                126,
                38,
                "ADD QUEUE",
                8
            )
    } else {
        AddQueueButton := ""
    }


    CloseButton :=
        CreateDarkButton(
            LauncherGui,
            300,
            403,
            102,
            40,
            "CLOSE",
            8
        )


    RunButton.OnEvent(
        "Click",
        RunCurrentMode
    )


    if queueButtonsEnabled {
        AddQueueButton.OnEvent(
            "Click",
            QueueCurrentSelection
        )

        QueueButton :=
            CreateDarkButton(
                LauncherGui,
                28,
                328,
                116,
                38,
                "QUEUE (0)",
                8
            )
    } else {
        QueueButton := ""
    }


    ModeButton :=
        CreateDarkButton(
            LauncherGui,
            queueButtonsEnabled ? 152 : 28,
            328,
            queueButtonsEnabled ? 116 : 183,
            38,
            "MODES",
            8
        )


    SettingsButton :=
        CreateDarkButton(
            LauncherGui,
            queueButtonsEnabled ? 276 : 219,
            328,
            queueButtonsEnabled ? 126 : 183,
            38,
            "SETTINGS",
            8
        )


    if queueButtonsEnabled {
        QueueButton.OnEvent(
            "Click",
            ShowQueueManager
        )
    }


    SettingsButton.OnEvent(
        "Click",
        ShowSettingsUI
    )


    CloseButton.OnEvent(
        "Click",
        RequestCloseLauncher
    )



    CreateHelpBadgeForButton(
        LauncherGui,
        RunButton,
        "PRIMARY ACTION",
        "Default Mode opens the strategy picker.`n`nMonkey EXP Grind starts the selected grind script.`n`nIf your queue has jobs, this button becomes START QUEUE."
    )


    if queueButtonsEnabled {
        CreateHelpBadgeForButton(
            LauncherGui,
            AddQueueButton,
            "ADD QUEUE",
            "Adds a new job to your queue.`n`nChoose the job type and script, then choose how many times it should run."
        )

        CreateHelpBadgeForButton(
            LauncherGui,
            QueueButton,
            "QUEUE",
            "Opens the Queue Manager.`n`nJobs run from top to bottom. You can edit their order, remove jobs, clear the queue, or start it."
        )
    }


    CreateHelpBadgeForButton(
        LauncherGui,
        ModeButton,
        "MODES",
        "Changes what kind of macro you want to run.`n`nUse this to switch between Map Scripts and Monkey EXP Grind."
    )


    CreateHelpBadgeForButton(
        LauncherGui,
        SettingsButton,
        "SETTINGS",
        "Opens Settings.`n`nManage confirmations, queue buttons, retry behavior, Run History, and per-run diagnostic logs."
    )


    CreateHelpBadgeForButton(
        LauncherGui,
        CloseButton,
        "CLOSE",
        "Closes BTD6 Everything Macro.`n`nAny queue that has not been saved as a Queue Profile will be lost when the launcher closes."
    )



    ModeButton.OnEvent(
        "Click",
        ShowModePicker
    )


    ; The footer uses the same surface color as the launcher so status and
    ; update text never render as mismatched opaque rectangles.
    StatusIndicator := LauncherGui.Add(
        "Progress",
        "x28 y419 w8 h8 c" . UIColorSuccess
        . " Background" . UIColorSuccess . " Disabled",
        100
    )


    SetUIBodyFont(LauncherGui, 9, UIColorSuccess)
    StatusText := LauncherGui.Add(
        "Text",
        "x43 y414 w238 h18 Left +0x200 c" . UIColorSuccess,
        "READY"
    )


    SetUIBodyFont(LauncherGui, 8, UIColorMutedText)
    UpdateCheckText := LauncherGui.Add(
        "Text",
        "x43 y439 w238 h15 Left c" . UIColorMutedText . " Hidden",
        ""
    )


    SetUIBodyFont(LauncherGui, 8, UIColorAccent)
    UpdateLinkText := LauncherGui.Add(
        "Text",
        "x194 y439 w92 h15 Left c" . UIColorAccent . " Hidden",
        "Update"
    )


    UpdateLinkText.SetFont("Underline")
    UpdateLinkText.OnEvent("Click", OpenUpdateRepository)


    MapDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            28,
            194,
            374,
            initialMaps,
            1,
            5
        )


    CategoryDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            28,
            127,
            374,
            categories,
            1,
            5
        )


    MonkeyExpTypeDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            28,
            149,
            374,
            GetMonkeyExpTowerTypes(),
            1,
            5
        )


    MonkeyExpScriptDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            28,
            212,
            374,
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
            "Click ☆ to favorite the selected map.`n`n★ means it is already a favorite. Favorites appear at the top of map lists."
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
            "Click ☆ to favorite the selected EXP script.`n`n★ means it is already a favorite. Favorites appear at the top of EXP script lists."
        )


    MonkeyExpFavoriteButton.Visible := false
    MonkeyExpFavoriteHelpBadge.Visible := false


    CategoryHelpBadge :=
        CreateHelpBadgeForField(
            LauncherGui,
            CategoryDropdown,
            CategoryLabel,
            "CATEGORY",
            "Choose a map category, such as Beginner or Expert.`n`nThe Map list updates automatically to show maps from that category."
        )


    MapHelpBadge :=
        CreateHelpBadgeForField(
            LauncherGui,
            MapDropdown,
            MapLabel,
            "MAP",
            "Choose the map you want to run.`n`nOnly maps that have at least one usable strategy are shown."
        )


    MonkeyExpTypeHelpBadge :=
        CreateHelpBadgeForField(
            LauncherGui,
            MonkeyExpTypeDropdown,
            MonkeyExpTypeLabel,
            "TOWER TYPE",
            "Choose the tower group: Primary, Military, Magic, or Support.`n`nThe Tower Script list then shows scripts from that group."
        )


    MonkeyExpScriptHelpBadge :=
        CreateHelpBadgeForField(
            LauncherGui,
            MonkeyExpScriptDropdown,
            MonkeyExpScriptLabel,
            "TOWER SCRIPT",
            "Choose the exact Monkey EXP Grind script to run.`n`nThe .ahk filename is shown exactly as it appears in the folder."
        )


    MonkeyExpTypeHelpBadge.Visible := false
    MonkeyExpScriptHelpBadge.Visible := false


    CategoryDropdown.OnEvent(
        "Change",
        OnCategoryChanged
    )


    MapDropdown.OnEvent(
        "Change",
        OnLauncherMapChanged
    )


    MonkeyExpTypeDropdown.OnEvent(
        "Change",
        OnMonkeyExpTypeChanged
    )


    MonkeyExpScriptDropdown.OnEvent(
        "Change",
        OnLauncherExpScriptChanged
    )


    LauncherGui.OnEvent(
        "Close",
        RequestCloseLauncher
    )


    LauncherGui.Show(
        "Hide w"
        . GuiWidth
        . " h"
        . GuiHeight
    )


    ApplyModernWindowStyle()


    RestoreLauncherState()


    UpdateLauncherMapFavoriteButton()
    UpdateLauncherExpFavoriteButton()


    ApplyLauncherMode()
    UpdateQueueLauncherButton()


    ShowLauncher(
        true
    )
}


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

            if LaunchMapScript(
                script.path
            ) {
                RememberLastRunStrategy(
                    script.path
                )
            }
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


    ; Keep the main launcher visible while the user chooses the run count.
    ; It is only hidden after a valid run is confirmed and startup begins.
    ClearLauncherReturnPending()
    SetLauncherRunSuppressed(false)
    ShowLauncher(true)


    runCount :=
        PromptForRunCount()


    if runCount = 0 {

        ShowLauncher(true)

        return false
    }


    ForceLauncherVisible :=
        false


    SetLauncherRunSuppressed(true)


    SetRunHistoryCurrentSource(
        "MANUAL RUN"
    )


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


StartNextQueuedRun(isRetry := false, defeatRestart := false) {
    global MacroRunning
    global RunningPid
    global ActiveRunToken
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


    if (
        !isRetry
        && RepeatRunRemaining < 1
    ) {

        return false
    }


    if !FileExist(
        RepeatScriptPath
    ) {

        MacroRunning :=
            false


        RunningPid :=
            0


        ClearChildRunResult(ActiveRunToken)
        ActiveRunToken := ""


        HideCycleStatusUI()


        ClearRepeatRunState()
        ClearQueueExecutionState()


        UpdateStatus(
            "SCRIPT NOT FOUND",
            UIColorError
        )


        RecordRunHistoryFailure(
            "SCRIPT NOT FOUND"
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


    ; Optional Daily Chest check runs before normal map launches.
    ; A defeat-restart retry is already inside the restarted map, so
    ; do not click Home-screen Daily Chest coordinates during recovery.
    if !defeatRestart
        RunPreMapDailyChestIfEnabled()


    ActiveRunToken := CreateChildRunToken()
    ClearChildRunResult(ActiveRunToken)


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
        . " "
        . Chr(34)
        . "--btd6-run-token="
        . ActiveRunToken
        . Chr(34)


    if defeatRestart {
        command .=
            " "
            . Chr(34)
            . "--btd6-defeat-restart=1"
            . Chr(34)
    }


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


        if !isRetry {
            RepeatRunRemaining--
        }


        return true
    }
    catch Error as err {

        MacroRunning :=
            false


        RunningPid :=
            0


        ClearChildRunResult(ActiveRunToken)
        ActiveRunToken := ""


        HideCycleStatusUI()


        ClearRepeatRunState()
        ClearQueueExecutionState()
        ClearCycleStopRequest()


        UpdateStatus(
            "FAILED TO START",
            UIColorError
        )


        RecordRunHistoryFailure(
            "FAILED TO START"
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
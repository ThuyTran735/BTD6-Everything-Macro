#Requires AutoHotkey v2.0


CreateLauncherUI() {
    global LauncherGui

    global SubtitleText

    global CategoryLabel
    global CategoryDropdown

    global MapLabel
    global MapDropdown

    global HotkeyText

    global ParagonTitle
    global ParagonDescription

    global StatusText

    global RunButton
    global ConfigButton
    global ModeButton
    global LogsButton

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
        "BTD6 Everything Macro"
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
        "x21 y53 w205 h20 c"
        . UIColorMutedText
        . " BackgroundTrans",
        "Made By @Thuy_"
        . Chr(8202)
        . "_"
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


    ParagonTitle :=
        AddUIOutlinedText(
            LauncherGui,
            "PARAGON XP FARM",
            20,
            110,
            350,
            38,
            13,
            "Center",
            false
        )


    SetUIBodyFont(
        LauncherGui,
        9,
        UIColorSecondaryText
    )


    ParagonDescription :=
        LauncherGui.Add(
            "Text",
            "x35 y157 w320 h65 Center c"
            . UIColorSecondaryText
            . " BackgroundTrans Hidden",
            "Paragon XP Farm controls will go here.`n"
            . "This mode is ready to be built next."
        )


    RunButton :=
        CreateDarkButton(
            LauncherGui,
            20,
            250,
            350,
            44,
            "RUN MACRO",
            9
        )


    RunButton.OnEvent(
        "Click",
        RunCurrentMode
    )


    ConfigButton :=
        CreateDarkButton(
            LauncherGui,
            20,
            306,
            110,
            36,
            "CONFIGS",
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


    ConfigButton.Enabled :=
        false


    LogsButton.Enabled :=
        false


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
            6
        )


    CategoryDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            20,
            118,
            350,
            categories,
            1,
            6
        )


    CategoryDropdown.OnEvent(
        "Change",
        OnCategoryChanged
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


    ApplyLauncherMode()


    ShowLauncher(
        true
    )
}


RunCurrentMode(*) {
    global CurrentMode


    CloseAllDarkDropdowns()


    if CurrentMode = "Default" {

        RunDefaultMode()

        return
    }


    if CurrentMode
        = "Paragon XP Farm" {

        RunParagonXPMode()

        return
    }


    if CurrentMode
        = "Monkey Money Grind" {

        RunMonkeyMoneyGrindMode()

        return
    }
}


RunParagonXPMode() {
    global UIColorWarning


    UpdateStatus(
        "PARAGON FARM NOT SET UP YET",
        UIColorWarning
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
            -2500
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


PromptForRunCount() {
    return ShowCycleInputPrompt()
}


LaunchMapScript(
    scriptPath
) {
    global MacroRunning
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


    CloseAllDarkDropdowns()
    CloseModePicker()
    CloseScriptPicker()


    ; Replace the launcher with the fake loading
    ; screen before cycle 1 begins.
    LauncherGui.Hide()


    RunStartupLoadingAnimation()


    MacroRunning :=
        true


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


        UpdateStatus(
            "SCRIPT NOT FOUND",
            UIColorError
        )


        ShowLauncher(
            true
        )


        return false
    }


    currentRun :=
        RepeatRunCompleted
        + 1


    UpdateStatus(
        "STARTING RUN "
        . currentRun
        . " OF "
        . RepeatRunTotal
        . "...",
        UIColorWarning
    )


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
        ClearCycleStopRequest()


        UpdateStatus(
            "FAILED TO START",
            UIColorError
        )


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
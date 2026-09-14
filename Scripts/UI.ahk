#Requires AutoHotkey v2.0


global LauncherGui := ""
global CategoryDropdown := ""
global MapDropdown := ""
global StatusText := ""
global RunButton := ""
global ConfigButton := ""
global LogsButton := ""

global ScriptPickerGui := ""
global ScriptPickerState := ""

global MacroRunning := false
global RunningPid := 0

global GuiWidth := 390
global GuiHeight := 390

global GuiX := 0
global GuiY := 0

global CategoryData := Map()


CreateLauncherUI() {
    global LauncherGui
    global CategoryDropdown
    global MapDropdown
    global StatusText
    global RunButton
    global ConfigButton
    global LogsButton

    global GuiWidth
    global GuiHeight


    categories := GetConfiguredCategories()


    LauncherGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "BTD6 Everything Macro"
    )


    LauncherGui.BackColor := "0F172A"


    LauncherGui.SetFont(
        "s10",
        "Segoe UI"
    )


    ; Blue accent line.
    LauncherGui.Add(
        "Progress",
        "x0 y0 w" GuiWidth " h5 Background2563EB c2563EB",
        100
    )


    ; Main title.
    LauncherGui.SetFont(
        "s16 Bold",
        "Segoe UI"
    )


    LauncherGui.Add(
        "Text",
        "x20 y20 w350 h28 cF8FAFC BackgroundTrans",
        "BTD6 Everything Macro"
    )


    ; Subtitle.
    LauncherGui.SetFont(
        "s9 Norm",
        "Segoe UI"
    )


    LauncherGui.Add(
        "Text",
        "x21 y51 w350 h20 c64748B BackgroundTrans",
        "Automation Control Center"
    )


    ; Divider.
    LauncherGui.Add(
        "Text",
        "x20 y79 w350 h1 0x10"
    )


    ; Category heading.
    LauncherGui.SetFont(
        "s9 Bold",
        "Segoe UI"
    )


    LauncherGui.Add(
        "Text",
        "x20 y95 w350 h20 cCBD5E1 BackgroundTrans",
        "SELECT CATEGORY"
    )


    ; Category dropdown.
    LauncherGui.SetFont(
        "s10 Norm",
        "Segoe UI"
    )


    CategoryDropdown := LauncherGui.Add(
        "DropDownList",
        "x20 y118 w350 Choose1",
        categories
    )


    CategoryDropdown.OnEvent(
        "Change",
        OnCategoryChanged
    )


    ; Map heading.
    LauncherGui.SetFont(
        "s9 Bold",
        "Segoe UI"
    )


    LauncherGui.Add(
        "Text",
        "x20 y158 w350 h20 cCBD5E1 BackgroundTrans",
        "SELECT MAP"
    )


    initialMaps := []


    if (
        categories.Length > 0
        && categories[1] != "No configured categories"
    ) {
        initialMaps := GetMapNamesForCategory(
            categories[1]
        )
    }


    if initialMaps.Length = 0 {
        initialMaps.Push(
            "No configured maps"
        )
    }


    ; Map dropdown.
    LauncherGui.SetFont(
        "s10 Norm",
        "Segoe UI"
    )


    MapDropdown := LauncherGui.Add(
        "DropDownList",
        "x20 y181 w350 Choose1",
        initialMaps
    )


    ; Hotkey display.
    LauncherGui.Add(
        "Text",
        "x20 y221 w350 h20 Center c94A3B8 BackgroundTrans",
        "Run Hotkey   •   Ctrl + Shift + P"
    )


    ; Run button.
    LauncherGui.SetFont(
        "s11 Bold",
        "Segoe UI"
    )


    RunButton := LauncherGui.Add(
        "Button",
        "x20 y250 w350 h44 Default",
        "RUN MACRO"
    )


    RunButton.OnEvent(
        "Click",
        RunSelectedMap
    )


    ; Config and Logs buttons.
    LauncherGui.SetFont(
        "s9 Bold",
        "Segoe UI"
    )


    ConfigButton := LauncherGui.Add(
        "Button",
        "x20 y306 w170 h36",
        "CONFIGS"
    )


    LogsButton := LauncherGui.Add(
        "Button",
        "x200 y306 w170 h36",
        "LOGS"
    )


    ConfigButton.Enabled := false
    LogsButton.Enabled := false


    ; Status display.
    StatusText := LauncherGui.Add(
        "Text",
        "x20 y356 w350 h20 Center c22C55E BackgroundTrans",
        "READY"
    )


    LauncherGui.OnEvent(
        "Close",
        (*) => ExitApp()
    )


    ; Create the window invisibly first.
    ; This lets us measure its real outer size.
    LauncherGui.Show(
        "Hide w" GuiWidth
        . " h" GuiHeight
    )


    ApplyModernWindowStyle()


    ShowLauncher(
        true
    )
}


GetConfiguredCategories() {
    global CategoryData


    CategoryData := Map()

    categories := []


    mapsRoot := A_ScriptDir "\Maps"


    if !DirExist(
        mapsRoot
    ) {
        categories.Push(
            "No configured categories"
        )

        return categories
    }


    ; Normal BTD6 category order.
    preferredCategories := [
        "Beginner",
        "Intermediate",
        "Advanced",
        "Expert"
    ]


    for categoryName in preferredCategories {

        categoryDirectory :=
            mapsRoot
            . "\"
            . categoryName


        if !DirExist(
            categoryDirectory
        ) {
            continue
        }


        data := BuildCategoryData(
            categoryDirectory
        )


        ; Hide categories that currently
        ; contain no runnable map scripts.
        if data.names.Length = 0 {
            continue
        }


        CategoryData[
            categoryName
        ] := data


        categories.Push(
            categoryName
        )
    }


    ; Also allow additional category folders
    ; to be discovered automatically.
    Loop Files mapsRoot "\*", "D" {

        categoryName := A_LoopFileName

        categoryDirectory :=
            A_LoopFileFullPath


        if CategoryData.Has(
            categoryName
        ) {
            continue
        }


        data := BuildCategoryData(
            categoryDirectory
        )


        if data.names.Length = 0 {
            continue
        }


        CategoryData[
            categoryName
        ] := data


        categories.Push(
            categoryName
        )
    }


    if categories.Length = 0 {
        categories.Push(
            "No configured categories"
        )
    }


    return categories
}


BuildCategoryData(
    categoryDirectory
) {
    mapNames := []

    mapDirectories := Map()


    ; Every direct folder underneath the
    ; category folder is treated as a map.
    Loop Files categoryDirectory "\*", "D" {

        mapName := A_LoopFileName

        mapDirectory :=
            A_LoopFileFullPath


        ; Only show maps with at least one
        ; .ahk strategy under Easy, Medium,
        ; or Hard.
        if !MapHasRunnableScripts(
            mapDirectory
        ) {
            continue
        }


        mapNames.Push(
            mapName
        )


        mapDirectories[
            mapName
        ] := mapDirectory
    }


    return {
        names: mapNames,
        directories: mapDirectories
    }
}


GetMapNamesForCategory(
    categoryName
) {
    global CategoryData


    maps := []


    if !CategoryData.Has(
        categoryName
    ) {
        return maps
    }


    data := CategoryData[
        categoryName
    ]


    for mapName in data.names {

        maps.Push(
            mapName
        )
    }


    return maps
}


OnCategoryChanged(*) {
    global CategoryDropdown
    global MapDropdown


    categoryName :=
        CategoryDropdown.Text


    maps := GetMapNamesForCategory(
        categoryName
    )


    MapDropdown.Delete()


    if maps.Length = 0 {

        MapDropdown.Add(
            [
                "No configured maps"
            ]
        )
    }
    else {

        MapDropdown.Add(
            maps
        )
    }


    MapDropdown.Choose(
        1
    )


    UpdateStatus(
        "READY",
        "22C55E"
    )
}


MapHasRunnableScripts(
    mapDirectory
) {
    difficulties := [
        "Easy",
        "Medium",
        "Hard"
    ]


    for difficulty in difficulties {

        difficultyDirectory :=
            mapDirectory
            . "\"
            . difficulty


        if !DirExist(
            difficultyDirectory
        ) {
            continue
        }


        ; Search recursively so mode-specific
        ; subfolders are supported later too.
        Loop Files difficultyDirectory "\*.ahk", "R" {

            return true
        }
    }


    return false
}


GetMapScripts(
    mapDirectory
) {
    scripts := Map(
        "Easy", [],
        "Medium", [],
        "Hard", []
    )


    difficulties := [
        "Easy",
        "Medium",
        "Hard"
    ]


    for difficulty in difficulties {

        difficultyDirectory :=
            mapDirectory
            . "\"
            . difficulty


        if !DirExist(
            difficultyDirectory
        ) {
            continue
        }


        Loop Files difficultyDirectory "\*.ahk", "R" {

            scripts[
                difficulty
            ].Push(
                {
                    name: A_LoopFileName,
                    path: A_LoopFileFullPath
                }
            )
        }
    }


    return scripts
}


CountMapScripts(
    scripts
) {
    total := 0


    total += scripts[
        "Easy"
    ].Length


    total += scripts[
        "Medium"
    ].Length


    total += scripts[
        "Hard"
    ].Length


    return total
}


GetOnlyMapScript(
    scripts
) {
    difficulties := [
        "Easy",
        "Medium",
        "Hard"
    ]


    for difficulty in difficulties {

        if scripts[
            difficulty
        ].Length = 1 {

            return scripts[
                difficulty
            ][1]
        }
    }


    return false
}


RefreshLauncherLists() {
    global CategoryDropdown
    global MapDropdown


    categories :=
        GetConfiguredCategories()


    CategoryDropdown.Delete()


    CategoryDropdown.Add(
        categories
    )


    CategoryDropdown.Choose(
        1
    )


    maps := []


    if (
        categories.Length > 0
        && categories[1] != "No configured categories"
    ) {
        maps := GetMapNamesForCategory(
            categories[1]
        )
    }


    MapDropdown.Delete()


    if maps.Length = 0 {

        MapDropdown.Add(
            [
                "No configured maps"
            ]
        )
    }
    else {

        MapDropdown.Add(
            maps
        )
    }


    MapDropdown.Choose(
        1
    )
}


PositionLauncher() {
    global LauncherGui

    global GuiWidth
    global GuiHeight

    global GuiX
    global GuiY


    ; This project uses only 1920 x 1080.
    ;
    ; We intentionally use the physical
    ; screen dimensions instead of the
    ; Windows work area so the launcher
    ; sits flush with the bottom-right.
    screenLeft := 0
    screenTop := 0
    screenRight := 1920
    screenBottom := 1080


    windowWidth := GuiWidth
    windowHeight := GuiHeight


    ; Get the real outside dimensions,
    ; including title bar and borders.
    rect := Buffer(
        16,
        0
    )


    gotRect := DllCall(
        "GetWindowRect",
        "Ptr",
        LauncherGui.Hwnd,
        "Ptr",
        rect.Ptr,
        "Int"
    )


    if gotRect {

        rectLeft := NumGet(
            rect,
            0,
            "Int"
        )


        rectTop := NumGet(
            rect,
            4,
            "Int"
        )


        rectRight := NumGet(
            rect,
            8,
            "Int"
        )


        rectBottom := NumGet(
            rect,
            12,
            "Int"
        )


        measuredWidth :=
            rectRight - rectLeft


        measuredHeight :=
            rectBottom - rectTop


        if measuredWidth > 0 {

            windowWidth :=
                measuredWidth
        }


        if measuredHeight > 0 {

            windowHeight :=
                measuredHeight
        }
    }


    ; Flush with physical bottom-right.
    GuiX :=
        screenRight
        - windowWidth


    GuiY :=
        screenBottom
        - windowHeight


    ; Safety clamps.
    if GuiX < screenLeft
        GuiX := screenLeft


    if GuiY < screenTop
        GuiY := screenTop


    if (
        GuiX
        + windowWidth
        > screenRight
    ) {
        GuiX :=
            screenRight
            - windowWidth
    }


    if (
        GuiY
        + windowHeight
        > screenBottom
    ) {
        GuiY :=
            screenBottom
            - windowHeight
    }


    GuiX := Round(
        GuiX
    )


    GuiY := Round(
        GuiY
    )
}


ShowLauncher(
    activate := false
) {
    global LauncherGui

    global GuiWidth
    global GuiHeight

    global GuiX
    global GuiY


    PositionLauncher()


    options :=
        "x" GuiX
        . " y" GuiY
        . " w" GuiWidth
        . " h" GuiHeight


    if !activate {

        options :=
            "NA "
            . options
    }


    LauncherGui.Show(
        options
    )
}


HideLauncher() {
    global LauncherGui


    if IsLauncherVisible()
        LauncherGui.Hide()
}


ApplyModernWindowStyle() {
    global LauncherGui


    ; Dark Windows title bar.
    try {

        darkMode := Buffer(
            4,
            0
        )


        NumPut(
            "Int",
            1,
            darkMode,
            0
        )


        DllCall(
            "dwmapi\DwmSetWindowAttribute",
            "Ptr",
            LauncherGui.Hwnd,
            "Int",
            20,
            "Ptr",
            darkMode.Ptr,
            "Int",
            4
        )
    }


    ; Rounded Windows 11 corners.
    try {

        cornerPreference := Buffer(
            4,
            0
        )


        NumPut(
            "Int",
            2,
            cornerPreference,
            0
        )


        DllCall(
            "dwmapi\DwmSetWindowAttribute",
            "Ptr",
            LauncherGui.Hwnd,
            "Int",
            33,
            "Ptr",
            cornerPreference.Ptr,
            "Int",
            4
        )
    }
}


RunSelectedMap(*) {
    global MacroRunning

    global CategoryDropdown
    global MapDropdown
    global CategoryData


    if MacroRunning
        return


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
            "EF4444"
        )


        return
    }


    if (
        mapName = ""
        || mapName = "No configured maps"
    ) {

        UpdateStatus(
            "NO MAP SELECTED",
            "EF4444"
        )


        return
    }


    ; Rebuild directory information if
    ; something changed since launch.
    if !CategoryData.Has(
        categoryName
    ) {

        GetConfiguredCategories()
    }


    if !CategoryData.Has(
        categoryName
    ) {

        UpdateStatus(
            "CATEGORY NOT FOUND",
            "EF4444"
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

        ; Rebuild once in case a new map
        ; was added while the launcher
        ; was already open.
        GetConfiguredCategories()


        if !CategoryData.Has(
            categoryName
        ) {

            UpdateStatus(
                "MAP FOLDER NOT FOUND",
                "EF4444"
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
                "EF4444"
            )


            return
        }
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
            "EF4444"
        )


        return
    }


    scripts := GetMapScripts(
        mapDirectory
    )


    scriptCount :=
        CountMapScripts(
            scripts
        )


    if scriptCount = 0 {

        UpdateStatus(
            "NO STRATEGIES FOUND",
            "EF4444"
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


    ; If only one script exists across
    ; Easy / Medium / Hard, run it directly.
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


    ; Multiple scripts exist.
    ShowScriptPicker(
        mapName,
        mapDirectory,
        scripts
    )
}


ShowScriptPicker(
    mapName,
    mapDirectory,
    scripts
) {
    global ScriptPickerGui
    global ScriptPickerState


    ; Destroy an old picker if one
    ; somehow still exists.
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


    if availableDifficulties.Length = 0
        return


    ScriptPickerGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Select Strategy"
    )


    ScriptPickerGui.BackColor :=
        "0F172A"


    ; Map title.
    ScriptPickerGui.SetFont(
        "s14 Bold cF8FAFC",
        "Segoe UI"
    )


    ScriptPickerGui.Add(
        "Text",
        "x20 y18 w460 h28 cF8FAFC BackgroundTrans",
        mapName
    )


    ; Subtitle.
    ScriptPickerGui.SetFont(
        "s9 Norm c94A3B8",
        "Segoe UI"
    )


    ScriptPickerGui.Add(
        "Text",
        "x21 y48 w460 h20 c94A3B8 BackgroundTrans",
        "Choose the strategy you want to run"
    )


    tabNames := []


    for difficulty in availableDifficulties {

        tabNames.Push(
            difficulty
        )
    }


    ; Difficulty tabs.
    ScriptPickerGui.SetFont(
        "s9 Bold cF8FAFC",
        "Segoe UI"
    )


    tabs := ScriptPickerGui.Add(
        "Tab3",
        "x20 y78 w460 h250 Background0F172A cF8FAFC",
        tabNames
    )


    ; Disable the normal Windows theme
    ; for the difficulty tabs so the text
    ; doesn't appear as plain black.
    try {

        DllCall(
            "uxtheme\SetWindowTheme",
            "Ptr",
            tabs.Hwnd,
            "Str",
            "",
            "Str",
            ""
        )
    }


    listControls := Map()


    index := 0


    for difficulty in availableDifficulties {

        index++


        tabs.UseTab(
            index
        )


        names := []


        for script in scripts[
            difficulty
        ] {

            names.Push(
                script.name
            )
        }


        ; IMPORTANT:
        ;
        ; Tab text is white, but the native
        ; ListBox background is light.
        ;
        ; Explicitly switch the font back to
        ; BLACK before creating each ListBox.
        ;
        ; Without this, only the selected file
        ; appears visible because the other
        ; filenames become white-on-white.
        ScriptPickerGui.SetFont(
            "s9 Norm c000000",
            "Segoe UI"
        )


        listControl :=
            ScriptPickerGui.Add(
                "ListBox",
                "x40 y120 w420 h170 Choose1",
                names
            )


        listControl.OnEvent(
            "DoubleClick",
            RunPickedScript
        )


        listControls[
            difficulty
        ] := listControl
    }


    tabs.UseTab()


    ; Native buttons have light backgrounds,
    ; so reset text to black here as well.
    ScriptPickerGui.SetFont(
        "s9 Bold c000000",
        "Segoe UI"
    )


    runSelectedButton :=
        ScriptPickerGui.Add(
            "Button",
            "x20 y345 w220 h38 Default",
            "RUN SELECTED"
        )


    openFolderButton :=
        ScriptPickerGui.Add(
            "Button",
            "x260 y345 w220 h38",
            "OPEN MAP FOLDER"
        )


    cancelButton :=
        ScriptPickerGui.Add(
            "Button",
            "x20 y393 w460 h34",
            "CANCEL"
        )


    ScriptPickerState := {
        gui: ScriptPickerGui,
        tabs: tabs,
        lists: listControls,
        difficulties: availableDifficulties,
        scripts: scripts,
        mapDirectory: mapDirectory
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
        CloseScriptPicker
    )


    ScriptPickerGui.OnEvent(
        "Close",
        CloseScriptPicker
    )


    ; Create it invisibly first so the
    ; window exists before DWM styling.
    ScriptPickerGui.Show(
        "Hide w500 h445"
    )


    ApplyScriptPickerStyle()


    ScriptPickerGui.Show(
        "w500 h445 Center"
    )
}


RunPickedScript(*) {
    global ScriptPickerState


    if !IsObject(
        ScriptPickerState
    ) {

        return
    }


    tabIndex :=
        ScriptPickerState.tabs.Value


    if (
        tabIndex < 1
        || tabIndex > ScriptPickerState.difficulties.Length
    ) {

        return
    }


    difficulty :=
        ScriptPickerState.difficulties[
            tabIndex
        ]


    listControl :=
        ScriptPickerState.lists[
            difficulty
        ]


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


    CloseScriptPicker()


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


ApplyScriptPickerStyle() {
    global ScriptPickerGui


    ; Dark Windows title bar.
    try {

        darkMode := Buffer(
            4,
            0
        )


        NumPut(
            "Int",
            1,
            darkMode,
            0
        )


        DllCall(
            "dwmapi\DwmSetWindowAttribute",
            "Ptr",
            ScriptPickerGui.Hwnd,
            "Int",
            20,
            "Ptr",
            darkMode.Ptr,
            "Int",
            4
        )
    }


    ; Rounded Windows 11 corners.
    try {

        cornerPreference := Buffer(
            4,
            0
        )


        NumPut(
            "Int",
            2,
            cornerPreference,
            0
        )


        DllCall(
            "dwmapi\DwmSetWindowAttribute",
            "Ptr",
            ScriptPickerGui.Hwnd,
            "Int",
            33,
            "Ptr",
            cornerPreference.Ptr,
            "Int",
            4
        )
    }
}


LaunchMapScript(
    scriptPath
) {
    global MacroRunning
    global RunningPid
    global LauncherGui


    if MacroRunning
        return


    if !FileExist(
        scriptPath
    ) {

        UpdateStatus(
            "SCRIPT NOT FOUND",
            "EF4444"
        )


        return
    }


    UpdateStatus(
        "STARTING...",
        "F59E0B"
    )


    MacroRunning := true


    ; Hide launcher before starting
    ; the strategy so it cannot interfere
    ; with FindText.
    LauncherGui.Hide()


    command :=
        Chr(34)
        . A_AhkPath
        . Chr(34)
        . " "
        . Chr(34)
        . scriptPath
        . Chr(34)


    try {

        Run(
            command,
            A_ScriptDir,
            ,
            &RunningPid
        )
    }
    catch Error as err {

        MacroRunning := false

        RunningPid := 0


        UpdateStatus(
            "FAILED TO START",
            "EF4444"
        )


        ShowLauncher(
            true
        )


        MsgBox(
            "Could not start the selected macro.`n`n"
            . err.Message,
            "BTD6 Macro"
        )
    }
}


MonitorLauncherState() {
    global MacroRunning
    global RunningPid
    global LauncherGui


    ; Strategy launched from this UI
    ; is currently running.
    if MacroRunning {

        ; Child script finished.
        if (
            RunningPid
            && !ProcessExist(
                RunningPid
            )
        ) {

            MacroRunning := false

            RunningPid := 0


            UpdateStatus(
                "READY",
                "22C55E"
            )
        }
        else {

            ; Keep the launcher hidden while
            ; the child strategy is running.
            if IsLauncherVisible()
                LauncherGui.Hide()


            return
        }
    }


    ; Hide launcher while BTD6 is
    ; actually inside a game.
    if IsInGameScreen() {

        if IsLauncherVisible()
            LauncherGui.Hide()


        return
    }


    ; Show launcher again outside of a game.
    if !IsLauncherVisible() {

        ShowLauncher(
            false
        )
    }
}


IsInGameScreen() {
    global NavigationPatterns


    if !NavigationPatterns.Has(
        "Settings"
    ) {

        return false
    }


    return PatternExists(
        NavigationPatterns[
            "Settings"
        ]
    )
}


IsLauncherVisible() {
    global LauncherGui


    if !LauncherGui
        return false


    return !!DllCall(
        "IsWindowVisible",
        "Ptr",
        LauncherGui.Hwnd
    )
}


UpdateStatus(
    text,
    color := "22C55E"
) {
    global StatusText


    if !StatusText
        return


    StatusText.SetFont(
        "c" color
    )


    StatusText.Text :=
        text
}
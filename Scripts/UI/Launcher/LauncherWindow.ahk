#Requires AutoHotkey v2.0

; Build the launcher once, then let mode changes reuse its controls.
; Keep selection, action, and status rows aligned when queue buttons are hidden.

UpdateLauncherActionLayout() {
    global CurrentMode, RunButton, AddQueueButton, QueueButton, ModeButton, SettingsButton
    global LauncherRunHelpBadge, LauncherAddQueueHelpBadge, LauncherQueueHelpBadge
    global LauncherModeHelpBadge, LauncherSettingsHelpBadge

    if !IsSet(RunButton) || !IsObject(RunButton)
        return

    ; Event mode chooses its next map every cycle. Queue jobs stay saved in
    ; memory for the other modes, but have no controls on this screen.
    showQueue := CurrentMode != "Auto Collection Event" && AreQueueLauncherButtonsEnabled()
    for button in [AddQueueButton, QueueButton, LauncherAddQueueHelpBadge, LauncherQueueHelpBadge] {
        if IsObject(button) && button.Visible != showQueue
            button.Visible := showQueue
    }

    MoveLauncherActionWithHelp(RunButton, LauncherRunHelpBadge, 36, 282, showQueue ? 236 : 358)
    MoveLauncherActionWithHelp(ModeButton, LauncherModeHelpBadge, showQueue ? 158 : 36, 328, showQueue ? 114 : 175)
    MoveLauncherActionWithHelp(SettingsButton, LauncherSettingsHelpBadge, showQueue ? 280 : 219, 328, showQueue ? 114 : 175)
}

MoveLauncherActionWithHelp(button, badge, x, y, width) {
    if !IsObject(button) || (button.X = x && button.Y = y && button.Width = width)
        return

    MoveLauncherActionSurface(button, x, y, width)
    if IsObject(badge) {
        MoveLauncherActionSurface(badge, x + width - badge.Width - 3, y + 3, badge.Width)
        button.ProtectTopRightOverlay(badge.X, badge.Y, badge.Width, badge.Height, 1)
    }
}

MoveLauncherActionSurface(button, x, y, width) {
    ; Keep the existing controls and their callbacks. Moving every drawn
    ; layer together also keeps the hover animation and help hit areas aligned.
    button.X := x
    button.Y := y
    button.Width := width
    height := button.Height
    button.Glow.Move(x - 2, y - 2, width + 4, height + 4)
    button.Border.Move(x - 1, y - 1, width + 2, height + 2)
    button.Top.Move(x, y, width, button.IsFlatFace ? height : Ceil(height / 2))
    button.Bottom.Move(x, y + Ceil(height / 2), width, Floor(height / 2))
    button.Highlight.Move(x + 1, y + 1, width - 2, 2)
    button.TextX := x
    button.TextWidth := width
    button.LastTextOffset := -999
    button.SetTextOffset(0)

    ; Windows can restore a native Progress edge when its size changes.
    for surface in [button.Glow, button.Border, button.Top, button.Bottom, button.Highlight] {
        surface.Opt("-0x800000 -E0x200 -E0x20000")
        DllCall("SetWindowPos", "Ptr", surface.Hwnd, "Ptr", 0,
            "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x37)
    }
}

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
    global LauncherRunHelpBadge
    global LauncherAddQueueHelpBadge
    global LauncherQueueHelpBadge
    global LauncherModeHelpBadge
    global LauncherSettingsHelpBadge

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

    AddUICard(LauncherGui, 24, 92, 382, 166)
    AddUICard(LauncherGui, 24, 270, 382, 106)
    AddUICard(LauncherGui, 24, 388, 382, 70)


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
            36,
            104,
            358,
            20,
            8
        )


    MapLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT MAP",
            36,
            171,
            358,
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
            "x36 y234 w358 h18 Center c"
            . UIColorSecondaryText
            . " BackgroundTrans",
            "Run Hotkey   •   Ctrl + Shift + P"
        )


    MonkeyExpTitle :=
        AddUIOutlinedText(
            LauncherGui,
            "MONKEY EXP GRIND",
            36,
            102,
            358,
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
            36,
            128,
            358,
            20,
            8,
            "Left",
            false
        )


    MonkeyExpScriptLabel :=
        AddUIOutlinedText(
            LauncherGui,
            "SELECT TOWER",
            36,
            191,
            358,
            20,
            8,
            "Left",
            false
        )


    queueButtonsEnabled := AreQueueLauncherButtonsEnabled()

    RunButton :=
        CreateDarkButton(
            LauncherGui,
            36,
            282,
            queueButtonsEnabled ? 236 : 358,
            38,
            "SELECT SCRIPT",
            8
        )


    ; Keep optional controls alive so the setting can toggle their layout
    ; without replacing the launcher and losing its current selections.
    AddQueueButton :=
        CreateDarkButton(
            LauncherGui,
            280,
            282,
            114,
            38,
            "ADD QUEUE",
            8
        )


    CloseButton :=
        CreateDarkButton(
            LauncherGui,
            302,
            403,
            92,
            40,
            "CLOSE",
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
            36,
            328,
            114,
            38,
            "QUEUE (0)",
            8
        )


    ModeButton :=
        CreateDarkButton(
            LauncherGui,
            queueButtonsEnabled ? 158 : 36,
            328,
            queueButtonsEnabled ? 114 : 175,
            38,
            "MODES",
            8
        )


    SettingsButton :=
        CreateDarkButton(
            LauncherGui,
            queueButtonsEnabled ? 280 : 219,
            328,
            queueButtonsEnabled ? 114 : 175,
            38,
            "SETTINGS",
            8
        )


    QueueButton.OnEvent(
        "Click",
        ShowQueueManager
    )


    SettingsButton.OnEvent(
        "Click",
        ShowSettingsUI
    )


    CloseButton.OnEvent(
        "Click",
        RequestCloseLauncher
    )



    LauncherRunHelpBadge := CreateHelpBadgeForButton(
        LauncherGui,
        RunButton,
        "PRIMARY ACTION",
        "Default Mode opens the strategy picker.`nMonkey EXP Grind runs the selected script.`nAuto Collection Event runs Expert Impoppable until stopped and does not use the queue.`n`nIn the other modes, START QUEUE runs any queued jobs first."
    )


    LauncherAddQueueHelpBadge := CreateHelpBadgeForButton(
        LauncherGui,
        AddQueueButton,
        "ADD QUEUE",
        "Adds a new job to your queue.`n`nChoose the job type and script, then choose how many times it should run."
    )

    LauncherQueueHelpBadge := CreateHelpBadgeForButton(
        LauncherGui,
        QueueButton,
        "QUEUE",
        "Opens the Queue Manager.`n`nJobs run from top to bottom. You can edit their order, remove jobs, clear the queue, or start it."
    )


    LauncherModeHelpBadge := CreateHelpBadgeForButton(
        LauncherGui,
        ModeButton,
        "MODES",
        "Choose Default map scripts, Monkey EXP Grind, or Auto Collection Event.`n`nEvent mode runs Expert Impoppable until stopped. Monkey Money Grind is not available yet."
    )


    LauncherSettingsHelpBadge := CreateHelpBadgeForButton(
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
        "x36 y412 w8 h8 c" . UIColorSuccess
        . " Background" . UIColorSuccess . " Disabled",
        100
    )


    SetUIBodyFont(LauncherGui, 9, UIColorSuccess)
    StatusText := LauncherGui.Add(
        "Text",
        "x51 y406 w234 h20 Left +0x200 c" . UIColorSuccess,
        "READY"
    )


    SetUIBodyFont(LauncherGui, 8, UIColorMutedText)
    UpdateCheckText := LauncherGui.Add(
        "Text",
        "x51 y434 w234 h15 Left c" . UIColorMutedText . " Hidden",
        ""
    )


    SetUIBodyFont(LauncherGui, 8, UIColorAccent)
    UpdateLinkText := LauncherGui.Add(
        "Text",
        "x221 y434 w64 h15 Left c" . UIColorAccent . " Hidden",
        "Update"
    )


    UpdateLinkText.SetFont("Underline")
    UpdateLinkText.OnEvent("Click", OpenUpdateRepository)


    MapDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            36,
            194,
            358,
            initialMaps,
            1,
            5
        )


    CategoryDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            36,
            127,
            358,
            categories,
            1,
            5
        )


    MonkeyExpTypeDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            36,
            149,
            358,
            GetMonkeyExpTowerTypes(),
            1,
            5
        )


    MonkeyExpScriptDropdown :=
        CreateDarkDropdown(
            LauncherGui,
            36,
            212,
            358,
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



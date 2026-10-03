#Requires AutoHotkey v2.0

; v3 file note: Builds the main launcher window and wires its controls.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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



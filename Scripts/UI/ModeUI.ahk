#Requires AutoHotkey v2.0


ShowModePicker(*) {
    global ModePickerGui
    global CurrentMode

    global UIColorBackground
    global UIColorSecondaryText


    CloseAllDarkDropdowns()
    CloseAllSecondaryMenus()


    try {
        if ModePickerGui
            ModePickerGui.Destroy()
    }


    ModePickerGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Select Mode"
    )


    ModePickerGui.BackColor :=
        UIColorBackground


    EnableCustomWindowChrome(ModePickerGui)
    AddCustomWindowBorder(ModePickerGui, 360, 295)


    AddUIOutlinedText(
        ModePickerGui,
        "SELECT MODE",
        20,
        18,
        320,
        36,
        12,
        "Center"
    )


    SetUIBodyFont(
        ModePickerGui,
        9,
        UIColorSecondaryText
    )


    ModePickerGui.Add(
        "Text",
        "x20 y55 w320 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Choose how you want to run the macro"
    )


    modes := [
        "Default",
        "Monkey EXP Grind",
        "Monkey Money Grind"
    ]


    modeList :=
        CreateDarkList(
            ModePickerGui,
            20,
            90,
            320,
            120,
            modes,
            40
        )


    if CurrentMode = "Default" {

        modeList.Choose(
            1
        )
    }
    else if CurrentMode
        = "Monkey EXP Grind" {

        modeList.Choose(
            2
        )
    }
    else if CurrentMode
        = "Monkey Money Grind" {

        modeList.Choose(
            3
        )
    }
    else {

        modeList.Choose(
            1
        )
    }


    modeList.OnEvent(
        "DoubleClick",
        (*) => UseSelectedMode(
            modeList
        )
    )


    useButton :=
        CreateDarkButton(
            ModePickerGui,
            20,
            225,
            155,
            46,
            "USE SELECTED",
            9
        )


    cancelButton :=
        CreateDarkButton(
            ModePickerGui,
            185,
            225,
            155,
            46,
            "BACK",
            9
        )


    CreateHelpBadgeForButton(
        ModePickerGui,
        useButton,
        "USE SELECTED",
        "Uses the highlighted mode.`n`nThe main launcher changes its controls to match your selection."
    )


    CreateHelpBadgeForButton(
        ModePickerGui,
        cancelButton,
        "BACK",
        "Returns to the launcher without changing the current mode."
    )


    useButton.OnEvent(
        "Click",
        (*) => UseSelectedMode(
            modeList
        )
    )


    cancelButton.OnEvent(
        "Click",
        CloseModePickerAndReturnToLauncher
    )


    ModePickerGui.OnEvent(
        "Close",
        CloseModePickerAndReturnToLauncher
    )


    ModePickerGui.Show(
        "Hide w360 h295"
    )


    ApplyDarkWindowStyle(
        ModePickerGui
    )


    ModePickerGui.Show(
        "w360 h295 Center"
    )
}


UseSelectedMode(
    modeList
) {
    selectedIndex :=
        modeList.Value


    if selectedIndex < 1 {

        ToolTip(
            "Select a mode first."
        )


        SetTimer(
            () => ToolTip(),
            -1500
        )


        return
    }


    selectedMode :=
        modeList.Text


    SelectLauncherMode(
        selectedMode
    )
}


SelectLauncherMode(
    modeName
) {
    global CurrentMode


    CurrentMode :=
        modeName


    CloseModePicker()


    ApplyLauncherMode()
    ShowLauncher(true)
}


ApplyLauncherMode() {
    global CurrentMode

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

    global CategoryHelpBadge
    global MapHelpBadge
    global MapFavoriteHelpBadge
    global MonkeyExpTypeHelpBadge
    global MonkeyExpScriptHelpBadge
    global MonkeyExpFavoriteHelpBadge

    global MapFavoriteButton
    global MonkeyExpFavoriteButton

    global RunButton
    global AddQueueButton

    global UIColorSuccess
    global UIColorWarning


    if CurrentMode = "Default" {

        SubtitleText.Text :=
            "Default Mode"


        CategoryLabel.Visible := true
        CategoryDropdown.Visible := true

        MapLabel.Visible := true
        MapDropdown.Visible := true

        HotkeyText.Visible := true


        MonkeyExpTitle.Visible := false
        MonkeyExpDescription.Visible := false
        MonkeyExpTypeLabel.Visible := false
        MonkeyExpTypeDropdown.Visible := false
        MonkeyExpScriptLabel.Visible := false
        MonkeyExpScriptDropdown.Visible := false

        CategoryHelpBadge.Visible := true
        MapHelpBadge.Visible := true
        MapFavoriteHelpBadge.Visible := true
        MonkeyExpTypeHelpBadge.Visible := false
        MonkeyExpScriptHelpBadge.Visible := false
        MonkeyExpFavoriteHelpBadge.Visible := false

        MapFavoriteButton.Visible := true
        MonkeyExpFavoriteButton.Visible := false
        UpdateLauncherMapFavoriteButton()


        RunButton.Enabled := true
        if AddQueueButton {
            AddQueueButton.Enabled := true
        }

        RunButton.Text :=
            "SELECT SCRIPT"


        UpdateStatus(
            "READY",
            UIColorSuccess
        )


        UpdateQueueLauncherButton()


        return
    }


    if CurrentMode
        = "Monkey EXP Grind" {

        SubtitleText.Text :=
            "Monkey EXP Grind Mode"


        CategoryLabel.Visible := false
        CategoryDropdown.Visible := false

        MapLabel.Visible := false
        MapDropdown.Visible := false

        HotkeyText.Visible := false


        MonkeyExpTitle.Text :=
            "MONKEY EXP GRIND"


        MonkeyExpTitle.Visible := true
        MonkeyExpDescription.Visible := false
        MonkeyExpTypeLabel.Visible := true
        MonkeyExpTypeDropdown.Visible := true
        MonkeyExpScriptLabel.Visible := true
        MonkeyExpScriptDropdown.Visible := true

        CategoryHelpBadge.Visible := false
        MapHelpBadge.Visible := false
        MapFavoriteHelpBadge.Visible := false
        MonkeyExpTypeHelpBadge.Visible := true
        MonkeyExpScriptHelpBadge.Visible := true
        MonkeyExpFavoriteHelpBadge.Visible := true

        MapFavoriteButton.Visible := false
        MonkeyExpFavoriteButton.Visible := true


        scriptCount :=
            RefreshMonkeyExpScripts(
                MonkeyExpTypeDropdown.Text
            )


        RunButton.Enabled :=
            scriptCount > 0

        if AddQueueButton {
            AddQueueButton.Enabled := true
        }

        RunButton.Text :=
            "START EXP GRIND"


        if scriptCount > 0 {

            UpdateStatus(
                scriptCount
                . " "
                . StrUpper(
                    MonkeyExpTypeDropdown.Text
                )
                . " SCRIPT"
                . (
                    scriptCount = 1
                    ? ""
                    : "S"
                )
                . " FOUND",
                UIColorSuccess
            )
        }
        else {

            UpdateStatus(
                "NO "
                . StrUpper(
                    MonkeyExpTypeDropdown.Text
                )
                . " SCRIPTS FOUND",
                UIColorWarning
            )
        }


        UpdateQueueLauncherButton()


        return
    }


    if CurrentMode
        = "Monkey Money Grind" {

        SubtitleText.Text :=
            "Monkey Money Grind Mode"


        CategoryLabel.Visible := false
        CategoryDropdown.Visible := false

        MapLabel.Visible := false
        MapDropdown.Visible := false

        HotkeyText.Visible := false


        MonkeyExpTitle.Text :=
            "MONKEY MONEY GRIND"


        MonkeyExpDescription.Text :=
            "Monkey Money Grind controls will go here.`n"
            . "This mode is ready to be built next."


        MonkeyExpTitle.Visible := true
        MonkeyExpDescription.Visible := true
        MonkeyExpTypeLabel.Visible := false
        MonkeyExpTypeDropdown.Visible := false
        MonkeyExpScriptLabel.Visible := false
        MonkeyExpScriptDropdown.Visible := false

        CategoryHelpBadge.Visible := false
        MapHelpBadge.Visible := false
        MapFavoriteHelpBadge.Visible := false
        MonkeyExpTypeHelpBadge.Visible := false
        MonkeyExpScriptHelpBadge.Visible := false
        MonkeyExpFavoriteHelpBadge.Visible := false

        MapFavoriteButton.Visible := false
        MonkeyExpFavoriteButton.Visible := false


        RunButton.Enabled := false
        if AddQueueButton {
            AddQueueButton.Enabled := true
        }

        RunButton.Text :=
            "MODE UNAVAILABLE"


        UpdateStatus(
            "MODE NOT CONFIGURED YET",
            UIColorWarning
        )


        UpdateQueueLauncherButton()


        return
    }
}


CloseModePickerAndReturnToLauncher(*) {
    CloseModePicker()
    ShowLauncher(true)
}


CloseModePicker(*) {
    global ModePickerGui


    try {
        if ModePickerGui
            ModePickerGui.Destroy()
    }


    ModePickerGui := ""
}
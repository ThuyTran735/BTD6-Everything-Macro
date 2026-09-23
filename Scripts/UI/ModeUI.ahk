#Requires AutoHotkey v2.0


ShowModePicker(*) {
    global ModePickerGui
    global CurrentMode

    global UIColorBackground
    global UIColorSecondaryText
    global UIColorPrimaryText


    CloseAllDarkDropdowns()
    CloseAllSecondaryMenus()


    try {
        if ModePickerGui
            ModePickerGui.Destroy()
    }


    uiWidth := 440
    uiHeight := 430


    ModePickerGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Select Mode"
    )


    ModePickerGui.BackColor :=
        UIColorBackground


    EnableCustomWindowChrome(ModePickerGui)
    AddCustomWindowBorder(ModePickerGui, uiWidth, uiHeight)

    ; Three clear layers: mode selection, mode details, and actions.
    AddUICard(ModePickerGui, 16, 84, 408, 164)
    AddUICard(ModePickerGui, 16, 258, 408, 86)
    AddUICard(ModePickerGui, 16, 354, 408, 60)


    AddUIOutlinedText(
        ModePickerGui,
        "SELECT MODE",
        20,
        18,
        400,
        34,
        13,
        "Center"
    )


    SetUIBodyFont(
        ModePickerGui,
        9,
        UIColorSecondaryText
    )


    ModePickerGui.Add(
        "Text",
        "x20 y55 w400 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Choose how the macro should run"
    )


    modes := [
        "Default",
        "Monkey EXP Grind",
        "Monkey Money Grind"
    ]


    modeList :=
        CreateDarkList(
            ModePickerGui,
            26,
            94,
            388,
            144,
            modes,
            48
        )


    if CurrentMode = "Default" {
        modeList.Choose(1)
    }
    else if CurrentMode = "Monkey EXP Grind" {
        modeList.Choose(2)
    }
    else if CurrentMode = "Monkey Money Grind" {
        modeList.Choose(3)
    }
    else {
        modeList.Choose(1)
    }


    SetUIBodyFont(
        ModePickerGui,
        9,
        UIColorPrimaryText
    )


    ; Use two independent single-line controls instead of a multiline
    ; SS_CENTERIMAGE text control. Windows can clip multiline centered static
    ; text horizontally, especially under DPI scaling.
    modeDescriptionLine1 :=
        ModePickerGui.Add(
            "Text",
            "x30 y278 w380 h20 Center c"
            . UIColorPrimaryText
            . " BackgroundTrans",
            ""
        )


    modeDescriptionLine2 :=
        ModePickerGui.Add(
            "Text",
            "x30 y303 w380 h20 Center c"
            . UIColorPrimaryText
            . " BackgroundTrans",
            ""
        )


    UpdateModePickerDescription(
        modeList,
        modeDescriptionLine1,
        modeDescriptionLine2
    )


    modeList.OnEvent(
        "Change",
        (*) => UpdateModePickerDescription(
            modeList,
            modeDescriptionLine1,
            modeDescriptionLine2
        )
    )


    modeList.OnEvent(
        "DoubleClick",
        (*) => UseSelectedMode(
            modeList
        )
    )


    useButton :=
        CreateDarkButton(
            ModePickerGui,
            26,
            364,
            245,
            40,
            "USE SELECTED",
            9
        )


    cancelButton :=
        CreateDarkButton(
            ModePickerGui,
            281,
            364,
            133,
            40,
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
        "Hide w"
        . uiWidth
        . " h"
        . uiHeight
    )


    ApplyDarkWindowStyle(
        ModePickerGui
    )


    ModePickerGui.Show(
        "w"
        . uiWidth
        . " h"
        . uiHeight
        . " Center"
    )
}


UpdateModePickerDescription(modeList, line1Control, line2Control) {
    selectedMode := modeList.Text


    if selectedMode = "Monkey EXP Grind" {
        line1Control.Text :=
            "Run tower-specific EXP scripts repeatedly"
        line2Control.Text :=
            "for the selected tower group."
        return
    }


    if selectedMode = "Monkey Money Grind" {
        line1Control.Text :=
            "Monkey Money Grind is a placeholder mode."
        line2Control.Text :=
            "Its controls are not implemented yet."
        return
    }


    line1Control.Text :=
        "Run configured map strategies using the launcher"
    line2Control.Text :=
        "category, map, and strategy controls."
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
    SaveLauncherState()
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
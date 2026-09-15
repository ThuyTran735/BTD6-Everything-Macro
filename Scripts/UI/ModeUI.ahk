#Requires AutoHotkey v2.0


ShowModePicker(*) {
    global ModePickerGui
    global CurrentMode

    global UIColorBackground
    global UIColorSecondaryText


    CloseAllDarkDropdowns()


    CloseScriptPicker()


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
        "Monkey EXP Grind Farm",
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
        = "Monkey EXP Grind Farm" {

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
            "CANCEL",
            9
        )


    useButton.OnEvent(
        "Click",
        (*) => UseSelectedMode(
            modeList
        )
    )


    cancelButton.OnEvent(
        "Click",
        CloseModePicker
    )


    ModePickerGui.OnEvent(
        "Close",
        CloseModePicker
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

    global RunButton

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


        RunButton.Enabled := true

        RunButton.Text :=
            "RUN MACRO"


        UpdateStatus(
            "READY",
            UIColorSuccess
        )


        return
    }


    if CurrentMode
        = "Monkey EXP Grind Farm" {

        SubtitleText.Text :=
            "Monkey EXP Grind Farm Mode"


        CategoryLabel.Visible := false
        CategoryDropdown.Visible := false

        MapLabel.Visible := false
        MapDropdown.Visible := false

        HotkeyText.Visible := false


        MonkeyExpTitle.Text :=
            "Monkey EXP Grind FARM"


        MonkeyExpDescription.Text :=
            "Monkey EXP Grind Farm controls will go here.`n"
            . "This mode is ready to be built next."


        MonkeyExpTitle.Visible := true
        MonkeyExpDescription.Visible := true


        RunButton.Enabled := false

        RunButton.Text :=
            "RUN MACRO"


        UpdateStatus(
            "MODE NOT CONFIGURED YET",
            UIColorWarning
        )


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


        RunButton.Enabled := false

        RunButton.Text :=
            "RUN MACRO"


        UpdateStatus(
            "MODE NOT CONFIGURED YET",
            UIColorWarning
        )


        return
    }
}


CloseModePicker(*) {
    global ModePickerGui


    try {
        if ModePickerGui
            ModePickerGui.Destroy()
    }


    ModePickerGui := ""
}
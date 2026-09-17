#Requires AutoHotkey v2.0


global UIConfirmGui := ""
global UIConfirmCallback := ""
global UIConfirmOwner := ""


GetConfirmationSettingsFilePath() {
    return A_ScriptDir . "\\UserData\\Settings.ini"
}


AreThemedConfirmationsEnabled() {
    path := GetConfirmationSettingsFilePath()

    try {
        value := IniRead(path, "Confirmations", "Enabled", "1")
        return value != "0"
    }

    return true
}


SetThemedConfirmationsEnabled(enabled) {
    settingsDir := A_ScriptDir . "\\UserData"

    if !DirExist(settingsDir) {
        DirCreate(settingsDir)
    }

    IniWrite(
        enabled ? "1" : "0",
        GetConfirmationSettingsFilePath(),
        "Confirmations",
        "Enabled"
    )
}


ShowThemedConfirmation(
    title,
    message,
    confirmText,
    confirmCallback,
    ownerGui := "",
    helpBody := ""
) {
    global UIConfirmGui
    global UIConfirmCallback
    global UIConfirmOwner

    global UIColorBackground
    global UIColorError
    global UIColorSecondaryText


    if !AreThemedConfirmationsEnabled() {
        if confirmCallback {
            confirmCallback.Call()
        }
        return
    }


    CloseThemedConfirmation()
    CloseAllDarkDropdowns()
    CloseContextHelp()


    UIConfirmCallback := confirmCallback
    UIConfirmOwner := ownerGui


    dialogWidth := 470
    dialogHeight := 300
    ownerOption := ""


    if ownerGui {
        try ownerOption := " +Owner" . ownerGui.Hwnd
    }


    UIConfirmGui :=
        Gui(
            "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox" . ownerOption,
            "Confirm Action"
        )


    UIConfirmGui.BackColor := UIColorBackground


    UIConfirmGui.Add(
        "Progress",
        "x0 y0 w" . dialogWidth . " h4 c" . UIColorError
        . " Background" . UIColorError . " Disabled",
        100
    )


    AddUIOutlinedText(
        UIConfirmGui,
        title,
        24,
        22,
        422,
        34,
        12,
        "Center",
        true,
        UIColorError
    )


    SetUIBodyFont(
        UIConfirmGui,
        10,
        UIColorSecondaryText
    )


    UIConfirmGui.Add(
        "Text",
        "x34 y76 w402 h105 Center c" . UIColorSecondaryText . " BackgroundTrans",
        message
    )


    confirmButton :=
        CreateDarkButton(
            UIConfirmGui,
            34,
            208,
            194,
            46,
            confirmText,
            8,
            "Danger"
        )


    backButton :=
        CreateDarkButton(
            UIConfirmGui,
            242,
            208,
            194,
            46,
            "GO BACK",
            8,
            "Default"
        )


    if helpBody != "" {
        CreateHelpBadgeForButton(
            UIConfirmGui,
            confirmButton,
            confirmText,
            helpBody
        )
    }


    CreateHelpBadgeForButton(
        UIConfirmGui,
        backButton,
        "GO BACK",
        "Cancels this action and closes the confirmation.`n`nNothing is changed."
    )


    confirmButton.OnEvent(
        "Click",
        ConfirmThemedAction
    )


    backButton.OnEvent(
        "Click",
        CloseThemedConfirmation
    )


    UIConfirmGui.OnEvent(
        "Close",
        CloseThemedConfirmation
    )


    UIConfirmGui.OnEvent(
        "Escape",
        CloseThemedConfirmation
    )


    UIConfirmGui.Show(
        "Hide w" . dialogWidth . " h" . dialogHeight
    )


    ApplyDarkWindowStyle(
        UIConfirmGui
    )


    if ownerGui {
        try ownerGui.Opt("+Disabled")
    }


    UIConfirmGui.Show(
        "w" . dialogWidth . " h" . dialogHeight . " Center"
    )


    try WinActivate(
        "ahk_id " . UIConfirmGui.Hwnd
    )
}


ConfirmThemedAction(*) {
    global UIConfirmCallback


    callback := UIConfirmCallback


    CloseThemedConfirmation()


    if callback {
        callback.Call()
    }
}


CloseThemedConfirmation(*) {
    global UIConfirmGui
    global UIConfirmCallback
    global UIConfirmOwner


    owner := UIConfirmOwner


    try {
        if UIConfirmGui
            UIConfirmGui.Destroy()
    }


    UIConfirmGui := ""
    UIConfirmCallback := ""
    UIConfirmOwner := ""


    if owner {
        try owner.Opt("-Disabled")
        try WinActivate("ahk_id " . owner.Hwnd)
    }
}
#Requires AutoHotkey v2.0


global SettingsGui := ""


ShowSettingsUI(*) {
    global SettingsGui
    global MacroRunning

    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText

    if MacroRunning {
        return
    }

    CloseAllSecondaryMenus()
    CloseContextHelp()
    CloseAllDarkDropdowns()

    SettingsGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Settings - V1.4"
    )
    SettingsGui.BackColor := UIColorBackground

    SettingsGui.Add(
        "Progress",
        "x0 y0 w420 h4 c" . UIColorAccent . " Background" . UIColorAccent . " Disabled",
        100
    )

    AddUIOutlinedText(SettingsGui, "SETTINGS", 20, 18, 380, 34, 13, "Center")

    CreateHelpBadgeForHeader(
        SettingsGui,
        420,
        "SETTINGS",
        "Change how the launcher behaves.`n`nYou can manage History, confirmations, queue buttons, and Retry / Recovery here."
    )

    SetUIBodyFont(SettingsGui, 9, UIColorSecondaryText)
    SettingsGui.Add(
        "Text",
        "x30 y60 w360 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Macro preferences and launcher utilities"
    )

    historyButton := CreateDarkButton(
        SettingsGui,
        50,
        112,
        320,
        48,
        "HISTORY",
        9
    )

    confirmationsEnabled := AreThemedConfirmationsEnabled()
    confirmationsButton := CreateDarkButton(
        SettingsGui,
        50,
        176,
        320,
        48,
        confirmationsEnabled ? "CONFIRMATIONS: ON" : "CONFIRMATIONS: OFF",
        9
    )

    queueButtonsEnabled := AreQueueLauncherButtonsEnabled()
    queueButtonsButton := CreateDarkButton(
        SettingsGui,
        50,
        240,
        320,
        48,
        queueButtonsEnabled ? "QUEUE BUTTONS: ON" : "QUEUE BUTTONS: OFF",
        9
    )

    retryButton := CreateDarkButton(
        SettingsGui,
        50,
        304,
        320,
        48,
        "RETRY / RECOVERY",
        9
    )

    closeButton := CreateDarkButton(
        SettingsGui,
        50,
        370,
        320,
        42,
        "CLOSE",
        8
    )

    historyButton.OnEvent("Click", OpenHistoryFromSettings)
    confirmationsButton.OnEvent(
        "Click",
        ToggleConfirmationSetting.Bind(confirmationsButton)
    )
    queueButtonsButton.OnEvent(
        "Click",
        ToggleQueueLauncherButtonsSetting.Bind(queueButtonsButton)
    )
    retryButton.OnEvent("Click", OpenRetryRecoveryFromSettings)
    closeButton.OnEvent("Click", CloseSettingsAndReturnToLauncher)

    CreateHelpBadgeForButton(
        SettingsGui,
        historyButton,
        "HISTORY",
        "Opens Run History.`n`nSee your last run, last failure, successful and failed runs, total cycles, and recent queue or profile."
    )

    CreateHelpBadgeForButton(
        SettingsGui,
        confirmationsButton,
        "CONFIRMATIONS",
        "Turns confirmation prompts on or off.`n`nOFF means close, clear, and delete actions happen immediately. This setting is saved for next time."
    )

    CreateHelpBadgeForButton(
        SettingsGui,
        queueButtonsButton,
        "QUEUE BUTTONS",
        "Shows or hides the queue buttons on the main launcher.`n`nWhen OFF, ADD QUEUE and QUEUE disappear and the other buttons expand to fill the space. This setting is saved."
    )

    CreateHelpBadgeForButton(
        SettingsGui,
        retryButton,
        "RETRY / RECOVERY",
        "Opens Retry / Recovery settings.`n`nChoose whether failed queue cycles retry automatically and how many retries are allowed."
    )

    CreateHelpBadgeForButton(
        SettingsGui,
        closeButton,
        "CLOSE",
        "Closes Settings and returns to the main launcher."
    )

    SettingsGui.OnEvent("Close", CloseSettingsAndReturnToLauncher)
    SettingsGui.OnEvent("Escape", CloseSettingsAndReturnToLauncher)

    SettingsGui.Show("Hide w420 h440")
    ApplyDarkWindowStyle(SettingsGui)
    SettingsGui.Show("w420 h440 Center")
}


ToggleConfirmationSetting(button, *) {
    enabled := !AreThemedConfirmationsEnabled()

    SetThemedConfirmationsEnabled(enabled)
    button.Text := enabled ? "CONFIRMATIONS: ON" : "CONFIRMATIONS: OFF"
}


AreQueueLauncherButtonsEnabled() {
    path := GetConfirmationSettingsFilePath()

    try {
        value := IniRead(path, "Launcher", "QueueButtonsEnabled", "1")
        return value != "0"
    }

    return true
}


SetQueueLauncherButtonsEnabled(enabled) {
    settingsDir := A_ScriptDir . "\\UserData"

    if !DirExist(settingsDir) {
        DirCreate(settingsDir)
    }

    IniWrite(
        enabled ? "1" : "0",
        GetConfirmationSettingsFilePath(),
        "Launcher",
        "QueueButtonsEnabled"
    )
}


ToggleQueueLauncherButtonsSetting(button, *) {
    enabled := !AreQueueLauncherButtonsEnabled()
    SetQueueLauncherButtonsEnabled(enabled)
    button.Text := enabled ? "QUEUE BUTTONS: ON" : "QUEUE BUTTONS: OFF"
    RebuildLauncherForQueueButtonSetting()
}


RebuildLauncherForQueueButtonSetting() {
    global LauncherGui
    global SettingsGui
    global MacroRunning

    if MacroRunning {
        return
    }

    try {
        if LauncherGui {
            LauncherGui.Destroy()
        }
    }

    LauncherGui := ""
    CreateLauncherUI()
    ShowLauncher(true)

}


OpenHistoryFromSettings(*) {
    CloseSettingsUI()
    ShowRunHistoryUI()
}


OpenRetryRecoveryFromSettings(*) {
    CloseSettingsUI()
    ShowRetryRecoveryUI()
}


CloseSettingsAndReturnToLauncher(*) {
    CloseSettingsUI()
    ShowLauncher(true)
}


CloseSettingsUI(*) {
    global SettingsGui

    try {
        if SettingsGui {
            SettingsGui.Destroy()
        }
    }

    SettingsGui := ""
}
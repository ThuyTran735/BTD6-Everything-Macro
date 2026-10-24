#Requires AutoHotkey v2.0

; Keep screen transitions in one place so closing a child menu returns consistently.

RebuildLauncherForQueueButtonSetting() {
    global LauncherGui
    global SettingsGui
    global MacroRunning

    if MacroRunning
        return

    ; Queue controls change the action-row widths, so rebuild instead of hiding them.
    try {
        if LauncherGui
            LauncherGui.Destroy()
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
    global SettingsStatusText
    global SettingsUpdateCheckActive
    global SettingsUpdateCheckFrame

    ; Stop delayed update callbacks before their status control is destroyed.
    SetTimer(AdvanceSettingsUpdateCheckAnimation, 0)
    SetTimer(RunSettingsUpdateCheck, 0)
    SettingsUpdateCheckActive := false
    SettingsUpdateCheckFrame := 0

    try {
        if SettingsGui
            SettingsGui.Destroy()
    }

    SettingsGui := ""
    SettingsStatusText := ""
}

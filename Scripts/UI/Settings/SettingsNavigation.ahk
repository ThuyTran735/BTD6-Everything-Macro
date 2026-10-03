#Requires AutoHotkey v2.0

; v3 file note: Rebuilds launcher bits when needed and moves between Settings/history/retry screens.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

RebuildLauncherForQueueButtonSetting() {
    global LauncherGui
    global SettingsGui
    global MacroRunning

    if MacroRunning
        return

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
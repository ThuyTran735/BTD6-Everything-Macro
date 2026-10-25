#Requires AutoHotkey v2.0

; Keep screen transitions in one place so closing a child menu returns consistently.

RebuildLauncherForQueueButtonSetting() {
    global LauncherGui
    global SettingsGui
    global MacroRunning

    if MacroRunning
        return

    ; The controls already exist. Keep selections, position, and focus while
    ; laying out the final button arrangement in one paint.
    updatingGui := LauncherGui
    BeginUIUpdate(updatingGui)
    try UpdateLauncherActionLayout()
    finally EndUIUpdate(updatingGui)
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

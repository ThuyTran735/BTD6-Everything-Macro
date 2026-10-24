#Requires AutoHotkey v2.0

; Save toggles immediately and reflect the new value on the button that was clicked.

SetSettingsStatus(message) {
    global SettingsStatusText

    try {
        if !SettingsStatusText
            return

        ; Clear and repaint first so a shorter status message cannot leave
        ; transparent remnants of the previous text behind.
        SettingsStatusText.Text := ""
        DllCall(
            "RedrawWindow",
            "Ptr", SettingsStatusText.Hwnd,
            "Ptr", 0,
            "Ptr", 0,
            "UInt", 0x85
        )

        SettingsStatusText.Text := message
        DllCall(
            "RedrawWindow",
            "Ptr", SettingsStatusText.Hwnd,
            "Ptr", 0,
            "Ptr", 0,
            "UInt", 0x85
        )
    }
}


ToggleConfirmationSetting(button, *) {
    enabled := !AreThemedConfirmationsEnabled()
    SetThemedConfirmationsEnabled(enabled)
    button.Text := enabled ? "CONFIRMATIONS: ON" : "CONFIRMATIONS: OFF"
    SetSettingsStatus(enabled ? "Confirmation prompts enabled." : "Confirmation prompts disabled.")
}


ToggleRememberLauncherStateSetting(button, *) {
    enabled := !IsRememberLauncherStateEnabled()
    SetRememberLauncherStateEnabled(enabled)

    ; Turning memory off also clears old selections so they cannot return later.
    if enabled {
        SaveLauncherState()
    }
    else {
        ClearLauncherSavedState()
    }

    button.Text := enabled ? "REMEMBER LAST STATE: ON" : "REMEMBER LAST STATE: OFF"
    SetSettingsStatus(
        enabled
            ? "Launcher state memory enabled. Selections and the last run strategy are saved in UserData."
            : "Launcher state memory disabled. Saved launcher selections and strategy memory were cleared."
    )
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

    if !DirExist(settingsDir)
        DirCreate(settingsDir)

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
    SetSettingsStatus(enabled ? "Queue launcher buttons enabled." : "Queue launcher buttons hidden.")
    RebuildLauncherForQueueButtonSetting()
}


ToggleDailyChestSetting(button, *) {
    enabled := !IsPreRunDailyChestEnabled()
    SetPreRunDailyChestEnabled(enabled)
    button.Text := enabled
        ? "OPEN DAILY CHEST: ON"
        : "OPEN DAILY CHEST: OFF"
    SetSettingsStatus(
        enabled
            ? "Daily Chest opening enabled before every map cycle."
            : "Daily Chest opening disabled."
    )
}


ToggleAutoUpdateCheckSetting(button, *) {
    enabled := !IsAutoUpdateCheckEnabled()
    SetAutoUpdateCheckEnabled(enabled)
    button.Text := enabled ? "AUTO UPDATE CHECK: ON" : "AUTO UPDATE CHECK: OFF"
    SetSettingsStatus(
        enabled
            ? "Automatic GitHub update checks enabled."
            : "Automatic GitHub update checks disabled. Manual checks still work."
    )
}



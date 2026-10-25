#Requires AutoHotkey v2.0

; Manage diagnostic files without mixing them with the separate Run History records.

ToggleLoggingSetting(button, *) {
    enabled := !IsLoggingEnabled()
    SetLoggingEnabled(enabled)
    button.Text := enabled ? "RUN LOGGING: ON" : "RUN LOGGING: OFF"
    SetLogsStatus(
        enabled
            ? "Logging enabled. New runs will create individual log files."
            : "Logging disabled. Existing logs are kept."
    )
}


ExportLogsFromSettings(*) {
    global LogsGui

    ; DirSelect can appear behind an always-on-top GUI on Windows.
    ; Temporarily lower the Logs window while the native folder picker is open.
    if IsObject(LogsGui) {
        try LogsGui.Opt("-AlwaysOnTop")
    }

    count := 0
    try count := ExportLogFiles()
    finally {
        if IsObject(LogsGui) {
            try LogsGui.Opt("+AlwaysOnTop")
            try WinActivate("ahk_id " . LogsGui.Hwnd)
        }
    }

    if count > 0
        SetLogsStatus("Exported " . count . (count = 1 ? " log file." : " log files."))
    else
        SetLogsStatus("No log files were exported.")
}


OpenLogsFolderFromSettings(*) {
    if OpenLogsFolder()
        SetLogsStatus("Opened UserData\\Logs.")
    else
        SetLogsStatus("Could not open the log folder.")
}


DeleteAllLogsConfirmed(*) {
    count := DeleteAllLogFiles()
    SetLogsStatus("Deleted " . count . (count = 1 ? " log file." : " log files."))
}


RequestDeleteAllLogs(*) {
    global LogsGui

    ShowThemedConfirmation(
        "DELETE ALL LOGS?",
        "Delete every file inside UserData\\Logs?`n`nThis cannot be undone.",
        "DELETE LOGS",
        DeleteAllLogsConfirmed,
        LogsGui,
        "Deletes only diagnostic log files. Run History, favorites, profiles, scripts, and settings are not deleted."
    )
}



ShowLogsUI(*) {
    global LogsGui
    global LogsStatusText
    global MacroRunning

    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText
    global UIColorMutedText
    global UIColorHeadingText

    if MacroRunning
        return

    if ActivateExistingUIWindow(LogsGui)
        return

    CloseSettingsUI()
    CloseContextHelp()
    CloseAllDarkDropdowns()
    CloseLogsUI()

    LogsGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        GetVersionedTitle("Logs")
    )
    ; Keep native dialogs such as DirSelect/MsgBox in front of the Logs window.
    LogsGui.Opt("+OwnDialogs")
    LogsGui.BackColor := UIColorBackground


    EnableCustomWindowChrome(LogsGui)
    AddCustomWindowBorder(LogsGui, 500, 452)
    AddUICard(LogsGui, 24, 88, 452, 92)
    AddUICard(LogsGui, 24, 192, 452, 136)

    AddUIOutlinedText(LogsGui, "LOGS", 24, 20, 452, 32, 13, "Center")

    CreateHelpBadgeForHeader(
        LogsGui,
        500,
        "LOGS",
        "Manage run logging and diagnostic log files."
    )

    SetUIBodyFont(LogsGui, 9, UIColorSecondaryText)
    LogsGui.Add(
        "Text",
        "x24 y60 w452 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Run diagnostics and log file management"
    )

    SetUIBodyFont(LogsGui, 8, UIColorHeadingText)
    LogsGui.Add("Text", "x36 y100 w428 h20 c" . UIColorHeadingText . " BackgroundTrans", "RUN LOGGING")

    loggingEnabled := IsLoggingEnabled()
    loggingButton := CreateDarkButton(
        LogsGui, 36, 128, 428, 40,
        loggingEnabled ? "RUN LOGGING: ON" : "RUN LOGGING: OFF", 8
    )

    SetUIBodyFont(LogsGui, 8, UIColorHeadingText)
    LogsGui.Add("Text", "x36 y204 w428 h20 c" . UIColorHeadingText . " BackgroundTrans", "LOG FILES")

    exportLogsButton := CreateDarkButton(LogsGui, 36, 232, 208, 36, "EXPORT LOGS", 8)
    openLogsButton := CreateDarkButton(LogsGui, 256, 232, 208, 36, "OPEN LOG FOLDER", 8)
    deleteLogsButton := CreateDarkButton(LogsGui, 36, 280, 428, 36, "DELETE ALL LOGS", 8)

    SetUIBodyFont(LogsGui, 8, UIColorSecondaryText)
    LogsStatusText := LogsGui.Add(
        "Text",
        "x36 y340 w428 h32 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Each macro run creates its own log in UserData\\Logs."
    )

    backButton := CreateDarkButton(LogsGui, 24, 388, 452, 40, "BACK TO SETTINGS", 8, "Default")

    loggingButton.OnEvent("Click", ToggleLoggingSetting.Bind(loggingButton))
    exportLogsButton.OnEvent("Click", ExportLogsFromSettings)
    openLogsButton.OnEvent("Click", OpenLogsFolderFromSettings)
    deleteLogsButton.OnEvent("Click", RequestDeleteAllLogs)
    backButton.OnEvent("Click", CloseLogsAndReturnToSettings)

    CreateHelpBadgeForButton(
        LogsGui, loggingButton, "RUN LOGGING",
        "When ON, every macro run creates a separate timestamped log file. Logging is enabled by default."
    )
    CreateHelpBadgeForButton(
        LogsGui, exportLogsButton, "EXPORT LOGS",
        "Copies all current diagnostic logs to a folder you choose."
    )
    CreateHelpBadgeForButton(
        LogsGui, openLogsButton, "OPEN LOG FOLDER",
        "Opens UserData\\Logs in Windows Explorer."
    )
    CreateHelpBadgeForButton(
        LogsGui, deleteLogsButton, "DELETE ALL LOGS",
        "Deletes all files currently stored in UserData\\Logs."
    )
    CreateHelpBadgeForButton(
        LogsGui, backButton, "BACK TO SETTINGS",
        "Returns to the main Settings menu."
    )

    LogsGui.OnEvent("Close", CloseLogsAndReturnToSettings)
    LogsGui.OnEvent("Escape", CloseLogsAndReturnToSettings)

    LogsGui.Show("Hide w500 h452")
    ApplyDarkWindowStyle(LogsGui)
    LogsGui.Show("w500 h452 Center")
}


SetLogsStatus(message) {
    global LogsStatusText

    try {
        if LogsStatusText
            LogsStatusText.Text := message
    }
}


OpenLogsFromSettings(*) {
    ShowLogsUI()
}


CloseLogsAndReturnToSettings(*) {
    CloseLogsUI()
    ShowSettingsUI()
}


CloseLogsUI(*) {
    global LogsGui
    global LogsStatusText

    try {
        if LogsGui
            LogsGui.Destroy()
    }

    LogsGui := ""
    LogsStatusText := ""
}


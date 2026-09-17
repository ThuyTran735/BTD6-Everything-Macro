#Requires AutoHotkey v2.0


global SettingsGui := ""
global SettingsStatusText := ""
global LogsGui := ""
global LogsStatusText := ""


ShowSettingsUI(*) {
    global SettingsGui
    global SettingsStatusText
    global MacroRunning

    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText
    global UIColorMutedText

    if MacroRunning
        return

    CloseAllSecondaryMenus()
    CloseContextHelp()
    CloseAllDarkDropdowns()
    CloseLogsUI()

    SettingsGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Settings - V1.5"
    )
    SettingsGui.BackColor := UIColorBackground

    SettingsGui.Add(
        "Progress",
        "x0 y0 w500 h4 c" . UIColorAccent . " Background" . UIColorAccent . " Disabled",
        100
    )

    AddUIOutlinedText(SettingsGui, "SETTINGS", 20, 18, 460, 34, 13, "Center")

    CreateHelpBadgeForHeader(
        SettingsGui,
        500,
        "SETTINGS",
        "Manage launcher behavior, recovery, Daily Chest automation, and diagnostics."
    )

    SetUIBodyFont(SettingsGui, 9, UIColorSecondaryText)
    SettingsGui.Add(
        "Text",
        "x30 y58 w440 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Launcher preferences and recovery"
    )

    SetUIBodyFont(SettingsGui, 8, UIColorMutedText)
    SettingsGui.Add("Text", "x42 y96 w416 h18 c" . UIColorMutedText . " BackgroundTrans", "GENERAL")

    confirmationsEnabled := AreThemedConfirmationsEnabled()
    confirmationsButton := CreateDarkButton(
        SettingsGui, 42, 120, 202, 44,
        confirmationsEnabled ? "CONFIRMATIONS: ON" : "CONFIRMATIONS: OFF", 8
    )

    queueButtonsEnabled := AreQueueLauncherButtonsEnabled()
    queueButtonsButton := CreateDarkButton(
        SettingsGui, 256, 120, 202, 44,
        queueButtonsEnabled ? "QUEUE BUTTONS: ON" : "QUEUE BUTTONS: OFF", 8
    )

    ; Force Default so RUN HISTORY does not inherit the green RUN action style.
    historyButton := CreateDarkButton(SettingsGui, 42, 174, 202, 44, "RUN HISTORY", 8, "Default")
    retryButton := CreateDarkButton(SettingsGui, 256, 174, 202, 44, "RETRY / RECOVERY", 8)

    SetUIBodyFont(SettingsGui, 8, UIColorMutedText)
    SettingsGui.Add("Text", "x42 y238 w416 h18 c" . UIColorMutedText . " BackgroundTrans", "AUTOMATION & DATA")

    dailyChestEnabled := IsPreRunDailyChestEnabled()
    dailyChestButton := CreateDarkButton(
        SettingsGui, 42, 262, 202, 38,
        dailyChestEnabled ? "OPEN DAILY CHEST: ON" : "OPEN DAILY CHEST: OFF", 7
    )

    logsButton := CreateDarkButton(SettingsGui, 256, 262, 202, 38, "LOGS", 8, "Default")

    SetUIBodyFont(SettingsGui, 8, UIColorSecondaryText)
    SettingsStatusText := SettingsGui.Add(
        "Text",
        "x42 y316 w416 h34 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Daily Chest can run before every map cycle. Logs are managed in their own menu."
    )

    closeButton := CreateDarkButton(SettingsGui, 90, 370, 320, 42, "CLOSE", 8)

    confirmationsButton.OnEvent("Click", ToggleConfirmationSetting.Bind(confirmationsButton))
    queueButtonsButton.OnEvent("Click", ToggleQueueLauncherButtonsSetting.Bind(queueButtonsButton))
    historyButton.OnEvent("Click", OpenHistoryFromSettings)
    retryButton.OnEvent("Click", OpenRetryRecoveryFromSettings)
    dailyChestButton.OnEvent("Click", ToggleDailyChestSetting.Bind(dailyChestButton))
    logsButton.OnEvent("Click", OpenLogsFromSettings)
    closeButton.OnEvent("Click", CloseSettingsAndReturnToLauncher)

    CreateHelpBadgeForButton(
        SettingsGui, confirmationsButton, "CONFIRMATIONS",
        "Turns destructive-action confirmation prompts on or off."
    )
    CreateHelpBadgeForButton(
        SettingsGui, queueButtonsButton, "QUEUE BUTTONS",
        "Shows or hides queue controls on the main launcher."
    )
    CreateHelpBadgeForButton(
        SettingsGui, historyButton, "RUN HISTORY",
        "Shows recent run results, failures, totals, and queue/profile source information."
    )
    CreateHelpBadgeForButton(
        SettingsGui, retryButton, "RETRY / RECOVERY",
        "Controls automatic retries for failed queue cycles."
    )
    CreateHelpBadgeForButton(
        SettingsGui, dailyChestButton, "OPEN DAILY CHEST BEFORE EACH CYCLE",
        "When ON, checks for and opens the Daily Chest before every map cycle. Reward screens use five clicks at screen position 583,388, spaced 350 ms apart."
    )
    CreateHelpBadgeForButton(
        SettingsGui, logsButton, "LOGS",
        "Opens the Logs menu with logging, export, folder, and delete controls."
    )
    CreateHelpBadgeForButton(
        SettingsGui, closeButton, "CLOSE",
        "Closes Settings and returns to the main launcher."
    )

    SettingsGui.OnEvent("Close", CloseSettingsAndReturnToLauncher)
    SettingsGui.OnEvent("Escape", CloseSettingsAndReturnToLauncher)

    SettingsGui.Show("Hide w500 h436")
    ApplyDarkWindowStyle(SettingsGui)
    SettingsGui.Show("w500 h436 Center")
}


SetSettingsStatus(message) {
    global SettingsStatusText

    try {
        if SettingsStatusText
            SettingsStatusText.Text := message
    }
}


ToggleConfirmationSetting(button, *) {
    enabled := !AreThemedConfirmationsEnabled()
    SetThemedConfirmationsEnabled(enabled)
    button.Text := enabled ? "CONFIRMATIONS: ON" : "CONFIRMATIONS: OFF"
    SetSettingsStatus(enabled ? "Confirmation prompts enabled." : "Confirmation prompts disabled.")
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

    if MacroRunning
        return

    CloseSettingsUI()
    CloseContextHelp()
    CloseAllDarkDropdowns()
    CloseLogsUI()

    LogsGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Logs - V1.5"
    )
    ; Keep native dialogs such as DirSelect/MsgBox in front of the Logs window.
    LogsGui.Opt("+OwnDialogs")
    LogsGui.BackColor := UIColorBackground

    LogsGui.Add(
        "Progress",
        "x0 y0 w500 h4 c" . UIColorAccent . " Background" . UIColorAccent . " Disabled",
        100
    )

    AddUIOutlinedText(LogsGui, "LOGS", 20, 18, 460, 34, 13, "Center")

    CreateHelpBadgeForHeader(
        LogsGui,
        500,
        "LOGS",
        "Manage run logging and diagnostic log files."
    )

    SetUIBodyFont(LogsGui, 9, UIColorSecondaryText)
    LogsGui.Add(
        "Text",
        "x30 y58 w440 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Run diagnostics and log file management"
    )

    SetUIBodyFont(LogsGui, 8, UIColorMutedText)
    LogsGui.Add("Text", "x42 y96 w416 h18 c" . UIColorMutedText . " BackgroundTrans", "RUN LOGGING")

    loggingEnabled := IsLoggingEnabled()
    loggingButton := CreateDarkButton(
        LogsGui, 42, 120, 416, 44,
        loggingEnabled ? "RUN LOGGING: ON" : "RUN LOGGING: OFF", 8
    )

    SetUIBodyFont(LogsGui, 8, UIColorMutedText)
    LogsGui.Add("Text", "x42 y184 w416 h18 c" . UIColorMutedText . " BackgroundTrans", "LOG FILES")

    exportLogsButton := CreateDarkButton(LogsGui, 42, 208, 202, 44, "EXPORT LOGS", 8)
    openLogsButton := CreateDarkButton(LogsGui, 256, 208, 202, 44, "OPEN LOG FOLDER", 8)
    deleteLogsButton := CreateDarkButton(LogsGui, 42, 262, 416, 44, "DELETE ALL LOGS", 8)

    SetUIBodyFont(LogsGui, 8, UIColorSecondaryText)
    LogsStatusText := LogsGui.Add(
        "Text",
        "x42 y322 w416 h34 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Each macro run creates its own log in UserData\\Logs."
    )

    backButton := CreateDarkButton(LogsGui, 90, 376, 320, 42, "BACK TO SETTINGS", 8, "Default")

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

    LogsGui.Show("Hide w500 h442")
    ApplyDarkWindowStyle(LogsGui)
    LogsGui.Show("w500 h442 Center")
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

    try {
        if SettingsGui
            SettingsGui.Destroy()
    }

    SettingsGui := ""
    SettingsStatusText := ""
}
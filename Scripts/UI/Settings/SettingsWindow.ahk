#Requires AutoHotkey v2.0

; Build Settings from the saved preferences; each action delegates to its own module.


global SettingsGui := ""
global SettingsStatusText := ""
global SettingsUpdateCheckActive := false
global SettingsUpdateCheckFrame := 0
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
    global UIColorHeadingText

    if MacroRunning
        return

    ; If Settings is already open, keep the existing window instead of
    ; destroying/recreating it. Rebuilding here caused a visible flicker when
    ; the launcher SETTINGS button was clicked a second time.
    if SettingsGui {
        try {
            if (
                DllCall("IsWindow", "Ptr", SettingsGui.Hwnd, "Int")
                && DllCall("IsWindowVisible", "Ptr", SettingsGui.Hwnd, "Int")
            ) {
                try WinActivate("ahk_id " . SettingsGui.Hwnd)
                return
            }
        }
    }

    CloseAllSecondaryMenus()
    CloseContextHelp()
    CloseAllDarkDropdowns()
    CloseLogsUI()

    SettingsGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        GetVersionedTitle("Settings")
    )
    SettingsGui.BackColor := UIColorBackground


    EnableCustomWindowChrome(SettingsGui)
    ; Leave a visible gap between groups and keep status messages outside the cards.
    AddCustomWindowBorder(SettingsGui, 500, 700)
    AddUICard(SettingsGui, 24, 88, 452, 196)
    AddUICard(SettingsGui, 24, 296, 452, 84)
    AddUICard(SettingsGui, 24, 392, 452, 84)
    AddUICard(SettingsGui, 24, 488, 452, 84)

    AddUIOutlinedText(SettingsGui, "SETTINGS", 24, 20, 452, 32, 13, "Center")

    CreateHelpBadgeForHeader(
        SettingsGui,
        500,
        "SETTINGS",
        "Manage launcher behavior, recovery, UserData backups, updates, and diagnostics."
    )

    SetUIBodyFont(SettingsGui, 9, UIColorSecondaryText)
    SettingsGui.Add(
        "Text",
        "x24 y60 w452 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Launcher preferences and recovery"
    )

    SetUIHeadingFont(SettingsGui, 8, UIColorHeadingText)
    SettingsGui.Add("Text", "x36 y100 w428 h20 c" . UIColorHeadingText . " BackgroundTrans", "GENERAL")

    confirmationsEnabled := AreThemedConfirmationsEnabled()
    confirmationsButton := CreateDarkButton(
        SettingsGui, 36, 128, 208, 40,
        confirmationsEnabled ? "CONFIRMATIONS: ON" : "CONFIRMATIONS: OFF", 8
    )

    queueButtonsEnabled := AreQueueLauncherButtonsEnabled()
    queueButtonsButton := CreateDarkButton(
        SettingsGui, 256, 128, 208, 40,
        queueButtonsEnabled ? "QUEUE BUTTONS: ON" : "QUEUE BUTTONS: OFF", 8
    )

    rememberStateEnabled := IsRememberLauncherStateEnabled()
    rememberStateButton := CreateDarkButton(
        SettingsGui, 36, 180, 428, 40,
        rememberStateEnabled ? "REMEMBER LAST STATE: ON" : "REMEMBER LAST STATE: OFF", 8
    )

    ; Force Default so RUN HISTORY does not inherit the green RUN action style.
    historyButton := CreateDarkButton(SettingsGui, 36, 232, 208, 40, "RUN HISTORY", 8, "Default")
    retryButton := CreateDarkButton(SettingsGui, 256, 232, 208, 40, "RETRY / RECOVERY", 8)

    SetUIHeadingFont(SettingsGui, 8, UIColorHeadingText)
    SettingsGui.Add("Text", "x36 y308 w428 h20 c" . UIColorHeadingText . " BackgroundTrans", "MACRO TOOLS")

    dailyChestEnabled := IsPreRunDailyChestEnabled()
    dailyChestButton := CreateDarkButton(
        SettingsGui, 36, 332, 208, 36,
        dailyChestEnabled ? "OPEN DAILY CHEST: ON" : "OPEN DAILY CHEST: OFF", 8
    )

    logsButton := CreateDarkButton(SettingsGui, 256, 332, 208, 36, "LOGS", 8, "Default")

    SetUIHeadingFont(SettingsGui, 8, UIColorHeadingText)
    SettingsGui.Add("Text", "x36 y404 w428 h20 c" . UIColorHeadingText . " BackgroundTrans", "USER DATA")

    userDataButton := CreateDarkButton(
        SettingsGui, 36, 428, 428, 36,
        "BACKUP / RESTORE USER DATA", 8, "Default"
    )

    SetUIHeadingFont(SettingsGui, 8, UIColorHeadingText)
    SettingsGui.Add("Text", "x36 y500 w428 h20 c" . UIColorHeadingText . " BackgroundTrans", "UPDATES")

    autoUpdatesEnabled := IsAutoUpdateCheckEnabled()
    autoUpdatesButton := CreateDarkButton(
        SettingsGui, 36, 524, 208, 36,
        autoUpdatesEnabled ? "AUTO UPDATE CHECK: ON" : "AUTO UPDATE CHECK: OFF", 8
    )

    checkUpdatesButton := CreateDarkButton(
        SettingsGui, 256, 524, 208, 36,
        "CHECK FOR UPDATES", 8, "Default"
    )
    SetUIBodyFont(SettingsGui, 8, UIColorSecondaryText)
    SettingsStatusText := SettingsGui.Add(
        "Text",
        "x36 y584 w428 h36 Center c" . UIColorSecondaryText . " Background" . UIColorBackground,
        "Launcher selections are stored only inside UserData."
    )

    closeButton := CreateDarkButton(SettingsGui, 24, 636, 452, 40, "BACK TO LAUNCHER", 8, "Default")

    confirmationsButton.OnEvent("Click", ToggleConfirmationSetting.Bind(confirmationsButton))
    queueButtonsButton.OnEvent("Click", ToggleQueueLauncherButtonsSetting.Bind(queueButtonsButton))
    rememberStateButton.OnEvent("Click", ToggleRememberLauncherStateSetting.Bind(rememberStateButton))
    historyButton.OnEvent("Click", OpenHistoryFromSettings)
    retryButton.OnEvent("Click", OpenRetryRecoveryFromSettings)
    dailyChestButton.OnEvent("Click", ToggleDailyChestSetting.Bind(dailyChestButton))
    logsButton.OnEvent("Click", OpenLogsFromSettings)
    userDataButton.OnEvent("Click", OpenUserDataTransferFromSettings)
    autoUpdatesButton.OnEvent("Click", ToggleAutoUpdateCheckSetting.Bind(autoUpdatesButton))
    checkUpdatesButton.OnEvent("Click", CheckForUpdatesFromSettings)
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
        SettingsGui, rememberStateButton, "REMEMBER LAST STATE",
        "When ON, remembers the last launcher mode, its selections, and the last successfully run strategy in the Select Script screen. The saved values stay in UserData and are ignored by Git."
    )
    CreateHelpBadgeForButton(
        SettingsGui, historyButton, "RUN HISTORY",
        "Shows recent run results, failures, totals, and queue/profile source information."
    )
    CreateHelpBadgeForButton(
        SettingsGui, retryButton, "RETRY / RECOVERY",
        "Controls queue retries plus defeat retries for manual and EXP runs."
    )
    CreateHelpBadgeForButton(
        SettingsGui, dailyChestButton, "OPEN DAILY CHEST BEFORE EACH CYCLE",
        "When ON, checks for the normal or Halloween Daily Chest before every map cycle. It opens the chest and dismisses reward screens until the home screen returns."
    )
    CreateHelpBadgeForButton(
        SettingsGui, logsButton, "LOGS",
        "Opens the Logs menu with logging, export, folder, and delete controls."
    )
    CreateHelpBadgeForButton(
        SettingsGui, userDataButton, "BACKUP / RESTORE USER DATA",
        "Exports the whole UserData folder for safekeeping or imports a previous backup into this version."
    )
    CreateHelpBadgeForButton(
        SettingsGui, autoUpdatesButton, "AUTO UPDATE CHECK",
        "When ON, the launcher checks your GitHub repository shortly after startup and notifies you only when a newer version is listed."
    )
    CreateHelpBadgeForButton(
        SettingsGui, checkUpdatesButton, "CHECK FOR UPDATES",
        "Checks GitHub now and compares Scripts/Version.ahk with this installed copy."
    )
    CreateHelpBadgeForButton(
        SettingsGui, closeButton, "BACK TO LAUNCHER",
        "Returns to the main launcher."
    )

    SettingsGui.OnEvent("Close", CloseSettingsAndReturnToLauncher)
    SettingsGui.OnEvent("Escape", CloseSettingsAndReturnToLauncher)

    SettingsGui.Show("Hide w500 h700")
    ApplyDarkWindowStyle(SettingsGui)
    SettingsGui.Show("w500 h700 Center")
}

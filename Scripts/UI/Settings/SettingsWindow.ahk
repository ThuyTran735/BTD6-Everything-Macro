#Requires AutoHotkey v2.0

; v3 file note: Builds the Settings window and its controls.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.


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
    AddCustomWindowBorder(SettingsGui, 500, 664)
    AddUICard(SettingsGui, 30, 88, 440, 196)
    AddUICard(SettingsGui, 30, 284, 440, 82)
    AddUICard(SettingsGui, 30, 366, 440, 82)
    AddUICard(SettingsGui, 30, 448, 440, 82)
    AddUICard(SettingsGui, 30, 530, 440, 54)
    AddUICard(SettingsGui, 30, 584, 440, 64)

    AddUIOutlinedText(SettingsGui, "SETTINGS", 20, 18, 460, 34, 13, "Center")

    CreateHelpBadgeForHeader(
        SettingsGui,
        500,
        "SETTINGS",
        "Manage launcher behavior, recovery, UserData backups, updates, and diagnostics."
    )

    SetUIBodyFont(SettingsGui, 9, UIColorSecondaryText)
    SettingsGui.Add(
        "Text",
        "x30 y58 w440 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Launcher preferences and recovery"
    )

    SetUIHeadingFont(SettingsGui, 8, UIColorHeadingText)
    SettingsGui.Add("Text", "x42 y96 w416 h18 c" . UIColorHeadingText . " BackgroundTrans", "GENERAL")

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

    rememberStateEnabled := IsRememberLauncherStateEnabled()
    rememberStateButton := CreateDarkButton(
        SettingsGui, 42, 174, 416, 44,
        rememberStateEnabled ? "REMEMBER LAST STATE: ON" : "REMEMBER LAST STATE: OFF", 8
    )

    ; Force Default so RUN HISTORY does not inherit the green RUN action style.
    historyButton := CreateDarkButton(SettingsGui, 42, 228, 202, 44, "RUN HISTORY", 8, "Default")
    retryButton := CreateDarkButton(SettingsGui, 256, 228, 202, 44, "RETRY / RECOVERY", 8)

    SetUIHeadingFont(SettingsGui, 8, UIColorHeadingText)
    SettingsGui.Add("Text", "x42 y292 w416 h18 c" . UIColorHeadingText . " BackgroundTrans", "MACRO TOOLS")

    dailyChestEnabled := IsPreRunDailyChestEnabled()
    dailyChestButton := CreateDarkButton(
        SettingsGui, 42, 316, 202, 38,
        dailyChestEnabled ? "OPEN DAILY CHEST: ON" : "OPEN DAILY CHEST: OFF", 7
    )

    logsButton := CreateDarkButton(SettingsGui, 256, 316, 202, 38, "LOGS", 8, "Default")

    SetUIHeadingFont(SettingsGui, 8, UIColorHeadingText)
    SettingsGui.Add("Text", "x42 y374 w416 h18 c" . UIColorHeadingText . " BackgroundTrans", "USER DATA")

    userDataButton := CreateDarkButton(
        SettingsGui, 42, 398, 416, 38,
        "BACKUP / RESTORE USER DATA", 7, "Default"
    )

    SetUIHeadingFont(SettingsGui, 8, UIColorHeadingText)
    SettingsGui.Add("Text", "x42 y456 w416 h18 c" . UIColorHeadingText . " BackgroundTrans", "UPDATES")

    autoUpdatesEnabled := IsAutoUpdateCheckEnabled()
    autoUpdatesButton := CreateDarkButton(
        SettingsGui, 42, 480, 202, 40,
        autoUpdatesEnabled ? "AUTO UPDATE CHECK: ON" : "AUTO UPDATE CHECK: OFF", 7
    )

    checkUpdatesButton := CreateDarkButton(
        SettingsGui, 256, 480, 202, 40,
        "CHECK FOR UPDATES", 7, "Default"
    )
    SetUIBodyFont(SettingsGui, 8, UIColorSecondaryText)
    SettingsStatusText := SettingsGui.Add(
        "Text",
        "x42 y538 w416 h38 Center c" . UIColorSecondaryText,
        "Launcher selections are stored only inside UserData."
    )

    closeButton := CreateDarkButton(SettingsGui, 90, 595, 320, 42, "BACK TO LAUNCHER", 8, "Default")

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
        "When ON, checks for and opens the Daily Chest before every map cycle. Reward screens use five clicks at screen position 583,388, spaced 350 ms apart."
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

    SettingsGui.Show("Hide w500 h664")
    ApplyDarkWindowStyle(SettingsGui)
    SettingsGui.Show("w500 h664 Center")
}
#Requires AutoHotkey v2.0


global RunHistoryGui := ""
global RunHistoryLastRunText := ""
global RunHistoryLastFailureText := ""
global RunHistorySuccessText := ""
global RunHistoryFailureText := ""
global RunHistoryCyclesText := ""
global RunHistoryRecentSourceText := ""
global RunHistoryCurrentSource := "NONE"


GetRunHistoryFilePath() {
    return A_ScriptDir . "\\UserData\\RunHistory.ini"
}


EnsureRunHistoryStorage() {
    historyDir := A_ScriptDir . "\\UserData"

    if !DirExist(historyDir) {
        try DirCreate(historyDir)
    }
}


ReadRunHistoryValue(key, defaultValue := "") {
    path := GetRunHistoryFilePath()

    if !FileExist(path) {
        return defaultValue
    }

    try return IniRead(path, "History", key, defaultValue)
    catch {
        return defaultValue
    }
}


WriteRunHistoryValue(key, value) {
    EnsureRunHistoryStorage()

    try {
        IniWrite(value, GetRunHistoryFilePath(), "History", key)
        return true
    }
    catch {
        return false
    }
}


GetRunHistoryTimestamp() {
    return FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
}


SetRunHistoryCurrentSource(source) {
    global RunHistoryCurrentSource

    source := Trim(source)
    if source = "" {
        source := "NONE"
    }

    RunHistoryCurrentSource := source
    WriteRunHistoryValue("RecentSource", source)
    RefreshRunHistoryUI()
}


RecordRunHistoryCycle() {
    totalCycles := ReadRunHistoryValue("TotalCycles", 0) + 0
    totalCycles++
    WriteRunHistoryValue("TotalCycles", totalCycles)
    RefreshRunHistoryUI()
}


RecordRunHistorySuccess() {
    global RunHistoryCurrentSource

    source := RunHistoryCurrentSource
    if source = "" {
        source := "NONE"
    }

    successfulRuns := ReadRunHistoryValue("SuccessfulRuns", 0) + 0
    successfulRuns++

    timestamp := GetRunHistoryTimestamp()

    WriteRunHistoryValue("SuccessfulRuns", successfulRuns)
    WriteRunHistoryValue("LastRun", timestamp . "  |  SUCCESS  |  " . source)
    WriteRunHistoryValue("RecentSource", source)

    RefreshRunHistoryUI()
}


RecordRunHistoryFailure(reason := "RUN FAILED") {
    global RunHistoryCurrentSource

    source := RunHistoryCurrentSource
    if source = "" {
        source := "NONE"
    }

    reason := Trim(reason)
    if reason = "" {
        reason := "RUN FAILED"
    }

    failedRuns := ReadRunHistoryValue("FailedRuns", 0) + 0
    failedRuns++

    timestamp := GetRunHistoryTimestamp()
    failureText := timestamp . "  |  " . reason . "  |  " . source

    WriteRunHistoryValue("FailedRuns", failedRuns)
    WriteRunHistoryValue("LastFailure", failureText)
    WriteRunHistoryValue("LastRun", timestamp . "  |  FAILED  |  " . source)
    WriteRunHistoryValue("RecentSource", source)

    RefreshRunHistoryUI()
}


ClearRunHistoryConfirmed(*) {
    path := GetRunHistoryFilePath()

    try {
        if FileExist(path) {
            FileDelete(path)
        }
    }

    RefreshRunHistoryUI()
}


RequestClearRunHistory(*) {
    global RunHistoryGui

    ShowThemedConfirmation(
        "CLEAR RUN HISTORY?",
        "Clear all saved run-history statistics?`n`nThis resets run counts, cycle totals, last run, last failure, and recent queue/profile information.",
        "CLEAR HISTORY",
        ClearRunHistoryConfirmed,
        RunHistoryGui,
        "Clears the saved Run History statistics.`n`nQueue Profiles, favorites, scripts, and current queue jobs are not deleted."
    )
}


ShowRunHistoryUI(*) {
    global RunHistoryGui
    global RunHistoryLastRunText
    global RunHistoryLastFailureText
    global RunHistorySuccessText
    global RunHistoryFailureText
    global RunHistoryCyclesText
    global RunHistoryRecentSourceText

    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorMutedText
    global UIColorSuccess
    global UIColorError

    CloseAllSecondaryMenus()
    CloseContextHelp()
    CloseAllDarkDropdowns()

    RunHistoryGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        GetVersionedTitle("Run History")
    )
    RunHistoryGui.BackColor := UIColorBackground


    EnableCustomWindowChrome(RunHistoryGui)
    AddCustomWindowBorder(RunHistoryGui, 620, 458)

    AddUIOutlinedText(RunHistoryGui, "RUN HISTORY", 20, 18, 580, 34, 13, "Center")

    CreateHelpBadgeForHeader(
        RunHistoryGui,
        620,
        "RUN HISTORY",
        "Shows saved run statistics across launcher restarts.`n`nSuccessful/Failed Runs count full sessions. Total Cycles counts individual completed cycles."
    )

    SetUIBodyFont(RunHistoryGui, 9, UIColorSecondaryText)
    RunHistoryGui.Add(
        "Text",
        "x30 y58 w560 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Persistent statistics for completed and failed macro sessions"
    )

    AddUIOutlinedText(RunHistoryGui, "LAST RUN", 34, 96, 160, 20, 8)
    SetUIBodyFont(RunHistoryGui, 9, UIColorPrimaryText)
    RunHistoryLastRunText := RunHistoryGui.Add(
        "Text",
        "x205 y94 w375 h42 c" . UIColorPrimaryText . " BackgroundTrans",
        "NEVER"
    )

    AddUIOutlinedText(RunHistoryGui, "LAST FAILURE", 34, 148, 160, 20, 8)
    SetUIBodyFont(RunHistoryGui, 9, UIColorError)
    RunHistoryLastFailureText := RunHistoryGui.Add(
        "Text",
        "x205 y146 w375 h42 c" . UIColorError . " BackgroundTrans",
        "NONE"
    )

    AddUIOutlinedText(RunHistoryGui, "SUCCESSFUL RUNS", 34, 204, 180, 20, 8)
    SetUIBodyBoldFont(RunHistoryGui, 10, UIColorSuccess)
    RunHistorySuccessText := RunHistoryGui.Add(
        "Text",
        "x230 y202 w120 h24 c" . UIColorSuccess . " BackgroundTrans",
        "0"
    )

    AddUIOutlinedText(RunHistoryGui, "FAILED RUNS", 34, 240, 180, 20, 8)
    SetUIBodyBoldFont(RunHistoryGui, 10, UIColorError)
    RunHistoryFailureText := RunHistoryGui.Add(
        "Text",
        "x230 y238 w120 h24 c" . UIColorError . " BackgroundTrans",
        "0"
    )

    AddUIOutlinedText(RunHistoryGui, "TOTAL CYCLES", 330, 204, 150, 20, 8)
    SetUIBodyBoldFont(RunHistoryGui, 10, UIColorPrimaryText)
    RunHistoryCyclesText := RunHistoryGui.Add(
        "Text",
        "x495 y202 w90 h24 Right c" . UIColorPrimaryText . " BackgroundTrans",
        "0"
    )

    AddUIOutlinedText(RunHistoryGui, "RECENT QUEUE / PROFILE", 34, 294, 220, 20, 8)
    SetUIBodyFont(RunHistoryGui, 9, UIColorPrimaryText)
    RunHistoryRecentSourceText := RunHistoryGui.Add(
        "Text",
        "x34 y322 w552 h42 c" . UIColorPrimaryText . " BackgroundTrans",
        "NONE"
    )

    clearButton := CreateDarkButton(
        RunHistoryGui,
        34,
        388,
        268,
        42,
        "CLEAR HISTORY",
        8,
        "Danger"
    )

    closeButton := CreateDarkButton(
        RunHistoryGui,
        318,
        388,
        268,
        42,
        "BACK TO SETTINGS",
        8,
        "Default"
    )

    clearButton.OnEvent("Click", RequestClearRunHistory)
    closeButton.OnEvent("Click", CloseRunHistoryAndReturnToSettings)

    CreateHelpBadgeForButton(
        RunHistoryGui,
        clearButton,
        "CLEAR HISTORY",
        "Clears only the saved Run History statistics.`n`nScripts, Queue Profiles, favorites, and your current queue are not deleted."
    )

    CreateHelpBadgeForButton(
        RunHistoryGui,
        closeButton,
        "BACK TO SETTINGS",
        "Returns to Settings."
    )

    RunHistoryGui.OnEvent("Close", CloseRunHistoryAndReturnToSettings)
    RunHistoryGui.OnEvent("Escape", CloseRunHistoryAndReturnToSettings)

    RefreshRunHistoryUI()

    RunHistoryGui.Show("Hide w620 h458")
    ApplyDarkWindowStyle(RunHistoryGui)
    RunHistoryGui.Show("w620 h458 Center")
}


RefreshRunHistoryUI() {
    global RunHistoryGui
    global RunHistoryLastRunText
    global RunHistoryLastFailureText
    global RunHistorySuccessText
    global RunHistoryFailureText
    global RunHistoryCyclesText
    global RunHistoryRecentSourceText

    if !RunHistoryGui {
        return
    }

    try RunHistoryLastRunText.Text := ReadRunHistoryValue("LastRun", "NEVER")
    try RunHistoryLastFailureText.Text := ReadRunHistoryValue("LastFailure", "NONE")
    try RunHistorySuccessText.Text := ReadRunHistoryValue("SuccessfulRuns", 0)
    try RunHistoryFailureText.Text := ReadRunHistoryValue("FailedRuns", 0)
    try RunHistoryCyclesText.Text := ReadRunHistoryValue("TotalCycles", 0)
    try RunHistoryRecentSourceText.Text := ReadRunHistoryValue("RecentSource", "NONE")
}


CloseRunHistoryAndReturnToSettings(*) {
    CloseRunHistoryUI()
    ShowSettingsUI()
}


CloseRunHistoryUI(*) {
    global RunHistoryGui
    global RunHistoryLastRunText
    global RunHistoryLastFailureText
    global RunHistorySuccessText
    global RunHistoryFailureText
    global RunHistoryCyclesText
    global RunHistoryRecentSourceText

    try {
        if RunHistoryGui {
            RunHistoryGui.Destroy()
        }
    }

    RunHistoryGui := ""
    RunHistoryLastRunText := ""
    RunHistoryLastFailureText := ""
    RunHistorySuccessText := ""
    RunHistoryFailureText := ""
    RunHistoryCyclesText := ""
    RunHistoryRecentSourceText := ""
}
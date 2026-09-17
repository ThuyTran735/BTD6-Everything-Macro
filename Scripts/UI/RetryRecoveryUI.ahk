#Requires AutoHotkey v2.0


global RetryRecoveryGui := ""
global RetryLimitValueText := ""


GetRetryRecoverySettingsFilePath() {
    return A_ScriptDir . "\\UserData\\Settings.ini"
}


EnsureRetryRecoverySettingsStorage() {
    settingsDir := A_ScriptDir . "\\UserData"
    if !DirExist(settingsDir)
        DirCreate(settingsDir)
}


IsQueueAutoRetryEnabled() {
    try {
        value := IniRead(
            GetRetryRecoverySettingsFilePath(),
            "RetryRecovery",
            "Enabled",
            "1"
        )
        return value != "0"
    }

    return true
}


SetQueueAutoRetryEnabled(enabled) {
    EnsureRetryRecoverySettingsStorage()
    IniWrite(
        enabled ? "1" : "0",
        GetRetryRecoverySettingsFilePath(),
        "RetryRecovery",
        "Enabled"
    )
}


GetQueueRetryLimit() {
    value := 3

    try {
        value := IniRead(
            GetRetryRecoverySettingsFilePath(),
            "RetryRecovery",
            "QueueRetryLimit",
            "3"
        ) + 0
    }

    if value < 0
        value := 0
    if value > 10
        value := 10

    return value
}


SetQueueRetryLimit(value) {
    value := Round(value)
    if value < 0
        value := 0
    if value > 10
        value := 10

    EnsureRetryRecoverySettingsStorage()
    IniWrite(
        value,
        GetRetryRecoverySettingsFilePath(),
        "RetryRecovery",
        "QueueRetryLimit"
    )

    return value
}


AdjustQueueRetryLimit(delta, *) {
    global RetryLimitValueText

    value := SetQueueRetryLimit(GetQueueRetryLimit() + delta)
    if RetryLimitValueText
        RetryLimitValueText.Text := value
}


ToggleQueueAutoRetrySetting(button, *) {
    enabled := !IsQueueAutoRetryEnabled()
    SetQueueAutoRetryEnabled(enabled)
    button.Text := enabled ? "AUTO RETRY: ON" : "AUTO RETRY: OFF"
}


ShowRetryRecoveryUI(*) {
    global RetryRecoveryGui
    global RetryLimitValueText
    global MacroRunning

    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText
    global UIColorPrimaryText

    if MacroRunning
        return

    CloseAllSecondaryMenus()
    CloseContextHelp()
    CloseAllDarkDropdowns()

    RetryRecoveryGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Retry / Recovery - V1.5"
    )
    RetryRecoveryGui.BackColor := UIColorBackground

    RetryRecoveryGui.Add(
        "Progress",
        "x0 y0 w440 h4 c" . UIColorAccent . " Background" . UIColorAccent . " Disabled",
        100
    )

    AddUIOutlinedText(RetryRecoveryGui, "RETRY / RECOVERY", 20, 18, 400, 34, 13, "Center")
    CreateHelpBadgeForHeader(
        RetryRecoveryGui,
        440,
        "RETRY / RECOVERY",
        "Controls retries for failed queue cycles.`n`nEach retry starts the same job again in a fresh script process."
    )

    SetUIBodyFont(RetryRecoveryGui, 9, UIColorSecondaryText)
    RetryRecoveryGui.Add(
        "Text",
        "x34 y61 w372 h36 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Retry a failed queue cycle from a fresh process before stopping the queue."
    )

    enabled := IsQueueAutoRetryEnabled()
    autoRetryButton := CreateDarkButton(
        RetryRecoveryGui,
        60,
        114,
        320,
        46,
        enabled ? "AUTO RETRY: ON" : "AUTO RETRY: OFF",
        9
    )
    autoRetryButton.OnEvent("Click", ToggleQueueAutoRetrySetting.Bind(autoRetryButton))

    AddUIOutlinedText(RetryRecoveryGui, "QUEUE RETRY LIMIT", 65, 184, 190, 24, 9)

    minusButton := CreateDarkButton(RetryRecoveryGui, 212, 218, 54, 40, "-", 11)
    RetryLimitValueText := RetryRecoveryGui.Add(
        "Text",
        "x274 y218 w54 h40 Center 0x200 c" . UIColorPrimaryText . " BackgroundTrans",
        GetQueueRetryLimit()
    )
    RetryLimitValueText.SetFont("s11 Bold")
    plusButton := CreateDarkButton(RetryRecoveryGui, 336, 218, 54, 40, "+", 11)

    minusButton.OnEvent("Click", AdjustQueueRetryLimit.Bind(-1))
    plusButton.OnEvent("Click", AdjustQueueRetryLimit.Bind(1))

    SetUIBodyFont(RetryRecoveryGui, 8, UIColorSecondaryText)
    RetryRecoveryGui.Add(
        "Text",
        "x50 y270 w340 h24 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "VALID RANGE: 0-10 | 0 DISABLES RETRIES"
    )

    closeButton := CreateDarkButton(RetryRecoveryGui, 60, 318, 320, 42, "CLOSE", 8)
    closeButton.OnEvent("Click", CloseRetryRecoveryAndReturnToSettings)

    CreateHelpBadgeForButton(
        RetryRecoveryGui,
        autoRetryButton,
        "AUTO RETRY",
        "When ON, a failed queue cycle starts again automatically.`n`nManual runs are not retried."
    )
    CreateHelpBadgeForButton(
        RetryRecoveryGui,
        plusButton,
        "QUEUE RETRY LIMIT",
        "Sets how many times one failed queue cycle may retry.`n`nThe counter resets after that cycle succeeds or the queue moves on."
    )
    CreateHelpBadgeForButton(
        RetryRecoveryGui,
        closeButton,
        "CLOSE",
        "Closes Retry / Recovery and returns to Settings."
    )

    RetryRecoveryGui.OnEvent("Close", CloseRetryRecoveryAndReturnToSettings)
    RetryRecoveryGui.OnEvent("Escape", CloseRetryRecoveryAndReturnToSettings)

    RetryRecoveryGui.Show("Hide w440 h386")
    ApplyDarkWindowStyle(RetryRecoveryGui)
    RetryRecoveryGui.Show("w440 h386 Center")
}


CloseRetryRecoveryAndReturnToSettings(*) {
    CloseRetryRecoveryUI()
    ShowSettingsUI()
}


CloseRetryRecoveryUI(*) {
    global RetryRecoveryGui
    global RetryLimitValueText

    try {
        if RetryRecoveryGui
            RetryRecoveryGui.Destroy()
    }

    RetryRecoveryGui := ""
    RetryLimitValueText := ""
}
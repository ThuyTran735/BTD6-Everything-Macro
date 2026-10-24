#Requires AutoHotkey v2.0


; Retry controls save immediately; the launcher and queue read the same preferences.

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
        GetVersionedTitle("Retry / Recovery")
    )
    RetryRecoveryGui.BackColor := UIColorBackground


    EnableCustomWindowChrome(RetryRecoveryGui)
    AddCustomWindowBorder(RetryRecoveryGui, 440, 386)

    AddUIOutlinedText(RetryRecoveryGui, "RETRY / RECOVERY", 24, 20, 392, 32, 13, "Center")
    CreateHelpBadgeForHeader(
        RetryRecoveryGui,
        440,
        "RETRY / RECOVERY",
        "Controls retries for failed queue cycles and defeated manual/EXP runs.`n`nEach retry starts the same strategy again in a fresh script process."
    )

    SetUIBodyFont(RetryRecoveryGui, 9, UIColorSecondaryText)
    RetryRecoveryGui.Add(
        "Text",
        "x24 y64 w392 h40 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Restart failed queue cycles and defeated manual or EXP runs automatically."
    )

    enabled := IsQueueAutoRetryEnabled()
    autoRetryButton := CreateDarkButton(
        RetryRecoveryGui,
        24,
        120,
        392,
        40,
        enabled ? "AUTO RETRY: ON" : "AUTO RETRY: OFF",
        9
    )
    autoRetryButton.OnEvent("Click", ToggleQueueAutoRetrySetting.Bind(autoRetryButton))

    AddUIOutlinedText(RetryRecoveryGui, "RETRY LIMIT", 24, 184, 392, 20, 9, "Center")

    minusButton := CreateDarkButton(RetryRecoveryGui, 128, 216, 56, 44, "-", 11)
    RetryLimitValueText := RetryRecoveryGui.Add(
        "Text",
        "x192 y216 w56 h44 Center 0x200 c" . UIColorPrimaryText . " BackgroundTrans",
        GetQueueRetryLimit()
    )
    RetryLimitValueText.SetFont("s11 Norm")
    plusButton := CreateDarkButton(RetryRecoveryGui, 256, 216, 56, 44, "+", 11)

    minusButton.OnEvent("Click", AdjustQueueRetryLimit.Bind(-1))
    plusButton.OnEvent("Click", AdjustQueueRetryLimit.Bind(1))

    SetUIBodyFont(RetryRecoveryGui, 8, UIColorSecondaryText)
    RetryRecoveryGui.Add(
        "Text",
        "x24 y272 w392 h24 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Choose 0-10 retries. Set 0 to disable retries."
    )

    closeButton := CreateDarkButton(RetryRecoveryGui, 24, 322, 392, 40, "BACK TO SETTINGS", 8, "Default")
    closeButton.OnEvent("Click", CloseRetryRecoveryAndReturnToSettings)

    CreateHelpBadgeForButton(
        RetryRecoveryGui,
        autoRetryButton,
        "AUTO RETRY",
        "When ON, queue failures and defeated manual/EXP runs start again automatically."
    )
    CreateHelpBadgeForButton(
        RetryRecoveryGui,
        plusButton,
        "RETRY LIMIT",
        "Sets how many times the current run may retry.`n`nThe counter resets after that run succeeds or the queue moves on."
    )
    CreateHelpBadgeForButton(
        RetryRecoveryGui,
        closeButton,
        "BACK TO SETTINGS",
        "Returns to Settings."
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

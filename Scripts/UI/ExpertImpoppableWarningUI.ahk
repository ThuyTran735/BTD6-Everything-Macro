#Requires AutoHotkey v2.0

; Warning shown before Expert Impoppable strategies are started.
; The user's "don't show again" choice is stored with the other safety settings.

global ExpertImpoppableWarningGui := ""
global ExpertImpoppableWarningAccepted := false
global ExpertImpoppableWarningDontShowAgain := ""

; Bump this if the warning changes enough that hidden warnings should be shown again.
global ExpertImpoppableWarningVersion := "1"


GetExpertImpoppableWarningSettingsPath() {
    return A_ScriptDir . "\\UserData\\Settings.ini"
}


HasHiddenExpertImpoppableWarning() {
    global ExpertImpoppableWarningVersion

    try {
        value := IniRead(
            GetExpertImpoppableWarningSettingsPath(),
            "Safety",
            "ExpertImpoppableWarningHidden",
            "0"
        )

        return value = ExpertImpoppableWarningVersion
    }

    return false
}


SaveExpertImpoppableWarningHidden() {
    global ExpertImpoppableWarningVersion

    settingsDir := A_ScriptDir . "\\UserData"

    if !DirExist(settingsDir) {
        DirCreate(settingsDir)
    }

    IniWrite(
        ExpertImpoppableWarningVersion,
        GetExpertImpoppableWarningSettingsPath(),
        "Safety",
        "ExpertImpoppableWarningHidden"
    )
}


IsExpertImpoppableScript(scriptPath) {
    if scriptPath = "" {
        return false
    }

    normalizedPath := StrLower(
        StrReplace(scriptPath, "/", "\")
    )

    ; Adding a leading slash also makes relative paths such as
    ; Maps\Expert\... match the same check as full paths.
    normalizedPath :=
        "\"
        . LTrim(normalizedPath, "\")

    SplitPath(
        scriptPath,
        &fileName
    )

    return (
        InStr(normalizedPath, "\maps\expert\")
        && InStr(normalizedPath, "\hard\")
        && InStr(StrLower(fileName), "impoppable")
    )
}


QueueContainsExpertImpoppableScript(jobs) {
    for job in jobs {
        if IsExpertImpoppableScript(job.path) {
            return true
        }
    }

    return false
}


ShowExpertImpoppableWarningIfNeeded() {
    global ExpertImpoppableWarningGui
    global ExpertImpoppableWarningAccepted
    global ExpertImpoppableWarningDontShowAgain

    global UIColorBackground
    global UIColorPanelRaised
    global UIColorPanelBorder
    global UIColorWarning
    global UIColorError
    global UIColorHeadingText
    global UIColorSecondaryText
    global UIColorMutedText

    if HasHiddenExpertImpoppableWarning() {
        return true
    }

    ExpertImpoppableWarningAccepted := false

    dialogWidth := 570
    dialogHeight := 464

    ExpertImpoppableWarningGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "BTD6 Everything Macro - Expert Impoppable Warning"
    )

    ExpertImpoppableWarningGui.BackColor := UIColorBackground

    EnableCustomWindowChrome(ExpertImpoppableWarningGui, 70, 0)
    AddCustomWindowBorder(ExpertImpoppableWarningGui, dialogWidth, dialogHeight)
    AddUICard(
        ExpertImpoppableWarningGui,
        24,
        80,
        522,
        304,
        UIColorPanelBorder,
        UIColorPanelRaised
    )

    AddUIOutlinedText(
        ExpertImpoppableWarningGui,
        "EXPERT IMPOPPABLE WARNING",
        24,
        24,
        522,
        38,
        12,
        "Center",
        true,
        UIColorWarning
    )

    SetUIHeadingFont(
        ExpertImpoppableWarningGui,
        9,
        UIColorHeadingText
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x40 y96 w490 h24 Center c" . UIColorHeadingText . " BackgroundTrans",
        "FULL MONKEY KNOWLEDGE EXPECTED"
    )

    SetUIBodyFont(
        ExpertImpoppableWarningGui,
        9,
        UIColorSecondaryText
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x40 y136 w490 h56 Left c" . UIColorSecondaryText . " BackgroundTrans",
        "All Expert Impoppable strategies in this macro were created and tested with every Monkey Knowledge upgrade researched and unlocked."
    )

    SetUIBodyFont(
        ExpertImpoppableWarningGui,
        8,
        UIColorSecondaryText
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x40 y204 w490 h50 Left c" . UIColorSecondaryText . " BackgroundTrans",
        "Without full Monkey Knowledge, cash, tower costs, cooldowns, and other bonuses may differ from what the strategy expects."
    )

    SetUIBodyBoldFont(
        ExpertImpoppableWarningGui,
        8,
        UIColorError
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x40 y266 w490 h42 Left c" . UIColorError . " BackgroundTrans",
        "Running the strategy without full Monkey Knowledge may result in losing."
    )

    SetUIBodyFont(
        ExpertImpoppableWarningGui,
        9,
        UIColorSecondaryText
    )

    ; Keep this unchecked by default so hiding the warning is always intentional.
    ExpertImpoppableWarningDontShowAgain := ExpertImpoppableWarningGui.Add(
        "CheckBox",
        "x40 y324 w490 h24 c" . UIColorSecondaryText,
        "Don't show this warning again"
    )

    SetUIBodyFont(
        ExpertImpoppableWarningGui,
        8,
        UIColorMutedText
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x60 y352 w470 h20 c" . UIColorMutedText . " BackgroundTrans",
        "Leave this unchecked if you want the reminder next time."
    )

    continueButton := CreateDarkButton(
        ExpertImpoppableWarningGui,
        24,
        396,
        340,
        44,
        "CONTINUE ANYWAY",
        8,
        "Success"
    )

    cancelButton := CreateDarkButton(
        ExpertImpoppableWarningGui,
        376,
        396,
        170,
        44,
        "CANCEL",
        8,
        "Danger"
    )

    CreateHelpBadgeForButton(
        ExpertImpoppableWarningGui,
        continueButton,
        "CONTINUE ANYWAY",
        "Continues the pending Expert Impoppable start.`n`nThese strategies expect full Monkey Knowledge. Future reminders are hidden only if you check 'Don't show this warning again'."
    )

    CreateHelpBadgeForButton(
        ExpertImpoppableWarningGui,
        cancelButton,
        "CANCEL",
        "Cancels this attempt to start Expert Impoppable and closes the warning.`n`nYour saved warning preference is not changed."
    )

    continueButton.OnEvent(
        "Click",
        AcceptExpertImpoppableWarning
    )

    cancelButton.OnEvent(
        "Click",
        CancelExpertImpoppableWarning
    )

    ExpertImpoppableWarningGui.OnEvent(
        "Close",
        CancelExpertImpoppableWarning
    )

    ExpertImpoppableWarningGui.OnEvent(
        "Escape",
        CancelExpertImpoppableWarning
    )

    ExpertImpoppableWarningGui.Show(
        "Hide w" . dialogWidth . " h" . dialogHeight
    )

    ApplyDarkWindowStyle(ExpertImpoppableWarningGui)

    ExpertImpoppableWarningGui.Show(
        "w" . dialogWidth . " h" . dialogHeight . " Center"
    )

    try WinActivate(
        "ahk_id " . ExpertImpoppableWarningGui.Hwnd
    )

    warningHwnd := ExpertImpoppableWarningGui.Hwnd

    WinWaitClose(
        "ahk_id " . warningHwnd
    )

    return ExpertImpoppableWarningAccepted
}


AcceptExpertImpoppableWarning(*) {
    global ExpertImpoppableWarningGui
    global ExpertImpoppableWarningAccepted
    global ExpertImpoppableWarningDontShowAgain

    if (
        ExpertImpoppableWarningDontShowAgain
        && ExpertImpoppableWarningDontShowAgain.Value
    ) {
        SaveExpertImpoppableWarningHidden()
    }

    ExpertImpoppableWarningAccepted := true

    CloseContextHelp()
    try {
        if ExpertImpoppableWarningGui {
            ExpertImpoppableWarningGui.Destroy()
        }
    }

    ExpertImpoppableWarningGui := ""
    ExpertImpoppableWarningDontShowAgain := ""
}


CancelExpertImpoppableWarning(*) {
    global ExpertImpoppableWarningGui
    global ExpertImpoppableWarningAccepted
    global ExpertImpoppableWarningDontShowAgain

    ExpertImpoppableWarningAccepted := false

    CloseContextHelp()
    try {
        if ExpertImpoppableWarningGui {
            ExpertImpoppableWarningGui.Destroy()
        }
    }

    ExpertImpoppableWarningGui := ""
    ExpertImpoppableWarningDontShowAgain := ""
}

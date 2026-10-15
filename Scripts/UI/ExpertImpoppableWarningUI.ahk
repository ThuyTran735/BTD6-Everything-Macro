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
    dialogHeight := 458

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
        82,
        522,
        300,
        UIColorPanelBorder,
        UIColorPanelRaised
    )

    AddUIOutlinedText(
        ExpertImpoppableWarningGui,
        "EXPERT IMPOPPABLE WARNING",
        18,
        18,
        534,
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
        "x42 y100 w486 h24 Center c" . UIColorHeadingText . " BackgroundTrans",
        "FULL MONKEY KNOWLEDGE EXPECTED"
    )

    SetUIBodyFont(
        ExpertImpoppableWarningGui,
        9,
        UIColorSecondaryText
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x52 y136 w466 h60 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "All Expert Impoppable strategies in this macro were created and tested with every Monkey Knowledge upgrade researched and unlocked."
    )

    SetUIBodyFont(
        ExpertImpoppableWarningGui,
        8,
        UIColorSecondaryText
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x52 y204 w466 h54 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Without full Monkey Knowledge, cash, tower costs, cooldowns, and other bonuses may differ from what the strategy expects."
    )

    SetUIBodyBoldFont(
        ExpertImpoppableWarningGui,
        8,
        UIColorError
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x52 y266 w466 h42 Center c" . UIColorError . " BackgroundTrans",
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
        "x52 y326 w300 h24 c" . UIColorSecondaryText,
        "Don't show this warning again"
    )

    SetUIBodyFont(
        ExpertImpoppableWarningGui,
        7,
        UIColorMutedText
    )

    ExpertImpoppableWarningGui.Add(
        "Text",
        "x72 y354 w430 h18 c" . UIColorMutedText . " BackgroundTrans",
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

    try {
        if ExpertImpoppableWarningGui {
            ExpertImpoppableWarningGui.Destroy()
        }
    }

    ExpertImpoppableWarningGui := ""
    ExpertImpoppableWarningDontShowAgain := ""
}
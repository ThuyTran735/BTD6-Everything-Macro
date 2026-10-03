#Requires AutoHotkey v2.0


; v3 file note: UI code for FirstRunWarning. Game automation should stay in the gameplay/navigation files instead of creeping in here.

global FirstRunWarningGui := ""
global FirstRunWarningAcceptedThisSession := false
global FirstRunWarningNeverShowAgain := ""

; Bump this when the warning changes enough that people should see it again.
; Version 3 adds the choice to keep showing this screen or hide it for good.
global FirstRunWarningVersion := "3"


GetFirstRunWarningSettingsPath() {
    return A_ScriptDir . "\\UserData\\Settings.ini"
}


HasAcceptedFirstRunWarning() {
    global FirstRunWarningVersion

    path := GetFirstRunWarningSettingsPath()

    try {
        value := IniRead(
            path,
            "Safety",
            "FirstRunWarningAccepted",
            "0"
        )

        return value = FirstRunWarningVersion
    }

    return false
}


SaveFirstRunWarningAcceptance() {
    global FirstRunWarningVersion

    settingsDir := A_ScriptDir . "\\UserData"

    if !DirExist(settingsDir) {
        DirCreate(settingsDir)
    }

    IniWrite(
        FirstRunWarningVersion,
        GetFirstRunWarningSettingsPath(),
        "Safety",
        "FirstRunWarningAccepted"
    )
}


ShowFirstRunWarningIfNeeded() {
    global FirstRunWarningGui
    global FirstRunWarningAcceptedThisSession
    global FirstRunWarningNeverShowAgain

    global UIColorBackground
    global UIColorPanelRaised
    global UIColorPanelBorder
    global UIColorWarning
    global UIColorError
    global UIColorHeadingText
    global UIColorSecondaryText
    global UIColorMutedText

    if HasAcceptedFirstRunWarning() {
        return true
    }

    FirstRunWarningAcceptedThisSession := false

    dialogWidth := 600
    dialogHeight := 810

    FirstRunWarningGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "BTD6 Everything Macro - Setup & Warning"
    )

    FirstRunWarningGui.BackColor := UIColorBackground

    EnableCustomWindowChrome(FirstRunWarningGui, 70, 0)
    AddCustomWindowBorder(FirstRunWarningGui, dialogWidth, dialogHeight)
    AddUICard(
        FirstRunWarningGui,
        28,
        86,
        544,
        620,
        UIColorPanelBorder,
        UIColorPanelRaised
    )

    AddUIOutlinedText(
        FirstRunWarningGui,
        "IMPORTANT BEFORE USING THE MACRO",
        22,
        20,
        556,
        38,
        12,
        "Center",
        true,
        UIColorWarning
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        9,
        UIColorSecondaryText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x42 y100 w516 h34 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Set up BTD6's hotkeys exactly like this before running a strategy."
    )

    SetUIHeadingFont(
        FirstRunWarningGui,
        9,
        UIColorHeadingText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x52 y145 w496 h22 c" . UIColorHeadingText . " BackgroundTrans",
        "1. RESET ALL HOTKEYS TO DEFAULT"
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        8,
        UIColorSecondaryText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x64 y171 w472 h40 c" . UIColorSecondaryText . " BackgroundTrans",
        "Open BTD6 Settings > Hotkeys and reset every binding to its default first. Do this before adding the three custom bindings below."
    )

    SetUIHeadingFont(
        FirstRunWarningGui,
        9,
        UIColorWarning
    )

    FirstRunWarningGui.Add(
        "Text",
        "x52 y222 w496 h22 c" . UIColorWarning . " BackgroundTrans",
        "2. SET THESE THREE CUSTOM TOWER HOTKEYS"
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        9,
        UIColorSecondaryText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x64 y249 w472 h62 c" . UIColorSecondaryText . " BackgroundTrans",
        "Mermonkey = F6`nSkywarden = F7`nDesperado = F8"
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        8,
        UIColorMutedText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x64 y307 w472 h28 c" . UIColorMutedText . " BackgroundTrans",
        "Leave every other BTD6 hotkey at its default."
    )

    SetUIHeadingFont(
        FirstRunWarningGui,
        9,
        UIColorHeadingText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x52 y350 w496 h22 c" . UIColorHeadingText . " BackgroundTrans",
        "3. DO NOT USE ALT+TAB OR TAB"
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        8,
        UIColorSecondaryText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x64 y376 w472 h44 c" . UIColorSecondaryText . " BackgroundTrans",
        "While BTD6 is running for a macro session, do not press Alt+Tab or Tab. It can leave the game in a bad keyboard/focus state and make macro inputs unreliable."
    )

    SetUIHeadingFont(
        FirstRunWarningGui,
        9,
        UIColorHeadingText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x52 y430 w496 h22 c" . UIColorHeadingText . " BackgroundTrans",
        "4. USE THE WINDOWS KEY TO SWITCH APPS"
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        8,
        UIColorSecondaryText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x64 y456 w472 h42 c" . UIColorSecondaryText . " BackgroundTrans",
        "If you need another app, press the Windows key first, then switch to or click that app from there."
    )

    SetUIHeadingFont(
        FirstRunWarningGui,
        9,
        UIColorError
    )

    FirstRunWarningGui.Add(
        "Text",
        "x52 y510 w496 h22 c" . UIColorError . " BackgroundTrans",
        "5. RESTART BTD6 IF IT HAPPENS"
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        8,
        UIColorSecondaryText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x64 y536 w472 h38 c" . UIColorSecondaryText . " BackgroundTrans",
        "If you accidentally use Alt+Tab or Tab, completely close and restart BTD6 before using the macro again."
    )

    SetUIHeadingFont(
        FirstRunWarningGui,
        9,
        UIColorError
    )

    FirstRunWarningGui.Add(
        "Text",
        "x52 y586 w496 h22 c" . UIColorError . " BackgroundTrans",
        "6. USE AT YOUR OWN RISK"
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        8,
        UIColorMutedText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x64 y612 w472 h38 c" . UIColorMutedText . " BackgroundTrans",
        "By agreeing, you accept that the macro author is not responsible for bans, suspensions, lost progress, or other action taken against your game account."
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        9,
        UIColorSecondaryText
    )

    ; Leave this off by default so hiding the warning is always the user's choice.
    FirstRunWarningNeverShowAgain := FirstRunWarningGui.Add(
        "CheckBox",
        "x64 y666 w300 h24 c" . UIColorSecondaryText,
        "Never show this warning again"
    )

    SetUIBodyFont(
        FirstRunWarningGui,
        7,
        UIColorMutedText
    )

    FirstRunWarningGui.Add(
        "Text",
        "x84 y692 w450 h22 c" . UIColorMutedText . " BackgroundTrans",
        "Leave this unchecked if you want the reminder next time."
    )

    agreeButton := CreateDarkButton(
        FirstRunWarningGui,
        28,
        736,
        350,
        48,
        "I AGREE - CONTINUE",
        8,
        "Success"
    )

    exitButton := CreateDarkButton(
        FirstRunWarningGui,
        392,
        736,
        180,
        48,
        "EXIT",
        8,
        "Danger"
    )

    agreeButton.OnEvent(
        "Click",
        AcceptFirstRunWarning
    )

    exitButton.OnEvent(
        "Click",
        DeclineFirstRunWarning
    )

    FirstRunWarningGui.OnEvent(
        "Close",
        DeclineFirstRunWarning
    )

    FirstRunWarningGui.OnEvent(
        "Escape",
        DeclineFirstRunWarning
    )

    FirstRunWarningGui.Show(
        "Hide w" . dialogWidth . " h" . dialogHeight
    )

    ApplyDarkWindowStyle(FirstRunWarningGui)

    FirstRunWarningGui.Show(
        "w" . dialogWidth . " h" . dialogHeight . " Center"
    )

    try WinActivate(
        "ahk_id " . FirstRunWarningGui.Hwnd
    )

    warningHwnd := FirstRunWarningGui.Hwnd

    WinWaitClose(
        "ahk_id " . warningHwnd
    )

    if !FirstRunWarningAcceptedThisSession {
        ExitApp()
    }

    return true
}


AcceptFirstRunWarning(*) {
    global FirstRunWarningGui
    global FirstRunWarningAcceptedThisSession
    global FirstRunWarningNeverShowAgain

    ; Only save the setting when the user actually asked us to stop showing it.
    if (
        FirstRunWarningNeverShowAgain
        && FirstRunWarningNeverShowAgain.Value
    ) {
        SaveFirstRunWarningAcceptance()
    }

    FirstRunWarningAcceptedThisSession := true

    try {
        if FirstRunWarningGui {
            FirstRunWarningGui.Destroy()
        }
    }

    FirstRunWarningGui := ""
    FirstRunWarningNeverShowAgain := ""
}


DeclineFirstRunWarning(*) {
    global FirstRunWarningGui
    global FirstRunWarningAcceptedThisSession
    global FirstRunWarningNeverShowAgain

    FirstRunWarningAcceptedThisSession := false

    try {
        if FirstRunWarningGui {
            FirstRunWarningGui.Destroy()
        }
    }

    FirstRunWarningGui := ""
    FirstRunWarningNeverShowAgain := ""
    ExitApp()
}
#Requires AutoHotkey v2.0

; v3 file note: Runs the small profile-name prompt and closes the profile windows cleanly.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

PromptQueueProfileName(promptText, defaultName := "") {
    global QueueProfilesGui
    global QueueProfileNameGui
    global QueueProfileNameEdit
    global QueueProfileNameErrorText
    global QueueProfileNameResult
    global QueueProfileNameFinished
    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorError
    global UIColorInputBorder
    global UIColorInputBackground
    global UIColorInputText

    CloseQueueProfileNamePrompt()
    CloseAllDarkDropdowns()
    CloseContextHelp()

    QueueProfileNameResult := ""
    QueueProfileNameFinished := false

    dialogWidth := 440
    dialogHeight := 276
    ownerOption := ""

    if QueueProfilesGui {
        try ownerOption := " +Owner" . QueueProfilesGui.Hwnd
    }

    QueueProfileNameGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox" . ownerOption,
        "Queue Profile Name"
    )
    QueueProfileNameGui.BackColor := UIColorBackground


    EnableCustomWindowChrome(QueueProfileNameGui)
    AddCustomWindowBorder(QueueProfileNameGui, dialogWidth, dialogHeight)

    SetUIHeadingFont(QueueProfileNameGui, 13, UIColorPrimaryText)
    QueueProfileNameGui.Add(
        "Text",
        "x20 y20 w400 h30 Center c" . UIColorPrimaryText . " BackgroundTrans",
        "QUEUE PROFILE NAME"
    )

    SetUIBodyFont(QueueProfileNameGui, 9, UIColorSecondaryText)
    QueueProfileNameGui.Add(
        "Text",
        "x30 y60 w380 h38 Center c" . UIColorSecondaryText . " BackgroundTrans",
        promptText
    )

    QueueProfileNameGui.Add(
        "Progress",
        "x29 y112 w382 h48 c" . UIColorInputBorder
        . " Background" . UIColorInputBorder . " Disabled",
        100
    )

    SetUIBodyBoldFont(QueueProfileNameGui, 11, UIColorPrimaryText)
    QueueProfileNameEdit := QueueProfileNameGui.Add(
        "Edit",
        "x31 y114 w378 h44 Center Limit80 c" . UIColorInputText
        . " Background" . UIColorInputBackground,
        defaultName
    )
    ApplyDarkControlTheme(QueueProfileNameEdit)
    QueueProfileNameEdit.OnEvent("Change", QueueProfileNameChanged)

    SetUIBodyFont(QueueProfileNameGui, 8, UIColorError)
    QueueProfileNameErrorText := QueueProfileNameGui.Add(
        "Text",
        "x20 y169 w400 h34 Center c" . UIColorError . " BackgroundTrans",
        ""
    )

    saveButton := CreateDarkButton(QueueProfileNameGui, 30, 211, 184, 44, "SAVE NAME", 8)
    cancelButton := CreateDarkButton(QueueProfileNameGui, 226, 211, 184, 44, "CANCEL", 8, "Default")

    CreateHelpBadgeForButton(
        QueueProfileNameGui,
        saveButton,
        "PROFILE NAME",
        "Saves this profile name.`n`nQueue Profiles remain available after restarting the launcher."
    )

    CreateHelpBadgeForButton(
        QueueProfileNameGui,
        cancelButton,
        "CANCEL",
        "Returns without saving the new name."
    )

    saveButton.OnEvent("Click", ConfirmQueueProfileName)
    cancelButton.OnEvent("Click", CancelQueueProfileName)
    QueueProfileNameGui.OnEvent("Close", CancelQueueProfileName)
    QueueProfileNameGui.OnEvent("Escape", CancelQueueProfileName)

    ApplyDarkWindowStyle(QueueProfileNameGui)

    if QueueProfilesGui {
        try QueueProfilesGui.Hide()
    }

    QueueProfileNameGui.Show("w" . dialogWidth . " h" . dialogHeight . " Center")
    try WinActivate("ahk_id " . QueueProfileNameGui.Hwnd)
    QueueProfileNameEdit.Focus()

    while !QueueProfileNameFinished {
        Sleep(25)
    }

    result := QueueProfileNameResult
    CloseQueueProfileNamePrompt()
    return result
}


ConfirmQueueProfileName(*) {
    global QueueProfileNameEdit
    global QueueProfileNameErrorText
    global QueueProfileNameResult
    global QueueProfileNameFinished

    if !QueueProfileNameEdit {
        return
    }

    value := Trim(QueueProfileNameEdit.Value)
    if value = "" {
        QueueProfileNameErrorText.Text := "ENTER A PROFILE NAME"
        return
    }

    if !IsValidQueueProfileName(value) {
        QueueProfileNameErrorText.Text :=
            "INVALID CHARACTERS  -  DO NOT USE  \\ / : * ? "
            . Chr(34)
            . " < > | [ ] ="
        return
    }

    QueueProfileNameResult := value
    QueueProfileNameFinished := true
}


CancelQueueProfileName(*) {
    global QueueProfileNameResult
    global QueueProfileNameFinished

    QueueProfileNameResult := ""
    QueueProfileNameFinished := true
}


QueueProfileNameChanged(*) {
    global QueueProfileNameErrorText
    if QueueProfileNameErrorText {
        QueueProfileNameErrorText.Text := ""
    }
}


CloseQueueProfileNamePrompt() {
    global QueueProfilesGui
    global QueueProfileNameGui
    global QueueProfileNameEdit
    global QueueProfileNameErrorText

    try {
        if QueueProfileNameGui
            QueueProfileNameGui.Destroy()
    }

    if QueueProfilesGui {
        try QueueProfilesGui.Show("w680 h490 Center")
        try WinActivate("ahk_id " . QueueProfilesGui.Hwnd)
    }

    QueueProfileNameGui := ""
    QueueProfileNameEdit := ""
    QueueProfileNameErrorText := ""
}


CloseQueueProfilesAndReturnToQueue(*) {
    CloseQueueProfilesManager()
    ShowQueueManager()
}


CloseQueueProfilesManager(*) {
    global QueueProfilesGui
    global QueueProfileDropdown
    global QueueProfileFavoriteButton
    global QueueProfileFavoriteHelpBadge
    global QueueProfileStatusText
    global QueueProfileSummaryText
    global QueueProfileDescriptionEdit
    global QueueProfileNotesScrollTrack
    global QueueProfileNotesScrollThumb
    global QueueProfileRepeatEdit
    global QueueProfileRepeatMinusButton
    global QueueProfileRepeatPlusButton
    global QueueProfileDetailsLoading
    global QueueProfileRecords

    CloseQueueProfileMoreActions()
    CloseQueueProfileNamePrompt()
    CloseAllDarkDropdowns()

    try {
        if QueueProfilesGui
            QueueProfilesGui.Destroy()
    }

    QueueProfilesGui := ""
    QueueProfileDropdown := ""
    QueueProfileFavoriteButton := ""
    QueueProfileFavoriteHelpBadge := ""
    QueueProfileStatusText := ""
    QueueProfileSummaryText := ""
    QueueProfileDescriptionEdit := ""
    QueueProfileNotesScrollTrack := ""
    QueueProfileNotesScrollThumb := ""
    QueueProfileRepeatEdit := ""
    QueueProfileRepeatMinusButton := ""
    QueueProfileRepeatPlusButton := ""
    QueueProfileDetailsLoading := false
    QueueProfileRecords := []
}
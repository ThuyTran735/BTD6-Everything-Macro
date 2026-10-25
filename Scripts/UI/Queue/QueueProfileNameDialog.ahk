#Requires AutoHotkey v2.0

; Waits for a name or cancellation, then restores the profile manager.

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

    CloseQueueProfileNamePrompt(false)
    CloseAllDarkDropdowns()
    CloseContextHelp()

    QueueProfileNameResult := ""
    QueueProfileNameFinished := false

    dialogWidth := 440
    dialogHeight := 280
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
        "x24 y24 w392 h28 Center c" . UIColorPrimaryText . " BackgroundTrans",
        "QUEUE PROFILE NAME"
    )

    SetUIBodyFont(QueueProfileNameGui, 9, UIColorSecondaryText)
    QueueProfileNameGui.Add(
        "Text",
        "x24 y64 w392 h36 Center c" . UIColorSecondaryText . " BackgroundTrans",
        promptText
    )

    QueueProfileNameGui.Add(
        "Progress",
        "x24 y116 w392 h44 c" . UIColorInputBorder
        . " Background" . UIColorInputBorder . " Disabled",
        100
    )

    SetUIBodyFont(QueueProfileNameGui, 11, UIColorPrimaryText)
    QueueProfileNameEdit := QueueProfileNameGui.Add(
        "Edit",
        "x26 y118 w388 h40 Center Limit80 c" . UIColorInputText
        . " Background" . UIColorInputBackground,
        defaultName
    )
    ApplyDarkControlTheme(QueueProfileNameEdit)
    QueueProfileNameEdit.OnEvent("Change", QueueProfileNameChanged)

    SetUIBodyFont(QueueProfileNameGui, 8, UIColorError)
    QueueProfileNameErrorText := QueueProfileNameGui.Add(
        "Text",
        "x24 y172 w392 h28 Center c" . UIColorError . " BackgroundTrans",
        ""
    )

    saveButton := CreateDarkButton(QueueProfileNameGui, 24, 212, 190, 44, "SAVE NAME", 8)
    cancelButton := CreateDarkButton(QueueProfileNameGui, 226, 212, 190, 44, "CANCEL", 8, "Default")

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


CloseQueueProfileNamePrompt(restoreOwner := true) {
    global QueueProfilesGui
    global QueueProfileNameGui
    global QueueProfileNameEdit
    global QueueProfileNameErrorText
    global QueueProfileNameFinished

    hadPrompt := IsObject(QueueProfileNameGui)
    QueueProfileNameFinished := true

    try {
        if QueueProfileNameGui
            QueueProfileNameGui.Destroy()
    }

    ; Closing the manager also calls this cleanup. Never resurrect the owner
    ; for a frame when no prompt existed or the whole manager is closing.
    if hadPrompt && restoreOwner
        RestoreExistingUIWindow(QueueProfilesGui)

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
    CloseQueueProfileNamePrompt(false)
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

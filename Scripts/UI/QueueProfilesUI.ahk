#Requires AutoHotkey v2.0


global QueueProfilesGui := ""
global QueueProfileDropdown := ""
global QueueProfileFavoriteButton := ""
global QueueProfileFavoriteHelpBadge := ""
global QueueProfileStatusText := ""
global QueueProfileRecords := []

global QueueProfileNameGui := ""
global QueueProfileNameEdit := ""
global QueueProfileNameErrorText := ""
global QueueProfileNameResult := ""
global QueueProfileNameFinished := false


ShowQueueProfilesManager(*) {
    global QueueProfilesGui
    global QueueProfileDropdown
    global QueueProfileFavoriteButton
    global QueueProfileFavoriteHelpBadge
    global QueueProfileStatusText

    global MacroRunning

    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText
    global UIColorSuccess

    if MacroRunning {
        return
    }

    CloseAllDarkDropdowns()
    CloseContextHelp()
    CloseQueueProfilesManager()

    QueueProfilesGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        "Queue Profiles - V1.1"
    )

    QueueProfilesGui.BackColor := UIColorBackground

    QueueProfilesGui.Add(
        "Progress",
        "x0 y0 w560 h4 c"
        . UIColorAccent
        . " Background"
        . UIColorAccent
        . " Disabled",
        100
    )

    AddUIOutlinedText(
        QueueProfilesGui,
        "QUEUE PROFILES",
        20,
        18,
        520,
        34,
        13,
        "Center"
    )

    CreateHelpBadgeForHeader(
        QueueProfilesGui,
        560,
        "QUEUE PROFILES",
        "Save the current queue as a reusable profile, then load it later with one click. UPDATE replaces a saved profile with the queue you currently have. RENAME changes only its name. Starred profiles stay at the top of this list."
    )

    SetUIBodyFont(
        QueueProfilesGui,
        9,
        UIColorSecondaryText
    )

    QueueProfilesGui.Add(
        "Text",
        "x20 y55 w520 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Save and reuse complete queue setups"
    )

    QueueProfileLabel :=
        AddUIOutlinedText(
        QueueProfilesGui,
        "SELECT PROFILE",
        30,
        88,
        470,
        22,
        9
    )

    QueueProfileDropdown := CreateDarkDropdown(
        QueueProfilesGui,
        30,
        112,
        470,
        ["No saved profiles"],
        1,
        5
    )

    QueueProfileFavoriteButton := CreateFavoriteButtonForField(
        QueueProfilesGui,
        QueueProfileDropdown
    )

    QueueProfileFavoriteButton.OnEvent(
        "Click",
        ToggleSelectedQueueProfileFavorite
    )

    QueueProfileFavoriteHelpBadge :=
        CreateFavoriteHelpBadgeForField(
            QueueProfilesGui,
            QueueProfileDropdown,
            "FAVORITES",
            "Click ☆ to favorite the selected profile. ★ means it is already a favorite. Favorite profiles automatically move to the top of the profile dropdown."
        )

    CreateHelpBadgeForField(
        QueueProfilesGui,
        QueueProfileDropdown,
        QueueProfileLabel,
        "PROFILE",
        "Choose a saved queue profile to load, update, rename, delete, or favorite."
    )

    loadButton := CreateDarkButton(
        QueueProfilesGui,
        30,
        166,
        155,
        42,
        "LOAD",
        9
    )

    saveButton := CreateDarkButton(
        QueueProfilesGui,
        202,
        166,
        155,
        42,
        "SAVE CURRENT",
        8
    )

    updateButton := CreateDarkButton(
        QueueProfilesGui,
        374,
        166,
        155,
        42,
        "UPDATE",
        9
    )

    renameButton := CreateDarkButton(
        QueueProfilesGui,
        30,
        220,
        155,
        42,
        "RENAME",
        9
    )

    deleteButton := CreateDarkButton(
        QueueProfilesGui,
        202,
        220,
        155,
        42,
        "DELETE",
        9
    )

    closeButton := CreateDarkButton(
        QueueProfilesGui,
        374,
        220,
        155,
        42,
        "CLOSE",
        9
    )

    loadButton.OnEvent("Click", LoadSelectedQueueProfile)
    saveButton.OnEvent("Click", SaveCurrentQueueProfile)
    updateButton.OnEvent("Click", UpdateSelectedQueueProfile)
    renameButton.OnEvent("Click", RenameSelectedQueueProfile)
    deleteButton.OnEvent("Click", DeleteSelectedQueueProfile)
    closeButton.OnEvent("Click", CloseQueueProfilesManager)

    CreateHelpBadgeForButton(
        QueueProfilesGui,
        loadButton,
        "LOAD PROFILE",
        "Replaces the current queue with every job and run count stored in the selected profile."
    )

    CreateHelpBadgeForButton(
        QueueProfilesGui,
        saveButton,
        "SAVE CURRENT",
        "Saves the queue you currently built as a new named profile. The profile is stored in UserData so it remains available after restarting the launcher."
    )

    CreateHelpBadgeForButton(
        QueueProfilesGui,
        updateButton,
        "UPDATE PROFILE",
        "Replaces the selected profile's saved jobs with the queue you currently have. Its name and favorite state are preserved."
    )

    CreateHelpBadgeForButton(
        QueueProfilesGui,
        renameButton,
        "RENAME PROFILE",
        "Changes the selected profile's name without changing any of its saved queue jobs."
    )

    CreateHelpBadgeForButton(
        QueueProfilesGui,
        deleteButton,
        "DELETE PROFILE",
        "Deletes the selected saved profile. This does not delete any map or Monkey EXP .ahk scripts."
    )

    SetUIBodyBoldFont(
        QueueProfilesGui,
        8,
        UIColorSuccess
    )

    QueueProfileStatusText := QueueProfilesGui.Add(
        "Text",
        "x30 y282 w500 h20 Center c"
        . UIColorSuccess
        . " BackgroundTrans",
        "READY"
    )

    QueueProfileDropdown.OnEvent(
        "Change",
        UpdateQueueProfileFavoriteButton
    )

    QueueProfilesGui.OnEvent("Close", CloseQueueProfilesManager)
    QueueProfilesGui.OnEvent("Escape", CloseQueueProfilesManager)

    QueueProfilesGui.Show("Hide w560 h325")
    ApplyDarkWindowStyle(QueueProfilesGui)

    RefreshQueueProfilesManager(false)

    QueueProfilesGui.Show("w560 h325 Center")
}


RefreshQueueProfilesManager(
    keepSelection := true
) {
    global QueueProfileDropdown
    global QueueProfileRecords

    if !QueueProfileDropdown {
        return
    }

    selectedName := keepSelection ? QueueProfileDropdown.Text : ""

    QueueProfileRecords := GetQueueProfileRecords()
    names := []

    for record in QueueProfileRecords {
        names.Push(record.name)
    }

    QueueProfileDropdown.Delete()

    if names.Length = 0 {
        QueueProfileDropdown.Add(["No saved profiles"])
        QueueProfileDropdown.Choose(1)
    }
    else {
        QueueProfileDropdown.Add(names)

        selectedIndex := FindTextIndex(names, selectedName)
        QueueProfileDropdown.Choose(
            selectedIndex > 0 ? selectedIndex : 1
        )
    }

    UpdateQueueProfileFavoriteButton()
}


GetSelectedQueueProfileRecord() {
    global QueueProfileDropdown
    global QueueProfileRecords

    if !QueueProfileDropdown {
        return false
    }

    selectedName := QueueProfileDropdown.Text

    for record in QueueProfileRecords {
        if record.name = selectedName {
            return record
        }
    }

    return false
}


UpdateQueueProfileFavoriteButton(*) {
    global QueueProfileFavoriteButton
    global QueueProfileFavoriteHelpBadge

    if !QueueProfileFavoriteButton {
        return
    }

    record := GetSelectedQueueProfileRecord()

    QueueProfileFavoriteButton.Enabled := record ? true : false

    SetFavoriteButtonState(
        QueueProfileFavoriteButton,
        record ? record.favorite : false
    )
}


ToggleSelectedQueueProfileFavorite(*) {
    record := GetSelectedQueueProfileRecord()

    if !record {
        return
    }

    SetQueueProfileFavorite(
        record.path,
        !record.favorite
    )

    RefreshQueueProfilesManager(true)
}


PromptQueueProfileName(
    promptText,
    defaultName := ""
) {
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
    global UIColorControlBorder
    global UIColorControlBottom

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
    QueueProfileNameGui.MarginX := 0
    QueueProfileNameGui.MarginY := 0

    QueueProfileNameGui.Add(
        "Progress",
        "x0 y0 w" . dialogWidth . " h4 c" . UIColorAccent
        . " Background" . UIColorAccent . " Disabled",
        100
    )

    SetUIHeadingFont(
        QueueProfileNameGui,
        13,
        UIColorPrimaryText
    )

    QueueProfileNameGui.Add(
        "Text",
        "x20 y20 w400 h30 Center c" . UIColorPrimaryText . " BackgroundTrans",
        "QUEUE PROFILE NAME"
    )

    SetUIBodyFont(
        QueueProfileNameGui,
        9,
        UIColorSecondaryText
    )

    QueueProfileNameGui.Add(
        "Text",
        "x30 y60 w380 h38 Center c" . UIColorSecondaryText . " BackgroundTrans",
        promptText
    )

    QueueProfileNameGui.Add(
        "Progress",
        "x29 y112 w382 h48 c" . UIColorControlBorder
        . " Background" . UIColorControlBorder . " Disabled",
        100
    )

    SetUIBodyBoldFont(
        QueueProfileNameGui,
        11,
        UIColorPrimaryText
    )

    QueueProfileNameEdit := QueueProfileNameGui.Add(
        "Edit",
        "x31 y114 w378 h44 Center Limit80 c" . UIColorPrimaryText
        . " Background" . UIColorControlBottom,
        defaultName
    )

    ApplyDarkControlTheme(QueueProfileNameEdit)

    try {
        DllCall(
            "uxtheme\SetWindowTheme",
            "Ptr", QueueProfileNameEdit.Hwnd,
            "Str", "",
            "Str", ""
        )
    }

    QueueProfileNameEdit.Opt(
        "c" . UIColorPrimaryText . " Background" . UIColorControlBottom
    )

    QueueProfileNameEdit.OnEvent(
        "Change",
        QueueProfileNameChanged
    )

    SetUIBodyFont(
        QueueProfileNameGui,
        8,
        UIColorError
    )

    QueueProfileNameErrorText := QueueProfileNameGui.Add(
        "Text",
        "x20 y169 w400 h34 Center c" . UIColorError . " BackgroundTrans",
        ""
    )

    saveButton := CreateDarkButton(
        QueueProfileNameGui,
        30,
        211,
        184,
        44,
        "SAVE NAME",
        8
    )

    cancelButton := CreateDarkButton(
        QueueProfileNameGui,
        226,
        211,
        184,
        44,
        "CANCEL",
        8
    )

    CreateHelpBadgeForButton(
        QueueProfileNameGui,
        saveButton,
        "PROFILE NAME",
        "Confirms the queue profile name. Profile names are stored locally in UserData and remain available after restarting the launcher."
    )

    saveButton.OnEvent(
        "Click",
        ConfirmQueueProfileName
    )

    cancelButton.OnEvent(
        "Click",
        CancelQueueProfileName
    )

    QueueProfileNameGui.OnEvent(
        "Close",
        CancelQueueProfileName
    )

    QueueProfileNameGui.OnEvent(
        "Escape",
        CancelQueueProfileName
    )

    ApplyDarkWindowStyle(QueueProfileNameGui)

    if QueueProfilesGui {
        try QueueProfilesGui.Opt("+Disabled")
    }

    QueueProfileNameGui.Show(
        "w" . dialogWidth . " h" . dialogHeight . " Center"
    )

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
            "INVALID CHARACTERS  -  DO NOT USE  \ / : * ? "
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
    global QueueProfileNameResult
    global QueueProfileNameFinished

    try {
        if QueueProfileNameGui {
            QueueProfileNameGui.Destroy()
        }
    }

    if QueueProfilesGui {
        try QueueProfilesGui.Opt("-Disabled")
        try WinActivate("ahk_id " . QueueProfilesGui.Hwnd)
    }

    QueueProfileNameGui := ""
    QueueProfileNameEdit := ""
    QueueProfileNameErrorText := ""
}


SetQueueProfileStatus(
    message,
    color := ""
) {
    global QueueProfileStatusText
    global UIColorSuccess

    if !QueueProfileStatusText {
        return
    }

    if color = "" {
        color := UIColorSuccess
    }

    QueueProfileStatusText.Text := message
    QueueProfileStatusText.SetFont("c" . color)
}


SaveCurrentQueueProfile(*) {
    global MacroJobQueue
    global QueueProfileDropdown
    global QueueProfileRecords
    global UIColorError
    global UIColorSuccess

    if MacroJobQueue.Length = 0 {
        SetQueueProfileStatus(
            "QUEUE IS EMPTY",
            UIColorError
        )
        return
    }

    profileName := PromptQueueProfileName(
        "Enter a name for this queue profile."
    )

    if profileName = "" {
        return
    }

    if !IsValidQueueProfileName(profileName) {
        SetQueueProfileStatus(
            "INVALID PROFILE NAME",
            UIColorError
        )
        return
    }

    if FindQueueProfileRecord(profileName) {
        SetQueueProfileStatus(
            "PROFILE EXISTS - USE UPDATE",
            UIColorError
        )
        return
    }

    savedPath := WriteQueueProfile(profileName, MacroJobQueue)

    if !savedPath {
        SetQueueProfileStatus(
            "COULD NOT SAVE PROFILE",
            UIColorError
        )
        return
    }

    ; Do not report success until the profile can be read back with the same
    ; number of jobs that were in the queue.
    savedJobs := ReadQueueProfileJobs(savedPath)

    if savedJobs.Length != MacroJobQueue.Length {
        SetQueueProfileStatus(
            "PROFILE SAVE VERIFY FAILED",
            UIColorError
        )
        return
    }

    RefreshQueueProfilesManager(false)

    ; Select the profile that was just saved from the refreshed records.
    names := []
    for record in QueueProfileRecords {
        names.Push(record.name)
    }

    index := FindTextIndex(names, profileName)
    if index > 0 {
        QueueProfileDropdown.Choose(index)
    }

    UpdateQueueProfileFavoriteButton()

    SetQueueProfileStatus(
        "PROFILE SAVED",
        UIColorSuccess
    )
}


LoadSelectedQueueProfile(*) {
    global MacroJobQueue
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()

    if !record {
        SetQueueProfileStatus(
            "NO PROFILE SELECTED",
            UIColorError
        )
        return
    }

    jobs := ReadQueueProfileJobs(record.path)

    if jobs.Length = 0 {
        SetQueueProfileStatus(
            "PROFILE HAS NO JOBS",
            UIColorError
        )
        return
    }

    MacroJobQueue := jobs

    RefreshQueueManager()
    UpdateQueueLauncherButton()

    SetQueueProfileStatus(
        "PROFILE LOADED",
        UIColorSuccess
    )
}


UpdateSelectedQueueProfile(*) {
    global MacroJobQueue
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()

    if !record {
        SetQueueProfileStatus(
            "NO PROFILE SELECTED",
            UIColorError
        )
        return
    }

    if MacroJobQueue.Length = 0 {
        SetQueueProfileStatus(
            "QUEUE IS EMPTY",
            UIColorError
        )
        return
    }

    if !WriteQueueProfile(
        record.name,
        MacroJobQueue,
        record.path
    ) {
        SetQueueProfileStatus(
            "COULD NOT UPDATE PROFILE",
            UIColorError
        )
        return
    }

    RefreshQueueProfilesManager(true)

    SetQueueProfileStatus(
        "PROFILE UPDATED",
        UIColorSuccess
    )
}


RenameSelectedQueueProfile(*) {
    global QueueProfileDropdown
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()

    if !record {
        SetQueueProfileStatus(
            "NO PROFILE SELECTED",
            UIColorError
        )
        return
    }

    newName := PromptQueueProfileName(
        "Enter the new profile name.",
        record.name
    )

    if newName = "" || newName = record.name {
        return
    }

    if !IsValidQueueProfileName(newName) {
        SetQueueProfileStatus(
            "INVALID PROFILE NAME",
            UIColorError
        )
        return
    }

    if FindQueueProfileRecord(newName) {
        SetQueueProfileStatus(
            "PROFILE NAME ALREADY EXISTS",
            UIColorError
        )
        return
    }

    newPath := GetQueueProfilesDirectory()
        . "\"
        . newName
        . ".ini"

    try {
        FileMove(record.path, newPath, false)
        IniWrite(newName, newPath, "Profile", "Name")
    }
    catch {
        SetQueueProfileStatus(
            "COULD NOT RENAME PROFILE",
            UIColorError
        )
        return
    }

    RefreshQueueProfilesManager(false)

    names := []
    for profile in GetQueueProfileRecords() {
        names.Push(profile.name)
    }

    index := FindTextIndex(names, newName)
    if index > 0 {
        QueueProfileDropdown.Choose(index)
    }

    UpdateQueueProfileFavoriteButton()

    SetQueueProfileStatus(
        "PROFILE RENAMED",
        UIColorSuccess
    )
}


DeleteSelectedQueueProfile(*) {
    global QueueProfilesGui
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()

    if !record {
        SetQueueProfileStatus(
            "NO PROFILE SELECTED",
            UIColorError
        )
        return
    }

    if QueueProfilesGui {
        try QueueProfilesGui.Opt("+OwnDialogs")
    }

    result := MsgBox(
        "Delete queue profile '"
        . record.name
        . "'?",
        "Delete Queue Profile",
        "YesNo Icon!"
    )

    if result != "Yes" {
        return
    }

    try FileDelete(record.path)
    catch {
        SetQueueProfileStatus(
            "COULD NOT DELETE PROFILE",
            UIColorError
        )
        return
    }

    RefreshQueueProfilesManager(false)

    SetQueueProfileStatus(
        "PROFILE DELETED",
        UIColorSuccess
    )
}


CloseQueueProfilesManager(*) {
    global QueueProfilesGui
    global QueueProfileDropdown
    global QueueProfileFavoriteButton
    global QueueProfileFavoriteHelpBadge
    global QueueProfileStatusText
    global QueueProfileRecords

    CloseQueueProfileNamePrompt()
    CloseAllDarkDropdowns()

    try {
        if QueueProfilesGui {
            QueueProfilesGui.Destroy()
        }
    }

    QueueProfilesGui := ""
    QueueProfileDropdown := ""
    QueueProfileFavoriteButton := ""
    QueueProfileFavoriteHelpBadge := ""
    QueueProfileStatusText := ""
    QueueProfileRecords := []
}
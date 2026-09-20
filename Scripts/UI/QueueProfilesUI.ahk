#Requires AutoHotkey v2.0


global QueueProfilesGui := ""
global QueueProfileDropdown := ""
global QueueProfileFavoriteButton := ""
global QueueProfileFavoriteHelpBadge := ""
global QueueProfileStatusText := ""
global QueueProfileSummaryText := ""
global QueueProfileDescriptionEdit := ""
global QueueProfileNotesScrollTrack := ""
global QueueProfileNotesScrollThumb := ""
global QueueProfileNotesWheelHooked := false
global QueueProfileRepeatEdit := ""
global QueueProfileRepeatMinusButton := ""
global QueueProfileRepeatPlusButton := ""
global QueueProfileDetailsLoading := false
global QueueProfileMoreGui := ""
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
    global QueueProfileSummaryText
    global QueueProfileDescriptionEdit
    global QueueProfileNotesScrollTrack
    global QueueProfileNotesScrollThumb
    global QueueProfileNotesWheelHooked
    global QueueProfileRepeatEdit
    global QueueProfileRepeatMinusButton
    global QueueProfileRepeatPlusButton
    global MacroRunning
    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorMutedText
    global UIColorSuccess
    global UIColorInputBorder
    global UIColorInputBackground
    global UIColorInputText
    global UIColorControlBorder

    if MacroRunning {
        return
    }

    CloseAllDarkDropdowns()
    CloseContextHelp()
    CloseAllSecondaryMenus()

    QueueProfilesGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        GetVersionedTitle("Queue Profiles")
    )
    QueueProfilesGui.BackColor := UIColorBackground


    EnableCustomWindowChrome(QueueProfilesGui)
    AddCustomWindowBorder(QueueProfilesGui, 680, 490)

    AddUIOutlinedText(QueueProfilesGui, "QUEUE PROFILES", 20, 18, 640, 34, 13, "Center")

    CreateHelpBadgeForHeader(
        QueueProfilesGui,
        680,
        "QUEUE PROFILES",
        "Save complete queue setups and load them later.`n`nNotes and repeat count save automatically. Use MORE for duplicate, rename, export, import, and delete."
    )

    SetUIBodyFont(QueueProfilesGui, 9, UIColorSecondaryText)
    QueueProfilesGui.Add(
        "Text",
        "x20 y55 w640 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Save, describe, repeat, and reuse complete queue setups"
    )

    profileLabel := AddUIOutlinedText(QueueProfilesGui, "SELECT PROFILE", 40, 88, 600, 22, 9)
    QueueProfileDropdown := CreateDarkDropdown(
        QueueProfilesGui,
        40,
        112,
        600,
        ["No saved profiles"],
        1,
        5
    )

    QueueProfileFavoriteButton := CreateFavoriteButtonForField(QueueProfilesGui, QueueProfileDropdown)
    QueueProfileFavoriteButton.OnEvent("Click", ToggleSelectedQueueProfileFavorite)

    QueueProfileFavoriteHelpBadge := CreateFavoriteHelpBadgeForField(
        QueueProfilesGui,
        QueueProfileDropdown,
        "FAVORITES",
        "Click ☆ to favorite the selected profile.`n`n★ means it is a favorite. Favorite profiles stay at the top of the list."
    )

    CreateHelpBadgeForField(
        QueueProfilesGui,
        QueueProfileDropdown,
        profileLabel,
        "PROFILE",
        "Choose a saved Queue Profile.`n`nYou can review it, load it, update it, or use MORE for extra actions."
    )

    SetUIBodyBoldFont(QueueProfilesGui, 8, UIColorMutedText)
    QueueProfileSummaryText := QueueProfilesGui.Add(
        "Text",
        "x40 y154 w600 h22 Center c" . UIColorMutedText . " BackgroundTrans",
        "NO PROFILE SELECTED"
    )

    AddUIOutlinedText(QueueProfilesGui, "DESCRIPTION / NOTES", 40, 190, 260, 22, 9)
    CreateHelpBadge(
        QueueProfilesGui,
        205,
        192,
        "PROFILE NOTES",
        "Write notes about this profile.`n`nYour changes save automatically after you stop typing."
    )

    SetUIBodyBoldFont(QueueProfilesGui, 8, UIColorMutedText)
    QueueProfilesGui.Add(
        "Text",
        "x480 y195 w160 h18 Right c" . UIColorMutedText . " BackgroundTrans",
        "SAVES AUTOMATICALLY"
    )

    QueueProfilesGui.Add(
        "Progress",
        "x39 y217 w602 h50 c" . UIColorInputBorder
        . " Background" . UIColorInputBorder . " Disabled",
        100
    )

    SetUIBodyFont(QueueProfilesGui, 10, UIColorPrimaryText)
    QueueProfileDescriptionEdit := QueueProfilesGui.Add(
        "Edit",
        "x41 y219 w580 h46 Limit2000 Multi WantReturn c" . UIColorInputText
        . " Background" . UIColorInputBackground,
        ""
    )
    ApplyDarkControlTheme(QueueProfileDescriptionEdit)
    QueueProfileDescriptionEdit.OnEvent("Change", QueueProfileNotesChanged)

    QueueProfileNotesScrollTrack := QueueProfilesGui.Add(
        "Progress",
        "x630 y223 w6 h38 c" . UIColorControlBorder
        . " Background" . UIColorControlBorder . " Disabled",
        100
    )
    QueueProfileNotesScrollThumb := QueueProfilesGui.Add(
        "Progress",
        "x630 y223 w6 h38 c" . UIColorAccent
        . " Background" . UIColorAccent . " Disabled",
        100
    )
    QueueProfileNotesScrollTrack.Visible := false
    QueueProfileNotesScrollThumb.Visible := false

    if !QueueProfileNotesWheelHooked {
        OnMessage(0x020A, QueueProfileNotesMouseWheel)
        QueueProfileNotesWheelHooked := true
    }

    AddUIOutlinedText(QueueProfilesGui, "REPEAT ENTIRE PROFILE", 40, 286, 210, 22, 9)
    CreateHelpBadge(
        QueueProfilesGui,
        203,
        288,
        "REPEAT PROFILE",
        "Choose how many times the entire profile should repeat when loaded.`n`nThis saves automatically, and the totals update right away."
    )

    QueueProfileRepeatMinusButton := CreateDarkButton(
        QueueProfilesGui,
        40,
        313,
        42,
        44,
        "-",
        11
    )

    QueueProfilesGui.Add(
        "Progress",
        "x91 y313 w76 h44 c" . UIColorInputBorder
        . " Background" . UIColorInputBorder . " Disabled",
        100
    )

    SetUIBodyBoldFont(QueueProfilesGui, 11, UIColorPrimaryText)
    QueueProfileRepeatEdit := QueueProfilesGui.Add(
        "Edit",
        "x93 y315 w72 h40 Center Limit2 c" . UIColorInputText
        . " Background" . UIColorInputBackground,
        "1"
    )
    ApplyDarkControlTheme(QueueProfileRepeatEdit)
    QueueProfileRepeatEdit.OnEvent("Change", QueueProfileRepeatChanged)

    QueueProfileRepeatPlusButton := CreateDarkButton(
        QueueProfilesGui,
        176,
        313,
        42,
        44,
        "+",
        11
    )

    QueueProfileRepeatMinusButton.OnEvent(
        "Click",
        AdjustQueueProfileRepeat.Bind(-1)
    )
    QueueProfileRepeatPlusButton.OnEvent(
        "Click",
        AdjustQueueProfileRepeat.Bind(1)
    )

    SetUIBodyBoldFont(QueueProfilesGui, 8, UIColorSecondaryText)
    QueueProfilesGui.Add(
        "Text",
        "x238 y323 w402 h24 c" . UIColorSecondaryText . " BackgroundTrans",
        "VALID RANGE: 1-99  |  TOTALS UPDATE AUTOMATICALLY"
    )

    loadButton := CreateDarkButton(QueueProfilesGui, 40, 386, 112, 44, "LOAD PROFILE", 7)
    saveButton := CreateDarkButton(QueueProfilesGui, 162, 386, 112, 44, "SAVE CURRENT", 7)
    updateButton := CreateDarkButton(QueueProfilesGui, 284, 386, 112, 44, "UPDATE", 8)
    moreButton := CreateDarkButton(QueueProfilesGui, 406, 386, 112, 44, "MORE", 8)
    closeButton := CreateDarkButton(QueueProfilesGui, 528, 386, 112, 44, "BACK", 8, "Default")

    CreateHelpBadgeForButton(QueueProfilesGui, loadButton, "LOAD PROFILE", "Loads this profile into the queue.`n`nYour current queue is replaced, and the saved repeat amount is applied.")
    CreateHelpBadgeForButton(QueueProfilesGui, saveButton, "SAVE CURRENT", "Saves your current queue as a new Queue Profile.")
    CreateHelpBadgeForButton(QueueProfilesGui, updateButton, "UPDATE PROFILE", "Updates the selected profile with your current queue.`n`nIts name, favorite status, notes, and repeat amount stay the same.")
    CreateHelpBadgeForButton(QueueProfilesGui, moreButton, "MORE ACTIONS", "Opens extra profile tools: Duplicate, Rename, Export, Import, and Delete.")
    CreateHelpBadgeForButton(
        QueueProfilesGui,
        closeButton,
        "BACK",
        "Returns to the Queue Manager.`n`nYour current queue and saved profiles are not changed."
    )

    loadButton.OnEvent("Click", LoadSelectedQueueProfile)
    saveButton.OnEvent("Click", SaveCurrentQueueProfile)
    updateButton.OnEvent("Click", UpdateSelectedQueueProfile)
    moreButton.OnEvent("Click", ShowQueueProfileMoreActions)
    closeButton.OnEvent("Click", CloseQueueProfilesAndReturnToQueue)

    QueueProfileDropdown.OnEvent("Change", QueueProfileSelectionChanged)
    QueueProfilesGui.OnEvent("Close", CloseQueueProfilesAndReturnToQueue)
    QueueProfilesGui.OnEvent("Escape", CloseQueueProfilesAndReturnToQueue)

    SetUIBodyBoldFont(QueueProfilesGui, 8, UIColorSuccess)
    QueueProfileStatusText := QueueProfilesGui.Add(
        "Text",
        "x40 y448 w600 h22 Center c" . UIColorSuccess . " BackgroundTrans",
        "READY"
    )

    QueueProfilesGui.Show("Hide w680 h490")
    ApplyDarkWindowStyle(QueueProfilesGui)
    RefreshQueueProfilesManager(false)
    QueueProfilesGui.Show("w680 h490 Center")
}


SetQueueProfileStatus(text, color := "") {
    global QueueProfileStatusText
    global UIColorSuccess

    if !QueueProfileStatusText {
        return
    }

    if color = "" {
        color := UIColorSuccess
    }

    QueueProfileStatusText.SetFont("c" . color)
    QueueProfileStatusText.Text := text
}


RefreshQueueProfilesManager(keepSelection := true) {
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
        QueueProfileDropdown.Choose(selectedIndex > 0 ? selectedIndex : 1)
    }

    QueueProfileSelectionChanged()
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


QueueProfileSelectionChanged(*) {
    UpdateQueueProfileFavoriteButton()
    RefreshSelectedQueueProfileDetails()
}


UpdateQueueProfileFavoriteButton(*) {
    global QueueProfileFavoriteButton

    if !QueueProfileFavoriteButton {
        return
    }

    record := GetSelectedQueueProfileRecord()
    QueueProfileFavoriteButton.Enabled := record ? true : false
    SetFavoriteButtonState(QueueProfileFavoriteButton, record ? record.favorite : false)
}


ToggleSelectedQueueProfileFavorite(*) {
    record := GetSelectedQueueProfileRecord()
    if !record {
        return
    }

    SetQueueProfileFavorite(record.path, !record.favorite)
    RefreshQueueProfilesManager(true)
}


RefreshSelectedQueueProfileDetails() {
    global QueueProfileSummaryText
    global QueueProfileDescriptionEdit
    global QueueProfileRepeatEdit
    global QueueProfileRepeatMinusButton
    global QueueProfileRepeatPlusButton
    global QueueProfileDetailsLoading

    QueueProfileDetailsLoading := true

    record := GetSelectedQueueProfileRecord()

    if !record {
        if QueueProfileSummaryText
            QueueProfileSummaryText.Text := "NO PROFILE SELECTED"
        if QueueProfileDescriptionEdit {
            QueueProfileDescriptionEdit.Value := ""
            QueueProfileDescriptionEdit.Enabled := false
            UpdateQueueProfileNotesScrollbar()
        }
        if QueueProfileRepeatEdit {
            QueueProfileRepeatEdit.Value := "1"
            QueueProfileRepeatEdit.Enabled := false
        }
        if QueueProfileRepeatMinusButton
            QueueProfileRepeatMinusButton.Enabled := false
        if QueueProfileRepeatPlusButton
            QueueProfileRepeatPlusButton.Enabled := false
        QueueProfileDetailsLoading := false
        return
    }

    QueueProfileDescriptionEdit.Enabled := true
    QueueProfileRepeatEdit.Enabled := true
    QueueProfileRepeatMinusButton.Enabled := true
    QueueProfileRepeatPlusButton.Enabled := true
    QueueProfileDescriptionEdit.Value := GetQueueProfileDescription(record.path)
    ScrollQueueProfileNotesToTop()
    UpdateQueueProfileNotesScrollbar()
    QueueProfileRepeatEdit.Value := GetQueueProfileRepeatCount(record.path)
    QueueProfileDetailsLoading := false
    RefreshQueueProfileSummary()
}


CloneQueueProfileJob(job) {
    cloned := {
        path: job.path,
        label: job.HasOwnProp("label") ? job.label : job.path,
        mode: job.HasOwnProp("mode") ? job.mode : "",
        runs: job.HasOwnProp("runs") ? Max(1, job.runs) : 1
    }

    if job.HasOwnProp("enabled") {
        cloned.enabled := job.enabled
    }

    return cloned
}


RefreshQueueProfileSummary(repeatOverride := "") {
    global QueueProfileSummaryText

    if !QueueProfileSummaryText {
        return
    }

    record := GetSelectedQueueProfileRecord()
    if !record {
        QueueProfileSummaryText.Text := "NO PROFILE SELECTED"
        return
    }

    summary := GetQueueProfileSummary(record.path, repeatOverride)

    QueueProfileSummaryText.Text :=
        summary.jobsPerPass
        . " JOB" . (summary.jobsPerPass = 1 ? "" : "S")
        . "  x" . summary.repeatCount
        . "  =  " . summary.queueJobs
        . " QUEUE JOB" . (summary.queueJobs = 1 ? "" : "S")
        . "  -  " . summary.totalRuns
        . " TOTAL RUN" . (summary.totalRuns = 1 ? "" : "S")
}



QueueProfileNotesChanged(*) {
    UpdateQueueProfileNotesScrollbar()
    QueueProfileDetailsChanged()
}


ScrollQueueProfileNotesToTop() {
    global QueueProfileDescriptionEdit

    if !QueueProfileDescriptionEdit {
        return
    }

    try DllCall(
        "SendMessage",
        "Ptr",
        QueueProfileDescriptionEdit.Hwnd,
        "UInt",
        0x00B6,
        "Ptr",
        0,
        "Ptr",
        -32767,
        "Ptr"
    )
}


QueueProfileNotesMouseWheel(wParam, lParam, msg, hwnd) {
    global QueueProfileDescriptionEdit

    if !QueueProfileDescriptionEdit || !QueueProfileDescriptionEdit.Enabled {
        return
    }

    if hwnd != QueueProfileDescriptionEdit.Hwnd {
        return
    }

    delta := (wParam >> 16) & 0xFFFF
    if delta > 32767 {
        delta -= 65536
    }

    lines := delta > 0 ? -2 : 2

    try DllCall(
        "SendMessage",
        "Ptr",
        QueueProfileDescriptionEdit.Hwnd,
        "UInt",
        0x00B6,
        "Ptr",
        0,
        "Ptr",
        lines,
        "Ptr"
    )

    SetTimer(UpdateQueueProfileNotesScrollbar, -10)
    return 0
}


UpdateQueueProfileNotesScrollbar(*) {
    global QueueProfileDescriptionEdit
    global QueueProfileNotesScrollTrack
    global QueueProfileNotesScrollThumb

    if !QueueProfileDescriptionEdit || !QueueProfileNotesScrollTrack || !QueueProfileNotesScrollThumb {
        return
    }

    if !QueueProfileDescriptionEdit.Enabled {
        QueueProfileNotesScrollTrack.Visible := false
        QueueProfileNotesScrollThumb.Visible := false
        return
    }

    lineCount := 1
    firstVisible := 0

    try lineCount := DllCall(
        "SendMessage",
        "Ptr",
        QueueProfileDescriptionEdit.Hwnd,
        "UInt",
        0x00BA,
        "Ptr",
        0,
        "Ptr",
        0,
        "Ptr"
    )

    try firstVisible := DllCall(
        "SendMessage",
        "Ptr",
        QueueProfileDescriptionEdit.Hwnd,
        "UInt",
        0x00CE,
        "Ptr",
        0,
        "Ptr",
        0,
        "Ptr"
    )

    visibleLines := 2
    needsScroll := lineCount > visibleLines

    QueueProfileNotesScrollTrack.Visible := needsScroll
    QueueProfileNotesScrollThumb.Visible := needsScroll

    if !needsScroll {
        return
    }

    trackY := 223
    trackHeight := 38
    thumbHeight := Max(14, Floor(trackHeight * visibleLines / lineCount))
    thumbHeight := Min(trackHeight, thumbHeight)
    maxFirst := Max(1, lineCount - visibleLines)
    travel := Max(0, trackHeight - thumbHeight)
    thumbY := trackY + Round(travel * Min(firstVisible, maxFirst) / maxFirst)

    QueueProfileNotesScrollThumb.Move(630, thumbY, 6, thumbHeight)
}


AdjustQueueProfileRepeat(delta, *) {
    global QueueProfileRepeatEdit

    if !QueueProfileRepeatEdit || !QueueProfileRepeatEdit.Enabled {
        return
    }

    rawRepeat := Trim(QueueProfileRepeatEdit.Value)
    current := RegExMatch(rawRepeat, "^\d+$")
        ? Integer(rawRepeat)
        : 1

    nextValue := Max(1, Min(99, current + delta))

    if nextValue = current {
        return
    }

    QueueProfileRepeatEdit.Value := nextValue
    QueueProfileRepeatChanged()
    QueueProfileRepeatEdit.Focus()
}


PreviewQueueProfileRepeatChanged(*) {
    global QueueProfileRepeatEdit

    if !QueueProfileRepeatEdit {
        return
    }

    rawRepeat := Trim(QueueProfileRepeatEdit.Value)
    if rawRepeat = "" || !RegExMatch(rawRepeat, "^\d+$") {
        return
    }

    repeatCount := Integer(rawRepeat)
    if repeatCount < 1 || repeatCount > 99 {
        return
    }

    RefreshQueueProfileSummary(repeatCount)
}


QueueProfileRepeatChanged(*) {
    PreviewQueueProfileRepeatChanged()
    QueueProfileDetailsChanged()
}


QueueProfileDetailsChanged(*) {
    global QueueProfileDetailsLoading

    if QueueProfileDetailsLoading {
        return
    }

    AutoSaveSelectedQueueProfileDetails()
}


AutoSaveSelectedQueueProfileDetails(*) {
    global QueueProfileDescriptionEdit
    global QueueProfileRepeatEdit
    global QueueProfileDetailsLoading
    global UIColorError
    global UIColorSuccess

    if QueueProfileDetailsLoading {
        return
    }

    record := GetSelectedQueueProfileRecord()
    if !record {
        return
    }

    rawRepeat := Trim(QueueProfileRepeatEdit.Value)
    if rawRepeat = "" || !RegExMatch(rawRepeat, "^\d+$") {
        SetQueueProfileStatus("REPEAT COUNT MUST BE 1 - 99", UIColorError)
        return
    }

    repeatCount := Integer(rawRepeat)
    if repeatCount < 1 || repeatCount > 99 {
        SetQueueProfileStatus("REPEAT COUNT MUST BE 1 - 99", UIColorError)
        return
    }

    if !SetQueueProfileDetails(record.path, QueueProfileDescriptionEdit.Value, repeatCount) {
        SetQueueProfileStatus("COULD NOT SAVE PROFILE DETAILS", UIColorError)
        return
    }

    record.description := QueueProfileDescriptionEdit.Value
    record.repeatCount := repeatCount
    RefreshQueueProfileSummary(repeatCount)
    SetQueueProfileStatus("CHANGES SAVED AUTOMATICALLY", UIColorSuccess)
}


SaveCurrentQueueProfile(*) {
    global MacroJobQueue
    global QueueProfileDropdown
    global QueueProfileRecords
    global UIColorError
    global UIColorSuccess

    if MacroJobQueue.Length = 0 {
        SetQueueProfileStatus("QUEUE IS EMPTY", UIColorError)
        return
    }

    profileName := PromptQueueProfileName("Enter a name for this queue profile.")
    if profileName = "" {
        return
    }

    if FindQueueProfileRecord(profileName) {
        SetQueueProfileStatus("PROFILE EXISTS - USE UPDATE", UIColorError)
        return
    }

    savedPath := WriteQueueProfile(profileName, MacroJobQueue)
    if !savedPath {
        SetQueueProfileStatus("COULD NOT SAVE PROFILE", UIColorError)
        return
    }

    savedJobs := ReadQueueProfileJobs(savedPath)
    if savedJobs.Length != MacroJobQueue.Length {
        SetQueueProfileStatus("PROFILE SAVE VERIFY FAILED", UIColorError)
        return
    }

    RefreshQueueProfilesManager(false)
    names := []
    for record in QueueProfileRecords {
        names.Push(record.name)
    }

    index := FindTextIndex(names, profileName)
    if index > 0 {
        QueueProfileDropdown.Choose(index, true)
    }

    SetQueueProfileStatus("PROFILE SAVED", UIColorSuccess)
}


LoadSelectedQueueProfile(*) {
    global MacroJobQueue
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    jobs := ReadQueueProfileJobs(record.path)
    if jobs.Length = 0 {
        SetQueueProfileStatus("PROFILE HAS NO JOBS", UIColorError)
        return
    }

    repeatCount := GetQueueProfileRepeatCount(record.path)
    expanded := []

    Loop repeatCount {
        for job in jobs {
            expanded.Push(CloneQueueProfileJob(job))
        }
    }

    MacroJobQueue := expanded

    SetQueueHistorySource(
        "PROFILE: " . record.name
    )

    RefreshQueueManager()
    UpdateQueueLauncherButton()

    SetQueueProfileStatus(
        "PROFILE LOADED - " . repeatCount . " PASS" . (repeatCount = 1 ? "" : "ES"),
        UIColorSuccess
    )
}


UpdateSelectedQueueProfile(*) {
    global MacroJobQueue
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    if MacroJobQueue.Length = 0 {
        SetQueueProfileStatus("QUEUE IS EMPTY", UIColorError)
        return
    }

    if !WriteQueueProfile(record.name, MacroJobQueue, record.path) {
        SetQueueProfileStatus("COULD NOT UPDATE PROFILE", UIColorError)
        return
    }

    RefreshQueueProfilesManager(true)
    SetQueueProfileStatus("PROFILE UPDATED", UIColorSuccess)
}


DuplicateSelectedQueueProfile(*) {
    global QueueProfileDropdown
    global QueueProfileRecords
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    newName := PromptQueueProfileName("Enter a name for the duplicated profile.", record.name . " Copy")
    if newName = "" {
        return
    }

    if FindQueueProfileRecord(newName) {
        SetQueueProfileStatus("PROFILE NAME ALREADY EXISTS", UIColorError)
        return
    }

    jobs := ReadQueueProfileJobs(record.path)
    newPath := WriteQueueProfile(newName, jobs)
    if !newPath {
        SetQueueProfileStatus("COULD NOT DUPLICATE PROFILE", UIColorError)
        return
    }

    SetQueueProfileDetails(
        newPath,
        GetQueueProfileDescription(record.path),
        GetQueueProfileRepeatCount(record.path)
    )
    SetQueueProfileFavorite(newPath, record.favorite)

    RefreshQueueProfilesManager(false)
    names := []
    for profile in QueueProfileRecords {
        names.Push(profile.name)
    }

    index := FindTextIndex(names, newName)
    if index > 0 {
        QueueProfileDropdown.Choose(index, true)
    }

    SetQueueProfileStatus("PROFILE DUPLICATED", UIColorSuccess)
}


ShowQueueProfileMoreActions(*) {
    global QueueProfilesGui
    global QueueProfileMoreGui
    global UIColorBackground
    global UIColorAccent
    global UIColorSecondaryText

    CloseQueueProfileMoreActions()
    if QueueProfilesGui {
        try QueueProfilesGui.Hide()
    }
    CloseAllDarkDropdowns()
    CloseContextHelp()

    ownerOption := ""
    if QueueProfilesGui {
        try ownerOption := " +Owner" . QueueProfilesGui.Hwnd
    }

    QueueProfileMoreGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox" . ownerOption,
        GetVersionedTitle("Profile Actions")
    )
    QueueProfileMoreGui.BackColor := UIColorBackground


    EnableCustomWindowChrome(QueueProfileMoreGui)
    AddCustomWindowBorder(QueueProfileMoreGui, 320, 380)

    AddUIOutlinedText(QueueProfileMoreGui, "MORE PROFILE ACTIONS", 20, 18, 280, 30, 11, "Center")

    SetUIBodyFont(QueueProfileMoreGui, 8, UIColorSecondaryText)
    QueueProfileMoreGui.Add(
        "Text",
        "x20 y53 w280 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Less common profile tools"
    )

    duplicateButton := CreateDarkButton(QueueProfileMoreGui, 40, 84, 240, 40, "DUPLICATE", 8)
    renameButton := CreateDarkButton(QueueProfileMoreGui, 40, 132, 240, 40, "RENAME", 8)
    exportButton := CreateDarkButton(QueueProfileMoreGui, 40, 180, 240, 40, "EXPORT", 8)
    importButton := CreateDarkButton(QueueProfileMoreGui, 40, 228, 240, 40, "IMPORT", 8)
    deleteButton := CreateDarkButton(QueueProfileMoreGui, 40, 276, 240, 40, "DELETE", 8)
    closeButton := CreateDarkButton(QueueProfileMoreGui, 40, 324, 240, 40, "BACK", 8, "Default")

    duplicateButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(DuplicateSelectedQueueProfile))
    renameButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(RenameSelectedQueueProfile))
    exportButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(ExportSelectedQueueProfile))
    importButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(ImportQueueProfile))
    deleteButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(DeleteSelectedQueueProfile))
    closeButton.OnEvent("Click", CloseQueueProfileMoreActionsAndReturn)

    CreateHelpBadgeForButton(
        QueueProfileMoreGui,
        duplicateButton,
        "DUPLICATE PROFILE",
        "Creates a copy of the selected profile.`n`nThe copy keeps its jobs, run counts, notes, repeat amount, and favorite status."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui,
        renameButton,
        "RENAME PROFILE",
        "Changes only the profile name.`n`nIts jobs, notes, repeat amount, and favorite status stay the same."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui,
        exportButton,
        "EXPORT PROFILE",
        "Saves this profile as an .ini file.`n`nYou can back it up, share it, or import it into another copy of the macro."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui,
        importButton,
        "IMPORT PROFILE",
        "Imports a Queue Profile from an .ini file.`n`nThe imported profile is added to your saved profiles."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui,
        deleteButton,
        "DELETE PROFILE",
        "Permanently deletes the selected Queue Profile.`n`nThe map and EXP scripts used by it are not deleted."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui,
        closeButton,
        "BACK",
        "Returns to Queue Profiles.`n`nNothing is changed."
    )

    QueueProfileMoreGui.OnEvent("Close", CloseQueueProfileMoreActionsAndReturn)
    QueueProfileMoreGui.OnEvent("Escape", CloseQueueProfileMoreActionsAndReturn)

    QueueProfileMoreGui.Show("Hide w320 h380")
    ApplyDarkWindowStyle(QueueProfileMoreGui)
    QueueProfileMoreGui.Show("w320 h380 Center")
}


RunQueueProfileMoreAction(callback, *) {
    CloseQueueProfileMoreActions()
    ShowQueueProfilesAfterMoreActions()
    callback.Call()
}


ShowQueueProfilesAfterMoreActions() {
    global QueueProfilesGui

    if QueueProfilesGui {
        try QueueProfilesGui.Show("w680 h490 Center")
        try WinActivate("ahk_id " . QueueProfilesGui.Hwnd)
    }
}


CloseQueueProfileMoreActionsAndReturn(*) {
    CloseQueueProfileMoreActions()
    ShowQueueProfilesAfterMoreActions()
}


CloseQueueProfileMoreActions(*) {
    global QueueProfileMoreGui

    try {
        if QueueProfileMoreGui
            QueueProfileMoreGui.Destroy()
    }

    QueueProfileMoreGui := ""
}


ExportSelectedQueueProfile(*) {
    global QueueProfilesGui
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    if QueueProfilesGui {
        try QueueProfilesGui.Opt("+OwnDialogs")
    }

    destination := ""
    try destination := FileSelect(
        "S16",
        A_Desktop . "\\" . record.name . ".ini",
        "Export Queue Profile",
        "Queue Profile (*.ini)"
    )

    if destination = "" {
        return
    }

    if !RegExMatch(destination, "i)\\.ini$") {
        destination .= ".ini"
    }

    try FileCopy(record.path, destination, true)
    catch {
        SetQueueProfileStatus("COULD NOT EXPORT PROFILE", UIColorError)
        return
    }

    SetQueueProfileStatus("PROFILE EXPORTED", UIColorSuccess)
}


ImportQueueProfile(*) {
    global QueueProfileDropdown
    global QueueProfileRecords
    global QueueProfilesGui
    global UIColorError
    global UIColorSuccess

    if QueueProfilesGui {
        try QueueProfilesGui.Opt("+OwnDialogs")
    }

    source := ""
    try source := FileSelect(
        1,
        "",
        "Import Queue Profile",
        "Queue Profile (*.ini)"
    )

    if source = "" || !FileExist(source) {
        return
    }

    try sourceJobs := ReadQueueProfileJobs(source)
    catch {
        SetQueueProfileStatus("INVALID PROFILE FILE", UIColorError)
        return
    }

    if sourceJobs.Length = 0 {
        SetQueueProfileStatus("INVALID OR EMPTY PROFILE", UIColorError)
        return
    }

    defaultName := IniRead(
        source,
        "Profile",
        "Name",
        RegExReplace(RegExReplace(source, "^.*\\"), "i)\\.ini$")
    )

    newName := PromptQueueProfileName("Choose the local name for this imported profile.", defaultName)
    if newName = "" {
        return
    }

    if FindQueueProfileRecord(newName) {
        SetQueueProfileStatus("PROFILE NAME ALREADY EXISTS", UIColorError)
        return
    }

    newPath := WriteQueueProfile(newName, sourceJobs)
    if !newPath {
        SetQueueProfileStatus("COULD NOT IMPORT PROFILE", UIColorError)
        return
    }

    SetQueueProfileDetails(
        newPath,
        GetQueueProfileDescription(source),
        GetQueueProfileRepeatCount(source)
    )
    SetQueueProfileFavorite(
        newPath,
        IniRead(source, "Profile", "Favorite", "0") = "1"
    )

    RefreshQueueProfilesManager(false)
    names := []
    for record in QueueProfileRecords {
        names.Push(record.name)
    }

    index := FindTextIndex(names, newName)
    if index > 0 {
        QueueProfileDropdown.Choose(index, true)
    }

    SetQueueProfileStatus("PROFILE IMPORTED", UIColorSuccess)
}


RenameSelectedQueueProfile(*) {
    global QueueProfileDropdown
    global QueueProfileRecords
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    newName := PromptQueueProfileName("Enter the new profile name.", record.name)
    if newName = "" || newName = record.name {
        return
    }

    if FindQueueProfileRecord(newName) {
        SetQueueProfileStatus("PROFILE NAME ALREADY EXISTS", UIColorError)
        return
    }

    newPath := GetQueueProfilesDirectory() . "\\" . newName . ".ini"

    try {
        FileMove(record.path, newPath, false)
        IniWrite(newName, newPath, "Profile", "Name")
    }
    catch {
        SetQueueProfileStatus("COULD NOT RENAME PROFILE", UIColorError)
        return
    }

    RefreshQueueProfilesManager(false)
    names := []
    for profile in QueueProfileRecords {
        names.Push(profile.name)
    }

    index := FindTextIndex(names, newName)
    if index > 0 {
        QueueProfileDropdown.Choose(index, true)
    }

    SetQueueProfileStatus("PROFILE RENAMED", UIColorSuccess)
}


DeleteSelectedQueueProfile(*) {
    global QueueProfilesGui
    global UIColorError

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    ShowThemedConfirmation(
        "DELETE PROFILE?",
        "Delete '" . record.name . "' permanently?`n`nThis cannot be undone.",
        "DELETE PROFILE",
        DeleteQueueProfileConfirmed.Bind(
            record.path
        ),
        QueueProfilesGui,
        "Deletes this saved Queue Profile permanently.`n`nMap and EXP script files are not deleted."
    )
}


DeleteQueueProfileConfirmed(
    profilePath,
    *
) {
    global UIColorError
    global UIColorSuccess

    if !FileExist(profilePath) {
        SetQueueProfileStatus("PROFILE NO LONGER EXISTS", UIColorError)
        RefreshQueueProfilesManager(false)
        return
    }

    try FileDelete(profilePath)
    catch {
        SetQueueProfileStatus("COULD NOT DELETE PROFILE", UIColorError)
        return
    }

    RefreshQueueProfilesManager(false)
    SetQueueProfileStatus("PROFILE DELETED", UIColorSuccess)
}


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
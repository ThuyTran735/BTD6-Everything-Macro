#Requires AutoHotkey v2.0

; v3 file note: Handles the MORE menu plus export/import/rename/delete actions.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

ShowQueueProfileMoreActions(*) {
    global QueueProfilesGui
    global QueueProfileMoreGui
    global UIColorBackground
    global UIColorSecondaryText
    global UIColorMutedText

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
    AddCustomWindowBorder(QueueProfileMoreGui, 420, 400)

    AddUIOutlinedText(QueueProfileMoreGui, "MORE PROFILE ACTIONS", 20, 18, 380, 30, 11, "Center")

    SetUIBodyFont(QueueProfileMoreGui, 8, UIColorSecondaryText)
    QueueProfileMoreGui.Add(
        "Text",
        "x20 y53 w380 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Manage, move, or remove the selected profile"
    )

    AddUICard(QueueProfileMoreGui, 16, 82, 388, 226)
    AddUICard(QueueProfileMoreGui, 16, 316, 388, 68)

    AddUIOutlinedText(QueueProfileMoreGui, "PROFILE TOOLS", 30, 92, 360, 20, 9, "Center")

    duplicateButton := CreateDarkButton(QueueProfileMoreGui, 30, 120, 174, 42, "DUPLICATE", 8)
    renameButton := CreateDarkButton(QueueProfileMoreGui, 216, 120, 174, 42, "RENAME", 8)
    exportButton := CreateDarkButton(QueueProfileMoreGui, 30, 172, 174, 42, "EXPORT", 8)
    importButton := CreateDarkButton(QueueProfileMoreGui, 216, 172, 174, 42, "IMPORT", 8)
    deleteButton := CreateDarkButton(QueueProfileMoreGui, 30, 224, 360, 42, "DELETE", 8, "Danger")

    SetUIBodyFont(QueueProfileMoreGui, 8, UIColorMutedText)
    QueueProfileMoreGui.Add(
        "Text",
        "x30 y274 w360 h20 Center c" . UIColorMutedText . " BackgroundTrans",
        "Actions apply to the currently selected Queue Profile"
    )

    closeButton := CreateDarkButton(QueueProfileMoreGui, 30, 329, 360, 42, "BACK TO PROFILES", 8, "Flat")

    duplicateButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(DuplicateSelectedQueueProfile))
    renameButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(RenameSelectedQueueProfile))
    exportButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(ExportSelectedQueueProfile))
    importButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(ImportQueueProfile))
    deleteButton.OnEvent("Click", RunQueueProfileMoreAction.Bind(DeleteSelectedQueueProfile))
    closeButton.OnEvent("Click", CloseQueueProfileMoreActionsAndReturn)

    CreateHelpBadgeForButton(
        QueueProfileMoreGui, duplicateButton, "DUPLICATE PROFILE",
        "Creates a copy of the selected profile.`n`nThe copy keeps its jobs, run counts, notes, repeat amount, and favorite status."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui, renameButton, "RENAME PROFILE",
        "Changes only the profile name.`n`nIts jobs, notes, repeat amount, and favorite status stay the same."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui, exportButton, "EXPORT PROFILE",
        "Saves this profile as an .ini file.`n`nYou can back it up, share it, or import it into another copy of the macro."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui, importButton, "IMPORT PROFILE",
        "Imports a Queue Profile from an .ini file.`n`nThe imported profile is added to your saved profiles."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui, deleteButton, "DELETE PROFILE",
        "Permanently deletes the selected Queue Profile.`n`nThe map and EXP scripts used by it are not deleted."
    )
    CreateHelpBadgeForButton(
        QueueProfileMoreGui, closeButton, "BACK TO PROFILES",
        "Returns to Queue Profiles.`n`nNothing is changed."
    )

    QueueProfileMoreGui.OnEvent("Close", CloseQueueProfileMoreActionsAndReturn)
    QueueProfileMoreGui.OnEvent("Escape", CloseQueueProfileMoreActionsAndReturn)

    QueueProfileMoreGui.Show("Hide w420 h400")
    ApplyDarkWindowStyle(QueueProfileMoreGui)
    QueueProfileMoreGui.Show("w420 h400 Center")
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



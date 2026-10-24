#Requires AutoHotkey v2.0

; Drafts contain editor data, never executable AutoHotkey. Keep them beside the
; launcher's other local settings so a UserData backup also includes unfinished work.
InitializeBuilderPersistence() {
    global BuilderPersistenceReady, BuilderSavedState, BuilderLastRecoveryText
    global BuilderExitApproved, BuilderRecoveryWarning
    BuilderPersistenceReady := false
    BuilderSavedState := CaptureBuilderState()
    BuilderLastRecoveryText := ""
    BuilderExitApproved := false
    BuilderRecoveryWarning := ""
    OnExit(BuilderPersistenceExit, -1)
    ConfigureBuilderTrayMenu()
    try {
        EnsureBuilderDataFolders()
        RecoverBuilderDraft()
    } catch as err {
        MsgBox("The local draft folder could not be opened.`n`n" err.Message,
            "Strategy Builder - Local drafts", "Icon!")
    }
    BuilderPersistenceReady := true
    BuilderDraftChanged()
}

ConfigureBuilderTrayMenu() {
    ; Native Reload starts its replacement before asking the old process to
    ; exit. Ask about unsaved work first, while normal GUI events still run.
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Open Strategy Builder", OpenBuilderFromTray)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Reload Builder", CompleteBuilderExitRequest.Bind("Reload"))
    A_TrayMenu.Add("Exit", RequestBuilderClose)
    A_TrayMenu.Default := "Open Strategy Builder"
}

OpenBuilderFromTray(*) {
    global MainGui
    if !IsObject(MainGui) || !DllCall("IsWindowEnabled", "Ptr", MainGui.Hwnd)
        return false
    return RestoreBuilderAfterCapture()
}

GetBuilderDataFolder(section := "") {
    projectRoot := RegExReplace(A_ScriptDir, "i)\\Tools$")
    folder := projectRoot "\UserData\StrategyBuilder"
    return section = "" ? folder : folder "\" section
}

EnsureBuilderDataFolders() {
    for section in ["Drafts", "Exports", "Recovery"]
        DirCreate(GetBuilderDataFolder(section))
}

GetBuilderRecoveryPath() {
    return GetBuilderDataFolder("Recovery") "\unfinished.btd6draft"
}

BuilderHasUnsavedWork(state := false) {
    global BuilderSavedState
    if !state
        state := CaptureBuilderState()
    return !BuilderStatesEqual(BuilderStateContent(state), BuilderStateContent(BuilderSavedState))
}

MarkBuilderSaved(state := false) {
    global BuilderSavedState, BuilderLastRecoveryText
    BuilderSavedState := CloneBuilderState(state ? state : CaptureBuilderState())
    BuilderLastRecoveryText := ""
    RemoveBuilderRecovery()
}

ConfirmBuilderReplace(reason := "replacing this strategy") {
    BuilderFlushHistory()
    if !BuilderHasUnsavedWork()
        return true
    choice := AskBuilderSaveChanges(reason)
    if choice = "Save"
        return SaveBuilderDraft()
    return choice = "Discard"
}

RequestBuilderClose(*) {
    return CompleteBuilderExitRequest("Exit")
}

CompleteBuilderExitRequest(reason, *) {
    global BuilderExitApproved, MainGui
    static asking := false
    if asking || !DllCall("IsWindowEnabled", "Ptr", MainGui.Hwnd)
        return false
    asking := true
    try {
        if !ConfirmBuilderReplace("closing Strategy Builder")
            return false
        BuilderExitApproved := true
        if reason = "Reload"
            Reload()
        else
            ExitApp()
    } finally {
        asking := false
    }
}

BuilderPersistenceExit(exitReason, exitCode) {
    global BuilderExitApproved, BuilderPersistenceReady
    if !IsSet(BuilderPersistenceReady)
        return 0
    SetTimer(WriteBuilderRecovery, 0)
    ; A tray Exit, Reload, or second instance must not bypass the close warning.
    if !BuilderExitApproved && BuilderPersistenceReady
        && (exitReason = "Exit" || exitReason = "Menu" || exitReason = "Close"
            || exitReason = "Reload" || exitReason = "Single") {
        ; OnExit cannot run an event-driven dialog safely. Veto this attempt,
        ; then let an ordinary timer thread ask once normal GUI events resume.
        BuilderDraftChanged()
        SetTimer(CompleteBuilderExitRequest.Bind(exitReason), -1)
        return 1
    }
    if BuilderExitApproved
        RemoveBuilderRecovery()
    else if BuilderPersistenceReady
        WriteBuilderRecovery(true)
    return 0
}

SaveBuilderDraft(*) {
    global FunctionNameEdit, StatusText, MainGui
    BuilderFlushHistory()
    state := CaptureBuilderState()
    try EnsureBuilderDataFolders()
    catch as err {
        MsgBox("Could not create the local draft folder.`n`n" err.Message, "Strategy Builder", "Iconx")
        return false
    }
    defaultName := SanitizeFileName(FunctionNameEdit.Value)
    if defaultName = ""
        defaultName := "UnfinishedStrategy"
    MainGui.Opt("-AlwaysOnTop")
    path := FileSelect("S", GetBuilderDataFolder("Drafts") "\" defaultName ".btd6draft",
        "Save editable draft in UserData", "Strategy Builder Draft (*.btd6draft)")
    if path = ""
        return false
    if !RegExMatch(path, "i)\.btd6draft$")
        path .= ".btd6draft"
    if !IsBuilderLocalSavePath(path, "Drafts") {
        MsgBox("Save drafts inside this local folder so they stay out of GitHub:`n`n"
            GetBuilderDataFolder("Drafts"), "Strategy Builder - Local drafts", "Icon!")
        return false
    }
    if !ConfirmBuilderFileOverwrite(path)
        return false
    try {
        WriteBuilderDraftFile(path, state)
        MarkBuilderSaved(state)
        StatusText.Text := "Draft saved locally, including unfinished fields: " path
        return true
    } catch as err {
        MsgBox("Could not save the draft. Your work is still open.`n`n" err.Message,
            "Strategy Builder", "Iconx")
        return false
    }
}

ConfirmBuilderFileOverwrite(path) {
    if !FileExist(path)
        return true
    SplitPath(path, &name)
    return AskBuilderChoice("Replace local file", "A local file named " name " already exists.`n`nReplace it with the current strategy?",
        ["Replace", "Cancel"], "Cancel") = "Replace"
}

IsBuilderLocalSavePath(path, section) {
    ; Normalize '..' segments before checking the selected directory.
    target := Buffer(32768 * 2, 0)
    count := DllCall("GetFullPathNameW", "Str", path, "UInt", 32768, "Ptr", target, "Ptr", 0, "UInt")
    if count = 0 || count >= 32768
        return false
    fullPath := StrGet(target)
    root := GetBuilderDataFolder(section) "\"
    ; A single save folder keeps relative #Include paths in exported scripts correct.
    SplitPath(fullPath, , &parent)
    return StrLower(parent "\") = StrLower(root)
}

BuilderDraftChanged(*) {
    global BuilderPersistenceReady
    if !IsSet(BuilderPersistenceReady) || !BuilderPersistenceReady
        return
    ; History already batches typing. A short final delay avoids saving midway
    ; through a multi-control edit such as loading a row or changing game mode.
    SetTimer(WriteBuilderRecovery, -350)
}

WriteBuilderRecovery(force := false) {
    global BuilderPersistenceReady, BuilderLastRecoveryText, BuilderRecoveryWarning, StatusText
    global BuilderHistoryDepth, MainGui
    if !IsSet(BuilderPersistenceReady) || !BuilderPersistenceReady
        return false
    if (IsSet(BuilderHistoryDepth) && BuilderHistoryDepth)
        || (!force && (!DllCall("IsWindowEnabled", "Ptr", MainGui.Hwnd) || !DllCall("IsWindowVisible", "Ptr", MainGui.Hwnd))) {
        SetTimer(WriteBuilderRecovery, -350)
        return false
    }
    try {
        state := CaptureBuilderState()
        if !BuilderHasUnsavedWork(state) {
            RemoveBuilderRecovery()
            BuilderLastRecoveryText := ""
            return true
        }
        text := EncodeBuilderDraft(state)
        if text == BuilderLastRecoveryText
            return true
        EnsureBuilderDataFolders()
        WriteBuilderFileAtomic(GetBuilderRecoveryPath(), text)
        BuilderLastRecoveryText := text
        BuilderRecoveryWarning := ""
        return true
    } catch as err {
        if !(BuilderRecoveryWarning == err.Message) {
            BuilderRecoveryWarning := err.Message
            StatusText.Text := "Draft recovery could not be saved. Use Save draft: " err.Message
        }
        return false
    }
}

RemoveBuilderRecovery() {
    global BuilderLastRecoveryText
    BuilderLastRecoveryText := ""
    try {
        path := GetBuilderRecoveryPath()
        if FileExist(path)
            FileDelete(path)
    }
}

RecoverBuilderDraft() {
    global StatusText, BuilderLastRecoveryText
    path := GetBuilderRecoveryPath()
    if !FileExist(path)
        return
    try state := ReadBuilderDraftFile(path)
    catch as err {
        ; Leave an unreadable file available for inspection instead of destroying it.
        archived := ArchiveBuilderRecovery("unreadable")
        MsgBox("The unfinished draft could not be restored. It was kept here:`n" archived
            "`n`n" err.Message, "Strategy Builder - Draft recovery", "Icon!")
        return
    }
    choice := AskBuilderChoice("Recover unfinished strategy",
        "Strategy Builder found unfinished work from the previous session.`n`n"
        "Restore brings back placements, actions, and unfinished fields. Later keeps a copy you can open through Import.",
        ["Restore", "Discard", "Later"], "Later")
    if choice = "Restore" {
        RestoreBuilderState(state)
        ResetBuilderHistory()
        BuilderLastRecoveryText := ""
        StatusText.Text := "Recovered unfinished work. Save draft to keep an editable copy."
    } else if choice = "Discard" {
        RemoveBuilderRecovery()
    } else {
        archived := ArchiveBuilderRecovery("unfinished")
        StatusText.Text := "Previous draft kept for Import: " archived
    }
}

ArchiveBuilderRecovery(label) {
    global BuilderLastRecoveryText
    source := GetBuilderRecoveryPath()
    destination := GetBuilderDataFolder("Recovery") "\" label "-" FormatTime(, "yyyyMMdd-HHmmss") "-" A_TickCount ".btd6draft"
    FileMove(source, destination, false)
    BuilderLastRecoveryText := ""
    return destination
}

WriteBuilderDraftFile(path, state) {
    WriteBuilderFileAtomic(path, EncodeBuilderDraft(state))
}

ReadBuilderDraftFile(path) {
    if FileGetSize(path) > 8 * 1024 * 1024
        throw Error("This draft is too large to open safely.")
    text := FileRead(path, "UTF-8")
    header := "BTD6-STRATEGY-DRAFT/1`r`n"
    if SubStr(text, 1, StrLen(header)) != header
        throw Error("This is not a supported Strategy Builder draft.")
    reader := BuilderDraftReader(SubStr(text, StrLen(header) + 1))
    state := reader.Read()
    if reader.Position <= StrLen(reader.Text) || !ValidateBuilderState(state)
        throw Error("The draft contains invalid or unsupported editor data.")
    return state
}

EncodeBuilderDraft(state) {
    if !ValidateBuilderState(state)
        throw Error("The editor state could not be saved as a valid draft.")
    payload := EncodeBuilderDraftValue(state)
    text := "BTD6-STRATEGY-DRAFT/1`r`n" payload
    if StrPut(text, "UTF-8") - 1 > 8 * 1024 * 1024
        throw Error("This draft is too large to save.")
    ; Apply the reader's depth, row, and item budgets before replacing a file.
    ; A successful save must always be something this version can reopen.
    reader := BuilderDraftReader(payload)
    reader.Read()
    if reader.Position <= StrLen(payload)
        throw Error("The draft could not be verified before saving.")
    return text
}

EncodeBuilderDraftValue(value, depth := 0) {
    if depth > 16
        throw Error("The draft contains too many nested values.")
    if value is Map {
        text := "M" value.Count ":"
        for key, item in value
            text .= EncodeBuilderDraftValue(key "", depth + 1) EncodeBuilderDraftValue(item, depth + 1)
        return text
    }
    if value is Array {
        text := "A" value.Length ":"
        for item in value
            text .= EncodeBuilderDraftValue(item, depth + 1)
        return text
    }
    if Type(value) = "Integer" || Type(value) = "Float"
        return "N" value ";"
    if Type(value) != "String"
        throw Error("Drafts cannot contain executable objects.")
    return "S" StrLen(value) ":" value
}

; Each string has a length prefix, so quotes, newlines, Unicode, and code-like
; text stay ordinary data. No Include, expression evaluation, or script execution.
class BuilderDraftReader {
    __New(text) {
        this.Text := text
        this.Position := 1
        this.Items := 0
    }

    Read(depth := 0) {
        this.Items += 1
        if depth > 16 || this.Items > 100000 || this.Position > StrLen(this.Text)
            throw Error("The draft is incomplete or exceeds its data limits.")
        kind := SubStr(this.Text, this.Position++, 1)
        if kind = "N" {
            end := InStr(this.Text, ";",, this.Position)
            if !end || end - this.Position > 32
                throw Error("Invalid number in draft.")
            number := SubStr(this.Text, this.Position, end - this.Position)
            if !RegExMatch(number, "^-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?$")
                throw Error("Invalid number in draft.")
            value := number + 0
            if !RegExMatch(value "", "^-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?$")
                throw Error("The draft contains an unsupported number.")
            this.Position := end + 1
            return value
        }
        end := InStr(this.Text, ":",, this.Position)
        if !end || end - this.Position > 8
            throw Error("Invalid length in draft.")
        count := SubStr(this.Text, this.Position, end - this.Position)
        if !RegExMatch(count, "^\d+$")
            throw Error("Invalid length in draft.")
        count += 0
        this.Position := end + 1
        if kind = "S" {
            if count > StrLen(this.Text) - this.Position + 1
                throw Error("The draft ends before its text is complete.")
            value := SubStr(this.Text, this.Position, count)
            this.Position += count
            return value
        }
        if count > 10000
            throw Error("The draft has too many rows.")
        if kind = "A" {
            value := []
            Loop count
                value.Push(this.Read(depth + 1))
            return value
        }
        if kind = "M" {
            value := Map()
            Loop count {
                key := this.Read(depth + 1)
                if Type(key) != "String" || value.Has(key)
                    throw Error("The draft contains an invalid or duplicate field.")
                value[key] := this.Read(depth + 1)
            }
            return value
        }
        throw Error("Unknown data type in draft.")
    }
}

WriteBuilderFileAtomic(path, text) {
    temporary := path "." A_TickCount "-" Random(100000, 999999) ".tmp"
    try {
        file := FileOpen(temporary, "w", "UTF-8-RAW")
        if !file
            throw Error("The temporary save file could not be opened.")
        try {
            file.Write(text)
            if !DllCall("FlushFileBuffers", "Ptr", file.Handle)
                throw OSError()
        }
        finally file.Close()
        if !(FileRead(temporary, "UTF-8") == text)
            throw Error("The saved data could not be verified. The previous file was kept.")
        ; The previous file survives a failed write. Rename only after closing the
        ; complete temporary file, on the same drive as the destination.
        FileMove(temporary, path, true)
    } finally {
        if FileExist(temporary)
            try FileDelete(temporary)
    }
}

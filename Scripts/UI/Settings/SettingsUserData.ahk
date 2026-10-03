#Requires AutoHotkey v2.0

; Backs up and restores the whole UserData folder so updating the macro does not mean setting everything up again.

global UserDataTransferGui := ""
global UserDataTransferStatusText := ""
global PendingUserDataImportFolder := ""


GetMacroUserDataFolder() {
    return A_ScriptDir . "\\UserData"
}


NormalizeUserDataPath(path) {
    path := StrReplace(path, "/", "\\")
    return StrLower(RTrim(path, "\\"))
}


IsFolderInsideCurrentUserData(path) {
    userDataPath := NormalizeUserDataPath(GetMacroUserDataFolder())
    candidatePath := NormalizeUserDataPath(path)

    return (
        candidatePath = userDataPath
        || InStr(candidatePath . "\\", userDataPath . "\\") = 1
    )
}


GetUniqueUserDataBackupFolder(parentFolder) {
    stamp := FormatTime(, "yyyyMMdd-HHmmss")
    basePath := RTrim(parentFolder, "\\")
        . "\\BTD6-Everything-Macro-UserData-Backup-"
        . stamp

    candidate := basePath
    suffix := 2

    while DirExist(candidate) || FileExist(candidate) {
        candidate := basePath . "-" . suffix
        suffix += 1
    }

    return candidate
}


CopyUserDataTree(sourceFolder, destinationFolder) {
    copiedFiles := 0

    if !DirExist(destinationFolder)
        DirCreate(destinationFolder)

    Loop Files, sourceFolder . "\\*", "FD" {
        destinationPath := destinationFolder . "\\" . A_LoopFileName

        if InStr(A_LoopFileAttrib, "D") {
            copiedFiles += CopyUserDataTree(A_LoopFileFullPath, destinationPath)
            continue
        }

        FileCopy(A_LoopFileFullPath, destinationPath, true)
        copiedFiles += 1
    }

    return copiedFiles
}


PickUserDataFolder(prompt) {
    global UserDataTransferGui

    ; The Windows folder picker likes hiding behind always-on-top GUIs.
    if IsObject(UserDataTransferGui) {
        try UserDataTransferGui.Opt("-AlwaysOnTop")
    }

    selectedFolder := ""

    try selectedFolder := DirSelect(A_ScriptDir, 0, prompt)
    finally {
        if IsObject(UserDataTransferGui) {
            try UserDataTransferGui.Opt("+AlwaysOnTop")
            try WinActivate("ahk_id " . UserDataTransferGui.Hwnd)
        }
    }

    return selectedFolder
}


ExportUserDataFromSettings(*) {
    sourceFolder := GetMacroUserDataFolder()

    if !DirExist(sourceFolder) {
        SetUserDataTransferStatus("There is no UserData folder to export yet.")
        return
    }

    destinationParent := PickUserDataFolder(
        "Choose where to save the BTD6 Everything Macro UserData backup."
    )

    if destinationParent = ""
        return

    if IsFolderInsideCurrentUserData(destinationParent) {
        SetUserDataTransferStatus("Choose a backup location outside the current UserData folder.")
        return
    }

    backupRoot := GetUniqueUserDataBackupFolder(destinationParent)
    backupUserData := backupRoot . "\\UserData"

    try {
        DirCreate(backupRoot)
        copiedFiles := CopyUserDataTree(sourceFolder, backupUserData)

        backupInfo := (
            "BTD6 Everything Macro UserData Backup`r`n"
            . "Created: " . FormatTime(, "yyyy-MM-dd HH:mm:ss") . "`r`n"
            . "Macro version: " . GetAppVersionLabel() . "`r`n"
            . "Files copied: " . copiedFiles . "`r`n"
        )

        FileAppend(backupInfo, backupRoot . "\\BackupInfo.txt", "UTF-8")

        SplitPath(backupRoot, &backupName)
        SetUserDataTransferStatus(
            "Exported " . copiedFiles . (copiedFiles = 1 ? " file" : " files")
            . " to " . backupName . "."
        )
    }
    catch as err {
        try {
            if DirExist(backupRoot)
                DirDelete(backupRoot, true)
        }

        SetUserDataTransferStatus("Export failed: " . err.Message)
    }
}


ResolveUserDataImportFolder(selectedFolder) {
    selectedFolder := RTrim(selectedFolder, "\\/")

    if selectedFolder = ""
        return ""

    SplitPath(selectedFolder, &folderName)

    if StrLower(folderName) = "userdata"
        return selectedFolder

    nestedUserData := selectedFolder . "\\UserData"

    if DirExist(nestedUserData)
        return nestedUserData

    return ""
}


RequestImportUserDataFromSettings(*) {
    global PendingUserDataImportFolder
    global UserDataTransferGui

    selectedFolder := PickUserDataFolder(
        "Select an exported UserData backup folder, or select its UserData folder directly."
    )

    if selectedFolder = ""
        return

    sourceFolder := ResolveUserDataImportFolder(selectedFolder)

    if sourceFolder = "" {
        SetUserDataTransferStatus(
            "That folder is not a UserData backup. Select the backup folder or its UserData folder."
        )
        return
    }

    if IsFolderInsideCurrentUserData(sourceFolder) {
        SetUserDataTransferStatus("Choose a backup outside this version's current UserData folder.")
        return
    }

    PendingUserDataImportFolder := sourceFolder

    ShowThemedConfirmation(
        "IMPORT USER DATA?",
        "Import this backup into the current version?`n`nMatching files will be overwritten. Files that only exist in this version will be kept.",
        "IMPORT DATA",
        ImportPendingUserDataBackup,
        UserDataTransferGui,
        "Restores settings, favorites, launcher state, queue profiles, run history, logs, and anything else stored in UserData. Restart the macro after importing so every screen reloads the restored values."
    )
}


ImportPendingUserDataBackup(*) {
    global PendingUserDataImportFolder

    sourceFolder := PendingUserDataImportFolder
    PendingUserDataImportFolder := ""

    if sourceFolder = "" || !DirExist(sourceFolder) {
        SetUserDataTransferStatus("The selected backup folder is no longer available.")
        return
    }

    destinationFolder := GetMacroUserDataFolder()

    try {
        copiedFiles := CopyUserDataTree(sourceFolder, destinationFolder)
        SetUserDataTransferStatus(
            "Imported " . copiedFiles . (copiedFiles = 1 ? " file" : " files")
            . ". Restart the macro to load all restored data."
        )
    }
    catch as err {
        SetUserDataTransferStatus("Import failed: " . err.Message)
    }
}


SetUserDataTransferStatus(message) {
    global UserDataTransferStatusText

    try {
        if UserDataTransferStatusText
            UserDataTransferStatusText.Text := message
    }
}


ShowUserDataTransferUI(*) {
    global UserDataTransferGui
    global UserDataTransferStatusText
    global PendingUserDataImportFolder
    global MacroRunning

    global UIColorBackground
    global UIColorSecondaryText
    global UIColorMutedText
    global UIColorHeadingText

    if MacroRunning
        return

    CloseSettingsUI()
    CloseContextHelp()
    CloseAllDarkDropdowns()
    CloseUserDataTransferUI()

    PendingUserDataImportFolder := ""

    UserDataTransferGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        GetVersionedTitle("User Data")
    )
    UserDataTransferGui.Opt("+OwnDialogs")
    UserDataTransferGui.BackColor := UIColorBackground

    EnableCustomWindowChrome(UserDataTransferGui)
    AddCustomWindowBorder(UserDataTransferGui, 500, 478)
    AddUICard(UserDataTransferGui, 30, 88, 440, 112)
    AddUICard(UserDataTransferGui, 30, 200, 440, 118)
    AddUICard(UserDataTransferGui, 30, 318, 440, 76)
    AddUICard(UserDataTransferGui, 30, 394, 440, 62)

    AddUIOutlinedText(UserDataTransferGui, "USER DATA", 20, 18, 460, 34, 13, "Center")

    CreateHelpBadgeForHeader(
        UserDataTransferGui,
        500,
        "USER DATA",
        "Back up UserData before updating the macro, then import it into the new copy."
    )

    SetUIBodyFont(UserDataTransferGui, 9, UIColorSecondaryText)
    UserDataTransferGui.Add(
        "Text",
        "x30 y58 w440 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Move your setup between macro versions"
    )

    SetUIHeadingFont(UserDataTransferGui, 8, UIColorHeadingText)
    UserDataTransferGui.Add(
        "Text",
        "x42 y98 w416 h18 c" . UIColorHeadingText . " BackgroundTrans",
        "WHAT GETS SAVED"
    )

    SetUIBodyFont(UserDataTransferGui, 8, UIColorSecondaryText)
    UserDataTransferGui.Add(
        "Text",
        "x42 y122 w416 h62 c" . UIColorSecondaryText . " BackgroundTrans",
        "The whole UserData folder: settings, favorites, launcher state, queue profiles, run history, logs, and any future UserData files."
    )

    SetUIHeadingFont(UserDataTransferGui, 8, UIColorHeadingText)
    UserDataTransferGui.Add(
        "Text",
        "x42 y210 w416 h18 c" . UIColorHeadingText . " BackgroundTrans",
        "BACKUP / RESTORE"
    )

    exportButton := CreateDarkButton(UserDataTransferGui, 42, 238, 202, 54, "EXPORT USER DATA", 8)
    importButton := CreateDarkButton(UserDataTransferGui, 256, 238, 202, 54, "IMPORT USER DATA", 8, "Default")

    SetUIBodyFont(UserDataTransferGui, 8, UIColorSecondaryText)
    UserDataTransferStatusText := UserDataTransferGui.Add(
        "Text",
        "x42 y328 w416 h54 Center c" . UIColorSecondaryText,
        "Export creates a dated backup folder. Import merges it into this version and overwrites matching files."
    )

    SetUIBodyFont(UserDataTransferGui, 7, UIColorMutedText)
    UserDataTransferGui.Add(
        "Text",
        "x42 y298 w416 h16 Center c" . UIColorMutedText . " BackgroundTrans",
        "Restart the macro after importing so every restored setting reloads."
    )

    backButton := CreateDarkButton(UserDataTransferGui, 90, 404, 320, 42, "BACK TO SETTINGS", 8, "Default")

    exportButton.OnEvent("Click", ExportUserDataFromSettings)
    importButton.OnEvent("Click", RequestImportUserDataFromSettings)
    backButton.OnEvent("Click", CloseUserDataTransferAndReturnToSettings)

    CreateHelpBadgeForButton(
        UserDataTransferGui,
        exportButton,
        "EXPORT USER DATA",
        "Choose a folder and the macro creates a dated backup containing a full copy of UserData."
    )
    CreateHelpBadgeForButton(
        UserDataTransferGui,
        importButton,
        "IMPORT USER DATA",
        "Select an exported backup folder. Matching files are restored over this version while new files that are not in the backup are left alone."
    )
    CreateHelpBadgeForButton(
        UserDataTransferGui,
        backButton,
        "BACK TO SETTINGS",
        "Returns to the main Settings menu."
    )

    UserDataTransferGui.OnEvent("Close", CloseUserDataTransferAndReturnToSettings)
    UserDataTransferGui.OnEvent("Escape", CloseUserDataTransferAndReturnToSettings)

    UserDataTransferGui.Show("Hide w500 h478")
    ApplyDarkWindowStyle(UserDataTransferGui)
    UserDataTransferGui.Show("w500 h478 Center")
}


OpenUserDataTransferFromSettings(*) {
    ShowUserDataTransferUI()
}


CloseUserDataTransferAndReturnToSettings(*) {
    CloseUserDataTransferUI()
    ShowSettingsUI()
}


CloseUserDataTransferUI(*) {
    global UserDataTransferGui
    global UserDataTransferStatusText
    global PendingUserDataImportFolder

    try {
        if UserDataTransferGui
            UserDataTransferGui.Destroy()
    }

    UserDataTransferGui := ""
    UserDataTransferStatusText := ""
    PendingUserDataImportFolder := ""
}

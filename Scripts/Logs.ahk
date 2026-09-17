#Requires AutoHotkey v2.0


global CurrentRunLogFile := ""
global CurrentRunLogStarted := false
global LastRunFailureReason := ""


GetMacroProjectRoot() {
    ; A_LineFile points at this included Logs.ahk file even when the
    ; active strategy script lives several folders below the project.
    SplitPath(A_LineFile, , &scriptsDir)
    SplitPath(scriptsDir, , &projectRoot)
    return projectRoot
}


GetLoggingSettingsFilePath() {
    return GetMacroProjectRoot() . "\UserData\Settings.ini"
}


GetLogsDirectory() {
    return GetMacroProjectRoot() . "\UserData\Logs"
}


EnsureLoggingStorage() {
    userDataDir := GetMacroProjectRoot() . "\UserData"
    logsDir := GetLogsDirectory()

    try {
        if !DirExist(userDataDir)
            DirCreate(userDataDir)

        if !DirExist(logsDir)
            DirCreate(logsDir)
    }
}


IsLoggingEnabled() {
    path := GetLoggingSettingsFilePath()

    if !FileExist(path) {
        SetLoggingEnabled(true)
        return true
    }

    try {
        value := IniRead(path, "Logging", "Enabled", "1")
        return value != "0"
    }
    catch {
        return true
    }
}


SetLoggingEnabled(enabled) {
    EnsureLoggingStorage()

    try {
        IniWrite(
            enabled ? "1" : "0",
            GetLoggingSettingsFilePath(),
            "Logging",
            "Enabled"
        )
        return true
    }
    catch {
        return false
    }
}


GetLogTimestamp() {
    return FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
}


GetLogFileTimestamp() {
    return FormatTime(A_Now, "yyyy-MM-dd_HH-mm-ss")
}


SanitizeLogText(text) {
    text := text . ""
    text := StrReplace(text, "`r", " ")
    text := StrReplace(text, "`n", " | ")
    return Trim(text)
}


InitializeRunLog(context := "") {
    global CurrentRunLogFile
    global CurrentRunLogStarted
    global LastRunFailureReason

    CurrentRunLogFile := ""
    CurrentRunLogStarted := false
    LastRunFailureReason := ""

    if !IsLoggingEnabled()
        return ""

    EnsureLoggingStorage()

    fileName := "Run_" . GetLogFileTimestamp() . "_PID" . ProcessExist() . "_" . Random(1000, 9999) . ".log"
    CurrentRunLogFile := GetLogsDirectory() . "\" . fileName

    try {
        FileAppend(
            "BTD6 Everything Macro Run Log`r`n"
            . "Started: " . GetLogTimestamp() . "`r`n"
            . "Process: " . ProcessExist() . "`r`n"
            . "Script: " . A_ScriptFullPath . "`r`n"
            . (context != "" ? "Context: " . SanitizeLogText(context) . "`r`n" : "")
            . "------------------------------------------------------------`r`n",
            CurrentRunLogFile,
            "UTF-8"
        )
        CurrentRunLogStarted := true
        LogMessage("INFO", "Run log initialized")
    }
    catch {
        CurrentRunLogFile := ""
        CurrentRunLogStarted := false
    }

    return CurrentRunLogFile
}


LogMessage(level, message) {
    global CurrentRunLogFile
    global CurrentRunLogStarted

    if !IsLoggingEnabled()
        return false

    if !CurrentRunLogStarted || CurrentRunLogFile = ""
        return false

    line := "[" . GetLogTimestamp() . "] [" . StrUpper(level) . "] " . SanitizeLogText(message) . "`r`n"

    try {
        FileAppend(line, CurrentRunLogFile, "UTF-8")
        return true
    }
    catch {
        return false
    }
}


SetRunFailureReason(reason, detail := "") {
    global LastRunFailureReason

    reason := SanitizeLogText(reason)
    detail := SanitizeLogText(detail)

    if reason = ""
        reason := "RUN FAILED"

    failureText := reason
    if detail != ""
        failureText .= ": " . detail

    ; Keep the first useful cause. Later cleanup failures should not
    ; overwrite the original reason the run actually failed.
    if LastRunFailureReason = ""
        LastRunFailureReason := failureText

    LogMessage("ERROR", failureText)

    return false
}


EnsureRunFailureReason(reason) {
    global LastRunFailureReason

    if LastRunFailureReason = ""
        SetRunFailureReason(reason)

    return false
}


GetRunFailureReason(defaultReason := "RUN FAILED") {
    global LastRunFailureReason

    return LastRunFailureReason != ""
        ? LastRunFailureReason
        : defaultReason
}


LogRunConfig() {
    global RunConfig

    try {
        LogMessage(
            "INFO",
            "Run config: category=" . RunConfig.category
            . ", map=" . RunConfig.map
            . ", difficulty=" . RunConfig.difficulty
            . ", mode=" . RunConfig.gameMode
            . ", hero=" . RunConfig.hero
        )
    }
}


LogException(err) {
    detail := err.Message

    try {
        if err.What != ""
            detail .= " | What: " . err.What
    }

    try {
        if err.File != ""
            detail .= " | File: " . err.File . ":" . err.Line
    }

    SetRunFailureReason("UNHANDLED ERROR", detail)
}


FinishRunLog(status, reason := "") {
    status := SanitizeLogText(status)
    reason := SanitizeLogText(reason)

    if reason != ""
        LogMessage(status = "Success" ? "INFO" : "ERROR", "Final result: " . status . " - " . reason)
    else
        LogMessage(status = "Success" ? "INFO" : "ERROR", "Final result: " . status)

    LogMessage("INFO", "Run finished")
}


OpenLogsFolder(*) {
    EnsureLoggingStorage()

    try {
        logsDir := GetLogsDirectory()
        if !DirExist(logsDir)
            return false
        Run(logsDir)
        return true
    }
    catch {
        return false
    }
}


ExportLogFiles(*) {
    EnsureLoggingStorage()

    logsDir := GetLogsDirectory()

    try destinationRoot := DirSelect(, 0, "Choose a folder to export logs")
    catch {
        return 0
    }

    if !destinationRoot
        return 0

    exportDir := destinationRoot . "\BTD6_Logs_" . GetLogFileTimestamp()

    try {
        if !DirExist(exportDir)
            DirCreate(exportDir)
    }
    catch {
        return 0
    }

    exported := 0

    Loop Files logsDir . "\*.*", "F" {
        try {
            FileCopy(A_LoopFileFullPath, exportDir . "\" . A_LoopFileName, false)
            exported++
        }
    }

    if exported = 0 {
        try DirDelete(exportDir)
    }

    return exported
}


DeleteAllLogFiles(*) {
    logsDir := GetLogsDirectory()

    if !DirExist(logsDir)
        return 0

    deleted := 0

    Loop Files logsDir . "\*.*", "F" {
        try {
            FileDelete(A_LoopFileFullPath)
            deleted++
        }
    }

    return deleted
}
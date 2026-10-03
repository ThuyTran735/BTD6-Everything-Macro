#Requires AutoHotkey v2.0

; v3 file note: Reads/writes the tiny child-run and cycle-stop files used between scripts.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

IsInGameScreen() {
    global NavigationPatterns


    if !NavigationPatterns.Has(
        "Settings"
    ) {

        return false
    }


    return PatternExists(
        NavigationPatterns[
            "Settings"
        ]
    )
}


CreateChildRunToken() {
    return A_TickCount . "-" . Random(100000, 999999)
}


GetChildRunResultPath(token) {
    if token = ""
        return ""

    return A_Temp . "\\BTD6EverythingMacro_RunResult_" . token . ".ini"
}


ClearChildRunResult(token) {
    path := GetChildRunResultPath(token)
    if path = ""
        return

    try FileDelete(path)
}


ReadChildRunResult(token) {
    result := {
        status: "Missing",
        reason: "NO RESULT REPORTED"
    }

    path := GetChildRunResultPath(token)
    if path = "" || !FileExist(path)
        return result

    try {
        result.status := IniRead(path, "Result", "Status", "Missing")
        result.reason := IniRead(path, "Result", "Reason", "")
    }

    try FileDelete(path)
    return result
}


GetCycleStopRequestPath() {
    return A_Temp
        . "\BTD6EverythingMacro_StopCycles.flag"
}


ClearCycleStopRequest() {
    stopFile :=
        GetCycleStopRequestPath()


    try {
        FileDelete(
            stopFile
        )
    }
}


ConsumeCycleStopRequest() {
    stopFile :=
        GetCycleStopRequestPath()


    if !FileExist(
        stopFile
    ) {

        return false
    }


    try {
        FileDelete(
            stopFile
        )
    }


    return true
}



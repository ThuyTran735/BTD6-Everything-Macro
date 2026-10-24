#Requires AutoHotkey v2.0

; Exchanges small result files between the launcher and each child strategy.
; A unique run token keeps reports separate; the stop flag is consumed once.

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

    ; Each result belongs to one completed child and should not be read twice.
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



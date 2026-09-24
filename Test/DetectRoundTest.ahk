#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\Scripts\IncludeAll.ahk

; Diagnostic only. Does not run a strategy, place towers, or buy upgrades.
;
; The production Hard round boxes were found to be ~90 px too far left on the
; current 1920x1080 BTD6 HUD. These test boxes are intentionally local to this
; file so production RoundLogic.ahk is not changed until detection is verified.
;
; Hotkeys:
;   Space = pause/resume
;   F2    = reset validation tracking
;   F3    = open DetectRoundTest.log
;   Esc   = exit

global RunConfig := {
    category: "Beginner",
    map: "Monkey Meadow",
    difficulty: "Hard",
    gameMode: "Alternate Bloons Rounds",
    hero: "Gwendolin",
    wingmonkeyMK: false,
    startRound: 3,
    endRound: 80
}

; Calibrated from the supplied 1920x1080 screenshot.
; Visible round digit was approximately x1533-1553 / y37-65.
global DetectRoundTestAreas := {
    regular: {
        x1: 1508,
        y1: 26,
        x2: 1579,
        y2: 80
    },

    ; The upgrade-panel layout shifts the round counter about 400 px left.
    ; This keeps the same width/height as the regular test area.
    rightPanel: {
        x1: 1105,
        y1: 26,
        x2: 1183,
        y2: 80
    }
}

global DetectRoundTestPaused := false
global DetectRoundTestLogPath := A_ScriptDir "\DetectRoundTest.log"

ResetRoundTracking()

try FileDelete(DetectRoundTestLogPath)
FileAppend(
    "timestamp,regular_round,regular_text,regular_ms,right_round,right_text,right_ms,chosen,validated,last_round`n",
    DetectRoundTestLogPath,
    "UTF-8"
)

Esc::ExitApp()

Space::{
    global DetectRoundTestPaused
    DetectRoundTestPaused := !DetectRoundTestPaused
}

F2::{
    ResetRoundTracking()
}

F3::{
    global DetectRoundTestLogPath
    Run('notepad.exe "' DetectRoundTestLogPath '"')
}

ReadDetectRoundArea(areaName) {
    global DetectRoundTestAreas
    global RoundDigits

    area := DetectRoundTestAreas.%areaName%
    started := A_TickCount

    ok := FindText(
        &X,
        &Y,
        area.x1,
        area.y1,
        area.x2,
        area.y2,
        0,
        0,
        RoundDigits,
        1,
        1
    )

    elapsedMs := A_TickCount - started

    if !ok {
        return {
            round: false,
            text: "",
            elapsedMs: elapsedMs
        }
    }

    ok := FindText().Sort(ok)
    result := FindText().Ocr(ok, 20, 20, 3)
    roundText := RegExReplace(result.text, "\D")

    return {
        round: roundText != "" ? Integer(roundText) : false,
        text: result.text,
        elapsedMs: elapsedMs
    }
}

FormatDetectRoundValue(value) {
    return value ? value : "NOT FOUND"
}

CsvEscapeDetectRound(value) {
    value := String(value)
    value := StrReplace(value, '"', '""')
    return '"' value '"'
}

Loop {
    if DetectRoundTestPaused {
        ToolTip(
            "DETECT ROUND TEST - PAUSED"
            . "`n`nSpace = Resume"
            . "`nF2 = Reset tracking"
            . "`nF3 = Open log"
            . "`nEsc = Exit",
            1000,
            110
        )

        Sleep(50)
        continue
    }

    regular := ReadDetectRoundArea("regular")
    rightPanel := ReadDetectRoundArea("rightPanel")

    chosenRound := regular.round ? regular.round : rightPanel.round
    validatedRound := chosenRound ? ValidateRound(chosenRound) : LastRound

    status :=
        "DETECT ROUND TEST - 1920x1080"
        . "`nStart round: " GetStartingRound()
        . "`n"
        . "`nREGULAR BOX: x1508-1579 y26-80"
        . "`n  Raw round: " FormatDetectRoundValue(regular.round)
        . "`n  OCR text: " (regular.text != "" ? regular.text : "<none>")
        . "`n  Scan: " regular.elapsedMs " ms"
        . "`n"
        . "`nRIGHT-PANEL BOX: x1105-1183 y26-80"
        . "`n  Raw round: " FormatDetectRoundValue(rightPanel.round)
        . "`n  OCR text: " (rightPanel.text != "" ? rightPanel.text : "<none>")
        . "`n  Scan: " rightPanel.elapsedMs " ms"
        . "`n"
        . "`nRAW CHOSEN: " FormatDetectRoundValue(chosenRound)
        . "`nVALIDATED: " FormatDetectRoundValue(validatedRound)
        . "`nLastRound: " LastRound
        . "`nWeirdRead: " (WeirdReadActive ? "YES" : "NO")
        . "`nLastWeird: " (LastWeirdRead ? LastWeirdRead : "None")
        . "`n"
        . "`nSpace = Pause | F2 = Reset | F3 = Log | Esc = Exit"

    ToolTip(status, 1000, 110)

    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "." Format("{:03}", Mod(A_TickCount, 1000))

    FileAppend(
        CsvEscapeDetectRound(timestamp) ","
        . CsvEscapeDetectRound(regular.round ? regular.round : "") ","
        . CsvEscapeDetectRound(regular.text) ","
        . regular.elapsedMs ","
        . CsvEscapeDetectRound(rightPanel.round ? rightPanel.round : "") ","
        . CsvEscapeDetectRound(rightPanel.text) ","
        . rightPanel.elapsedMs ","
        . CsvEscapeDetectRound(chosenRound ? chosenRound : "") ","
        . CsvEscapeDetectRound(validatedRound ? validatedRound : "") ","
        . LastRound
        . "`n",
        DetectRoundTestLogPath,
        "UTF-8"
    )

    Sleep(100)
}
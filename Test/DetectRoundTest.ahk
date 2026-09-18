#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\Scripts\IncludeAll.ahk

; Live round OCR/debug test.
; Open any active game first, then run this file.
global RunConfig := {
    category: "Beginner",
    map: "Test",
    difficulty: "CHIMPS",
    gameMode: "CHIMPS",
    hero: false,
    startRound: 1,
    endRound: 100
}

ResetRoundTracking()

Esc::ExitApp()

Loop {
    detectedRound := GetCurrentRound()
    validatedRound := detectedRound ? ValidateRound(detectedRound) : LastRound

    ToolTip(
        "BTD6 " . GetAppVersionLabel() . " Round Detection Test"
        "`nDetected OCR: " (detectedRound ? detectedRound : "Not Found")
        "`nValidated: " (validatedRound ? validatedRound : "Not Found")
        "`nLast Round: " LastRound
        "`nWeird Read: " (WeirdReadActive ? "YES" : "NO")
        "`nLast Weird: " (LastWeirdRead ? LastWeirdRead : "None")
        "`n`nEsc = Exit",
        1000,
        100
    )

    Sleep(200)
}
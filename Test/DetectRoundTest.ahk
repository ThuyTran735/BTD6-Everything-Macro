#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk
#Include ..\Scripts\RoundLogic.ahk

global RunConfig := {
    map: "Test",
    difficulty: "CHIMPS"
}

RoundAreas["CHIMPS"] := {
    x1: 1375,
    y1: 27,
    x2: 1560,
    y2: 71
}

ResetRoundTracking()

Loop {
    detectedRound := GetCurrentRound()

    if detectedRound
        currentRound := ValidateRound(detectedRound)
    else
        currentRound := LastRound

    ToolTip(
        "Round: " (currentRound ? currentRound : "Not Found")
        "`nOCR: " (detectedRound ? detectedRound : "Not Found")
        "`nWeird Mode: " (WeirdReadActive ? "YES" : "NO")
        "`nLast Weird: " (LastWeirdRead ? LastWeirdRead : "None"),
        1000,
        100
    )

    Sleep(200)
}
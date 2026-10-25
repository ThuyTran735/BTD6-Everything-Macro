#Requires AutoHotkey v2.0

; Waits for the in-game Settings button and clears optional startup notices.
; The shared pattern helpers report failure to callers rather than choosing another menu path.

WaitForGameLoad(
    timeout := 15000
) {
    global NavigationPatterns

    if !NavigationPatterns.Has(
        "Settings"
    ) {
        ToolTip(
            "Settings pattern is missing."
        )

        return false
    }

    pattern :=
        NavigationPatterns[
            "Settings"
        ]

    startTime :=
        A_TickCount

    readySince := 0

    Loop {
        if A_TickCount - startTime >= timeout {
            ToolTip("Game failed to load.")
            return false
        }

        ; Settings remains visible behind Monkey Teams. Check the notice first,
        ; including during the settling period, before allowing any placements.
        promptResult := HandleMonkeyTeamsPrompt()
        if promptResult = false
            return false
        if promptResult = "handled"
            readySince := 0

        settingsVisible := PatternExists(pattern)
        if !WinActive("ahk_exe BloonsTD6.exe")
            return SetRunFailureReason("BTD6 LOST FOCUS DURING GAME LOAD")
        if settingsVisible {
            if !readySince
                readySince := A_TickCount
            ; Poll throughout the original one-second load delay: the notice
            ; may animate in after Settings first becomes readable.
            if A_TickCount - readySince >= 1000
                return true
        } else {
            readySince := 0
        }

        Sleep(200)
    }
}

RequestLauncherCycleStop() {
    stopFile :=
        A_Temp
        . "\BTD6EverythingMacro_StopCycles.flag"

    try {
        FileDelete(
            stopFile
        )
    }

    try {
        FileAppend(
            "STOP",
            stopFile,
            "UTF-8"
        )
    }
}

PatternExists(pattern) {
    return !!FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        pattern
    )
}

ClickPattern(
    pattern,
    delay := 500
) {
    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        pattern
    ) {
        return false
    }

    Click(X, Y)

    Sleep(delay)

    return true
}

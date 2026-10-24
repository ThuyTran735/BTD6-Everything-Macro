#Requires AutoHotkey v2.0

; Waits for the in-game Settings button before returning control to the strategy.
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

    Loop {
        if PatternExists(
            pattern
        ) {
            ; Settings can appear before the map finishes its opening animation.
            Sleep(1000)

            return true
        }

        if (
            A_TickCount
            - startTime
            >= timeout
        ) {
            ToolTip(
                "Game failed to load."
            )

            return false
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
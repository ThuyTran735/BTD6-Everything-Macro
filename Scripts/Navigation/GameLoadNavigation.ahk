#Requires AutoHotkey v2.0

; v3 file note: Waits for the match to load and holds the small pattern-click helpers.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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
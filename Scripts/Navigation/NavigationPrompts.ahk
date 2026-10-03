#Requires AutoHotkey v2.0

; v3 file note: Handles save/mode prompts that can pop up during navigation.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

HandleSavePrompt(
    timeout := 4000
) {
    global NavigationPatterns

    if !NavigationPatterns.Has(
        "OK"
    ) {
        return true
    }

    pattern :=
        NavigationPatterns[
            "OK"
        ]

    startTime :=
        A_TickCount

    Loop {
        if FindText(
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
            Click(X, Y)

            Loop 20 {
                Sleep(50)

                if !FindText(
                    &CheckX,
                    &CheckY,
                    0,
                    0,
                    A_ScreenWidth,
                    A_ScreenHeight,
                    0,
                    0,
                    pattern
                ) {
                    Sleep(120)

                    return true
                }
            }

            Click(X, Y)

            Sleep(500)

            return true
        }

        if (
            A_TickCount
            - startTime
            >= timeout
        ) {
            return true
        }

        Sleep(50)
    }
}

HandleModePrompt(gameMode) {
    global NavigationPatterns

    if (
        gameMode != "CHIMPS"
        && gameMode != "Deflation"
        && gameMode != "Impoppable"
    ) {
        return true
    }

    patternName := (
        gameMode = "Impoppable"
            ? "Impoppable OK"
            : "CHIMPS OK"
    )

    if !NavigationPatterns.Has(
        patternName
    ) {
        ToolTip(
            "Mode confirmation pattern is missing."
            . "`nMode: "
            . gameMode
        )

        return false
    }

    pattern :=
        NavigationPatterns[
            patternName
        ]

    Sleep(250)

    Loop 30 {
        if FindText(
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
            Click(X, Y)

            Sleep(700)

            return true
        }

        Sleep(150)
    }

    ToolTip(
        "Could not find mode confirmation OK."
        . "`nMode: "
        . gameMode
    )

    Sleep(1500)

    ToolTip()

    return false
}


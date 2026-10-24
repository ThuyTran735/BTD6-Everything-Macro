#Requires AutoHotkey v2.0

; Handles optional save warnings and the required confirmation screen for special modes.
; A save prompt may never appear; a requested mode confirmation must be found to continue.

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

            ; Wait for the warning to disappear before the next navigation click.
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
            ; No warning is a valid path when this map has no saved game.
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
        && gameMode != "Apopalypse"
    ) {
        return true
    }

    if gameMode = "Apopalypse"
        patternName := "Apopalypse Play"
    else if gameMode = "Impoppable"
        patternName := "Impoppable OK"
    else
        patternName := "CHIMPS OK"

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
        "Could not find mode confirmation button."
        . "`nMode: "
        . gameMode
    )

    Sleep(1500)

    ToolTip()

    return false
}
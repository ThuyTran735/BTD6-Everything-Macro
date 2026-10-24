#Requires AutoHotkey v2.0

; Selects difficulty and game mode from their captures, with separate locked-mode detection.
; Lock checks require repeated evidence after the menu has had time to appear.

SelectDifficulty(difficulty) {
    global NavigationPatterns

    if !NavigationPatterns.Has(
        difficulty
    ) {
        ToolTip(
            "Unknown difficulty: "
            difficulty
        )

        return false
    }

    pattern :=
        NavigationPatterns[
            difficulty
        ]

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
        ToolTip(
            "Could not find difficulty: "
            difficulty
        )

        return false
    }

    Click(X, Y)

    Sleep(500)

    return true
}

SelectGameMode(gameMode) {
    global NavigationPatterns

    if !NavigationPatterns.Has(
        gameMode
    ) {
        ToolTip(
            "Unknown game mode: "
            gameMode
        )

        return false
    }

    pattern :=
        NavigationPatterns[
            gameMode
        ]

    lockedHits := 0

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

        ; Ignore early animation frames, then require three consecutive lock matches.
        if A_Index >= 5 {
            if IsGameModeLocked(
                gameMode
            ) {
                lockedHits++

                if lockedHits >= 3
                    return "Locked"
            }
            else {
                lockedHits := 0
            }
        }

        Sleep(150)
    }

    ToolTip(
        "Could not find game mode: "
        gameMode
    )

    return false
}

IsGameModeLocked(gameMode) {
    global GameModeLockPatterns

    if !GameModeLockPatterns.Has(
        gameMode
    ) {
        return false
    }

    pattern :=
        GameModeLockPatterns[
            gameMode
        ]

    if pattern = ""
        return false

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


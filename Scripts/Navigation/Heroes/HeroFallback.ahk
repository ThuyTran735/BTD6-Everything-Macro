#Requires AutoHotkey v2.0

; Falls back to Quincy when the requested hero is missing or locked.
; Search the current list position first, then scroll upward toward the default hero.

SelectFallbackHero(
    requestedHero
) {
    global HeroPatterns


    ; Quincy is the default hero available
    ; to every player.
    if !HeroPatterns.Has(
        "Quincy"
    ) {

        ToolTip(
            "Could not find "
            . requestedHero
            . " and Quincy patterns are missing."
        )


        Sleep(
            1500
        )


        ToolTip()


        return false
    }


    ToolTip(
        requestedHero
        . " not available."
        . "`nUsing Quincy instead."
    )


    Sleep(
        600
    )


    ToolTip()


    quincyPatterns :=
        HeroPatterns[
            "Quincy"
        ]


    ; Search wherever the hero list currently is.
    if FindAndClickHero(
        quincyPatterns
    ) {

        Sleep(
            500
        )


        return ClickSelectButton()
    }


    ; Quincy should be near the top of the hero list,
    ; so scroll upward until we find him.
    Loop 5 {

        MouseMove(
            200,
            500
        )


        Send(
            "{WheelUp 8}"
        )


        Sleep(
            300
        )


        if FindAndClickHero(
            quincyPatterns
        ) {

            Sleep(
                500
            )


            return ClickSelectButton()
        }
    }


    ToolTip(
        "Could not find "
        . requestedHero
        . " or fallback hero Quincy."
    )


    Sleep(
        1500
    )


    ToolTip()


    return false
}


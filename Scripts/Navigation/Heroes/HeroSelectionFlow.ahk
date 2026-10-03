#Requires AutoHotkey v2.0

; v3 file note: Runs the normal hero selection path.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

SelectHero(heroName) {
    global HeroPatterns


    ; If the requested hero isn't even configured,
    ; immediately fall back to Quincy.
    if !HeroPatterns.Has(
        heroName
    ) {
        return SelectFallbackHero(
            heroName
        )
    }


    patterns :=
        HeroPatterns[
            heroName
        ]


    ; Search current position.
    if FindAndClickHero(
        patterns
    ) {
        return FinishHeroSelection(
            heroName
        )
    }


    ; Search while scrolling down.
    Loop 2 {

        MouseMove(
            200,
            500
        )


        Send(
            "{WheelDown 6}"
        )


        Sleep(
            300
        )


        if FindAndClickHero(
            patterns
        ) {
            return FinishHeroSelection(
                heroName
            )
        }
    }


    ; Search while scrolling up.
    Loop 2 {

        MouseMove(
            200,
            500
        )


        Send(
            "{WheelUp 6}"
        )


        Sleep(
            300
        )


        if FindAndClickHero(
            patterns
        ) {
            return FinishHeroSelection(
                heroName
            )
        }
    }


    ; Requested hero could not be found.
    ; This can happen if the player hasn't
    ; unlocked that hero yet.
    return SelectFallbackHero(
        heroName
    )
}


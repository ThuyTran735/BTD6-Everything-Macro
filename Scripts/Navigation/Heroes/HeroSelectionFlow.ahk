#Requires AutoHotkey v2.0

; Searches the current hero list, then a bounded number of pages in both directions.
; A found portrait still goes through the ownership check before selection is completed.

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


#Requires AutoHotkey v2.0

; v3 file note: Finishes selection and deals with heroes that are not unlocked.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

FinishHeroSelection(
    heroName
) {
    ; Give the hero details panel time to update
    ; after the requested hero was clicked.
    Sleep(
        500
    )


    ; Higher-level accounts can display the normal
    ; hero portrait even when the hero is still locked.
    ; The Unlock button is the reliable ownership check.
    if IsHeroUnlockVisible() {
        return SelectFallbackHero(
            heroName
        )
    }


    return ClickSelectButton()
}

IsHeroUnlockVisible() {
    global HeroSelectionPatterns


    if !HeroSelectionPatterns.Has(
        "Unlock"
    ) {
        return false
    }


    unlockPattern :=
        HeroSelectionPatterns[
            "Unlock"
        ]


    ; Keep hero selection working while the new
    ; FindText capture has not been added yet.
    if Trim(
        unlockPattern
    ) = "" {
        return false
    }


    return !!FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        unlockPattern
    )
}



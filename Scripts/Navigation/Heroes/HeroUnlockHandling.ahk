#Requires AutoHotkey v2.0

; Waits for hero details and checks the Unlock button before pressing Select.
; A locked portrait routes to the fallback hero instead of assuming the account owns it.

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



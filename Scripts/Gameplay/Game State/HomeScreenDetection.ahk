#Requires AutoHotkey v2.0

; Recognizes the Home screen by its Play button.
; A missing or empty capture means unknown, so it must not be treated as proof of Home.

IsHomeScreenVisible() {
    global NavigationPatterns


    if !IsSet(
        NavigationPatterns
    ) {
        return false
    }


    if !NavigationPatterns.Has(
        "Play"
    ) {
        return false
    }


    playPattern :=
        NavigationPatterns["Play"]


    if playPattern = "" {
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
        playPattern
    )
}



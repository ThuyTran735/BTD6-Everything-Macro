#Requires AutoHotkey v2.0

; v3 file note: Checks whether BTD6 has dropped back to the home screen.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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



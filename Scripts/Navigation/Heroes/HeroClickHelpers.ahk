#Requires AutoHotkey v2.0

; v3 file note: Small FindText click helpers used by the hero picker.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

FindAndClickHero(patterns) {
    for pattern in patterns {
        if FindText(&X, &Y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, pattern) {
            Click(X, Y)
            return true
        }
    }

    return false
}

ClickSelectButton() {
    Click(1100, 600)
    Sleep(500)

    return true
}
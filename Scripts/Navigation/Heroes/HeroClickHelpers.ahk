#Requires AutoHotkey v2.0

; Tries the configured skin captures for one hero and clicks the first visible match.
; The Select button uses the calibrated details-panel coordinate after that panel has settled.

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
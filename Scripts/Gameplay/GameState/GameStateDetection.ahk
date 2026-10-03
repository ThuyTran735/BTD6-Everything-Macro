#Requires AutoHotkey v2.0

; v3 file note: Runs the quick top-level check for playing, victory, or defeat.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

CheckGameState() {
    global GameStatePatterns


    ; Mid-game interruption screens can appear while
    ; waiting for rounds or while upgrading.
    if HandleLevelUpPopup() {
        return "Playing"
    }


    if HandleNewBloonPopup() {
        return "Playing"
    }


    if HandleMonkeyMoneyPopup() {
        return "Playing"
    }


    if FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        GameStatePatterns["VictoryNext"]
    ) {
        return "Victory"
    }


    if FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        GameStatePatterns["Restart"]
    ) {
        return "Defeat"
    }


    return "Playing"
}



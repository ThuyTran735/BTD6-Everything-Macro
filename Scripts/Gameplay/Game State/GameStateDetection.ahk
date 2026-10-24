#Requires AutoHotkey v2.0

; Checks interruptions before deciding whether a run is still playing, won, or lost.
; A dismissed popup leaves the run active; result handlers own the later screen transitions.

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



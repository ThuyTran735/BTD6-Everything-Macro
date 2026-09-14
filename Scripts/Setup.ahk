#Requires AutoHotkey v2.0


IsBTD6Fullscreen() {
    gameWindow :=
        WinExist(
            "ahk_exe BloonsTD6.exe"
        )


    if !gameWindow {
        return false
    }


    try {
        WinGetPos(
            &windowX,
            &windowY,
            &windowWidth,
            &windowHeight,
            "ahk_id "
            . gameWindow
        )
    }
    catch {
        return false
    }


    ; Our macro is built around a fixed
    ; 1920x1080 BTD6 fullscreen setup.
    ;
    ; Give Windows a few pixels of tolerance
    ; in case the reported window rectangle
    ; differs slightly.
    if (
        windowX <= 2
        && windowY <= 2
        && windowWidth >= 1918
        && windowHeight >= 1078
    ) {
        return true
    }


    return false
}


SwitchToFullscreen() {
    playButtonText := "|<>*127$71.zzU00Q0001y1zD000s0003w3sS003U0003s40w00701w07k01s00C03s0DU03k00s0Ds0D007UDzk0Tk0S00Dzzzs0zUDw00Dzzzzzrzzs00Tzzzzzjzzzk0zzzzzzTzzzU0T00TzwTzzz000000DkT0Dy00000000007w0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"


    gameWindow :=
        WinExist(
            "ahk_exe BloonsTD6.exe"
        )


    if !gameWindow {

        ToolTip(
            "BTD6 is not running."
        )


        Sleep(
            1500
        )


        ToolTip()


        return false
    }


    ; Most important check:
    ; determine fullscreen from the actual
    ; BTD6 window instead of FindText.
    if IsBTD6Fullscreen() {
        return true
    }


    ; BTD6 may still be settling after returning
    ; to the home screen between cycles.
    ;
    ; Wait briefly before deciding that we
    ; actually need to toggle fullscreen.
    Loop 10 {

        Sleep(
            150
        )


        if IsBTD6Fullscreen() {
            return true
        }
    }


    ; Keep the old Play pattern only as an
    ; additional safety check.
    if FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        playButtonText
    ) {
        return true
    }


    WinActivate(
        "ahk_id "
        . gameWindow
    )


    if !WinWaitActive(
        "ahk_id "
        . gameWindow,
        ,
        2
    ) {

        ToolTip(
            "Could not activate BTD6."
        )


        Sleep(
            1500
        )


        ToolTip()


        return false
    }


    ; Check one final time after activation.
    ;
    ; This prevents Alt+Enter from being sent
    ; if activating BTD6 caused its fullscreen
    ; window to finish restoring.
    if IsBTD6Fullscreen() {
        return true
    }


    ; Only toggle when the real BTD6 window
    ; dimensions prove that it is not fullscreen.
    Send(
        "!{Enter}"
    )


    Sleep(
        750
    )


    ; Confirm using the window itself.
    Loop 15 {

        if IsBTD6Fullscreen() {
            return true
        }


        Sleep(
            100
        )
    }


    ToolTip(
        "Could not confirm BTD6 fullscreen."
        . "`nPlease switch the game to fullscreen."
    )


    Sleep(
        2000
    )


    ToolTip()


    return false
}
#Requires AutoHotkey v2.0


SwitchToFullscreen() {
    playButtonText := "|<>*127$71.zzU00Q0001y1zD000s0003w3sS003U0003s40w00701w07k01s00C03s0DU03k00s0Ds0D007UDzk0Tk0S00Dzzzs0zUDw00Dzzzzzrzzs00Tzzzzzjzzzk0zzzzzzTzzzU0T00TzwTzzz000000DkT0Dy00000000007w0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"


    ; First check whether the expected
    ; fullscreen home-screen pattern is
    ; already visible.
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


    ; Make sure Alt+Enter is sent to BTD6
    ; instead of another application.
    if WinExist(
        "ahk_exe BloonsTD6.exe"
    ) {
        WinActivate(
            "ahk_exe BloonsTD6.exe"
        )


        if !WinWaitActive(
            "ahk_exe BloonsTD6.exe",
            ,
            2
        ) {
            ToolTip(
                "Could not activate BTD6."
            )

            Sleep(1500)
            ToolTip()

            return false
        }
    }
    else {
        ToolTip(
            "BTD6 is not running."
        )

        Sleep(1500)
        ToolTip()

        return false
    }


    ; Try switching the game to fullscreen.
    Send("!{Enter}")

    Sleep(1000)


    ; Give the game a few seconds to finish
    ; resizing before deciding it failed.
    Loop 15 {
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


        Sleep(150)
    }


    ToolTip(
        "Could not confirm BTD6 fullscreen."
        "`nPlease switch the game to fullscreen."
    )

    Sleep(2000)
    ToolTip()


    return false
}
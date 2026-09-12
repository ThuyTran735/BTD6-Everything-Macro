#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

SwitchToFullscreen() {
    playButtonText := "|<>*127$71.zzU00Q0001y1zD000s0003w3sS003U0003s40w00701w07k01s00C03s0DU03k00s0Ds0D007UDzk0Tk0S00Dzzzs0zUDw00Dzzzzzrzzs00Tzzzzzjzzzk0zzzzzzTzzzU0T00TzwTzzz000000DkT0Dy00000000007w0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

    ToolTip("Checking for play button...")
    Sleep(1000)
    ToolTip()

    if FindText(&X, &Y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, playButtonText) {
        ToolTip("Setup complete! Starting macro...")
        Sleep(2500)
        ToolTip()
        return true
    }

    ToolTip("Play button not found. Trying fullscreen...")
    Sleep(1500)
    ToolTip()

    Send("!{Enter}")
    Sleep(1500)

    if FindText(&X, &Y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, playButtonText) {
        ToolTip("Setup complete! Starting macro...")
        Sleep(2500)
        ToolTip()
        return true
    }

    ToolTip("Error: Please put the game into fullscreen!")
    Sleep(2500)
    ToolTip()

    return false
}
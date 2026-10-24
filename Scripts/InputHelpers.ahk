#Requires AutoHotkey v2.0

; Small shared input helpers so timing-sensitive key presses stay consistent.

SendEscapeAndWait(waitMs := 300) {
    ; BTD6's panel/menu close animation needs time to finish before the next
    ; scripted input. Never let an Esc settle for less than 300 ms.
    Send("{Esc}")
    Sleep(Max(300, waitMs))
}

IsTowerInputActive() {
    return !!WinActive("ahk_exe BloonsTD6.exe")
}

SendGameKey(hotkey, holdMs := 80) {
    ; Tower bindings are single letters or named keys such as {F6}.
    ; Hold the key across a few frames so a busy game can notice it.
    if RegExMatch(hotkey, "^\{([A-Za-z0-9]+)\}$", &match)
        key := match[1]
    else if StrLen(hotkey) = 1
        key := hotkey
    else
        throw Error("Expected one game key, got: " . hotkey)

    if !IsTowerInputActive()
        return false

    try {
        SendEvent("{" . key . " down}")
        Sleep(Max(40, holdMs))
    }
    finally {
        ; Release even if an interruption happens during the hold.
        SendEvent("{" . key . " up}")
    }

    return IsTowerInputActive()
}

ClickTowerPoint(x, y) {
    ; The existing ClickMapPoint holdMs controls HUD visibility, not the
    ; mouse button. Tower actions need an actual press that lasts a few frames.
    if !IsTowerInputActive()
        return false

    RequestCycleStatusHideForPoint(x, y, 750)
    if !IsTowerInputActive()
        return false

    previousCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    try {
        MouseMove(x, y, 0)
        if !IsTowerInputActive()
            return false

        try {
            SendEvent("{LButton down}")
            Sleep(70)
        }
        finally {
            SendEvent("{LButton up}")
        }
    }
    finally {
        CoordMode("Mouse", previousCoordMode)
    }

    return IsTowerInputActive()
}

#Requires AutoHotkey v2.0

; Matches the standalone builder chrome to the dark launcher.
; Only the title area drags the window, leaving form controls free to receive clicks.

StrategyBuilderChromeHitTest(wParam, lParam, msg, hwnd) {
    global MainGui

    if !MainGui {
        return
    }

    rootHwnd := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")

    if !rootHwnd {
        rootHwnd := hwnd
    }

    if rootHwnd != MainGui.Hwnd {
        return
    }

    rect := Buffer(16, 0)

    if !DllCall("GetWindowRect", "Ptr", rootHwnd, "Ptr", rect.Ptr, "Int") {
        return
    }

    left := NumGet(rect, 0, "Int")
    top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int")

    screenX := lParam & 0xFFFF
    screenY := (lParam >> 16) & 0xFFFF

    ; WM_NCHITTEST packs signed screen coordinates into two 16-bit values.
    ; Decode negatives so title dragging also works on monitors left of the main display.
    if screenX >= 0x8000 {
        screenX -= 0x10000
    }

    if screenY >= 0x8000 {
        screenY -= 0x10000
    }

    clientX := screenX - left
    clientY := screenY - top
    windowWidth := right - left

    if (
        clientY >= 0
        && clientY < 68
        && clientX >= 0
        && clientX < windowWidth - 96
    ) {
        return 2
    }
}


CreateStrategyBuilderBorder(guiObject, width, height) {
    borderColor := "2A3441"
    thickness := 2

    top := guiObject.Add(
        "Progress",
        "x0 y0 w" . width . " h" . thickness
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    bottom := guiObject.Add(
        "Progress",
        "x0 y" . (height - thickness) . " w" . width . " h" . thickness
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    left := guiObject.Add(
        "Progress",
        "x0 y0 w" . thickness . " h" . height
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    right := guiObject.Add(
        "Progress",
        "x" . (width - thickness) . " y0 w" . thickness . " h" . height
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )

    return {
        Top: top,
        Bottom: bottom,
        Left: left,
        Right: right,
        Thickness: thickness
    }
}


ResizeStrategyBuilderBorder(border, width, height) {
    if !IsObject(border) {
        return
    }

    thickness := border.Thickness
    try border.Top.Move(0, 0, width, thickness)
    try border.Bottom.Move(0, height - thickness, width, thickness)
    try border.Left.Move(0, 0, thickness, height)
    try border.Right.Move(width - thickness, 0, thickness, height)
}


MinimizeStrategyBuilder(*) {
    global MainGui

    if MainGui {
        WinMinimize("ahk_id " . MainGui.Hwnd)
    }
}


ResizeStrategyBuilderChrome(guiObject, minMax, width, height) {
    global BuilderMinimizeControl
    global BuilderCloseControl
    global BuilderWindowBorder

    ; Minimized windows report dimensions that are not useful for laying out the chrome.
    if minMax = -1 {
        return
    }

    try BuilderMinimizeControl.Move(width - 86, 12, 30, 28)
    try BuilderCloseControl.Move(width - 46, 12, 30, 28)
    ResizeStrategyBuilderBorder(BuilderWindowBorder, width, height)
}

StyleBuilderNativeControls(guiObject) {
    ; Keep native keyboard navigation and the controls' existing event handlers.
    ; Older Windows themes can fall back to their usual control appearance.
    for control in guiObject {
        if control.Type = "ListView" {
            control.Opt("cF4F7FB Background10161D")
        }

        if (
            control.Type = "Edit"
            || control.Type = "ListView"
            || control.Type = "Button"
            || control.Type = "DropDownList"
        ) {
            try DllCall(
                "uxtheme\SetWindowTheme",
                "Ptr", control.Hwnd,
                "Str", "DarkMode_Explorer",
                "Ptr", 0
            )
        }
    }
}

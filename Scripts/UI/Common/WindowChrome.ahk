#Requires AutoHotkey v2.0

; Draws window frames and panels and makes the custom header draggable.
; The right header inset stays available for help and other clickable controls.


global UICustomChromeWindows := Map()
global UICustomChromeHitTestReady := false


EnableCustomWindowChrome(
    guiObject,
    dragHeight := 72,
    rightInset := 70
) {
    global UICustomChromeWindows
    global UICustomChromeHitTestReady


    if !guiObject {
        return
    }


    ; Remove native Windows chrome. The app draws its own dark frame
    ; inside the client area, and the branded header becomes the draggable
    ; title surface instead.
    guiObject.Opt("-Caption -Border")


    UICustomChromeWindows[guiObject.Hwnd] := {
        DragHeight: dragHeight,
        RightInset: rightInset
    }


    if !UICustomChromeHitTestReady {
        OnMessage(0x84, HandleCustomWindowHitTest) ; WM_NCHITTEST
        UICustomChromeHitTestReady := true
    }
}


HandleCustomWindowHitTest(wParam, lParam, msg, hwnd) {
    global UICustomChromeWindows


    rootHwnd := DllCall(
        "GetAncestor",
        "Ptr", hwnd,
        "UInt", 2,
        "Ptr"
    )


    if !rootHwnd {
        rootHwnd := hwnd
    }


    if !UICustomChromeWindows.Has(rootHwnd) {
        return
    }


    chrome := UICustomChromeWindows[rootHwnd]


    rect := Buffer(16, 0)


    if !DllCall(
        "GetWindowRect",
        "Ptr", rootHwnd,
        "Ptr", rect.Ptr,
        "Int"
    ) {
        return
    }


    left := NumGet(rect, 0, "Int")
    top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int")


    ; WM_NCHITTEST packs signed screen coordinates into two 16-bit halves.
    ; Restore their sign so dragging also works left of or above the main monitor.
    screenX := lParam & 0xFFFF
    screenY := (lParam >> 16) & 0xFFFF


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
        && clientY < chrome.DragHeight
        && clientX >= 0
        && clientX < windowWidth - chrome.RightInset
    ) {
        return 2 ; HTCAPTION - drag the borderless window.
    }
}


AddUICard(
    guiObject,
    x,
    y,
    width,
    height,
    borderColor := "",
    fillColor := ""
) {
    global UIColorPanelBorder
    global UIColorPanelRaised

    if borderColor = "" {
        borderColor := UIColorPanelBorder
    }

    if fillColor = "" {
        fillColor := UIColorPanelRaised
    }

    border := guiObject.Add(
        "Progress",
        "x" . x . " y" . y . " w" . width . " h" . height
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )

    fill := guiObject.Add(
        "Progress",
        "x" . (x + 1) . " y" . (y + 1)
        . " w" . (width - 2) . " h" . (height - 2)
        . " c" . fillColor . " Background" . fillColor . " Disabled",
        100
    )

    ; Keep the single theme-colored outline instead of nested native 3D frames.
    border.Opt("-0x800000 -E0x200 -E0x20000")
    fill.Opt("-0x800000 -E0x200 -E0x20000")

    return {Border: border, Fill: fill}
}


AddCustomWindowBorder(
    guiObject,
    windowWidth,
    windowHeight,
    thickness := 4,
    color := ""
) {
    global UIColorWindowBorder


    if !guiObject {
        return ""
    }


    if color = "" {
        color := UIColorWindowBorder
    }


    top := guiObject.Add(
        "Progress",
        "x0 y0 w" . windowWidth . " h" . thickness
        . " c" . color . " Background" . color . " Disabled",
        100
    )


    bottom := guiObject.Add(
        "Progress",
        "x0 y" . (windowHeight - thickness)
        . " w" . windowWidth . " h" . thickness
        . " c" . color . " Background" . color . " Disabled",
        100
    )


    left := guiObject.Add(
        "Progress",
        "x0 y0 w" . thickness . " h" . windowHeight
        . " c" . color . " Background" . color . " Disabled",
        100
    )


    right := guiObject.Add(
        "Progress",
        "x" . (windowWidth - thickness)
        . " y0 w" . thickness . " h" . windowHeight
        . " c" . color . " Background" . color . " Disabled",
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


ResizeCustomWindowBorder(
    border,
    windowWidth,
    windowHeight
) {
    if !IsObject(border) {
        return
    }


    thickness := border.Thickness


    try border.Top.Move(0, 0, windowWidth, thickness)
    try border.Bottom.Move(0, windowHeight - thickness, windowWidth, thickness)
    try border.Left.Move(0, 0, thickness, windowHeight)
    try border.Right.Move(windowWidth - thickness, 0, thickness, windowHeight)
}



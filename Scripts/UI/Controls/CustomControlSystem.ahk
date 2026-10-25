#Requires AutoHotkey v2.0

; Runs the shared hover and wheel handling for buttons and lists.
; Hit tests use screen coordinates so painted controls line up with the real cursor.

UIControlContainsScreenPoint(
    controlObject,
    screenX,
    screenY
) {
    try controlHwnd := controlObject.Hwnd
    catch {
        return false
    }

    if !DllCall("IsWindowVisible", "Ptr", controlHwnd)
        return false


    ; Cursor coordinates and this rectangle are both physical screen pixels.
    ; Mixing them with GUI layout coordinates would shift hit areas under DPI scaling.
    rect := Buffer(16, 0)


    if !DllCall(
        "GetWindowRect",
        "Ptr", controlHwnd,
        "Ptr", rect.Ptr,
        "Int"
    ) {
        return false
    }


    left := NumGet(rect, 0, "Int")
    top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int")
    bottom := NumGet(rect, 12, "Int")


    return (
        screenX >= left
        && screenX < right
        && screenY >= top
        && screenY < bottom
    )
}


StartUICustomControlSystem() {
    global UICustomControlTimerStarted
    global UICustomControlMessagesStarted


    if !UICustomControlTimerStarted {

        UICustomControlTimerStarted :=
            true


        SetTimer(
            PollUICustomControls,
            16
        )
    }


    if !UICustomControlMessagesStarted {

        UICustomControlMessagesStarted :=
            true


        OnMessage(
            0x20A,
            UICustomControlMouseWheel
        )
    }
}


PollUICustomControls() {
    global UIDarkLists
    global UIDarkButtons
    global UIDarkActiveDropdown


    cursorPoint := Buffer(
        8,
        0
    )


    if !DllCall(
        "GetCursorPos",
        "Ptr",
        cursorPoint.Ptr,
        "Int"
    ) {
        return
    }


    mouseX :=
        NumGet(
            cursorPoint,
            0,
            "Int"
        )


    mouseY :=
        NumGet(
            cursorPoint,
            4,
            "Int"
        )


    ; An open dropdown only owns hover inside the popup rectangle itself.
    ; Controls elsewhere in the owner UI should continue responding normally.
    ; This prevents controls physically covered by the popup from highlighting
    ; through it without freezing unrelated controls around the dropdown.
    backgroundHoverBlocked := false

    if IsSet(UIDarkActiveDropdown) && IsObject(UIDarkActiveDropdown) {
        try {
            backgroundHoverBlocked := (
                UIDarkActiveDropdown.IsOpen
                && UIDarkActiveDropdown.PopupContainsScreenPoint(
                    mouseX,
                    mouseY
                )
            )
        }
    }

    hoverX := backgroundHoverBlocked ? -2147483648 : mouseX
    hoverY := backgroundHoverBlocked ? -2147483648 : mouseY


    activeButtons := []


    for button in UIDarkButtons {
        isAlive := false

        try isAlive := button.IsAlive()

        if !isAlive {
            continue
        }

        ; Keep a valid control registered even if one visual refresh happens
        ; during a GUI state transition. A transient draw/move error should not
        ; permanently remove a button from hover tracking.
        activeButtons.Push(button)

        try button.UpdateHover(hoverX, hoverY)
    }


    UIDarkButtons := activeButtons


    activeLists := []


    for list in UIDarkLists {
        isAlive := false

        try isAlive := list.IsAlive()

        if !isAlive {
            continue
        }

        ; As with buttons, only an invalid window handle removes a list from
        ; tracking. Temporary refresh errors no longer disable future hovers.
        activeLists.Push(list)

        try list.UpdateHover(
            hoverX,
            hoverY
        )
    }


    UIDarkLists :=
        activeLists
}


UICustomControlMouseWheel(
    wParam,
    lParam,
    msg,
    hwnd
) {
    global UIDarkLists
    global UIDarkActiveDropdown


    cursorPoint := Buffer(
        8,
        0
    )


    if !DllCall(
        "GetCursorPos",
        "Ptr",
        cursorPoint.Ptr,
        "Int"
    ) {
        return
    }


    mouseX :=
        NumGet(
            cursorPoint,
            0,
            "Int"
        )


    mouseY :=
        NumGet(
            cursorPoint,
            4,
            "Int"
        )


    delta :=
        (
            wParam >> 16
        )
        & 0xFFFF

    ; A popup may overlap a list below it. Leave that wheel message for the
    ; dropdown hook instead of scrolling the covered list first.
    if IsSet(UIDarkActiveDropdown) && IsObject(UIDarkActiveDropdown)
        && UIDarkActiveDropdown.PopupContainsScreenPoint(mouseX, mouseY) {
        return
    }


    if delta > 0x7FFF {
        delta -= 0x10000
    }


    for list in UIDarkLists {

        try {
            if (
                list.IsAlive()
                && list.ContainsScreenPoint(
                    mouseX,
                    mouseY
                )
            ) {

                list.Scroll(
                    delta
                )


                return 0
            }
        }
    }
}


BlendUIColors(
    colorA,
    colorB,
    amount
) {
    amount :=
        Max(
            0,
            Min(
                1,
                amount
            )
        )


    r1 :=
        Integer(
            "0x"
            . SubStr(
                colorA,
                1,
                2
            )
        )


    g1 :=
        Integer(
            "0x"
            . SubStr(
                colorA,
                3,
                2
            )
        )


    b1 :=
        Integer(
            "0x"
            . SubStr(
                colorA,
                5,
                2
            )
        )


    r2 :=
        Integer(
            "0x"
            . SubStr(
                colorB,
                1,
                2
            )
        )


    g2 :=
        Integer(
            "0x"
            . SubStr(
                colorB,
                3,
                2
            )
        )


    b2 :=
        Integer(
            "0x"
            . SubStr(
                colorB,
                5,
                2
            )
        )


    r :=
        Round(
            r1
            + (
                (r2 - r1)
                * amount
            )
        )


    g :=
        Round(
            g1
            + (
                (g2 - g1)
                * amount
            )
        )


    b :=
        Round(
            b1
            + (
                (b2 - b1)
                * amount
            )
        )


    return Format(
        "{:02X}{:02X}{:02X}",
        r,
        g,
        b
    )
}


SetUIProgressColor(
    progressControl,
    color
) {
    try {
        normalizedColor := StrUpper(color)

        if (
            progressControl.HasOwnProp("LastUIProgressColor")
            && progressControl.LastUIProgressColor = normalizedColor
        ) {
            return
        }

        ; Keep AutoHotkey in charge of Progress styling. Direct PBM color
        ; messages can make themed Progress controls fall back to a flat gray
        ; surface after the first hover transition.
        progressControl.Opt(
            "c"
            . normalizedColor
            . " Background"
            . normalizedColor
        )

        ; Applying Progress colors can restore its native static edge. Keep
        ; every layer flat so rows and button halves do not acquire pale seams.
        style := DllCall("GetWindowLongPtr", "Ptr", progressControl.Hwnd, "Int", -16, "Ptr")
        extended := DllCall("GetWindowLongPtr", "Ptr", progressControl.Hwnd, "Int", -20, "Ptr")
        if (style & 0x800000) || (extended & 0x20200)
            progressControl.Opt("-0x800000 -E0x200 -E0x20000")

        ; The control is already filled. Setting its value and forcing another
        ; redraw exposed intermediate frames behind transparent labels. Keep
        ; the cache on this control too: Windows can reuse a destroyed HWND.
        progressControl.LastUIProgressColor := normalizedColor

        ; Repaint the affected stack together. Invalidating only a background
        ; Progress can paint over sibling labels and ? badges until the next
        ; mouse move. Queue one parent-region repaint, including its children,
        ; so overlapping text is painted after the changed background.
        parentHwnd := DllCall("GetParent", "Ptr", progressControl.Hwnd, "Ptr")
        rect := Buffer(16, 0)
        if parentHwnd && DllCall("GetWindowRect", "Ptr", progressControl.Hwnd, "Ptr", rect) {
            DllCall("MapWindowPoints", "Ptr", 0, "Ptr", parentHwnd, "Ptr", rect, "UInt", 2)
            DllCall("RedrawWindow", "Ptr", parentHwnd, "Ptr", rect, "Ptr", 0, "UInt", 0x81)
        }
    }
}

#Requires AutoHotkey v2.0

; v3 file note: Runs hover/click/wheel polling and shared color/progress helpers for custom controls.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

UIControlContainsScreenPoint(
    controlObject,
    screenX,
    screenY
) {
    try controlHwnd := controlObject.Hwnd
    catch {
        return false
    }


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
    static colorCache := Map()

    try {
        hwnd := progressControl.Hwnd
        normalizedColor := StrUpper(color)

        if (
            colorCache.Has(hwnd)
            && colorCache[hwnd] = normalizedColor
        ) {
            return
        }

        colorCache[hwnd] := normalizedColor

        ; Keep AutoHotkey in charge of Progress styling. Direct PBM color
        ; messages can make themed Progress controls fall back to a flat gray
        ; surface after the first hover transition.
        progressControl.Opt(
            "c"
            . normalizedColor
            . " Background"
            . normalizedColor
        )

        progressControl.Value := 100
        progressControl.Redraw()
    }
}
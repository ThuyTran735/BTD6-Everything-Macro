#Requires AutoHotkey v2.0

; v3 file note: Handles the dropdown wheel hook, polling, and closing other open dropdowns.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

StartDarkDropdownWheelHook() {
    global UIDarkDropdownWheelHookStarted

    if UIDarkDropdownWheelHookStarted {
        return
    }

    UIDarkDropdownWheelHookStarted := true

    ; WM_MOUSEWHEEL - reliable even though wheel buttons do not have a held state.
    OnMessage(
        0x020A,
        DarkDropdownMouseWheel
    )
}


DarkDropdownMouseWheel(
    wParam,
    lParam,
    msg,
    hwnd
) {
    global UIDarkDropdowns

    delta :=
        (wParam >> 16)
        & 0xFFFF

    if delta & 0x8000 {
        delta -= 0x10000
    }

    if delta = 0 {
        return
    }

    cursorPoint := Buffer(8, 0)

    if !DllCall(
        "GetCursorPos",
        "Ptr", cursorPoint.Ptr,
        "Int"
    ) {
        return
    }

    mouseX := NumGet(cursorPoint, 0, "Int")
    mouseY := NumGet(cursorPoint, 4, "Int")

    for dropdown in UIDarkDropdowns {
        if (
            dropdown.IsOpen
            && UIHwndContainsScreenPoint(
                dropdown.PopupGui.Hwnd,
                mouseX,
                mouseY
            )
        ) {
            dropdown.Scroll(
                delta > 0 ? 1 : -1
            )
            return 0
        }
    }
}


StartDarkDropdownSystem() {
    global UIDarkDropdownTimerStarted


    if UIDarkDropdownTimerStarted {
        return
    }


    UIDarkDropdownTimerStarted :=
        true


    SetTimer(
        PollDarkDropdowns,
        16
    )
}


PollDarkDropdowns() {
    global UIDarkDropdowns
    global UIDarkActiveDropdown
    global UIDarkDropdownMouseWasDown


    cursorPoint := Buffer(8, 0)


    if !DllCall(
        "GetCursorPos",
        "Ptr", cursorPoint.Ptr,
        "Int"
    ) {
        return
    }


    mouseX := NumGet(cursorPoint, 0, "Int")
    mouseY := NumGet(cursorPoint, 4, "Int")


    activeOpenDropdown := ""

    if IsObject(UIDarkActiveDropdown) {
        try {
            if UIDarkActiveDropdown.IsOpen {
                activeOpenDropdown := UIDarkActiveDropdown
            }
        }
    }


    popupHoverBlocked := false

    if IsObject(activeOpenDropdown) {
        try popupHoverBlocked := activeOpenDropdown.PopupContainsScreenPoint(
            mouseX,
            mouseY
        )
    }


    activeDropdowns := []


    for dropdown in UIDarkDropdowns {
        guiHwnd := 0

        try guiHwnd := dropdown.Gui.Hwnd

        ; Keep dropdowns registered while their owner GUI is hidden during
        ; construction. WinExist() can report hidden windows as missing and
        ; previously caused some dropdown/list hover states to disappear
        ; permanently before the GUI was first shown.
        if (
            !guiHwnd
            || !DllCall(
                "IsWindow",
                "Ptr",
                guiHwnd,
                "Int"
            )
        ) {
            continue
        }

        ; Do not permanently unregister a valid dropdown because of a single
        ; visual refresh during a show/hide or item-update transition.
        activeDropdowns.Push(dropdown)

        if IsObject(activeOpenDropdown) {
            isActiveDropdown := false

            try {
                isActiveDropdown := (
                    dropdown.PopupGui.Hwnd
                    = activeOpenDropdown.PopupGui.Hwnd
                )
            }

            if isActiveDropdown || !popupHoverBlocked {
                ; Outside the active popup, every dropdown keeps normal hover.
                ; Inside it, only the active dropdown may respond so controls
                ; physically underneath the popup cannot light up through it.
                try dropdown.UpdateHover(
                    mouseX,
                    mouseY
                )
            }
            else {
                try dropdown.UpdateHover(
                    -2147483648,
                    -2147483648
                )
            }
        }
        else {
            try dropdown.UpdateHover(
                mouseX,
                mouseY
            )
        }
    }


    UIDarkDropdowns := activeDropdowns


    leftDown :=
        GetKeyState(
            "LButton",
            "P"
        )


    if (
        leftDown
        && !UIDarkDropdownMouseWasDown
    ) {

        for dropdown in UIDarkDropdowns {

            if (
                dropdown.IsOpen
                && !dropdown.ContainsScreenPoint(
                    mouseX,
                    mouseY
                )
            ) {

                dropdown.Close()
            }
        }
    }


    UIDarkDropdownMouseWasDown :=
        leftDown
}


UIHwndContainsScreenPoint(
    hwnd,
    screenX,
    screenY
) {
    if !hwnd {
        return false
    }


    rect := Buffer(16, 0)


    if !DllCall(
        "GetWindowRect",
        "Ptr", hwnd,
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


CloseOtherDarkDropdowns(
    exceptDropdown := ""
) {
    global UIDarkDropdowns


    for dropdown in UIDarkDropdowns {

        if IsObject(exceptDropdown) {
            try {
                if dropdown.PopupGui.Hwnd = exceptDropdown.PopupGui.Hwnd {
                    continue
                }
            }
        }


        if dropdown.IsOpen {
            dropdown.Close()
        }
    }
}


CloseAllDarkDropdowns() {
    global UIDarkDropdowns


    for dropdown in UIDarkDropdowns {

        if dropdown.IsOpen {
            dropdown.Close()
        }
    }
}
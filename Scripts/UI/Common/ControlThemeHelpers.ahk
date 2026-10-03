#Requires AutoHotkey v2.0

; v3 file note: Applies dark window/control styling and updates the launcher status text.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

ApplyModernWindowStyle() {
    global LauncherGui


    ApplyDarkWindowStyle(
        LauncherGui
    )
}


ApplyDarkWindowStyle(
    guiObject
) {
    try {

        darkMode :=
            Buffer(
                4,
                0
            )


        NumPut(
            "Int",
            1,
            darkMode,
            0
        )


        DllCall(
            "dwmapi\DwmSetWindowAttribute",
            "Ptr",
            guiObject.Hwnd,
            "Int",
            20,
            "Ptr",
            darkMode.Ptr,
            "Int",
            4
        )
    }


    try {

        cornerPreference :=
            Buffer(
                4,
                0
            )


        NumPut(
            "Int",
            2,
            cornerPreference,
            0
        )


        DllCall(
            "dwmapi\DwmSetWindowAttribute",
            "Ptr",
            guiObject.Hwnd,
            "Int",
            33,
            "Ptr",
            cornerPreference.Ptr,
            "Int",
            4
        )
    }
}


ApplyDarkControlTheme(
    control
) {
    global UIColorInputBackground
    global UIColorInputText


    if !control {

        return
    }


    ; Use a flat native edit surface and let our custom Progress border
    ; provide the outline. This keeps every input consistent with the
    ; rest of the dark UI instead of inheriting a Windows light edge.
    try {
        control.Opt(
            "-Border -E0x200 -VScroll -HScroll c"
            . UIColorInputText
            . " Background"
            . UIColorInputBackground
        )
    }


    ; Remove the native horizontal/vertical scrollbar style bits directly.
    ; Some Windows themes can keep drawing the small up/down arrow chrome
    ; on Edit controls even after -VScroll/-HScroll has been applied.
    try {
        style := DllCall(
            "GetWindowLongPtr",
            "Ptr",
            control.Hwnd,
            "Int",
            -16,
            "Ptr"
        )

        style &= ~0x00300000

        DllCall(
            "SetWindowLongPtr",
            "Ptr",
            control.Hwnd,
            "Int",
            -16,
            "Ptr",
            style,
            "Ptr"
        )

        DllCall(
            "SetWindowPos",
            "Ptr",
            control.Hwnd,
            "Ptr",
            0,
            "Int",
            0,
            "Int",
            0,
            "Int",
            0,
            "Int",
            0,
            "UInt",
            0x37
        )
    }


    try {

        DllCall(
            "uxtheme\SetWindowTheme",
            "Ptr",
            control.Hwnd,
            "Str",
            "DarkMode_Explorer",
            "Str",
            ""
        )
    }


    try {

        DllCall(
            "RedrawWindow",
            "Ptr",
            control.Hwnd,
            "Ptr",
            0,
            "Ptr",
            0,
            "UInt",
            0x85
        )
    }
}


UpdateStatus(
    text,
    color := ""
) {
    global StatusText
    global StatusIndicator
    global UIColorSuccess


    if !StatusText {
        return
    }


    if color = "" {
        color := UIColorSuccess
    }


    try StatusText.Move(43, 414, 238, 18)
    try SetUIProgressColor(StatusIndicator, color)


    StatusText.SetFont("c" . color)
    StatusText.Text := text
}



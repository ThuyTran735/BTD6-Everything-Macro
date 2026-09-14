#Requires AutoHotkey v2.0


PositionLauncher() {
    global LauncherGui

    global GuiWidth
    global GuiHeight

    global GuiX
    global GuiY


    screenLeft := 0
    screenTop := 0
    screenRight := 1920
    screenBottom := 1080


    windowWidth := GuiWidth
    windowHeight := GuiHeight


    rect := Buffer(
        16,
        0
    )


    gotRect := DllCall(
        "GetWindowRect",
        "Ptr",
        LauncherGui.Hwnd,
        "Ptr",
        rect.Ptr,
        "Int"
    )


    if gotRect {

        rectLeft := NumGet(
            rect,
            0,
            "Int"
        )


        rectTop := NumGet(
            rect,
            4,
            "Int"
        )


        rectRight := NumGet(
            rect,
            8,
            "Int"
        )


        rectBottom := NumGet(
            rect,
            12,
            "Int"
        )


        measuredWidth :=
            rectRight - rectLeft


        measuredHeight :=
            rectBottom - rectTop


        if measuredWidth > 0 {
            windowWidth := measuredWidth
        }


        if measuredHeight > 0 {
            windowHeight := measuredHeight
        }
    }


    GuiX := screenLeft

    GuiY :=
        screenBottom
        - windowHeight


    if GuiX < screenLeft {
        GuiX := screenLeft
    }


    if GuiY < screenTop {
        GuiY := screenTop
    }


    if (
        GuiX
        + windowWidth
        > screenRight
    ) {
        GuiX :=
            screenRight
            - windowWidth
    }


    if (
        GuiY
        + windowHeight
        > screenBottom
    ) {
        GuiY :=
            screenBottom
            - windowHeight
    }


    GuiX := Round(
        GuiX
    )


    GuiY := Round(
        GuiY
    )
}


ShowLauncher(
    activate := false
) {
    global LauncherGui

    global GuiWidth
    global GuiHeight

    global GuiX
    global GuiY


    PositionLauncher()


    options :=
        "x"
        . GuiX
        . " y"
        . GuiY
        . " w"
        . GuiWidth
        . " h"
        . GuiHeight


    if !activate {
        options :=
            "NA "
            . options
    }


    LauncherGui.Show(
        options
    )
}


HideLauncher() {
    global LauncherGui


    if IsLauncherVisible() {
        LauncherGui.Hide()
    }
}


IsLauncherVisible() {
    global LauncherGui


    if !LauncherGui {
        return false
    }


    return !!DllCall(
        "IsWindowVisible",
        "Ptr",
        LauncherGui.Hwnd
    )
}


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
        darkMode := Buffer(
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
        cornerPreference := Buffer(
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
    if !control {
        return
    }


    try {
        DllCall(
            "uxtheme\SetWindowTheme",
            "Ptr",
            control.Hwnd,
            "Str",
            "DarkMode_Explorer",
            "Ptr",
            0
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
    global UIColorSuccess


    if !StatusText {
        return
    }


    if color = "" {
        color := UIColorSuccess
    }


    StatusText.SetFont(
        "c"
        . color
    )


    StatusText.Text := text
}


IsInGameScreen() {
    global NavigationPatterns


    if !NavigationPatterns.Has(
        "Settings"
    ) {
        return false
    }


    return PatternExists(
        NavigationPatterns[
            "Settings"
        ]
    )
}


MonitorLauncherState() {
    global MacroRunning
    global RunningPid
    global LauncherGui

    global UIColorSuccess


    if MacroRunning {

        if (
            RunningPid
            && !ProcessExist(
                RunningPid
            )
        ) {
            MacroRunning := false
            RunningPid := 0


            UpdateStatus(
                "READY",
                UIColorSuccess
            )
        }
        else {

            if IsLauncherVisible() {
                LauncherGui.Hide()
            }


            return
        }
    }


    if IsInGameScreen() {

        if IsLauncherVisible() {
            LauncherGui.Hide()
        }


        return
    }


    if !IsLauncherVisible() {
        ShowLauncher(
            false
        )
    }
}
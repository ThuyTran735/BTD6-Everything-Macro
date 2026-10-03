#Requires AutoHotkey v2.0

; v3 file note: Keeps launcher placement and its small positioning helpers together.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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


    windowWidth :=
        GuiWidth


    windowHeight :=
        GuiHeight


    rect :=
        Buffer(
            16,
            0
        )


    gotRect :=
        DllCall(
            "GetWindowRect",
            "Ptr",
            LauncherGui.Hwnd,
            "Ptr",
            rect.Ptr,
            "Int"
        )


    if gotRect {

        rectLeft :=
            NumGet(
                rect,
                0,
                "Int"
            )


        rectTop :=
            NumGet(
                rect,
                4,
                "Int"
            )


        rectRight :=
            NumGet(
                rect,
                8,
                "Int"
            )


        rectBottom :=
            NumGet(
                rect,
                12,
                "Int"
            )


        measuredWidth :=
            rectRight
            - rectLeft


        measuredHeight :=
            rectBottom
            - rectTop


        if measuredWidth > 0 {

            windowWidth :=
                measuredWidth
        }


        if measuredHeight > 0 {

            windowHeight :=
                measuredHeight
        }
    }


    GuiX :=
        screenLeft


    GuiY :=
        screenBottom
        - windowHeight


    if GuiX < screenLeft {

        GuiX :=
            screenLeft
    }


    if GuiY < screenTop {

        GuiY :=
            screenTop
    }


    if GuiX + windowWidth > screenRight {

        GuiX :=
            screenRight
            - windowWidth
    }


    if GuiY + windowHeight > screenBottom {

        GuiY :=
            screenBottom
            - windowHeight
    }


    GuiX :=
        Round(
            GuiX
        )


    GuiY :=
        Round(
            GuiY
        )
}



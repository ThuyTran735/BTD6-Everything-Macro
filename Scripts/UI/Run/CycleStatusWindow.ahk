#Requires AutoHotkey v2.0

; v3 file note: Builds and shows the small run-status HUD.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

CreateCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText
    global CycleCancelButton

    global CycleProgressText
    global CycleProgressBar
    global CycleProgressBackground

    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorControlBorder
    global UIColorPanelBorder


    if CycleStatusGui {

        try {
            CycleStatusGui.Destroy()
        }
    }


    CycleStatusGui := ""
    CycleStatusText := ""
    CycleProgressText := ""
    CycleProgressBar := ""
    CycleProgressBackground := ""
    CycleCancelButton := ""


    hudWidth := 420
    hudHeight := 98


    CycleStatusGui :=
        Gui(
            "+AlwaysOnTop -Caption +ToolWindow -Border",
            ""
        )


    CycleStatusGui.BackColor :=
        UIColorBackground


    CycleStatusGui.MarginX := 0
    CycleStatusGui.MarginY := 0


    AddCustomWindowBorder(CycleStatusGui, hudWidth, hudHeight, 3)
    AddUICard(CycleStatusGui, 8, 8, 404, 82)


    ; Keep the run information together in one compact status block.
    SetUIHeadingFont(
        CycleStatusGui,
        9,
        UIColorPrimaryText
    )


    CycleStatusText :=
        CycleStatusGui.Add(
            "Text",
            "x20 y17 w248 h24 Center +0x200 c"
            . UIColorPrimaryText
            . " BackgroundTrans",
            "CYCLE 1 / 1"
        )


    SetUIBodyFont(
        CycleStatusGui,
        8,
        UIColorSecondaryText
    )


    CycleProgressText :=
        CycleStatusGui.Add(
            "Text",
            "x20 y42 w248 h18 Center +0x200 c"
            . UIColorSecondaryText
            . " BackgroundTrans",
            "1 CYCLE LEFT"
        )


    CycleProgressBackground :=
        CycleStatusGui.Add(
            "Progress",
            "x20 y68 w248 h8 c"
            . UIColorControlBorder
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            100
        )


    CycleProgressBar :=
        CycleStatusGui.Add(
            "Progress",
            "x20 y68 w248 h8 Range0-100 c"
            . UIColorAccent
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            0
        )


    ; Quiet divider between run progress and the stop action.
    CycleStatusGui.Add(
        "Progress",
        "x278 y18 w1 h62 c"
        . UIColorPanelBorder
        . " Background"
        . UIColorPanelBorder
        . " Disabled",
        100
    )


    CycleCancelButton :=
        CreateDarkButton(
            CycleStatusGui,
            292,
            26,
            104,
            46,
            "CLOSE RUN",
            7
        )


    CreateHelpBadgeForButton(
        CycleStatusGui,
        CycleCancelButton,
        "CLOSE RUN",
        "Stops the active run.`n`nIf a queue is running, the entire queue stops and later jobs will not start."
    )


    CycleCancelButton.OnEvent(
        "Click",
        RequestCancelMacroCycles
    )


    CycleStatusGui.Show(
        "Hide w"
        . hudWidth
        . " h"
        . hudHeight
    )


    ApplyDarkWindowStyle(
        CycleStatusGui
    )
}


ShowCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusLastX
    global CycleStatusLastY
    global CycleStatusRightPanelOpen
    global CycleStatusRightPanelMisses


    if !CycleStatusGui {

        CreateCycleStatusUI()
    }


    CycleStatusRightPanelOpen := false
    CycleStatusRightPanelMisses := 0


    SetTimer(
        UpdateCycleStatusPosition,
        0
    )


    hudWidth := 420
    hudHeight := 98


    ; Center when safe, but never cover the round-number OCR region. This
    ; also handles a right-side upgrade panel immediately when the HUD opens.
    hudX := GetCycleStatusTargetX(hudWidth)
    hudY := 8


    CycleStatusGui.Show(
        "NA x"
        . hudX
        . " y"
        . hudY
        . " w"
        . hudWidth
        . " h"
        . hudHeight
    )


    CycleStatusLastX := hudX
    CycleStatusLastY := hudY


    UpdateCycleStatusUI()


    ; Panel detection uses FindText and can take longer than normal UI hover
    ; work. Give this timer a lower thread priority so it cannot interrupt a
    ; custom-control paint halfway through and expose a gray intermediate
    ; Progress layer for a frame.
    SetTimer(
        UpdateCycleStatusPosition,
        100,
        -10
    )
}



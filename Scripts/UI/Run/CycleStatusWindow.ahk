#Requires AutoHotkey v2.0

; Draws the compact run HUD. Showing it also hands ownership back to the
; position and click-guard timers; shutdown guards must stay in that sequence.

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


    AddCustomWindowBorder(CycleStatusGui, hudWidth, hudHeight, 1)


    ; Use the same card and heading as the launcher for every run type.
    ; Infinite runs keep this layout when the percentage bar is hidden.
    AddUICard(CycleStatusGui, 12, 10, 268, 78)
    AddUICard(CycleStatusGui, 288, 10, 120, 78)
    CycleStatusText := AddUIOutlinedText(
        CycleStatusGui, "CYCLE 1 / 1", 24, 16, 244, 22, 9, "Center"
    )


    SetUIBodyFont(
        CycleStatusGui,
        8,
        UIColorSecondaryText
    )


    CycleProgressText :=
        CycleStatusGui.Add(
            "Text",
            "x24 y39 w244 h18 Center +0x200 c"
            . UIColorSecondaryText
            . " BackgroundTrans",
            "1 CYCLE LEFT"
        )


    ; Keep the emergency shortcut with the status text instead of
    ; leaving it floating below the progress bar.
    SetUIBodyFont(
        CycleStatusGui,
        7,
        UIColorSecondaryText
    )


    CycleStatusGui.Add(
        "Text",
        "x24 y60 w244 h14 Center +0x200 c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Emergency Stop: Ctrl + Shift + X"
    )


    CycleProgressBackground :=
        CycleStatusGui.Add(
            "Progress",
            "x24 y78 w244 h4 -0x800000 -E0x200 -E0x20000 c"
            . UIColorControlBorder
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            100
        )


    CycleProgressBar :=
        CycleStatusGui.Add(
            "Progress",
            "x24 y78 w244 h4 -0x800000 -E0x200 -E0x20000 Range0-100 c"
            . UIColorAccent
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            0
        )


    CycleCancelButton :=
        CreateDarkButton(
            CycleStatusGui,
            296,
            28,
            104,
            42,
            "CLOSE RUN",
            8
        )


    CreateHelpBadgeForButton(
        CycleStatusGui,
        CycleCancelButton,
        "CLOSE RUN",
        "Stops the active run after confirmation.`n`nIf a queue is running, the entire queue stops and later jobs will not start.`n`nFor an immediate stop without confirmation, press Ctrl + Shift + X."
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
    global CycleStatusHudEnabled
    global CycleStatusSuppressedForMapClick
    global CycleStatusClosing


    ; A new run owns the HUD again. Clear the shutdown guard before the GUI
    ; is created/shown so normal multi-cycle runs can continue using it.
    CycleStatusClosing := false


    if !CycleStatusGui {

        CreateCycleStatusUI()
    }


    CycleStatusRightPanelOpen := false
    CycleStatusRightPanelMisses := 0
    CycleStatusHudEnabled := true
    CycleStatusSuppressedForMapClick := false

    ClearCycleStatusClickGuardRequest()
    SetCycleStatusClickGuardActive(true, CycleStatusGui.Hwnd)


    SetTimer(
        UpdateCycleStatusPosition,
        0
    )


    SetTimer(
        MonitorCycleStatusClickGuard,
        0
    )


    hudWidth := 420
    hudHeight := 98


    ; Center when safe, but never cover the round-number OCR region. This
    ; also handles a right-side upgrade panel immediately when the HUD opens.
    hudX := GetCycleStatusTargetX(hudWidth)
    hudY := 8

    ; Prepare continuous/count/retry text while hidden, so a new run never
    ; flashes the placeholder CYCLE 1 / 1 frame first.
    UpdateCycleStatusUI()

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


    ; Panel detection uses FindText and can take longer than normal UI hover
    ; work. Give this timer a lower thread priority so it cannot interrupt a
    ; custom-control paint halfway through and expose a gray intermediate
    ; Progress layer for a frame.
    SetTimer(
        UpdateCycleStatusPosition,
        100,
        -10
    )


    ; Map scripts run in a child AHK process. Check their tiny hide request
    ; file often enough that the HUD is gone before a guarded tower click.
    SetTimer(
        MonitorCycleStatusClickGuard,
        20,
        -5
    )
}

#Requires AutoHotkey v2.0

; v3 file note: Moves the HUD around the right-side upgrade panel without mixing that math into drawing code.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

IsRightUpgradePanelOpen() {
    global SellButtonPattern


    ; Detect the visible right-side upgrade panel directly, but only search
    ; the portion of the screen where that panel can actually exist. The Cycle
    ; HUD lives at the very top of the screen, so excluding that area prevents
    ; FindText from repeatedly capturing/scanning the HUD itself and cuts the
    ; amount of work substantially.
    searchLeft := Floor(A_ScreenWidth * 0.58)
    searchTop := Floor(A_ScreenHeight * 0.20)


    return !!FindText(
        &X,
        &Y,
        searchLeft,
        searchTop,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        SellButtonPattern
    )
}


UpdateCycleStatusRightPanelState() {
    global CycleStatusRightPanelOpen
    global CycleStatusRightPanelMisses


    if IsRightUpgradePanelOpen() {
        CycleStatusRightPanelOpen := true
        CycleStatusRightPanelMisses := 0
        return true
    }


    if CycleStatusRightPanelOpen {
        CycleStatusRightPanelMisses++

        ; FindText can miss a single frame while the game animates. Keep the
        ; HUD left through short misses so it does not blink back over the round
        ; number and then immediately move left again.
        if CycleStatusRightPanelMisses < 6 {
            return true
        }
    }


    CycleStatusRightPanelOpen := false
    CycleStatusRightPanelMisses := 0
    return false
}


GetCycleStatusTargetX(hudWidth, refreshPanelState := true) {
    global CycleStatusRightPanelOpen


    minX := 8
    maxX := Max(minX, A_ScreenWidth - hudWidth - 8)


    centerX := Floor((A_ScreenWidth - hudWidth) / 2)
    hudX := centerX


    rightPanelOpen := refreshPanelState
        ? UpdateCycleStatusRightPanelState()
        : CycleStatusRightPanelOpen


    if rightPanelOpen {
        hudX := centerX - 360
    }


    return Max(minX, Min(hudX, maxX))
}


UpdateCycleStatusPosition() {
    global CycleStatusGui
    global CycleStatusLastX
    global CycleStatusLastY
    if !CycleStatusGui {
        return
    }


    if !WinExist(
        "ahk_id "
        . CycleStatusGui.Hwnd
    ) {
        return
    }


    hudWidth := 420


    hudX := GetCycleStatusTargetX(hudWidth)
    hudY := 8


    if (
        hudX = CycleStatusLastX
        && hudY = CycleStatusLastY
    ) {
        return
    }


    try {
        WinMove(
            hudX,
            hudY,
            ,
            ,
            "ahk_id "
            . CycleStatusGui.Hwnd
        )
    }


    CycleStatusLastX := hudX
    CycleStatusLastY := hudY
}



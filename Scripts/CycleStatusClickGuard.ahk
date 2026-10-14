#Requires AutoHotkey v2.0

; Keeps map clicks from landing on the launcher Cycle HUD.
; The launcher and map strategy run in separate AHK processes. The launcher
; stores its HUD window handle here so the strategy can hide it immediately,
; then a tiny temp flag tells the launcher when it is safe to show it again.

GetCycleStatusClickGuardActivePath() {
    return A_Temp . "\\BTD6EverythingMacro_CycleHudActive.flag"
}

GetCycleStatusClickGuardRequestPath() {
    return A_Temp . "\\BTD6EverythingMacro_CycleHudHideUntil.flag"
}

GetCycleStatusClickGuardProcessId() {
    return DllCall("GetCurrentProcessId", "UInt")
}

WriteCycleStatusClickGuardFile(path, value) {
    tempPath := path . "." . GetCycleStatusClickGuardProcessId() . ".tmp"

    try FileDelete(tempPath)
    FileAppend(value, tempPath, "UTF-8")
    FileMove(tempPath, path, 1)
}

SetCycleStatusClickGuardActive(isActive, hudHwnd := 0) {
    activePath := GetCycleStatusClickGuardActivePath()

    if !isActive {
        try FileDelete(activePath)
        return
    }

    WriteCycleStatusClickGuardFile(
        activePath,
        GetCycleStatusClickGuardProcessId() . "|" . hudHwnd
    )
}

GetCycleStatusClickGuardInfo(&launcherPid, &hudHwnd) {
    launcherPid := 0
    hudHwnd := 0

    activePath := GetCycleStatusClickGuardActivePath()

    if !FileExist(activePath)
        return false

    try activeText := Trim(FileRead(activePath, "UTF-8"))
    catch {
        return false
    }

    parts := StrSplit(activeText, "|")

    try launcherPid := Integer(parts[1])
    catch {
        return false
    }

    ; Older guard files only stored the launcher PID. Keep that readable so a
    ; stale file never breaks a run while the launcher is being updated.
    if parts.Length >= 2 {
        try hudHwnd := Integer(parts[2])
        catch {
            hudHwnd := 0
        }
    }

    if launcherPid <= 0 || !ProcessExist(launcherPid) {
        try FileDelete(activePath)
        launcherPid := 0
        hudHwnd := 0
        return false
    }

    if hudHwnd > 0 {
        if !DllCall("IsWindow", "Ptr", hudHwnd) {
            hudHwnd := 0
        }
    }

    return true
}

IsCycleStatusClickGuardActive() {
    launcherPid := 0
    hudHwnd := 0
    return GetCycleStatusClickGuardInfo(&launcherPid, &hudHwnd)
}

ClearCycleStatusClickGuardRequest() {
    try FileDelete(GetCycleStatusClickGuardRequestPath())
}

IsCycleStatusClickGuardRequested() {
    requestPath := GetCycleStatusClickGuardRequestPath()

    if !FileExist(requestPath)
        return false

    try hideUntil := Integer(Trim(FileRead(requestPath, "UTF-8")))
    catch {
        return true
    }

    if hideUntil > A_TickCount
        return true

    try FileDelete(requestPath)
    return false
}

GetCycleStatusHudRect(hudHwnd, &rectX, &rectY, &rectW, &rectH) {
    rectX := 0
    rectY := 0
    rectW := 0
    rectH := 0

    if hudHwnd <= 0 || !DllCall("IsWindow", "Ptr", hudHwnd)
        return false

    rect := Buffer(16, 0)

    if !DllCall("GetWindowRect", "Ptr", hudHwnd, "Ptr", rect.Ptr)
        return false

    left := NumGet(rect, 0, "Int")
    top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int")
    bottom := NumGet(rect, 12, "Int")

    rectX := left
    rectY := top
    rectW := right - left
    rectH := bottom - top

    return rectW > 0 && rectH > 0
}

IsPointNearCycleStatusArea(x, y, margin := 75, hudHwnd := 0) {
    ; Prefer the HUD's real window rectangle. This automatically covers both
    ; its normal centered position and its shifted-left position when the
    ; right-side upgrade panel is open.
    if hudHwnd > 0 {
        rectX := 0
        rectY := 0
        rectW := 0
        rectH := 0

        if GetCycleStatusHudRect(
            hudHwnd,
            &rectX,
            &rectY,
            &rectW,
            &rectH
        ) {
            return IsPointInsideExpandedRect(
                x,
                y,
                rectX,
                rectY,
                rectW,
                rectH,
                margin
            )
        }
    }

    ; Fallback for an older launcher active flag that does not contain the HUD
    ; handle yet. Check both known HUD positions so either one remains safe.
    hudWidth := 420
    hudHeight := 98
    hudY := 8

    minX := 8
    maxX := Max(minX, A_ScreenWidth - hudWidth - 8)

    centerX := Max(
        minX,
        Min(
            Floor((A_ScreenWidth - hudWidth) / 2),
            maxX
        )
    )

    shiftedX := Max(
        minX,
        Min(centerX - 360, maxX)
    )

    return (
        IsPointInsideExpandedRect(
            x,
            y,
            centerX,
            hudY,
            hudWidth,
            hudHeight,
            margin
        )
        || IsPointInsideExpandedRect(
            x,
            y,
            shiftedX,
            hudY,
            hudWidth,
            hudHeight,
            margin
        )
    )
}

IsPointInsideExpandedRect(x, y, rectX, rectY, rectW, rectH, margin) {
    return (
        x >= rectX - margin
        && x <= rectX + rectW + margin
        && y >= rectY - margin
        && y <= rectY + rectH + margin
    )
}

HideCycleStatusHudWindow(hudHwnd) {
    if hudHwnd <= 0 || !DllCall("IsWindow", "Ptr", hudHwnd)
        return false

    ; Hide the launcher-owned HUD directly instead of hoping its polling timer
    ; runs before the strategy click. This removes the race that made the old
    ; file-only guard work sometimes and miss other times.
    DllCall("ShowWindow", "Ptr", hudHwnd, "Int", 0)

    ; Wait until Windows reports the HUD as hidden before allowing the map
    ; interaction to continue. Normally this finishes on the first check.
    Loop 20 {
        if !DllCall("IsWindowVisible", "Ptr", hudHwnd)
            return true

        Sleep(5)
    }

    return !DllCall("IsWindowVisible", "Ptr", hudHwnd)
}

RequestCycleStatusHideForPoint(x, y, holdMs := 500) {
    launcherPid := 0
    hudHwnd := 0

    if !GetCycleStatusClickGuardInfo(&launcherPid, &hudHwnd)
        return false

    if !IsPointNearCycleStatusArea(x, y, 75, hudHwnd)
        return false

    hideUntil := A_TickCount + Max(holdMs, 300)

    try {
        ; Write the hold request first. If the launcher timer runs while the
        ; child process is hiding the window, it will keep the HUD hidden.
        WriteCycleStatusClickGuardFile(
            GetCycleStatusClickGuardRequestPath(),
            hideUntil
        )
    }
    catch {
        return false
    }

    if hudHwnd > 0 {
        HideCycleStatusHudWindow(hudHwnd)
        Sleep(18)
    }
    else {
        ; Old active flag fallback. The launcher timer will process the request.
        Sleep(80)
    }

    return true
}

ClickMapPoint(x, y, holdMs := 500) {
    RequestCycleStatusHideForPoint(
        x,
        y,
        holdMs
    )

    Click(x, y)
    return true
}
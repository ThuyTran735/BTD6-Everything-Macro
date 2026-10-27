#Requires AutoHotkey v2.0

; Small shared input helpers so timing-sensitive key presses stay consistent.

SendEscapeAndWait(waitMs := 300) {
    ; BTD6's panel/menu close animation needs time to finish before the next
    ; scripted input. Never let an Esc settle for less than 300 ms.
    Send("{Esc}")
    Sleep(Max(300, waitMs))
}

IsTowerInputActive() {
    return !!WinActive("ahk_exe BloonsTD6.exe")
}

SendGameKey(hotkey, holdMs := 80) {
    ; Tower bindings are single letters or named keys such as {F6}.
    ; Hold the key across a few frames so a busy game can notice it.
    if RegExMatch(hotkey, "^\{([A-Za-z0-9]+)\}$", &match)
        key := match[1]
    else if StrLen(hotkey) = 1
        key := hotkey
    else
        throw Error("Expected one game key, got: " . hotkey)

    if !IsTowerInputActive()
        return false

    try {
        SendEvent("{" . key . " down}")
        Sleep(Max(40, holdMs))
    }
    finally {
        ; Release even if an interruption happens during the hold.
        SendEvent("{" . key . " up}")
    }

    return IsTowerInputActive()
}

SelectTowerForTargeting(x, y) {
    if !ClickTowerPoint(x, y)
        return SetRunFailureReason("TARGETING FAILED", "BTD6 lost focus while selecting the tower")

    ; Allow the panel to open before sending its first targeting key.
    Sleep(250)
    if !IsTowerInputActive()
        return SetRunFailureReason("TARGETING FAILED", "BTD6 lost focus before targeting")

    return true
}

SendTargetingSteps(stepCount) {
    ; Keep both key-down and key-up visible across multiple frames. A delay
    ; after an instantaneous Send alone does not make the press last longer.
    Loop stepCount {
        if !SendGameKey("{Tab}", 100)
            return SetRunFailureReason("TARGETING FAILED", "BTD6 lost focus during a targeting key")

        ; Include the last release gap before Escape or a manual aim action.
        Sleep(150)
        if !IsTowerInputActive()
            return SetRunFailureReason("TARGETING FAILED", "BTD6 lost focus after a targeting key")
    }

    ; Also check focus for a zero-step request. The displayed mode is not read.
    if !IsTowerInputActive()
        return SetRunFailureReason("TARGETING FAILED", "BTD6 lost focus before completing targeting")
    return true
}

ClickTowerPoint(x, y) {
    ; The existing ClickMapPoint holdMs controls HUD visibility, not the
    ; mouse button. Tower actions need an actual press that lasts a few frames.
    if !IsTowerInputActive()
        return false

    RequestCycleStatusHideForPoint(x, y, 750)
    if !IsTowerInputActive()
        return false

    previousCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    try {
        MouseMove(x, y, 0)
        if !IsTowerInputActive()
            return false

        try {
            SendEvent("{LButton down}")
            Sleep(70)
        }
        finally {
            SendEvent("{LButton up}")
        }
    }
    finally {
        CoordMode("Mouse", previousCoordMode)
    }

    return IsTowerInputActive()
}

RepeatMapClicks(x, y, count, intervalMs := 250) {
    ; Validate the whole action before sending any input. These are screen
    ; coordinates in the same 1920x1080 layout used by tower placements.
    if !TryNormalizeRepeatClickNumber(x, 0, 1919, &x) || !TryNormalizeRepeatClickNumber(y, 0, 1079, &y)
        return SetRunFailureReason("CLICK SEQUENCE FAILED", "X and Y must be inside the 1920x1080 game screen")
    if !TryNormalizeRepeatClickNumber(count, 1, 2147483647, &count)
        return SetRunFailureReason("CLICK SEQUENCE FAILED", "Click count must be a whole number from 1 to 2147483647")
    if !TryNormalizeRepeatClickNumber(intervalMs, 0, 2147483647, &intervalMs)
        return SetRunFailureReason("CLICK SEQUENCE FAILED", "Click interval must be a whole number from 0 to 2147483647")

    LogStrategyAction("Click (" . x . ", " . y . ") " . count . " times, " . intervalMs . " ms apart")
    lastStateCheck := 0
    Loop count {
        state := GetRepeatMapClickState(&lastStateCheck, A_Index = 1)
        if state != true
            return state

        ; Reuse the held click and HUD protection from tower placement.
        ; A failed click is not retried: it may already have reached the game.
        if !ClickTowerPoint(x, y)
            return SetRunFailureReason("CLICK SEQUENCE FAILED", "BTD6 lost focus during a click")

        if A_Index < count {
            state := WaitForRepeatMapClick(intervalMs, &lastStateCheck)
            if state != true
                return state
        }
    }
    return true
}

TryNormalizeRepeatClickNumber(value, minimum, maximum, &normalized) {
    if Type(value) = "Integer" {
        if value < minimum || value > maximum
            return false
        normalized := value
        return true
    }
    if Type(value) != "String"
        return false

    ; Comparing an oversized numeric string can wrap before the range check.
    ; Remove harmless padding, then bound the digits before converting it.
    digits := Trim(value)
    if !RegExMatch(digits, "^\+?[0-9]+$")
        return false
    digits := RegExReplace(digits, "^\+?0*", "")
    if digits = ""
        digits := "0"
    if StrLen(digits) > StrLen(maximum . "")
        return false

    number := Integer(digits)
    if number < minimum || number > maximum
        return false
    normalized := number
    return true
}

GetRepeatMapClickState(&lastStateCheck, forceCheck := false) {
    global IsPregame

    if !IsTowerInputActive()
        return SetRunFailureReason("CLICK SEQUENCE FAILED", "BTD6 lost focus")

    ; Short sequences should not pay for a full set of popup scans on every
    ; frame. Longer ones still hand victory/defeat back to the normal runner.
    ; Round-zero setup follows the runner's usual no-result-scan behavior.
    if !IsPregame && (forceCheck || A_TickCount - lastStateCheck >= 200) {
        state := CheckGameState()
        lastStateCheck := A_TickCount
        if state = "Victory" || state = "Defeat"
            return state
        if !IsTowerInputActive()
            return SetRunFailureReason("CLICK SEQUENCE FAILED", "BTD6 lost focus during a game-state check")
    }
    return true
}

WaitForRepeatMapClick(intervalMs, &lastStateCheck) {
    ; This is the gap after releasing one click, not an extra delay after the
    ; final click. Small sleeps keep focus checks and the stop hotkey responsive.
    deadline := A_TickCount + intervalMs
    Loop {
        remaining := deadline - A_TickCount
        if remaining <= 0
            break
        Sleep(Min(50, remaining))
        state := GetRepeatMapClickState(&lastStateCheck)
        if state != true
            return state
    }
    return true
}

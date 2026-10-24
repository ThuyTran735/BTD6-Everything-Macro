#Requires AutoHotkey v2.0

; Space toggles speed once the match has started. Fast requests are confirmed
; from the game icon, since a missed key press can leave the cached speed stale.

global CurrentGameSpeed := "Unknown"
global FastGameSpeedPattern := "|<>C0F801-0.90$74.0000000000000000000000000000000000000000000000000000000000000007000007000007z0000Dz00007Tw0007Tw0003UzU003UzU001s3y001k3y000Q0Tk00Q0Tk00D01y00D01y003k0Ds03k0Ds00s00z00s00z00C007s0S007s07U00z07U00z01s007s1s007s0S000T0S000T07U003sD0003s1s000T3k000S0S0003tw0003k70000Tz0000S1k0003zk0003UQ0000Tw0000Q700003z000031k0000Tk0000kQ00007w00004700000z000001k0000Dk00000Q00007w00004700001z000031k0000zk0000UA0000Tw0000M30000CD0000A0k00071k00060A00030Q0003030001U30001U0k000k0k000k0A000M0A000M01000A03000800E00400E00A004006004006001002001002000001000000000000000001000000U000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008"


ResetGameSpeedState() {
    global CurrentGameSpeed
    CurrentGameSpeed := "Unknown"
}


NormalizeGameSpeedMode(mode) {
    normalized := StrLower(Trim(mode))

    if normalized = "normal" || normalized = "1x"
        return "Normal"

    if normalized = "fast" || normalized = "3x"
        return "Fast"

    throw Error("Unknown game speed mode: " mode ". Use Normal or Fast.")
}


SetTrackedGameSpeed(mode) {
    global CurrentGameSpeed
    CurrentGameSpeed := NormalizeGameSpeedMode(mode)
    return CurrentGameSpeed
}


SetGameSpeed(mode) {
    global CurrentGameSpeed

    targetMode := NormalizeGameSpeedMode(mode)

    LogStrategyAction(
        "Game speed -> " . targetMode
    )

    ; StartGame() establishes the first known state. A speed action before
    ; that point would use Space as the Start Round hotkey instead of speed.
    if CurrentGameSpeed = "Unknown" {
        return SetRunFailureReason(
            "GAME SPEED FAILED",
            "Speed can only be changed after StartGame()"
        )
    }

    if !IsTowerInputActive()
        return FailGameSpeedChange("BTD6 must have focus before changing speed")

    ; A cached Fast value is not proof that the game accepted the last press.
    if targetMode = "Fast"
        return SetVerifiedFastGameSpeed()

    ; Normal keeps the existing tracked behavior; the supplied icon confirms Fast only.
    if CurrentGameSpeed = targetMode
        return true

    if !SendGameKey("{Space}")
        return FailGameSpeedChange("BTD6 lost focus while changing speed")
    Sleep(100)
    if !IsTowerInputActive()
        return FailGameSpeedChange("BTD6 lost focus while changing speed")

    CurrentGameSpeed := targetMode
    return true
}


SetVerifiedFastGameSpeed() {
    global CurrentGameSpeed

    state := CheckGameSpeedChangeState()
    if state != true
        return state
    fastVisible := IsFastGameSpeedVisible()
    if !IsTowerInputActive()
        return FailGameSpeedChange("BTD6 lost focus during the speed scan")
    if fastVisible {
        CurrentGameSpeed := "Fast"
        return true
    }

    ; Check after each press instead of queueing several toggles during lag.
    ; A missing/changed pattern must not leave the strategy toggling forever.
    Loop 5 {
        if !SendGameKey("{Space}")
            return FailGameSpeedChange("BTD6 lost focus while switching to Fast")
        Sleep(250)

        state := CheckGameSpeedChangeState()
        if state != true
            return state
        fastVisible := IsFastGameSpeedVisible()
        if !IsTowerInputActive()
            return FailGameSpeedChange("BTD6 lost focus during the speed scan")
        if fastVisible {
            CurrentGameSpeed := "Fast"
            return true
        }
    }
    return FailGameSpeedChange("Fast-speed icon was not detected after 5 Space presses (250 ms between checks)")
}

IsFastGameSpeedVisible() {
    global FastGameSpeedPattern
    ; The speed control sits in the lower-right HUD of the fixed 1920x1080 game.
    ; Capture a fresh frame; another FindText call may have cached an older one.
    return !!FindText(&iconX, &iconY, 1640, 800, 1919, 1079, 0, 0,
        FastGameSpeedPattern, 1, 0)
}

CheckGameSpeedChangeState() {
    if !IsTowerInputActive()
        return FailGameSpeedChange("BTD6 lost focus while checking game speed")
    state := CheckGameState()
    if state = "Victory" || state = "Defeat"
        return state
    if !IsTowerInputActive()
        return FailGameSpeedChange("BTD6 lost focus while checking game speed")
    return true
}

FailGameSpeedChange(detail) {
    global CurrentGameSpeed
    ; After an unconfirmed change, neither cached speed is safe to reuse.
    CurrentGameSpeed := "Unknown"
    return SetRunFailureReason("GAME SPEED FAILED", detail)
}


SetNormalGameSpeed() {
    return SetGameSpeed("Normal")
}


SetFastGameSpeed() {
    return SetGameSpeed("Fast")
}

#Requires AutoHotkey v2.0

; v3.1.1: Tracks the speed state that the macro itself selected.
; BTD6 uses Space to toggle between normal and fast speed once a round is running.

global CurrentGameSpeed := "Unknown"


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

    ; Do not toggle Space when we already know the game is at this speed.
    if CurrentGameSpeed = targetMode
        return true

    Send("{Space}")
    Sleep(100)

    CurrentGameSpeed := targetMode
    return true
}


SetNormalGameSpeed() {
    return SetGameSpeed("Normal")
}


SetFastGameSpeed() {
    return SetGameSpeed("Fast")
}

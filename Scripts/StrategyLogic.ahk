#Requires AutoHotkey v2.0

RunStrategy(actions) {
    for action in actions {
        targetRound := action[1]
        delayMs := action[2]
        callback := action[3]

        currentRound := GetValidatedRound()

        ; If this action belongs to a future round,
        ; wait until that round begins.
        if currentRound < targetRound {
            WaitForRound(targetRound)
            currentRound := GetValidatedRound()
        }

        ; If we are exactly on the target round,
        ; wait until the requested point in the round.
        if currentRound = targetRound && delayMs > 0 {
            WaitForRoundTime(delayMs)
        }

        ; If currentRound is already greater than targetRound,
        ; this is a catch-up action, so run it immediately.
        success := callback.Call()

        if success = false {
            ToolTip(
                "Strategy failed!"
                "`nRound: " targetRound
                "`nDelay: " delayMs " ms"
            )

            Sleep(2000)
            ToolTip()

            return false
        }
    }

    return true
}

WaitForRoundTime(targetMs) {
    Loop {
        elapsed := GetRoundElapsedTime()

        if elapsed >= targetMs
            return true

        ; Stop waiting if the round already changed.
        currentRound := GetValidatedRound()

        Sleep(20)
    }
}

UseAbility(hotkey) {
    Send(hotkey)
    return true
}
#Requires AutoHotkey v2.0

global IsPregame := false


RunPregameStrategy(actions) {
    global IsPregame

    IsPregame := true

    try {
        for action in actions {
            targetRound := action[1]
            delayMs := action[2]
            callback := action[3]

            if targetRound != 0
                continue

            ; Round 0:
            ; no OCR
            ; no CheckGameState
            ; no extra checks
            if delayMs > 0
                Sleep(delayMs)

            actionResult := callback.Call()

            if actionResult = false
                return false
        }

        return true
    }
    finally {
        IsPregame := false
    }
}


RunStrategy(actions) {
    for action in actions {
        targetRound := action[1]
        delayMs := action[2]
        callback := action[3]

        ; Round 0 was already handled before StartGame().
        if targetRound = 0
            continue


        ; Only ONE round read here.
        currentRound := GetValidatedRound()


        ; If we haven't reached the target yet,
        ; WaitForRound handles:
        ; - round OCR
        ; - victory
        ; - defeat
        if currentRound < targetRound {
            result := WaitForRound(targetRound)

            if result = "Victory"
                return "Victory"

            if result = "Defeat"
                return "Defeat"

            if result = false
                return false

            ; IMPORTANT:
            ; Do NOT OCR again.
            ; We already know the target round arrived.
            currentRound := targetRound
        }


        ; If this action has an in-round delay,
        ; wait for it.
        if currentRound = targetRound && delayMs > 0 {
            result := WaitForRoundTime(delayMs)

            if result = "Victory"
                return "Victory"

            if result = "Defeat"
                return "Defeat"

            if result = false
                return false
        }


        ; FIRE THE ACTION IMMEDIATELY.
        ;
        ; No CheckGameState here.
        ; No extra OCR here.
        actionResult := callback.Call()


        if actionResult = "Victory"
            return "Victory"

        if actionResult = "Defeat"
            return "Defeat"

        if actionResult = false
            return false
    }


    ; All scripted actions finished.
    ; Now we can watch for the end of the game.
    Loop {
        state := CheckGameState()

        if state = "Victory"
            return "Victory"

        if state = "Defeat"
            return "Defeat"

        Sleep(200)
    }
}


WaitForRoundTime(targetMs) {
    lastStateCheck := A_TickCount

    Loop {
        elapsed := GetRoundElapsedTime()

        if elapsed >= targetMs
            return true


        ; Keep round tracking updated.
        GetValidatedRound()


        ; Expensive Victory/Defeat FindText only every 200 ms.
        if A_TickCount - lastStateCheck >= 200 {
            lastStateCheck := A_TickCount

            state := CheckGameState()

            if state = "Victory"
                return "Victory"

            if state = "Defeat"
                return "Defeat"
        }


        Sleep(20)
    }
}


StartGame() {
    Send("{Space}")

    Sleep(100)

    Send("{Space}")

    Sleep(100)

    return true
}


UseAbility(hotkey) {
    Send(hotkey)

    return true
}
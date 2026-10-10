#Requires AutoHotkey v2.0


; v3 file note: Handles the Strategy part of the macro. Keep this focused so run bugs are easier to trace later.

global IsPregame := false
global CurrentStrategyTargetRound := 0
global CurrentStrategyRoundDetectedTick := 0
global CurrentStrategyRoundDetectedTimestamp := ""


MarkStrategyRoundDetected(targetRound) {
    global CurrentStrategyTargetRound
    global CurrentStrategyRoundDetectedTick
    global CurrentStrategyRoundDetectedTimestamp

    CurrentStrategyTargetRound := targetRound
    CurrentStrategyRoundDetectedTick := A_TickCount
    CurrentStrategyRoundDetectedTimestamp := GetLogTimestampMs()

    ; Round header is emitted before any callback/action logs. The helper
    ; deduplicates repeated actions on the same round.
    LogStrategyRoundHeader(targetRound)
}


RunPregameStrategy(actions) {
    global IsPregame


    IsPregame := true


    try {

        for action in actions {

            targetRound :=
                action[1]


            delayMs :=
                action[2]


            callback :=
                action[3]


            if targetRound != 0 {
                continue
            }


            ; Round 0:
            ; no OCR
            ; no CheckGameState
            ; no extra checks
            MarkStrategyRoundDetected(0)


            if delayMs > 0 {

                Sleep(
                    delayMs
                )
            }


            actionResult :=
                callback.Call()


            if actionResult = false {
                return EnsureRunFailureReason("PREGAME ACTION FAILED")
            }
        }


        return true
    }
    finally {
        IsPregame :=
            false
    }
}


RunStrategy(actions) {
    global LastRound


    for action in actions {

        targetRound :=
            action[1]


        delayMs :=
            action[2]


        callback :=
            action[3]


        ; Round 0 was already handled
        ; before StartGame().
        if targetRound = 0 {
            continue
        }


        ; Use the round already validated by the round tracker. Do not do an
        ; extra OCR pass here: when the next action targets a future round,
        ; WaitForRound() owns the timing-critical polling loop. This avoids
        ; paying for one full redundant FindText/OCR read before every wait.
        currentRound :=
            LastRound


        ; If we have not reached the target yet,
        ; WaitForRound handles:
        ;
        ; - round OCR
        ; - popup recovery
        ; - victory
        ; - defeat
        if currentRound < targetRound {

            result :=
                WaitForRound(
                    targetRound
                )


            if result = "Victory" {
                return "Victory"
            }


            if result = "Defeat" {
                return "Defeat"
            }


            if result = false {
                return false
            }


            ; Do not OCR again.
            ;
            ; We already know the target round arrived.
            currentRound :=
                targetRound
        }


        ; Capture the exact moment this scheduled round became eligible.
        ; Upgrade timing logs use this as their first timestamp.
        MarkStrategyRoundDetected(targetRound)


        ; If this action has an in-round delay,
        ; wait for it.
        if (
            currentRound = targetRound
            && delayMs > 0
        ) {

            result :=
                WaitForRoundTime(
                    delayMs
                )


            if result = "Victory" {
                return "Victory"
            }


            if result = "Defeat" {
                return "Defeat"
            }


            if result = false {
                return false
            }
        }


        ; Fire the action immediately.
        ;
        ; Do not add another OCR/state check here
        ; because timing-sensitive actions need to
        ; execute as soon as their wait finishes.
        actionResult :=
            callback.Call()


        if actionResult = "Victory" {
            return "Victory"
        }


        if actionResult = "Defeat" {
            return "Defeat"
        }


        if actionResult = false {
            return EnsureRunFailureReason("STRATEGY ACTION FAILED")
        }
    }


    ; Keep round scanning active while waiting for
    ; Victory/Defeat. This is important because an
    ; undetectable hero-unlock screen can appear near
    ; the end of a game, such as round 39/40 on Easy.
    ;
    ; GetValidatedRound() keeps the 1500 ms
    ; missing-round recovery alive, so the macro can
    ; still click the known bottom-right location
    ; five times and resume.
    Loop {

        GetValidatedRound()


        state :=
            CheckGameState()


        if state = "Victory" {
            return "Victory"
        }


        if state = "Defeat" {
            return "Defeat"
        }


        Sleep(
            200
        )
    }
}


WaitForRoundTime(targetMs) {

    lastStateCheck :=
        A_TickCount


    Loop {

        elapsed :=
            GetRoundElapsedTime()


        if elapsed >= targetMs {
            return true
        }


        ; Keep round tracking updated.
        ;
        ; This also keeps the unknown-screen
        ; 1500 ms recovery active.
        GetValidatedRound()


        ; Check game state every 200 ms.
        if (
            A_TickCount
            - lastStateCheck
            >= 200
        ) {

            lastStateCheck :=
                A_TickCount


            state :=
                CheckGameState()


            if state = "Victory" {
                return "Victory"
            }


            if state = "Defeat" {
                return "Defeat"
            }
        }


        Sleep(
            20
        )
    }
}


StartGame() {
    global RunConfig

    ; Apopalypse starts its rounds automatically, so Space only needs to be
    ; pressed once to switch the already-running game from normal to fast.
    ResetGameSpeedState()


    if (
        IsSet(RunConfig)
        && RunConfig.gameMode = "Apopalypse"
    ) {
        SetTrackedGameSpeed(
            "Normal"
        )


        Send(
            "{Space}"
        )


        Sleep(
            100
        )


        SetTrackedGameSpeed(
            "Fast"
        )


        return true
    }


    ; Normal modes still need the first Space to start the round and the
    ; second Space to switch BTD6 from normal to fast speed.
    Send(
        "{Space}"
    )


    Sleep(
        100
    )


    SetTrackedGameSpeed(
        "Normal"
    )


    Send(
        "{Space}"
    )


    Sleep(
        100
    )


    SetTrackedGameSpeed(
        "Fast"
    )


    return true
}


UseAbility(hotkey) {

    LogStrategyAction(
        "Use ability " . hotkey
    )


    Send(
        hotkey
    )


    return true
}
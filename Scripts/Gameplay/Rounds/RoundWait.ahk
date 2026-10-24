#Requires AutoHotkey v2.0

; Waits for validated target rounds and records when each round began.
; Readable counters take the fast path; interruption recovery is reserved for missing reads.

WaitForRound(
    targetRound
) {
    global LastRound
    global RoundReadMissingSince


    startingRound :=
        GetStartingRound()


    finalRound :=
        GetFinalRound()


    if targetRound < startingRound {

        throw Error(
            "Round "
            . targetRound
            . " is before this mode's starting round "
            . startingRound
            . "."
        )
    }


    if targetRound > finalRound {

        throw Error(
            "Round "
            . targetRound
            . " is after this mode's final round "
            . finalRound
            . "."
        )
    }


    lastStateCheck :=
        0


    Loop {

        ; Keep the hot path focused on round detection. Full-screen popup /
        ; victory / defeat scans are intentionally skipped while the round
        ; counter is readable because those scans can take long enough to
        ; delay a scheduled action by seconds.
        detectedRound :=
            GetCurrentRound()


        if detectedRound {

            ResetRoundReadFailureTracking()


            ; Never bypass ValidateRound() for an exact target match. A single
            ; bad OCR frame that happens to equal the scheduled round must not
            ; fire the action early. Normal +1 transitions need only two
            ; matching reads, so the safety cost is roughly one polling cycle.


            currentRound :=
                ValidateRound(
                    detectedRound
                )


            if currentRound >= targetRound {
                return true
            }


            ; Banana Farm collection is lowest priority. Only collect when a
            ; valid round is visible and the strategy is otherwise just
            ; waiting for a future round. The collector hovers one eligible Farm
            ; for 300 ms, then control returns here before the next Farm.
            ;
            ; Do NOT run CheckGameState() after every Farm. Its full-screen
            ; FindText scans are much slower than round OCR and used to turn a
            ; 300 ms Farm rotation into several seconds. If a popup covers the
            ; round counter, GetCurrentRound() will fail on the next pass and the
            ; existing missing-round recovery below will handle that popup.
            if CollectBananasWhileIdle() {
                Sleep(5)
                continue
            }


            Sleep(
                20
            )


            continue
        }


        ; The round display is actually missing. Keep the existing delayed
        ; unknown-popup recovery alive, but do not launch expensive full-
        ; screen state scans for a brief normal transition.
        HandleMissingRoundRead()


        ; Glacial Trail can legitimately lose the round glyph to snow/particle
        ; interference. If its map-specific recovery inferred the exact target
        ; round, let the strategy action run immediately instead of waiting for
        ; the OCR to become readable again.
        if LastRound >= targetRound {
            return true
        }


        if (
            RoundReadMissingSince != 0
            && A_TickCount - RoundReadMissingSince >= 350
            && (
                lastStateCheck = 0
                || A_TickCount - lastStateCheck >= 500
            )
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



WaitForFinalRound() {
    return WaitForRound(
        GetFinalRound()
    )
}


GetRoundElapsedTime() {
    global RoundStartTick


    if RoundStartTick = 0 {
        return 0
    }


    return A_TickCount
        - RoundStartTick
}


ResetRoundTracking() {
    global LastRound
    global LastWeirdRead
    global WeirdReadCount
    global WeirdReadActive
    global LastAcceptedRoundRead
    global LastRoundOcrRepairLogKey
    global LastGlacialRejectedOcrLogKey
    global LastGlacialFallbackLogRound
    global GlacialLastInferredRound
    global GlacialPostRecoveryResyncActive
    global GlacialPostRecoveryResyncTick
    global RoundStartTick
    global LastTrackedRound
    global RoundReadMissingSince


    LastRound :=
        GetStartingRound()
        - 1


    LastWeirdRead :=
        0


    WeirdReadCount :=
        0


    WeirdReadActive :=
        false


    LastAcceptedRoundRead :=
        0


    LastRoundOcrRepairLogKey :=
        ""


    LastGlacialRejectedOcrLogKey :=
        ""


    LastGlacialFallbackLogRound :=
        0


    GlacialLastInferredRound :=
        0


    GlacialPostRecoveryResyncActive :=
        false


    GlacialPostRecoveryResyncTick :=
        0


    RoundStartTick :=
        0


    LastTrackedRound :=
        LastRound


    RoundReadMissingSince :=
        0
}
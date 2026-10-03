#Requires AutoHotkey v2.0

; v3 file note: Validates round movement and keeps the tracker from jumping on noisy OCR.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

TrackRoundStart() {
    global LastRound
    global LastTrackedRound
    global RoundStartTick


    if LastTrackedRound != LastRound {

        LastTrackedRound :=
            LastRound


        RoundStartTick :=
            A_TickCount


        LogStrategyRoundHeader(
            LastRound
        )
    }
}


ValidateRound(
    detectedRound
) {
    global LastRound
    global LastWeirdRead
    global WeirdReadCount
    global WeirdReadActive
    global LastAcceptedRoundRead
    global RoundStartTick
    global GlacialPostRecoveryResyncActive
    global GlacialPostRecoveryResyncTick


    finalRound :=
        GetFinalRound()


    startingRound :=
        GetStartingRound()


    ; Startup is special. Pregame actions run before StartGame(), so round
    ; tracking is reset to startRound - 1. The first readable in-game round
    ; confirms that gameplay has started, but the configured startRound is
    ; authoritative. Remember the raw OCR value as the visual signature for
    ; that starting round so a persistent bad read cannot advance again.
    if LastRound < startingRound {

        if (
            detectedRound >= startingRound
            && detectedRound <= finalRound
        ) {

            LastRound :=
                startingRound


            LastAcceptedRoundRead :=
                detectedRound


            ResetWeirdReads()
            TrackRoundStart()


            if detectedRound != startingRound {
                LogMessage(
                    "ROUND",
                    "Startup OCR read "
                    . detectedRound
                    . "; initialized configured start round "
                    . startingRound
                )
            }


            return LastRound
        }


        return LastRound
    }


    ; The exact same raw OCR value that represented the current validated
    ; round cannot represent another new round. This is the key guard for a
    ; stable misread such as visible round 10 repeatedly being read as 14.
    if (
        LastAcceptedRoundRead
        && detectedRound = LastAcceptedRoundRead
    ) {
        ResetWeirdReads()
        return LastRound
    }


    difference :=
        detectedRound
        - LastRound


    ; After Glacial Trail popup recovery, the pause/overlay may have hidden
    ; several round transitions. If OCR comes back a few rounds ahead, catch
    ; up one validated round at a time rather than permanently rejecting the
    ; later reads. Require two matching reads for each inferred step.
    if (
        IsGlacialTrailRun()
        && GlacialPostRecoveryResyncActive
    ) {
        ; Keep recovery mode available long enough for a slow late-game round.
        ; A clean +1 read clears it immediately, so this longer timeout only
        ; matters when the popup hid several consecutive round transitions.
        if (
            GlacialPostRecoveryResyncTick != 0
            && A_TickCount - GlacialPostRecoveryResyncTick > 120000
        ) {
            GlacialPostRecoveryResyncActive := false
            GlacialPostRecoveryResyncTick := 0
        }
        else if (
            difference > 1
            && difference <= 5
        ) {
            if (
                !WeirdReadActive
                || detectedRound != LastWeirdRead
            ) {
                WeirdReadActive := true
                LastWeirdRead := detectedRound
                WeirdReadCount := 1
                return LastRound
            }


            WeirdReadCount++


            if WeirdReadCount < 2 {
                return LastRound
            }


            inferredRound :=
                LastRound + 1


            LogMessage(
                "ROUND",
                "Glacial Trail post-recovery resync: detected="
                . detectedRound
                . ", advancing "
                . LastRound
                . " -> "
                . inferredRound
            )


            LastRound :=
                inferredRound


            ; Keep the later OCR value available for the next sequential
            ; catch-up step instead of latching it to the inferred round.
            LastAcceptedRoundRead :=
                0


            TrackRoundStart()
            ResetWeirdReads()


            if LastRound >= detectedRound {
                GlacialPostRecoveryResyncActive := false
                GlacialPostRecoveryResyncTick := 0
            }


            return LastRound
        }
    }


    ; A clean sequential read is the normal path. Confirm it twice so one
    ; bad frame cannot fire the next round's actions early.
    if difference = 1 {

        if (
            !WeirdReadActive
            || detectedRound != LastWeirdRead
        ) {
            WeirdReadActive := true
            LastWeirdRead := detectedRound
            WeirdReadCount := 1
            return LastRound
        }


        WeirdReadCount++


        if WeirdReadCount < 2 {
            return LastRound
        }


        LastRound :=
            detectedRound


        LastAcceptedRoundRead :=
            detectedRound


        if GlacialPostRecoveryResyncActive {
            GlacialPostRecoveryResyncActive := false
            GlacialPostRecoveryResyncTick := 0
        }


        TrackRoundStart()
        ResetWeirdReads()
        return LastRound
    }


    ; Ignore stale/lower reads. They can happen while the round text animates
    ; and should never move strategy time forward.
    if difference <= 0 {
        ResetWeirdReads()
        return LastRound
    }


    ; A stable +2 read means exactly one displayed round was missed while
    ; OCR was unreadable. Confirm it several times, then catch up directly.
    ; Example: validated 6, first readable counter is 8 -> accept round 8 so
    ; round-8 actions still fire on round 8 instead of being delayed to 9.
    if difference = 2 {

        if (
            !WeirdReadActive
            || detectedRound != LastWeirdRead
        ) {
            WeirdReadActive := true
            LastWeirdRead := detectedRound
            WeirdReadCount := 1
            return LastRound
        }


        WeirdReadCount++


        if WeirdReadCount < 4 {
            return LastRound
        }


        if IsGlacialTrailEarlyOcrTrouble() {
            ; On Glacial Trail rounds 10-12, a +2 can mean the previous round
            ; was unreadable rather than that it is safe to skip it. Advance
            ; only one round, then let the same readable counter confirm the
            ; following +1 on the next polls. This prevents a round-12 action
            ; from being skipped when round 13 becomes readable again.
            inferredRound :=
                LastRound + 1


            LogMessage(
                "ROUND",
                "Glacial Trail OCR gap: validated="
                . LastRound
                . ", detected="
                . detectedRound
                . "; advancing sequentially to "
                . inferredRound
            )


            LastRound :=
                inferredRound


            ; Do not latch detectedRound here. It is the visible later round,
            ; so it must remain available to confirm the next +1 transition.
            LastAcceptedRoundRead :=
                0


            TrackRoundStart()
            ResetWeirdReads()
            return LastRound
        }


        LogMessage(
            "ROUND",
            "Confirmed one-round OCR gap: validated="
            . LastRound
            . ", detected="
            . detectedRound
            . "; catching up to "
            . detectedRound
        )


        LastRound :=
            detectedRound


        LastAcceptedRoundRead :=
            detectedRound


        TrackRoundStart()
        ResetWeirdReads()
        return LastRound
    }


    ; Glacial Trail's snowy early rounds can produce a completely implausible
    ; value (for example 29 while the real next round is 11). If the bad raw
    ; value changed and the previous validated round has been active for a few
    ; seconds, use it only as evidence that one round transition occurred.
    ; This is isolated to the observed 10-12 problem window.
    if (
        IsGlacialTrailEarlyOcrTrouble()
        && difference > 2
        && (
            RoundStartTick = 0
            || A_TickCount - RoundStartTick >= 3000
        )
    ) {
        inferredRound :=
            LastRound + 1


        LogMessage(
            "ROUND",
            "Glacial Trail noisy OCR read "
            . detectedRound
            . "; advancing sequentially from "
            . LastRound
            . " to "
            . inferredRound
        )


        LastRound :=
            inferredRound


        ; Latch this bad visual signature so the same on-screen misread cannot
        ; advance another round until the OCR output actually changes.
        LastAcceptedRoundRead :=
            detectedRound


        TrackRoundStart()
        ResetWeirdReads()
        return LastRound
    }


    ; Never infer a multi-round jump larger than +2. This specifically blocks
    ; the observed false 10 -> 14 read from unlocking rounds 11-14. Wait for
    ; OCR to return either the real next round or, at most, a confirmed +2 gap.
    if (
        !WeirdReadActive
        || detectedRound != LastWeirdRead
    ) {
        WeirdReadActive := true
        LastWeirdRead := detectedRound
        WeirdReadCount := 1

        LogMessage(
            "ROUND",
            "Rejected round OCR jump: validated="
            . LastRound
            . ", detected="
            . detectedRound
        )

        return LastRound
    }


    WeirdReadCount++
    return LastRound
}

ResetWeirdReads() {
    global LastWeirdRead
    global WeirdReadCount
    global WeirdReadActive


    LastWeirdRead :=
        0


    WeirdReadCount :=
        0


    WeirdReadActive :=
        false
}



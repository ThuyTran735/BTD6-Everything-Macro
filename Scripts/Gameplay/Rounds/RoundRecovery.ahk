#Requires AutoHotkey v2.0

; v3 file note: Handles missing round reads, popup recovery, and Glacial Trail resync behavior.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

CheckRoundReadRecovery(timeoutMs := "") {
    detectedRound :=
        GetCurrentRound()


    if detectedRound {

        ResetRoundReadFailureTracking()


        ValidateRound(
            detectedRound
        )


        return "Readable"
    }


    if HandleMissingRoundRead(timeoutMs) {

        return "Recovered"
    }


    return "Waiting"
}


HandleMissingRoundRead(timeoutMs := "") {
    global RoundReadMissingSince
    global RoundReadTimeoutMs


    effectiveTimeoutMs :=
        timeoutMs = ""
            ? RoundReadTimeoutMs
            : timeoutMs


    if RoundReadMissingSince = 0 {

        RoundReadMissingSince :=
            A_TickCount


        return false
    }


    if (
        A_TickCount
        - RoundReadMissingSince
        < effectiveTimeoutMs
    ) {

        return false
    }


    ; Glacial Trail's snow can make an otherwise visible round temporarily
    ; unreadable. Do not run the generic bottom-right popup click recovery on
    ; this map: that was the cursor movement seen around round 12. Instead,
    ; allow one conservative sequential inference for each newly validated
    ; round after the tolerant OCR retry has already failed.
    if IsGlacialTrailEarlyOcrTrouble() {
        return TryInferGlacialTrailMissingRound()
    }


    DismissUnknownRoundBlockingPopup()


    ; Prevent click spam if the first recovery attempt
    ; did not clear whatever blocked the round display.
    RoundReadMissingSince :=
        A_TickCount


    return true
}


TryInferGlacialTrailMissingRound() {
    global LastRound
    global LastAcceptedRoundRead
    global GlacialLastInferredRound
    global RoundReadMissingSince
    global RoundStartTick

    startingRound :=
        GetStartingRound()

    finalRound :=
        GetFinalRound()


    if (
        LastRound < startingRound
        || LastRound >= finalRound
    ) {
        return false
    }


    ; Never infer twice from the same validated round. A real OCR read must
    ; move LastRound forward before another missing-round inference is allowed.
    if GlacialLastInferredRound >= LastRound {
        return false
    }


    ; Avoid treating a brief transition/particle pass as a full missed round.
    ; Require the OCR itself to have been continuously missing for 3 seconds.
    ; This is longer than the old 1.5s popup-click timeout that was moving the
    ; cursor to the bottom-right on Glacial Trail round 12.
    if (
        RoundReadMissingSince = 0
        || A_TickCount - RoundReadMissingSince < 3000
    ) {
        return false
    }


    if (
        RoundStartTick != 0
        && A_TickCount - RoundStartTick < 3000
    ) {
        return false
    }


    inferredRound :=
        LastRound + 1


    LastRound :=
        inferredRound


    LastAcceptedRoundRead :=
        0


    GlacialLastInferredRound :=
        inferredRound


    ResetWeirdReads()
    TrackRoundStart()


    LogMessage(
        "ROUND",
        "Glacial Trail OCR remained unreadable; inferred sequential round "
        . inferredRound
    )


    ; Start a fresh missing interval. Do not infer another round from the same
    ; continuous OCR outage unless a real validated read advances LastRound.
    RoundReadMissingSince :=
        A_TickCount


    return true
}


DismissUnknownRoundBlockingPopup() {
    global RoundRecoveryX
    global RoundRecoveryY
    global GlacialPostRecoveryResyncActive
    global GlacialPostRecoveryResyncTick


    oldMouseMode :=
        A_CoordModeMouse


    CoordMode(
        "Mouse",
        "Screen"
    )


    Loop 5 {

        Click(
            RoundRecoveryX,
            RoundRecoveryY
        )


        Sleep(
            500
        )
    }


    CoordMode(
        "Mouse",
        oldMouseMode
    )


    Sleep(
        400
    )


    if IsGlacialTrailRun() {
        GlacialPostRecoveryResyncActive :=
            true


        GlacialPostRecoveryResyncTick :=
            A_TickCount


        LogMessage(
            "ROUND",
            "Glacial Trail popup recovery completed; enabling sequential round resync"
        )
    }


    return true
}


ResetRoundReadFailureTracking() {
    global RoundReadMissingSince


    RoundReadMissingSince :=
        0
}



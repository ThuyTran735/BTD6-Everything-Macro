#Requires AutoHotkey v2.0

; v3 file note: Provides the small validated-read helpers used by strategy and recovery code.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

GetValidatedRound() {
    global LastRound


    detectedRound :=
        GetCurrentRound()


    if !detectedRound {

        HandleMissingRoundRead()


        return LastRound
    }


    ResetRoundReadFailureTracking()


    return ValidateRound(
        detectedRound
    )
}


; Fast strategy read: never starts popup-recovery work before a scheduled
; action. If the round is briefly unreadable during a normal transition,
; return the last validated round immediately and let WaitForRound() keep
; polling at high frequency.
GetValidatedRoundForStrategy() {
    global LastRound


    detectedRound :=
        GetCurrentRound()


    if !detectedRound {
        return LastRound
    }


    ResetRoundReadFailureTracking()


    return ValidateRound(
        detectedRound
    )
}



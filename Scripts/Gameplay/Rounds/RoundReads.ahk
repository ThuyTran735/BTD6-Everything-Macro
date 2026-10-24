#Requires AutoHotkey v2.0

; Provides validated round reads for recovery and for scheduled strategy actions.
; The strategy variant returns the last known round quickly when the counter is briefly hidden.

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



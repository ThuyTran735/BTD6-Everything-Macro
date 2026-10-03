#Requires AutoHotkey v2.0

; v3 file note: Contains only the weird Glacial Trail OCR cleanup rules so other maps stay normal.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

NormalizeRoundOcrCandidate(candidate) {
    global LastRound


    ; Other maps are already stable. Never apply Glacial Trail's digit repair
    ; rules globally because that can turn a legitimate read into a fake one.
    if !IsGlacialTrailRun() {
        return candidate
    }


    if LastRound <= 0 {
        return candidate
    }


    expectedNext :=
        LastRound + 1


    ; Always trust a clean exact read first. The map-specific repair table is
    ; only a fallback when the OCR result is one of the confirmed bad values.
    if candidate = expectedNext {
        return candidate
    }


    ; Current/stale reads are harmless and should remain available to the
    ; normal validator so the tracker can hold its position while the round
    ; counter is transitioning.
    if candidate <= LastRound {
        return candidate
    }


    ; Exact Glacial Trail-only misreads observed after adding the newer digit
    ; templates. These are keyed by the next expected round, which also makes
    ; the ambiguous raw value 290 safe for both round 20 and round 29.
    if IsKnownGlacialTrailRoundMisread(
        candidate,
        expectedNext
    ) {
        LogRoundOcrRepair(
            candidate,
            expectedNext
        )


        return expectedNext
    }


    ; Keep the older generic 0->9 / 1->2 repair only for the known early
    ; Glacial Trail 10-12 problem window. It must never be allowed to turn a
    ; correct later read such as 22 into round 21.
    if (
        expectedNext <= 12
        && RoundOcrCandidateMatchesExpected(
            candidate,
            expectedNext
        )
    ) {
        LogRoundOcrRepair(
            candidate,
            expectedNext
        )


        return expectedNext
    }


    ; For the confirmed Glacial trouble rounds, an unmatched future value is
    ; not evidence of a new round. Reject it and keep polling instead of
    ; letting the generic +2 catch-up path fire a scheduled action early.
    if IsGlacialTrailStrictExpectedRound(expectedNext) {
        LogGlacialRejectedOcrCandidate(
            candidate,
            expectedNext
        )


        return false
    }


    return candidate
}


IsGlacialTrailStrictExpectedRound(expectedRound) {
    static StrictRounds := Map(
        10, true,
        11, true,
        12, true,
        20, true,
        21, true,
        22, true,
        25, true,
        27, true,
        29, true
    )


    return StrictRounds.Has(expectedRound)
}


LogGlacialRejectedOcrCandidate(observedRound, expectedRound) {
    global LastGlacialRejectedOcrLogKey


    key :=
        observedRound
        . "->"
        . expectedRound


    if LastGlacialRejectedOcrLogKey = key {
        return
    }


    LastGlacialRejectedOcrLogKey :=
        key


    LogMessage(
        "ROUND",
        "Glacial Trail ignored OCR read "
        . observedRound
        . " while expecting round "
        . expectedRound
    )
}

IsKnownGlacialTrailRoundMisread(candidate, expectedRound) {
    ; Confirmed Glacial Trail-only OCR artifacts after adding the newer digit
    ; patterns. The same raw value 290 can represent either round 20 or 29,
    ; so these repairs are keyed by the next expected sequential round instead
    ; of globally rewriting an OCR number.
    static KnownMisreads := Map(
        12, 129,
        20, 290,
        21, 291,
        22, 292,
        25, 295,
        27, 297,
        29, 290
    )


    return (
        KnownMisreads.Has(expectedRound)
        && candidate = KnownMisreads[expectedRound]
    )
}


LogRoundOcrRepair(observedRound, normalizedRound) {
    global LastRoundOcrRepairLogKey


    key :=
        observedRound
        . "->"
        . normalizedRound


    if LastRoundOcrRepairLogKey = key {
        return
    }


    LastRoundOcrRepairLogKey :=
        key


    LogMessage(
        "ROUND",
        "Normalized OCR read "
        . observedRound
        . " to expected round "
        . normalizedRound
    )
}



RoundOcrCandidateMatchesExpected(candidate, expectedRound) {
    observed :=
        String(candidate)


    expected :=
        String(expectedRound)


    ; Exact match remains the preferred path.
    if observed = expected {
        return true
    }


    ; Snow particles can appear as one extra leading digit inside the OCR
    ; result. Only strip one leading glyph and only when the remainder can be
    ; explained as the next expected round.
    if StrLen(observed) = StrLen(expected) + 1 {

        withoutLeadingNoise :=
            SubStr(observed, 2)


        if RoundOcrDigitsMatchExpected(
            withoutLeadingNoise,
            expected
        ) {
            return true
        }


        ; FindText can also duplicate the final glyph: 29 -> 299.
        if (
            SubStr(observed, -1) = SubStr(observed, -2, 1)
        ) {

            withoutDuplicateLast :=
                SubStr(observed, 1, StrLen(observed) - 1)


            if RoundOcrDigitsMatchExpected(
                withoutDuplicateLast,
                expected
            ) {
                return true
            }
        }
    }


    return RoundOcrDigitsMatchExpected(
        observed,
        expected
    )
}


RoundOcrDigitsMatchExpected(observed, expected) {
    if StrLen(observed) != StrLen(expected) {
        return false
    }


    Loop StrLen(expected) {

        expectedDigit :=
            SubStr(expected, A_Index, 1)


        observedDigit :=
            SubStr(observed, A_Index, 1)


        if observedDigit = expectedDigit {
            continue
        }


        ; Confirmed BTD6/FindText ambiguities on Glacial Trail:
        ; a visible 0 can be recognized as 9, and a visible 1 as 2.
        if (
            expectedDigit = "0"
            && observedDigit = "9"
        ) {
            continue
        }


        if (
            expectedDigit = "1"
            && observedDigit = "2"
        ) {
            continue
        }


        return false
    }


    return true
}



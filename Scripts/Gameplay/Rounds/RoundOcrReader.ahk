#Requires AutoHotkey v2.0

; v3 file note: Reads the round counter and runs the Glacial Trail fallback OCR pass.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

GetCurrentRound() {
    global RoundDigits


    areas :=
        GetRoundArea()


    for areaName in [
        "regular",
        "rightPanel"
    ] {

        area :=
            areas.%areaName%


        ok :=
            FindText(
                &X,
                &Y,
                area.x1,
                area.y1,
                area.x2,
                area.y2,
                0,
                0,
                RoundDigits,
                1,
                1
            )


        if !ok {
            continue
        }


        ok :=
            FindText().Sort(
                ok
            )


        result :=
            FindText().Ocr(
                ok,
                20,
                20,
                3
            )


        detectedRound :=
            ParseRoundOcrText(
                result.text
            )


        if detectedRound {
            return detectedRound
        }
    }


    if IsGlacialTrailRun() {
        fallbackRound :=
            GetGlacialTrailRoundFallback(
                areas
            )

        if fallbackRound {
            return fallbackRound
        }
    }


    return false
}


GetGlacialTrailRoundFallback(areas) {
    global RoundDigits
    global LastRound
    global LastGlacialFallbackLogRound

    ; Glacial Trail is the only map observed to have snow particles interfere
    ; with the round glyphs. Retry only on this map with a small amount of
    ; FindText fault tolerance. The normal strict scan always runs first.
    for areaName in [
        "regular",
        "rightPanel"
    ] {

        area :=
            areas.%areaName%


        ok :=
            FindText(
                &X,
                &Y,
                area.x1,
                area.y1,
                area.x2,
                area.y2,
                0.10,
                0.10,
                RoundDigits,
                1,
                1
            )


        if !ok {
            continue
        }


        ok :=
            FindText().Sort(
                ok
            )


        result :=
            FindText().Ocr(
                ok,
                20,
                20,
                3
            )


        detectedRound :=
            ParseRoundOcrText(
                result.text
            )


        if !detectedRound {
            continue
        }


        ; Keep the fuzzy retry conservative. It may confirm the current round
        ; or the next expected round, but it cannot manufacture a large jump.
        if (
            LastRound <= 0
            || detectedRound = LastRound
            || detectedRound = LastRound + 1
        ) {

            if LastGlacialFallbackLogRound != detectedRound {
                LastGlacialFallbackLogRound := detectedRound

                LogMessage(
                    "ROUND",
                    "Glacial Trail tolerant OCR recovered round "
                    . detectedRound
                )
            }

            return detectedRound
        }
    }


    return false
}


ParseRoundOcrText(ocrText) {
    global LastRound


    startingRound :=
        GetStartingRound()


    finalRound :=
        GetFinalRound()


    ; Before the first live round has been validated, startRound itself is
    ; authoritative. Accept any non-final numeric OCR candidate as proof that
    ; the in-game counter is visible, even if that first frame is misread below
    ; startRound. ValidateRound() will initialize to startRound, not to this raw
    ; number. This prevents startup from stalling on a bad first digit.
    minimumCandidateRound :=
        LastRound < startingRound
            ? 1
            : startingRound


    digitsOnly :=
        RegExReplace(
            ocrText,
            "\D"
        )


    if digitsOnly = "" {
        return false
    }


    finalText :=
        String(finalRound)


    ; A /100 mode can occasionally detect only the denominator. Never let a
    ; lone final-round value jump the run straight to the end unless the
    ; validated round is already adjacent to it.
    if (
        digitsOnly = finalText
        && LastRound < finalRound - 1
    ) {
        return false
    }


    ; If OCR joined the current round and denominator together, strip the
    ; configured final-round suffix first. Examples: 6100 -> 6,
    ; 10100 -> 10, 99100 -> 99, 100100 -> 100.
    if (
        StrLen(digitsOnly) > StrLen(finalText)
        && SubStr(
            digitsOnly,
            StrLen(digitsOnly) - StrLen(finalText) + 1
        ) = finalText
    ) {

        currentText :=
            SubStr(
                digitsOnly,
                1,
                StrLen(digitsOnly) - StrLen(finalText)
            )


        if currentText != "" {
            candidate := Integer(currentText)


            candidate :=
                NormalizeRoundOcrCandidate(
                    candidate
                )


            if (
                candidate >= minimumCandidateRound
                && candidate <= finalRound
            ) {
                return candidate
            }
        }
    }


    ; When FindText inserts a separator between the current round and /100,
    ; prefer the first visible numeric group instead of concatenating all
    ; digits from the OCR box.
    if RegExMatch(
        ocrText,
        "\d{1,3}",
        &firstNumber
    ) {

        candidate :=
            Integer(firstNumber[0])


        candidate :=
            NormalizeRoundOcrCandidate(
                candidate
            )


        if (
            candidate >= minimumCandidateRound
            && candidate <= finalRound
        ) {
            return candidate
        }
    }


    ; Finally accept a plain numeric OCR result only when it is in range.
    candidate :=
        NormalizeRoundOcrCandidate(
            Integer(digitsOnly)
        )


    if (
        candidate >= minimumCandidateRound
        && candidate <= finalRound
    ) {
        return candidate
    }


    ; Never let malformed OCR move strategy time forward.
    return false
}


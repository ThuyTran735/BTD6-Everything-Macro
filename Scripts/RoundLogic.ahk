#Requires AutoHotkey v2.0

; v3 file note: Round tracking got too hard to debug in one file. The OCR reader, Glacial Trail fixes, validation, and recovery are separate now while this path stays compatible.
; The split is organization-only; callers can keep including this file like before.

#Include Gameplay\Rounds\RoundData.ahk
#Include Gameplay\Rounds\RoundConfig.ahk
#Include Gameplay\Rounds\RoundOcrReader.ahk
#Include Gameplay\Rounds\GlacialTrailOcrFixes.ahk
#Include Gameplay\Rounds\RoundValidation.ahk
#Include Gameplay\Rounds\RoundReads.ahk
#Include Gameplay\Rounds\RoundRecovery.ahk
#Include Gameplay\Rounds\RoundWait.ahk
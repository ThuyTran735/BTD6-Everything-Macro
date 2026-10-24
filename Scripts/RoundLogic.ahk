#Requires AutoHotkey v2.0

; Share round reading, validation, and recovery behind the same include used by every strategy. RoundWait combines them while waiting for actions.

#Include Gameplay\Rounds\RoundData.ahk
#Include Gameplay\Rounds\RoundConfig.ahk
#Include Gameplay\Rounds\RoundOcrReader.ahk
#Include Gameplay\Rounds\GlacialTrailOcrFixes.ahk
#Include Gameplay\Rounds\RoundValidation.ahk
#Include Gameplay\Rounds\RoundReads.ahk
#Include Gameplay\Rounds\RoundRecovery.ahk
#Include Gameplay\Rounds\RoundWait.ahk
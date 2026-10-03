#Requires AutoHotkey v2.0

; v3 file note: Game-state handling is grouped by popup/end-screen job now. This wrapper keeps IncludeAll and older test scripts unchanged.
; The split is organization-only; callers can keep including this file like before.

#Include Gameplay\GameState\GameStatePatterns.ahk
#Include Gameplay\GameState\GameStateDetection.ahk
#Include Gameplay\GameState\LevelAndBloonPopups.ahk
#Include Gameplay\GameState\HomeAndMoneyPopups.ahk
#Include Gameplay\GameState\HomeScreenDetection.ahk
#Include Gameplay\GameState\RunResults.ahk
#Include Gameplay\GameState\RunStateReset.ahk
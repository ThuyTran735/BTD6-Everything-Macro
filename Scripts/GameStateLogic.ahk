#Requires AutoHotkey v2.0

; v3 file note: Game-state handling is grouped by popup/end-screen job now. This wrapper keeps IncludeAll and older test scripts unchanged.
; The split is organization-only; callers can keep including this file like before.

#Include Gameplay\Game State\GameStatePatterns.ahk
#Include Gameplay\Game State\GameStateDetection.ahk
#Include Gameplay\Game State\LevelAndBloonPopups.ahk
#Include Gameplay\Game State\HomeAndMoneyPopups.ahk
#Include Gameplay\Game State\HomeScreenDetection.ahk
#Include Gameplay\Game State\RunResults.ahk
#Include Gameplay\Game State\RunStateReset.ahk
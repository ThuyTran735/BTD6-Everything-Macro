#Requires AutoHotkey v2.0

; Loads the run HUD, its lifecycle guards, and the shared run-count prompt.
; Positioning and cancellation stay separate from drawing so timers can retire the HUD safely.

#Include Run\CycleStatusState.ahk
#Include Run\CycleStatusWindow.ahk
#Include Run\CycleStatusPosition.ahk
#Include Run\CycleStatusUpdates.ahk
#Include Run\CycleStatusCancel.ahk
#Include Run\RunCountPrompt.ahk
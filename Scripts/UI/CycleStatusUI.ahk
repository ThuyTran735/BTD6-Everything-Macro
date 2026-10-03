#Requires AutoHotkey v2.0

; v3 file note: Run HUD code is split into HUD drawing/positioning, status updates, cancel handling, and the run-count prompt.
; The split is organization-only; callers can keep including this file like before.

#Include Run\CycleStatusState.ahk
#Include Run\CycleStatusWindow.ahk
#Include Run\CycleStatusPosition.ahk
#Include Run\CycleStatusUpdates.ahk
#Include Run\CycleStatusCancel.ahk
#Include Run\RunCountPrompt.ahk
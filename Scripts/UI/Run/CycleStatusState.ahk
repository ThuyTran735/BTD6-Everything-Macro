#Requires AutoHotkey v2.0

; Shared HUD visibility, position, and prompt state.
; Closing and click suppression are separate: a temporary hide must not revive a stopped run.


global CycleProgressText := ""
global CycleProgressBar := ""
global CycleProgressBackground := ""

global CycleStatusLastX := ""
global CycleStatusLastY := ""
global CycleStatusRightPanelOpen := false
global CycleStatusRightPanelMisses := 0
global CycleStatusHudEnabled := false
global CycleStatusSuppressedForMapClick := false
global CycleStatusClosing := false

global CycleInputGui := ""
global CycleInputEdit := ""
global CycleInputInfiniteCheckbox := ""
global CycleInputErrorText := ""
global CycleInputResult := 0
global CycleInputFinished := false

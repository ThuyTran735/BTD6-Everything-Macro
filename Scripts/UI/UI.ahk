#Requires AutoHotkey v2.0

global LauncherGui := ""

global SubtitleText := ""

global CategoryLabel := ""
global CategoryDropdown := ""

global MapLabel := ""
global MapDropdown := ""

global HotkeyText := ""

global ParagonTitle := ""
global ParagonDescription := ""

global StatusText := ""

global RunButton := ""
global ConfigButton := ""
global ModeButton := ""
global LogsButton := ""

global ScriptPickerGui := ""
global ScriptPickerState := ""

global ModePickerGui := ""

global CycleStatusGui := ""
global CycleStatusText := ""
global CycleProgressText := ""
global CycleProgressBar := ""
global CycleProgressBackground := ""
global CycleCancelButton := ""

global CycleInputGui := ""
global CycleInputEdit := ""
global CycleInputErrorText := ""
global CycleInputResult := 0
global CycleInputFinished := false

global StartupLoadingGui := ""
global StartupLoadingMessage := ""
global StartupLoadingPercent := ""
global StartupLoadingProgress := ""
global StartupLoadingActive := false

global CurrentMode := "Default"

global MacroRunning := false
global RunningPid := 0

global RepeatScriptPath := ""
global RepeatRunTotal := 0
global RepeatRunRemaining := 0
global RepeatRunCompleted := 0

global ForceLauncherVisible := false

global GuiWidth := 390
global GuiHeight := 390

global GuiX := 0
global GuiY := 0

global CategoryData := Map()

#Include UITheme.ahk
#Include CustomControlsUI.ahk
#Include CustomDropdownUI.ahk
#Include UIHelpers.ahk
#Include LoadingUI.ahk
#Include CycleStatusUI.ahk
#Include MapDiscoveryUI.ahk
#Include ScriptPickerUI.ahk
#Include ModeUI.ahk
#Include LauncherUI.ahk


; UI.ahk is only loaded by the main launcher.
; Run the fake boot sequence before Main.ahk
; creates the normal launcher window.
RunMainStartupLoadingAnimation()
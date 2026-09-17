#Requires AutoHotkey v2.0

global LauncherGui := ""

global SubtitleText := ""

global CategoryLabel := ""
global CategoryDropdown := ""

global MapLabel := ""
global MapDropdown := ""

global HotkeyText := ""

global MonkeyExpTitle := ""
global MonkeyExpDescription := ""
global MonkeyExpTypeLabel := ""
global MonkeyExpTypeDropdown := ""
global MonkeyExpScriptLabel := ""
global MonkeyExpScriptDropdown := ""
global MonkeyExpScripts := []

global StatusText := ""

global RunButton := ""
global AddQueueButton := ""
global QueueButton := ""
global ModeButton := ""
global SettingsButton := ""
global CloseButton := ""

global CategoryHelpBadge := ""
global MapHelpBadge := ""
global MapFavoriteHelpBadge := ""
global MonkeyExpTypeHelpBadge := ""
global MonkeyExpScriptHelpBadge := ""
global MonkeyExpFavoriteHelpBadge := ""

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

global ActiveRunToken := ""

global ForceLauncherVisible := false

; While a macro run is active (and briefly while the child
; process is handing control back to BTD6), keep the launcher
; physically hidden and fully transparent. This prevents a
; one-frame launcher flash during fullscreen/menu transitions.
global LauncherRunSuppressed := false
global LauncherReturnPending := false
global LauncherReturnPendingTick := 0

; When one cycle/job ends, wait for BTD6 to be back on Home
; before launching the next child process. This avoids starting a
; queued map during the victory/menu transition.
global MacroContinuationAction := ""
global MacroContinuationTick := 0

global GuiWidth := 390
global GuiHeight := 390

global GuiX := 0
global GuiY := 0

global CategoryData := Map()

#Include UITheme.ahk
#Include CustomControlsUI.ahk
#Include CustomDropdownUI.ahk
#Include HelpUI.ahk
#Include ConfirmUI.ahk
#Include UIHelpers.ahk
#Include FavoritesProfilesData.ahk
#Include FavoritesUI.ahk
#Include LoadingUI.ahk
#Include CycleStatusUI.ahk
#Include MapDiscoveryUI.ahk
#Include QueueJobBuilderUI.ahk
#Include QueueProfilesUI.ahk
#Include RunHistoryUI.ahk
#Include RetryRecoveryUI.ahk
#Include ..\UpdateChecker.ahk
#Include SettingsUI.ahk
#Include QueueUI.ahk
#Include ScriptPickerUI.ahk
#Include ModeUI.ahk
#Include LauncherUI.ahk


; Load persistent favorites before discovery builds launcher lists.
LoadFavoriteData()

; UI.ahk is only loaded by the main launcher.
; Run the fake boot sequence before Main.ahk
; creates the normal launcher window.
RunMainStartupLoadingAnimation()
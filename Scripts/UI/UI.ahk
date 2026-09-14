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

global CurrentMode := "Default"

global MacroRunning := false
global RunningPid := 0

global GuiWidth := 390
global GuiHeight := 390

global GuiX := 0
global GuiY := 0

global CategoryData := Map()


#Include UITheme.ahk
#Include CustomControlsUI.ahk
#Include CustomDropdownUI.ahk
#Include UIHelpers.ahk
#Include MapDiscoveryUI.ahk
#Include ScriptPickerUI.ahk
#Include ModeUI.ahk
#Include LauncherUI.ahk
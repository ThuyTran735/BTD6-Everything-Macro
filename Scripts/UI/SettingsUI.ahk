#Requires AutoHotkey v2.0

; v3 file note: Settings is split into the main window, toggles, update checking, logs, and navigation actions. The public SettingsUI include stays the same.
; The split is organization-only; callers can keep including this file like before.

#Include Settings\SettingsWindow.ahk
#Include Settings\SettingsToggles.ahk
#Include Settings\SettingsUpdates.ahk
#Include Settings\SettingsLogging.ahk
#Include Settings\SettingsUserData.ahk
#Include Settings\SettingsNavigation.ahk
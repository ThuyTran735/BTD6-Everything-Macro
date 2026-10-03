#Requires AutoHotkey v2.0

; v3 file note: The old catch-all UI helper file is split into window chrome, launcher state, styling, IPC, and monitoring helpers now.
; The split is organization-only; callers can keep including this file like before.

#Include Common\WindowChrome.ahk
#Include Common\LauncherPosition.ahk
#Include Common\LauncherVisibility.ahk
#Include Common\ControlThemeHelpers.ahk
#Include Common\ChildRunIpc.ahk
#Include Common\LauncherMonitor.ahk
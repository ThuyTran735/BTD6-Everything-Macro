#Requires AutoHotkey v2.0

; v3 file note: Launcher code is split into drawing, mode actions, run launching, and queued/repeat execution. The old LauncherUI path remains the entry point.
; The split is organization-only; callers can keep including this file like before.

#Include Launcher\LauncherWindow.ahk
#Include Launcher\LauncherModeActions.ahk
#Include Launcher\LauncherRunStart.ahk
#Include Launcher\LauncherRunQueue.ahk
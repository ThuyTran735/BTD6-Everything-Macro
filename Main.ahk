#Requires AutoHotkey v2.0
#SingleInstance Force

#Include Scripts\IncludeAll.ahk
#Include Scripts\UI\UI.ahk


; Starts the launcher after the first-run warning and loading screen.
; Background checks begin only after the launcher controls exist.

ShowFirstRunWarningIfNeeded()


RunMainStartupLoadingAnimation()


CreateLauncherUI()


SetTimer(StartStartupUpdateCheck, -100)


SetTimer(
    MonitorLauncherState,
    500
)


^+p::RunCurrentMode()
^+x::EmergencyStopMacro()


return
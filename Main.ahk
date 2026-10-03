#Requires AutoHotkey v2.0
#SingleInstance Force

#Include Scripts\IncludeAll.ahk
#Include Scripts\UI\UI.ahk


; v3 file note: Starts the launcher and wires the shared game/UI pieces together. Startup-only stuff belongs here.

ShowFirstRunWarningIfNeeded()


RunMainStartupLoadingAnimation()


CreateLauncherUI()


SetTimer(StartStartupUpdateCheck, -100)


SetTimer(
    MonitorLauncherState,
    500
)


^+p::RunCurrentMode()


return
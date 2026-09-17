#Requires AutoHotkey v2.0
#SingleInstance Force

#Include Scripts\IncludeAll.ahk
#Include Scripts\UI\UI.ahk


CreateLauncherUI()


; V1.6: show a short update-search animation immediately after launch,
; then perform the real GitHub check.
SetTimer(StartStartupUpdateCheck, -100)


SetTimer(
    MonitorLauncherState,
    500
)


^+p::RunCurrentMode()


return
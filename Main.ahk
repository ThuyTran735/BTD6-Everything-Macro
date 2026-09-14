#Requires AutoHotkey v2.0
#SingleInstance Force

#Include Scripts\IncludeAll.ahk
#Include Scripts\UI\UI.ahk


CreateLauncherUI()


SetTimer(
    MonitorLauncherState,
    500
)


^+p::RunCurrentMode()


return
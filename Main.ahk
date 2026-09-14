#Requires AutoHotkey v2.0
#SingleInstance Force

#Include Scripts\IncludeAll.ahk
#Include Scripts\UI.ahk


CreateLauncherUI()


SetTimer(
    MonitorLauncherState,
    500
)


; Ctrl + Shift + P
^+p::RunSelectedMap()


return
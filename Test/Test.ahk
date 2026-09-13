#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk
#Include ..\Scripts\IncludeAll.ahk

Sleep(3000)

SendEvent("{u down}")
Sleep(100)
SendEvent("{u up}")
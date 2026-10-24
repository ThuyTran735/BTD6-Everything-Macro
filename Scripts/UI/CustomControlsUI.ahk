#Requires AutoHotkey v2.0

; Loads the button and list classes together with their shared input polling.
; Registries are included first so new controls can register during construction.

#Include Controls\ControlRegistry.ahk
#Include Controls\DarkButton.ahk
#Include Controls\DarkList.ahk
#Include Controls\CustomControlSystem.ahk
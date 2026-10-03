#Requires AutoHotkey v2.0

; v3 file note: Custom controls are split into button/list classes and the shared polling system. This file only keeps the old UI include nice and stable.
; The split is organization-only; callers can keep including this file like before.

#Include Controls\ControlRegistry.ahk
#Include Controls\DarkButton.ahk
#Include Controls\DarkList.ahk
#Include Controls\CustomControlSystem.ahk
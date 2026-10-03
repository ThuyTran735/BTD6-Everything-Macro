#Requires AutoHotkey v2.0

; v3 file note: The dropdown class is still a chunky control, but the global state/factory and polling code are separated so the class itself is the only long part left here.
; The split is organization-only; callers can keep including this file like before.

#Include Controls\DropdownRegistry.ahk
#Include Controls\DarkDropdown.ahk
#Include Controls\DropdownSystem.ahk
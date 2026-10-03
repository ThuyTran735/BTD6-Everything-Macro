#Requires AutoHotkey v2.0

; v3 file note: Keeps dropdown globals and the CreateDarkDropdown factory in one tiny file.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.


global UIDarkDropdowns := []
global UIDarkActiveDropdown := ""

global UIDarkDropdownTimerStarted := false
global UIDarkDropdownMouseWasDown := false
global UIDarkDropdownWheelHookStarted := false


CreateDarkDropdown(
    guiObject,
    x,
    y,
    width,
    items := "",
    chooseIndex := 1,
    maxVisibleRows := 5
) {
    return DarkDropdown(
        guiObject,
        x,
        y,
        width,
        items,
        chooseIndex,
        maxVisibleRows
    )
}



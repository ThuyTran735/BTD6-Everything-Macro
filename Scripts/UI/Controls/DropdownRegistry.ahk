#Requires AutoHotkey v2.0

; Shared dropdown registry and factory used by every launcher screen.
; The active-dropdown reference gives the polling code one popup to prioritize.


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



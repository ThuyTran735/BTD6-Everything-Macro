#Requires AutoHotkey v2.0

; Shared factories and registries for custom buttons and lists.
; The polling system uses these objects to update hover without separate timers per control.


global UIDarkLists := []
global UIDarkButtons := []

global UICustomControlTimerStarted := false
global UICustomControlMessagesStarted := false


CreateDarkButton(
    guiObject,
    x,
    y,
    width,
    height,
    text,
    fontSize := 8,
    style := ""
) {
    return DarkButton(
        guiObject,
        x,
        y,
        width,
        height,
        text,
        fontSize,
        style
    )
}


CreateDarkList(
    guiObject,
    x,
    y,
    width,
    height,
    items := "",
    rowHeight := 36
) {
    return DarkList(
        guiObject,
        x,
        y,
        width,
        height,
        items,
        rowHeight
    )
}



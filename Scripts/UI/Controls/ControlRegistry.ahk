#Requires AutoHotkey v2.0

; v3 file note: Creates the shared control registries and the small button/list factory helpers.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.


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



#Requires AutoHotkey v2.0

; Reopening a menu should focus its existing controls, not rebuild them.
ActivateExistingUIWindow(guiObject) {
    if !IsObject(guiObject)
        return false
    try {
        if !DllCall("IsWindowVisible", "Ptr", guiObject.Hwnd, "Int")
            return false
        WinActivate("ahk_id " . guiObject.Hwnd)
        return true
    }
    return false
}

RestoreExistingUIWindow(guiObject) {
    if !IsObject(guiObject)
        return false
    try {
        if !DllCall("IsWindow", "Ptr", guiObject.Hwnd, "Int")
            return false
        ; Preserve the user's position and the existing client size.
        DllCall("ShowWindow", "Ptr", guiObject.Hwnd, "Int", 5)
        WinActivate("ahk_id " . guiObject.Hwnd)
        return true
    }
    return false
}

BeginUIUpdate(guiObject) {
    if !IsObject(guiObject)
        return
    try hwnd := guiObject.Hwnd
    catch
        return
    if !DllCall("IsWindow", "Ptr", hwnd, "Int")
        return
    depth := guiObject.HasOwnProp("UIUpdateDepth") ? guiObject.UIUpdateDepth : 0
    guiObject.UIUpdateDepth := depth + 1
    if depth
        return
    guiObject.UIRedrawPaused := !!DllCall("IsWindowVisible", "Ptr", hwnd, "Int")
    if guiObject.UIRedrawPaused
        SendMessage(0xB, 0, 0, hwnd) ; WM_SETREDRAW
}

EndUIUpdate(guiObject) {
    if !IsObject(guiObject) || !guiObject.HasOwnProp("UIUpdateDepth") || !guiObject.UIUpdateDepth
        return
    guiObject.UIUpdateDepth--
    if guiObject.UIUpdateDepth || !guiObject.UIRedrawPaused
        return
    guiObject.UIRedrawPaused := false
    try hwnd := guiObject.Hwnd
    catch
        return
    if !DllCall("IsWindow", "Ptr", hwnd, "Int")
        return
    SendMessage(0xB, 1, 0, hwnd)
    ; Paint the final arrangement together, without exposing empty controls.
    DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x185)
}

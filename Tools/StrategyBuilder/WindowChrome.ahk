#Requires AutoHotkey v2.0

; Matches the standalone builder chrome to the dark launcher.
; Only the title area drags the window, leaving form controls free to receive clicks.

DisableBuilderNativeFrame(guiObject) {
    ; Windows can still composite a light resize frame over a full client area.
    ; Our own border and hit-testing replace that decoration, not resizing.
    guiObject.Opt("-E0x100 -E0x200 -E0x20000")
    policy := Buffer(4, 0)
    NumPut("UInt", 1, policy)
    try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", guiObject.Hwnd,
        "UInt", 2, "Ptr", policy.Ptr, "UInt", 4)
    NumPut("UInt", 0xFFFFFFFE, policy)
    try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", guiObject.Hwnd,
        "UInt", 34, "Ptr", policy.Ptr, "UInt", 4)
}

StrategyBuilderFramePaint(wParam, lParam, message, hwnd) {
    global MainGui
    if !MainGui || hwnd != MainGui.Hwnd
        return
    ; The resize style is still needed for Windows' sizing loop. Suppress
    ; its classic nonclient paint too, including when focus changes.
    return message = 0x86 ? 1 : 0
}

StrategyBuilderCheckboxColor(dc, controlHwnd, *) {
    global WingmonkeyMKCheckbox
    if !IsSet(WingmonkeyMKCheckbox) || controlHwnd != WingmonkeyMKCheckbox.Hwnd
        return
    ; Native checkboxes paint their own background. Match the card beneath
    ; this one instead of letting it use the darker window background.
    static brush := DllCall("CreateSolidBrush", "UInt", BuilderBGR("111820"), "Ptr")
    DllCall("SetBkColor", "Ptr", dc, "UInt", BuilderBGR("111820"))
    DllCall("SetTextColor", "Ptr", dc, "UInt", BuilderBGR("D8E0E8"))
    return brush
}

StrategyBuilderClientArea(wParam, lParam, message, hwnd) {
    global MainGui
    if !MainGui || hwnd != MainGui.Hwnd
        return
    ; Keep Windows' resize behavior, but draw the whole frame ourselves.
    ; A captionless WS_THICKFRAME otherwise leaves a pale strip above the UI.
    if wParam && DllCall("IsZoomed", "Ptr", hwnd, "Int") {
        monitor := DllCall("MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr")
        info := Buffer(40, 0)
        NumPut("UInt", 40, info)
        if DllCall("GetMonitorInfoW", "Ptr", monitor, "Ptr", info, "Int")
            DllCall("RtlMoveMemory", "Ptr", lParam, "Ptr", info.Ptr + 20, "UPtr", 16)
    }
    return 0
}

StrategyBuilderChromeHitTest(wParam, lParam, msg, hwnd) {
    global MainGui

    if !MainGui {
        return
    }

    rootHwnd := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")

    if !rootHwnd {
        rootHwnd := hwnd
    }

    if rootHwnd != MainGui.Hwnd {
        return
    }

    rect := Buffer(16, 0)

    if !DllCall("GetWindowRect", "Ptr", rootHwnd, "Ptr", rect.Ptr, "Int") {
        return
    }

    left := NumGet(rect, 0, "Int")
    top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int")
    bottom := NumGet(rect, 12, "Int")

    screenX := lParam & 0xFFFF
    screenY := (lParam >> 16) & 0xFFFF

    ; WM_NCHITTEST packs signed screen coordinates into two 16-bit values.
    ; Decode negatives so title dragging also works on monitors left of the main display.
    if screenX >= 0x8000 {
        screenX -= 0x10000
    }

    if screenY >= 0x8000 {
        screenY -= 0x10000
    }

    clientX := screenX - left
    clientY := screenY - top
    windowWidth := right - left
    windowHeight := bottom - top
    scale := DllCall("GetDpiForWindow", "Ptr", rootHwnd, "UInt") / 96

    if !DllCall("IsZoomed", "Ptr", rootHwnd, "Int") {
        edge := Round(6 * scale)
        nearLeft := clientX >= 0 && clientX < edge
        nearRight := clientX >= windowWidth - edge && clientX < windowWidth
        nearTop := clientY >= 0 && clientY < edge
        nearBottom := clientY >= windowHeight - edge && clientY < windowHeight
        if nearTop
            return nearLeft ? 13 : nearRight ? 14 : 12
        if nearBottom
            return nearLeft ? 16 : nearRight ? 17 : 15
        if nearLeft
            return 10
        if nearRight
            return 11
    }

    if (
        clientY >= 0
        && clientY < 74 * scale
        && clientX >= 0
        && clientX < windowWidth - 280 * scale
    ) {
        return 2
    }
}


CreateStrategyBuilderBorder(guiObject, width, height) {
    borderColor := "2A3441"
    thickness := 2

    top := guiObject.Add(
        "Progress",
        "x0 y0 w" . width . " h" . thickness
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    bottom := guiObject.Add(
        "Progress",
        "x0 y" . (height - thickness) . " w" . width . " h" . thickness
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    left := guiObject.Add(
        "Progress",
        "x0 y0 w" . thickness . " h" . height
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    right := guiObject.Add(
        "Progress",
        "x" . (width - thickness) . " y0 w" . thickness . " h" . height
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )

    for edge in [top, bottom, left, right]
        edge.Opt("-0x800000 -E0x200 -E0x20000")

    return {
        Top: top,
        Bottom: bottom,
        Left: left,
        Right: right,
        Thickness: thickness
    }
}


ResizeStrategyBuilderBorder(border, width, height) {
    if !IsObject(border) {
        return
    }

    thickness := border.Thickness
    try border.Top.Move(0, 0, width, thickness)
    try border.Bottom.Move(0, height - thickness, width, thickness)
    try border.Left.Move(0, 0, thickness, height)
    try border.Right.Move(width - thickness, 0, thickness, height)
}


MinimizeStrategyBuilder(*) {
    global MainGui

    if MainGui {
        WinMinimize("ahk_id " . MainGui.Hwnd)
    }
}


ResizeStrategyBuilderChrome(guiObject, minMax, width, height) {
    global BuilderWindowBorder, BuilderLayoutItems
    if minMax = -1
        return
    CloseBuilderDropdowns()
    dx := width - 1040
    dy := height - 744
    for item in BuilderLayoutItems {
        x := item.x + dx * item.ax
        y := item.y + dy * item.ay
        w := item.w + dx * item.aw
        h := item.h + dy * item.ah
        item.control.Move(x, y, w, h)
    }
    ResizeStrategyBuilderBorder(BuilderWindowBorder, width, height)
    DllCall("RedrawWindow", "Ptr", guiObject.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x585)
}

CloseBuilderDropdowns(*) {
    global UIDarkActiveDropdown
    if IsObject(UIDarkActiveDropdown)
        UIDarkActiveDropdown.Close()
}

BeginBuilderLayout() {
    global MainGui, BuilderLayoutDepth, BuilderRedrawPaused
    BuilderLayoutDepth += 1
    if BuilderLayoutDepth = 1 {
        BuilderRedrawPaused := !!DllCall("IsWindowVisible", "Ptr", MainGui.Hwnd)
        if BuilderRedrawPaused
            SendMessage(0xB, 0, 0, MainGui)
    }
}

EndBuilderLayout() {
    global MainGui, BuilderLayoutDepth, BuilderRedrawPaused
    BuilderLayoutDepth -= 1
    if BuilderLayoutDepth = 0 && BuilderRedrawPaused {
        ; Erase once after the complete change, including gaps that no visible
        ; control covers. Otherwise the hidden Export view leaves old pixels.
        SendMessage(0xB, 1, 0, MainGui)
        DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x585)
        BuilderRedrawPaused := false
    }
}
StyleBuilderNativeControls(guiObject) {
    ; Keep native keyboard navigation and the controls' existing event handlers.
    ; Older Windows themes can fall back to their usual control appearance.
    for control in guiObject {
        if control.Type = "ListView" {
            control.Opt("cF4F7FB Background10161D")
        }

        if (
            control.Type = "Edit"
            || control.Type = "ListView"
            || control.Type = "Button"
            || control.Type = "DropDownList"
        ) {
            try DllCall(
                "uxtheme\SetWindowTheme",
                "Ptr", control.Hwnd,
                "Str", "DarkMode_Explorer",
                "Ptr", 0
            )
        }
    }
}

BuilderBGR(hex) {
    value := Integer("0x" . hex)
    return ((value & 255) << 16) | (value & 0xFF00) | ((value >> 16) & 255)
}

LoadBuilderHeadingFont() {
    ; The standalone tool lives one level below the launcher.
    fontPath := A_ScriptDir . "\..\Lib\Fonts\LuckiestGuy\LuckiestGuy-Regular.ttf"
    if FileExist(fontPath) {
        try {
            if DllCall("gdi32\AddFontResourceEx", "Str", fontPath, "UInt", 0x10, "Ptr", 0, "Int") > 0
                return "Luckiest Guy"
        }
    }
    return "Segoe UI"
}

BuilderControl(control) {
    global BuilderBuildGroup, BuilderGroups
    if BuilderBuildGroup != ""
        BuilderGroups[BuilderBuildGroup].Push(control)
    return control
}

BuilderAnchor(control, x, y, w, h, ax := 0, ay := 0, aw := 0, ah := 0) {
    global BuilderLayoutItems
    BuilderLayoutItems.Push({control: control, x: x, y: y, w: w, h: h, ax: ax, ay: ay, aw: aw, ah: ah})
}

BuilderLabel(text, x, y, w, h := 18, color := "D8E0E8", ax := 0, ay := 0, aw := 0) {
    global MainGui
    MainGui.SetFont("s9 Norm c" . color, "Segoe UI")
    control := BuilderControl(MainGui.AddText("x" . x . " y" . y . " w" . w . " h" . h . " BackgroundTrans", text))
    if ax || ay || aw
        BuilderAnchor(control, x, y, w, h, ax, ay, aw)
    AddBuilderHelpBadge(control, text, x + w - 16, y, ax + aw, ay)
    return control
}

BuilderHeading(text, x, y, w, h := 24, size := 12) {
    global MainGui, BuilderHeadingFont
    MainGui.SetFont("s" . size . " Norm cF4F7FB", BuilderHeadingFont)
    control := BuilderControl(MainGui.AddText("x" . x . " y" . y . " w" . w . " h" . h . " BackgroundTrans", text))
    MainGui.SetFont("s9 Norm cF4F7FB", "Segoe UI")
    return control
}

BuilderPanel(x, y, w, h, aw := 0, ah := 0) {
    global MainGui
    for inset, color in Map(0, "26313D", 1, "111820") {
        control := BuilderControl(MainGui.AddProgress("x" . (x + inset) . " y" . (y + inset) . " w" . (w - inset * 2) . " h" . (h - inset * 2) . " c" . color . " Background" . color . " Disabled", 100))
        control.Opt("-0x800000 -E0x200 -E0x20000")
        BuilderAnchor(control, x + inset, y + inset, w - inset * 2, h - inset * 2, 0, 0, aw, ah)
    }
}

BuilderEdit(x, y, w, value := "", options := "") {
    global MainGui, BuilderEditFrames
    MainGui.SetFont("s9 Norm cF4F7FB", "Segoe UI")
    frame := BuilderControl(MainGui.AddProgress("x" . (x - 1) . " y" . (y - 1) . " w" . (w + 2) . " h28 c33404F Background33404F Disabled -0x800000 -E0x200", 100))
    control := BuilderControl(MainGui.AddEdit("x" . x . " y" . y . " w" . w . " h26 -Multi -VScroll -HScroll -Border -E0x200 " . options, value))
    BuilderEditFrames[control.Hwnd] := frame
    StyleBuilderEdit(control)
    return control
}

BuilderDDL(x, y, w, items) {
    global MainGui
    MainGui.SetFont("s9 Norm cF4F7FB", "Segoe UI")
    return BuilderControl(BuilderDarkDropdown(MainGui, x, y, w, items))
}

BuilderButton(text, x, y, w, h, callback, primary := false, ax := 0, ay := 0, aw := 0) {
    global MainGui, BuilderHeadingFont, BuilderButtons
    MainGui.SetFont("s9 Norm", BuilderHeadingFont)
    control := BuilderControl(BuilderDarkButton(MainGui, x, y, w, h, text, 8, primary ? "Success" : "Normal"))
    control.OnEvent("Click", callback)
    BuilderButtons[control.Hwnd] := {control: control, primary: primary, active: false}
    if ax || ay || aw
        BuilderAnchor(control, x, y, w, h, ax, ay, aw)
    badge := AddBuilderHelpBadge(control, text, x + w - 17, y + 3, ax + aw, ay)
    if badge {
        control.ProtectTopRightOverlay(x + w - 17, y + 3, 14, 14, 1)
        control.AddClickExclusionControl(badge.TextControl, 1, ObjBindMethod(badge, "HandleClick"))
    }
    MainGui.SetFont("s9 Norm cF4F7FB", "Segoe UI")
    return control
}

AddBuilderHelpBadge(owner, title, x, y, ax := 0, ay := 0) {
    global MainGui, BuilderBuildGroup, BuilderHelpBadges
    if title = "?" || title = "-" || title = "X"
        return false
    body := GetBuilderHelpText(title, BuilderBuildGroup)
    if body = ""
        return false
    badge := BuilderControl(BuilderDarkButton(MainGui, x, y, 14, 14, "?", 7, "Normal"))
    badge.LockTextPosition(2)
    badge.OnEvent("Click", ShowBuilderControlHelp.Bind(title, body))
    BuilderHelpBadges[owner.Hwnd] := badge
    if ax || ay
        BuilderAnchor(badge, x, y, 14, 14, ax, ay)
    return badge
}

SetBuilderFieldVisible(control, visible) {
    global BuilderEditFrames, BuilderHelpBadges
    control.Visible := visible
    ; Labels, outlines and their help badges belong to the same field.
    if BuilderEditFrames.Has(control.Hwnd)
        BuilderEditFrames[control.Hwnd].Visible := visible
    if BuilderHelpBadges.Has(control.Hwnd)
        BuilderHelpBadges[control.Hwnd].Visible := visible
}

ShowBuilderHelp(*) {
    global MainGui, BuilderHelpGui, BuilderHeadingFont, BuilderButtons
    if BuilderHelpGui {
        BuilderHelpGui.Show()
        return
    }
    BuilderHelpGui := Gui("-Caption +Border +Owner" . MainGui.Hwnd, "Strategy Builder help")
    BuilderHelpGui.BackColor := "0D1117"
    CreateStrategyBuilderBorder(BuilderHelpGui, 540, 500)
    BuilderHelpGui.SetFont("s15 Norm cF4F7FB", BuilderHeadingFont)
    BuilderHelpGui.AddText("x24 y24 w492 h30", "STRATEGY BUILDER")
    BuilderHelpGui.SetFont("s10 Norm cD8E0E8", "Segoe UI")
    help := "MONKEYS" . Chr(10) . "Add placements, or double-click a row to edit it. New starts another entry. Row options lets you edit or delete a selection."
    help .= Chr(10) . Chr(10) . "ACTIONS" . Chr(10) . "Choose an action type, set its round and delay, then add it. Double-click an action to save changes in the same row."
    help .= Chr(10) . Chr(10) . "EXPORT" . Chr(10) . "Generate a preview, copy the code, or save an .ahk file. Copy and Save check the schedule and use your latest changes."
    help .= Chr(10) . Chr(10) . "TOOLS / CAPTURE" . Chr(10) . "Tools contains labels, remapping and Clear. F2 captures placement; F3 captures a moved tower; F5 captures target coordinates."
    BuilderHelpGui.AddText("x24 y70 w492 h362", help)
    BuilderHelpGui.SetFont("s10 Norm", BuilderHeadingFont)
    close := BuilderDarkButton(BuilderHelpGui, 352, 448, 164, 32, "GOT IT", 8, "Success")
    BuilderButtons[close.Hwnd] := {control: close, primary: true, active: false}
    close.OnEvent("Click", CloseBuilderHelp)
    BuilderHelpGui.OnEvent("Close", CloseBuilderHelp)
    BuilderHelpGui.OnEvent("Escape", CloseBuilderHelp)
    MainGui.Opt("+Disabled")
    BuilderHelpGui.Show("w540 h500")
}

CloseBuilderHelp(*) {
    global MainGui, BuilderHelpGui, BuilderButtons
    MainGui.Opt("-Disabled")
    if BuilderHelpGui {
        for control in BuilderHelpGui
            if BuilderButtons.Has(control.Hwnd)
                BuilderButtons.Delete(control.Hwnd)
        BuilderHelpGui.Destroy()
    }
    BuilderHelpGui := false
    MainGui.Show()
}
RegisterBuilderListHeader(control, titles) {
    global BuilderHeaders
    headerHwnd := SendMessage(0x101F, 0, 0, control)
    if !headerHwnd
        return false

    ; Headers notify the ListView that owns them, not the main GUI window.
    ; Subclass only that parent and leave ordinary ListView messages alone.
    BuilderHeaders[headerHwnd] := {control: control, titles: titles}
    installed := DllCall("comctl32\SetWindowSubclass", "Ptr", control.Hwnd,
        "Ptr", GetBuilderHeaderSubclassCallback(), "UPtr", 0x42544436, "UPtr", headerHwnd, "Int")
    if !installed {
        BuilderHeaders.Delete(headerHwnd)
        return false
    }
    return true
}

GetBuilderHeaderSubclassCallback() {
    ; Keep this callback alive until process exit, including window destruction.
    static callback := CallbackCreate(BuilderHeaderNotifySubclass, "", 6)
    return callback
}

BuilderHeaderNotifySubclass(hwnd, message, wParam, lParam, subclassId, headerHwnd) {
    global BuilderHeaders
    try {
        if message = 0x4E && lParam {
            sourceHwnd := NumGet(lParam, 0, "Ptr")
            if sourceHwnd = headerHwnd && BuilderHeaders.Has(sourceHwnd) {
                result := DrawBuilderHeader(lParam, BuilderHeaders[sourceHwnd])
                if Type(result) = "Integer"
                    return result
            }
        } else if message = 0x82 {
            ; WM_NCDESTROY is the final notification for this control.
            DllCall("comctl32\RemoveWindowSubclass", "Ptr", hwnd,
                "Ptr", GetBuilderHeaderSubclassCallback(), "UPtr", subclassId, "Int")
            if BuilderHeaders.Has(headerHwnd)
                BuilderHeaders.Delete(headerHwnd)
        }
    } catch {
        ; Native painting is still available if a window disappears mid-paint.
    }
    return DllCall("comctl32\DefSubclassProc", "Ptr", hwnd, "UInt", message,
        "UPtr", wParam, "Ptr", lParam, "Ptr")
}

DrawBuilderHeader(data, header) {
    if NumGet(data, A_PtrSize * 2, "Int") != -12
        return
    headerSize := A_PtrSize = 8 ? 24 : 12
    stage := NumGet(data, headerSize, "UInt")
    if stage != 1 && stage != 2 && stage != 0x10001
        return
    dcOffset := A_PtrSize = 8 ? 32 : 16
    dc := NumGet(data, dcOffset, "Ptr")
    rect := data + dcOffset + A_PtrSize
    if stage = 2 {
        ; Windows paints unused header space after the item callbacks. Cover
        ; that last strip too, including after columns are resized or scrolled.
        headerHwnd := NumGet(data, 0, "Ptr")
        clientRect := Buffer(16, 0)
        lastItemRect := Buffer(16, 0)
        DllCall("GetClientRect", "Ptr", headerHwnd, "Ptr", clientRect.Ptr)
        if header.titles.Length && DllCall("SendMessageW", "Ptr", headerHwnd,
            "UInt", 0x1207, "UPtr", header.titles.Length - 1, "Ptr", lastItemRect.Ptr, "Ptr")
            NumPut("Int", Max(0, NumGet(lastItemRect, 8, "Int")), clientRect, 0)
        if NumGet(clientRect, 0, "Int") < NumGet(clientRect, 8, "Int") {
            brush := DllCall("CreateSolidBrush", "UInt", BuilderBGR("19212B"), "Ptr")
            DllCall("FillRect", "Ptr", dc, "Ptr", clientRect.Ptr, "Ptr", brush)
            DllCall("DeleteObject", "Ptr", brush)
        }
        return 0
    }
    brush := DllCall("CreateSolidBrush", "UInt", BuilderBGR("19212B"), "Ptr")
    DllCall("FillRect", "Ptr", dc, "Ptr", rect, "Ptr", brush)
    DllCall("DeleteObject", "Ptr", brush)
    if stage = 1
        return 0x30
    index := NumGet(data, dcOffset + A_PtrSize + 16, "UPtr") + 1
    if index > header.titles.Length
        return 4
    textRect := Buffer(16)
    DllCall("RtlMoveMemory", "Ptr", textRect.Ptr, "Ptr", rect, "UPtr", 16)
    NumPut("Int", NumGet(textRect, 0, "Int") + 8, textRect, 0)
    font := SendMessage(0x31, 0, 0, header.control)
    previous := DllCall("SelectObject", "Ptr", dc, "Ptr", font, "Ptr")
    DllCall("SetBkMode", "Ptr", dc, "Int", 1)
    DllCall("SetTextColor", "Ptr", dc, "UInt", BuilderBGR("B3BFCC"))
    DllCall("DrawTextW", "Ptr", dc, "Str", header.titles[index], "Int", -1, "Ptr", textRect.Ptr, "UInt", 0x24)
    DllCall("SelectObject", "Ptr", dc, "Ptr", previous)
    return 4
}

#Requires AutoHotkey v2.0


global UIHelpGui := ""
global UIHelpBadges := []


CreateHelpBadge(
    guiObject,
    x,
    y,
    title,
    body,
    size := 16
) {
    global UIHelpBadges


    fontSize :=
        Max(
            7,
            Round(size * 0.45)
        )


    badge :=
        CreateDarkButton(
            guiObject,
            x,
            y,
            size,
            size,
            "?",
            fontSize
        )


    badge.OnEvent(
        "Click",
        ShowContextHelp.Bind(
            title,
            body
        )
    )


    UIHelpBadges.Push(
        badge
    )


    return badge
}


CreateHelpBadgeForButton(
    guiObject,
    buttonObject,
    title,
    body
) {
    ; Keep the normal button at its original size and preserve every
    ; visual layer. The help badge simply overlays the upper-right corner.
    size :=
        Floor(
            Min(
                buttonObject.Height * 0.27,
                buttonObject.Width * 0.075
            )
        )


    ; Keep the same dynamic sizing, but make the badge exactly 4 px
    ; larger than the previous 10-12 px range.
    size :=
        Min(
            16,
            Max(
                14,
                size + 4
            )
        )


    inset := 3


    badgeX :=
        buttonObject.X
        + buttonObject.Width
        - size
        - inset


    badgeY :=
        buttonObject.Y
        + inset


    badge :=
        CreateHelpBadge(
            guiObject,
            badgeX,
            badgeY,
            title,
            body,
            size
        )


    ; Register the actual help control HWND instead of a calculated GUI
    ; rectangle. This avoids DPI/coordinate mismatches and makes the parent
    ; reliably ignore the exact click that belongs to the help badge.
    buttonObject.AddClickExclusionControl(
        badge.TextControl,
        1,
        ObjBindMethod(
            badge,
            "HandleClick"
        )
    )


    return badge
}


GetHelpLabelTextWidth(labelObject) {
    control := labelObject.MainControl
    fallback := Max(20, StrLen(control.Text) * 7)

    hdc := DllCall(
        "GetDC",
        "Ptr", control.Hwnd,
        "Ptr"
    )

    if !hdc {
        return fallback
    }

    hfont := DllCall(
        "SendMessage",
        "Ptr", control.Hwnd,
        "UInt", 0x31,
        "Ptr", 0,
        "Ptr", 0,
        "Ptr"
    )

    oldFont := 0

    if hfont {
        oldFont := DllCall(
            "SelectObject",
            "Ptr", hdc,
            "Ptr", hfont,
            "Ptr"
        )
    }

    sizeBuffer := Buffer(8, 0)
    measured := DllCall(
        "GetTextExtentPoint32W",
        "Ptr", hdc,
        "Str", control.Text,
        "Int", StrLen(control.Text),
        "Ptr", sizeBuffer.Ptr,
        "Int"
    )

    if oldFont {
        DllCall(
            "SelectObject",
            "Ptr", hdc,
            "Ptr", oldFont
        )
    }

    DllCall(
        "ReleaseDC",
        "Ptr", control.Hwnd,
        "Ptr", hdc
    )

    if !measured {
        return fallback
    }

    return NumGet(sizeBuffer, 0, "Int")
}


CreateHelpBadgeForField(
    guiObject,
    fieldObject,
    labelObject,
    title,
    body,
    size := 16,
    gap := 6
) {
    ; Field help belongs to the label, not the far edge of the dropdown.
    ; Nudge the complete outlined label group down slightly so its visual
    ; baseline lines up with the centered ? button beside it. Do this only
    ; once even if the same label is reused.
    if !labelObject.HasOwnProp("HelpBaselineAdjusted") {
        for control in labelObject.Controls {
            control.GetPos(&controlX, &controlY)
            control.Move(controlX, controlY + 4)
        }

        labelObject.HelpBaselineAdjusted := true
    }

    ; Measure the rendered label text so the ? follows immediately after it
    ; even when labels have different lengths.
    labelObject.MainControl.GetPos(
        &labelX,
        &labelY,
        &labelWidth,
        &labelHeight
    )

    textWidth := GetHelpLabelTextWidth(labelObject)

    badgeX := labelX + textWidth + gap
    maxX := fieldObject.X + fieldObject.Width - size

    if badgeX > maxX {
        badgeX := maxX
    }

    ; Anchor every field-help badge to the shared label-action row instead
    ; of moving it down with the label text. This lets the outlined text
    ; sit a few pixels lower while the ?, favorite star, and favorite ?
    ; remain perfectly aligned with each other.
    badgeY := fieldObject.Y - size - 6

    return CreateHelpBadge(
        guiObject,
        badgeX,
        badgeY,
        title,
        body,
        size
    )
}


CreateHelpBadgeForHeader(
    guiObject,
    guiWidth,
    title,
    body,
    top := 18,
    rightMargin := 20,
    size := 16
) {
    return CreateHelpBadge(
        guiObject,
        guiWidth
        - rightMargin
        - size,
        top,
        title,
        body,
        size
    )
}


ShowContextHelp(
    title,
    body,
    *
) {
    global UIHelpGui

    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText


    CloseAllDarkDropdowns()


    try {
        if UIHelpGui
            UIHelpGui.Destroy()
    }


    UIHelpGui :=
        Gui(
            "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
            "Help"
        )


    UIHelpGui.BackColor :=
        UIColorBackground


    EnableCustomWindowChrome(UIHelpGui)
    AddCustomWindowBorder(UIHelpGui, 520, 330)


    AddUIOutlinedText(
        UIHelpGui,
        title,
        24,
        20,
        472,
        34,
        12,
        "Center"
    )


    SetUIBodyFont(
        UIHelpGui,
        11,
        UIColorSecondaryText
    )


    UIHelpGui.Add(
        "Text",
        "x36 y74 w448 h176 Left c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        body
    )


    closeButton :=
        CreateDarkButton(
            UIHelpGui,
            130,
            270,
            260,
            44,
            "GOT IT",
            9
        )


    closeButton.OnEvent(
        "Click",
        CloseContextHelp
    )


    UIHelpGui.OnEvent(
        "Close",
        CloseContextHelp
    )


    UIHelpGui.OnEvent(
        "Escape",
        CloseContextHelp
    )


    UIHelpGui.Show(
        "Hide w520 h330"
    )


    ApplyDarkWindowStyle(
        UIHelpGui
    )


    UIHelpGui.Show(
        "w520 h330 Center"
    )
}


CloseContextHelp(*) {
    global UIHelpGui


    try {
        if UIHelpGui
            UIHelpGui.Destroy()
    }


    UIHelpGui := ""
}
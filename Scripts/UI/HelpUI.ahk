#Requires AutoHotkey v2.0


global UIHelpGui := ""
global UIHelpBadges := []


CreateHelpBadge(
    guiObject,
    x,
    y,
    title,
    body,
    size := 15
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


CreateHelpBadgeForField(
    guiObject,
    fieldObject,
    title,
    body,
    size := 15
) {
    ; Sit on the right side of the field's label row. Because this
    ; position is derived from the field itself it remains aligned
    ; when the field is moved or resized.
    return CreateHelpBadge(
        guiObject,
        fieldObject.X
        + fieldObject.Width
        - size,
        fieldObject.Y
        - size
        - 4,
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
    size := 15
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


    UIHelpGui.Add(
        "Progress",
        "x0 y0 w470 h4 c"
        . UIColorAccent
        . " Background"
        . UIColorAccent
        . " Disabled",
        100
    )


    AddUIOutlinedText(
        UIHelpGui,
        title,
        24,
        20,
        422,
        34,
        12,
        "Center"
    )


    SetUIBodyFont(
        UIHelpGui,
        10,
        UIColorSecondaryText
    )


    UIHelpGui.Add(
        "Text",
        "x34 y72 w402 h160 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        body
    )


    closeButton :=
        CreateDarkButton(
            UIHelpGui,
            120,
            248,
            230,
            42,
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
        "Hide w470 h312"
    )


    ApplyDarkWindowStyle(
        UIHelpGui
    )


    UIHelpGui.Show(
        "w470 h312 Center"
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
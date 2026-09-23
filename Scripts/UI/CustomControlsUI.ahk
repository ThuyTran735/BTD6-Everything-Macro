#Requires AutoHotkey v2.0


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


class DarkButton {

    __New(
        guiObject,
        x,
        y,
        width,
        height,
        text,
        fontSize := 8,
        style := ""
    ) {
        global UIColorBackground
        global UIColorControlBorder

        global UIColorControlTop
        global UIColorControlBottom
        global UIColorControlHighlight

        global UIFontHeading
        global UIColorControlText
        global UIDarkButtons


        this.Gui := guiObject

        this.X := x
        this.Y := y
        this.Width := width
        this.Height := height

        this.FontSize := fontSize

        this.AutoStyle := (style = "")
        this.Style := this.AutoStyle
            ? GetDarkButtonStyleForText(text)
            : style
        this.IsFlatFace := (this.Style = "Flat")

        this.ClickCallback := ""
        this.ClickExclusions := []
        this.LockTextOffset := false

        this.IsEnabled := true
        this._Visible := true

        this.ActionPending := false
        this.IsHovered := false
        this.BaseTextOffset := 0
        this.LastTextOffset := -999
        this.LastTextColor := UIColorControlText
        this.TextX := x
        this.TextWidth := width
        this.OverlayStableSurface := false
        this.ClickAnimationEnabled := true


        this.Glow := guiObject.Add(
            "Progress",
            "x"
            . (x - 2)
            . " y"
            . (y - 2)
            . " w"
            . (width + 4)
            . " h"
            . (height + 4)
            . " c"
            . UIColorBackground
            . " Background"
            . UIColorBackground
            . " Disabled",
            100
        )


        this.Border := guiObject.Add(
            "Progress",
            "x"
            . (x - 1)
            . " y"
            . (y - 1)
            . " w"
            . (width + 2)
            . " h"
            . (height + 2)
            . " c"
            . UIColorControlBorder
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            100
        )


        topHeight :=
            Ceil(
                height / 2
            )


        bottomHeight :=
            height
            - topHeight


        this.Top := guiObject.Add(
            "Progress",
            "x"
            . x
            . " y"
            . y
            . " w"
            . width
            . " h"
            . topHeight
            . " c"
            . UIColorControlTop
            . " Background"
            . UIColorControlTop
            . " Disabled",
            100
        )


        this.Bottom := guiObject.Add(
            "Progress",
            "x"
            . x
            . " y"
            . (y + topHeight)
            . " w"
            . width
            . " h"
            . bottomHeight
            . " c"
            . UIColorControlBottom
            . " Background"
            . UIColorControlBottom
            . " Disabled",
            100
        )


        this.Highlight := guiObject.Add(
            "Progress",
            "x"
            . (x + 1)
            . " y"
            . (y + 1)
            . " w"
            . (width - 2)
            . " h2 c"
            . UIColorControlHighlight
            . " Background"
            . UIColorControlHighlight
            . " Disabled",
            100
        )


        ; A Flat button uses one physical face control instead of two stacked
        ; Progress controls. Giving Top the full height and keeping Bottom
        ; hidden removes the native Progress edge that otherwise appears as a
        ; horizontal seam through wide footer/navigation buttons.
        if this.IsFlatFace {
            ; Progress controls carry a native 3D frame. With a full-height
            ; flat face that frame became the bright white/gray rectangle seen
            ; around BACK TO PROFILES. Remove the native frames and keep only
            ; our theme-colored custom border.
            this.Border.Opt("-0x800000 -E0x200 -E0x20000")
            this.Top.Opt("-0x800000 -E0x200 -E0x20000")
            this.Bottom.Opt("-0x800000 -E0x200 -E0x20000")
            this.Highlight.Opt("-0x800000 -E0x200 -E0x20000")

            this.Top.Move(x, y, width, height)
            this.Bottom.Visible := false
        }


        guiObject.SetFont(
            "s"
            . fontSize
            . " Norm c"
            . UIColorControlText,
            UIFontHeading
        )


        this.TextControl := guiObject.Add(
            "Text",
            "x"
            . x
            . " y"
            . y
            . " w"
            . width
            . " h"
            . height
            . " Center +0x200 BackgroundTrans",
            text
        )


        this.TextControl.OnEvent(
            "Click",
            ObjBindMethod(
                this,
                "HandleClick"
            )
        )


        UIDarkButtons.Push(this)
        StartUICustomControlSystem()
        this.ShowRestState()
    }


    Text {
        get => this.TextControl.Text

        set {
            this.TextControl.Text := value

            if this.AutoStyle {
                newStyle := GetDarkButtonStyleForText(value)

                if newStyle != this.Style {
                    this.Style := newStyle

                    if this.ActionPending {
                        this.ShowPressedState()
                    }
                    else if this.IsHovered && this.IsEnabled {
                        this.ShowHoverState()
                    }
                    else {
                        this.ShowRestState()
                    }
                }
            }
        }
    }


    Enabled {
        get => this.IsEnabled

        set {
            this.IsEnabled := value

            this.ActionPending := false


            this.ShowRestState()
        }
    }


    Visible {
        get => this._Visible

        set {
            this._Visible := value


            if !value {
                this.IsHovered := false
                this.ActionPending := false
            }

            this.Glow.Visible := value
            this.Border.Visible := value

            this.Top.Visible := value
            this.Bottom.Visible := value && !this.IsFlatFace

            this.Highlight.Visible := value
            this.TextControl.Visible := value

        }
    }


    OnEvent(
        eventName,
        callback
    ) {
        if eventName = "Click" {

            this.ClickCallback :=
                callback
        }


        return this
    }


    AddClickExclusion(
        x,
        y,
        width,
        height
    ) {
        this.ClickExclusions.Push(
            {
                Type: "Rect",
                X: x,
                Y: y,
                Width: width,
                Height: height
            }
        )


        return this
    }


    AddClickExclusionControl(
        controlObject,
        padding := 0,
        clickHandler := ""
    ) {
        this.ClickExclusions.Push(
            {
                Type: "Control",
                Control: controlObject,
                Padding: padding,
                ClickHandler: clickHandler
            }
        )


        return this
    }


    ProtectTopRightOverlay(
        overlayX,
        overlayY,
        overlayWidth,
        overlayHeight,
        padding := 1
    ) {
        ; Keep the button as one continuous visual surface. For buttons with
        ; an embedded help badge, avoid repainting that surface on hover/click
        ; and shrink only the transparent label's render rectangle so it never
        ; overlaps the badge. The label remains centered on the original button.
        cutRight := Max(this.X + 1, overlayX - padding)
        originalCenter := this.X + (this.Width / 2)
        textLeft := Round((2 * originalCenter) - cutRight)

        textLeft := Max(this.X, textLeft)
        textRight := Min(this.X + this.Width, cutRight)

        if textRight > textLeft {
            this.TextX := textLeft
            this.TextWidth := textRight - textLeft
            this.LastTextOffset := -999
            this.SetTextOffset(0)
        }

        this.OverlayStableSurface := true
        return this
    }


    LockTextPosition(baseOffset := 0) {
        ; Keep this label at one stable baseline while the button surface
        ; animates. This is especially important for overlapping help badges:
        ; moving or repeatedly repainting a large transparent text control can
        ; briefly cover smaller sibling controls.
        this.LockTextOffset := true
        this.BaseTextOffset := baseOffset
        this.LastTextOffset := -999
        this.SetTextOffset(0)
        return this
    }


    ApplyTextColor(color) {
        ; Avoid calling SetFont() on every hover/press/rest repaint when the
        ; color did not actually change. BackgroundTrans text controls can
        ; repaint a large area and cause overlapping ? badges to flash.
        if color = this.LastTextColor {
            return
        }

        this.LastTextColor := color
        this.TextControl.SetFont("Norm c" . color)
    }


    IsCursorInClickExclusion() {
        if this.ClickExclusions.Length = 0 {
            return false
        }


        point :=
            Buffer(
                8,
                0
            )


        if !DllCall(
            "GetCursorPos",
            "Ptr",
            point.Ptr,
            "Int"
        ) {
            return false
        }


        screenX :=
            NumGet(
                point,
                0,
                "Int"
            )


        screenY :=
            NumGet(
                point,
                4,
                "Int"
            )


        for exclusion in this.ClickExclusions {
            if (
                exclusion.HasOwnProp("Type")
                && exclusion.Type = "Control"
            ) {
                try controlHwnd := exclusion.Control.Hwnd
                catch {
                    continue
                }


                rect :=
                    Buffer(
                        16,
                        0
                    )


                if !DllCall(
                    "GetWindowRect",
                    "Ptr",
                    controlHwnd,
                    "Ptr",
                    rect.Ptr,
                    "Int"
                ) {
                    continue
                }


                padding :=
                    exclusion.HasOwnProp("Padding")
                    ? exclusion.Padding
                    : 0


                left := NumGet(rect, 0, "Int") - padding
                top := NumGet(rect, 4, "Int") - padding
                right := NumGet(rect, 8, "Int") + padding
                bottom := NumGet(rect, 12, "Int") + padding


                if (
                    screenX >= left
                    && screenX < right
                    && screenY >= top
                    && screenY < bottom
                ) {
                    return exclusion
                }


                continue
            }


            ; Legacy rectangle exclusions are kept for compatibility.
            clientPoint :=
                Buffer(
                    8,
                    0
                )


            NumPut("Int", screenX, clientPoint, 0)
            NumPut("Int", screenY, clientPoint, 4)


            if !DllCall(
                "ScreenToClient",
                "Ptr",
                this.Gui.Hwnd,
                "Ptr",
                clientPoint.Ptr,
                "Int"
            ) {
                continue
            }


            mouseX := NumGet(clientPoint, 0, "Int")
            mouseY := NumGet(clientPoint, 4, "Int")


            left := this.X + exclusion.X
            top := this.Y + exclusion.Y


            if (
                mouseX >= left
                && mouseX < left + exclusion.Width
                && mouseY >= top
                && mouseY < top + exclusion.Height
            ) {
                return exclusion
            }
        }


        return false
    }


    HandleClick(*) {
        if !this.IsEnabled {
            return
        }


        ; Help badges intentionally overlap the visual button. Keep the
        ; parent's full hitbox, but ignore only the exact pixels occupied
        ; by a registered badge so the rest of the right side still works.
        clickExclusion :=
            this.IsCursorInClickExclusion()


        if clickExclusion {
            ; An overlapping help badge may not receive the Windows click
            ; itself because the parent text layer occupies the same pixels.
            ; Route the click directly to the badge when one is registered so
            ; clicking the ? always opens help and never fires this button.
            if (
                clickExclusion.HasOwnProp("ClickHandler")
                && clickExclusion.ClickHandler
            ) {
                try clickExclusion.ClickHandler.Call()
            }


            return
        }


        if this.ActionPending {
            return
        }


        ; Long-running actions such as the manual GitHub update check should
        ; not repaint the custom Progress layers immediately before the GUI
        ; thread is blocked. Keeping the existing hover visual prevents the
        ; button text/help badge from briefly being painted underneath them.
        if !this.ClickAnimationEnabled {
            if this.ClickCallback {
                try this.ClickCallback.Call(this)
            }
            return
        }


        this.ActionPending := true


        this.ShowPressedState()


        SetTimer(
            ObjBindMethod(
                this,
                "ReleaseClick"
            ),
            -90
        )
    }


    ReleaseClick() {
        if !this.ActionPending {
            return
        }


        if !this.IsAlive() {

            this.ActionPending := false

            return
        }


        if this.IsHovered {
            this.ShowHoverState()
        }
        else {
            this.ShowRestState()
        }


        SetTimer(
            ObjBindMethod(
                this,
                "CompleteClick"
            ),
            -55
        )
    }


    CompleteClick() {
        if !this.ActionPending {
            return
        }


        this.ActionPending := false


        if !this.IsAlive() {
            return
        }


        if this.IsHovered {
            this.ShowHoverState()
        }
        else {
            this.ShowRestState()
        }


        if !this.ClickCallback {
            return
        }


        try {
            this.ClickCallback.Call(
                this
            )
        }
    }


    ShowPressedState() {
        global UIColorBackground
        global UIColorAccent
        global UIColorSuccess
        global UIColorError

        global UIColorControlPressedTop
        global UIColorControlPressedBottom
        global UIColorControlPressedHighlight
        global UIColorControlTop
        global UIColorControlBottom

        global UIColorControlText


        accentColor := UIColorAccent
        pressedTop := UIColorControlPressedTop
        pressedBottom := UIColorControlPressedBottom
        pressedHighlight := UIColorControlPressedHighlight


        if this.Style = "Success" || this.Style = "ToggleOn" {
            accentColor := UIColorSuccess
            pressedTop := BlendUIColors(UIColorControlTop, UIColorSuccess, 0.72)
            pressedBottom := BlendUIColors(UIColorControlBottom, UIColorSuccess, 0.58)
            pressedHighlight := UIColorSuccess
        }
        else if this.Style = "Danger" || this.Style = "ToggleOff" {
            accentColor := UIColorError
            pressedTop := BlendUIColors(UIColorControlTop, UIColorError, 0.72)
            pressedBottom := BlendUIColors(UIColorControlBottom, UIColorError, 0.58)
            pressedHighlight := UIColorError
        }
        else if this.Style = "Flat" {
            ; Flat footer/navigation buttons use one continuous face so
            ; the normal top/bottom split cannot read as a center seam.
            pressedBottom := pressedTop
        }


        SetUIProgressColor(
            this.Glow,
            BlendUIColors(
                UIColorBackground,
                accentColor,
                0.72
            )
        )


        SetUIProgressColor(
            this.Border,
            accentColor
        )


        if !this.OverlayStableSurface {
            SetUIProgressColor(
                this.Top,
                pressedTop
            )


            if !this.IsFlatFace {
                SetUIProgressColor(
                    this.Bottom,
                    pressedBottom
                )
            }
        }


        SetUIProgressColor(
            this.Highlight,
            pressedHighlight
        )


        this.ApplyTextColor(UIColorControlText)


        this.SetTextOffset(
            1
        )

    }

    ShowHoverState() {
        global UIColorBackground
        global UIColorAccent
        global UIColorSuccess
        global UIColorError
        global UIColorControlBorder
        global UIColorControlHoverTop
        global UIColorControlHoverBottom
        global UIColorControlHoverHighlight
        global UIColorControlText

        if !this.IsEnabled {
            return
        }

        accentColor := UIColorAccent
        hoverHighlight := UIColorControlHoverHighlight
        hoverBorder := BlendUIColors(UIColorControlBorder, UIColorAccent, 0.48)

        if this.Style = "Success" || this.Style = "ToggleOn" {
            accentColor := UIColorSuccess
            hoverHighlight := UIColorSuccess
            hoverBorder := BlendUIColors(UIColorControlBorder, UIColorSuccess, 0.58)
        }
        else if this.Style = "Danger" || this.Style = "ToggleOff" {
            accentColor := UIColorError
            hoverHighlight := UIColorError
            hoverBorder := BlendUIColors(UIColorControlBorder, UIColorError, 0.58)
        }

        ; Hover changes only the accent layers. Keeping the large button face
        ; stable prevents rapid mouse movement from exposing intermediate
        ; full-blue/green/red Progress frames or briefly hiding transparent
        ; button text. Click/pressed feedback still uses the full face.
        isCompact := this.Width <= 24 && this.Height <= 24

        if isCompact {
            hoverBorder := accentColor
            glowAmount := 0.34
        } else {
            glowAmount := 0.30
        }

        SetUIProgressColor(this.Glow, BlendUIColors(UIColorBackground, accentColor, glowAmount))
        SetUIProgressColor(this.Border, hoverBorder)
        SetUIProgressColor(this.Highlight, hoverHighlight)
        this.ApplyTextColor(UIColorControlText)

        ; Keep the label stationary on hover. The click animation still presses
        ; it down, but rapid hover transitions no longer move/redraw a large
        ; transparent text layer.
        this.SetTextOffset(0)
    }


    UpdateHover(
        mouseX,
        mouseY
    ) {
        if !this._Visible || !this.IsEnabled {
            if this.IsHovered {
                this.IsHovered := false
                this.ShowRestState()
            }
            return
        }

        ; Use the control's real screen rectangle. GUI logical coordinates can
        ; differ from GetCursorPos pixels under Windows DPI scaling, which made
        ; hover states appear above/below the actual button.
        hovered := (
            UIControlContainsScreenPoint(
                this.Border,
                mouseX,
                mouseY
            )
            && !this.IsCursorInClickExclusion()
        )

        if hovered = this.IsHovered {
            return
        }

        this.IsHovered := hovered

        if this.ActionPending {
            return
        }

        if hovered {
            this.ShowHoverState()
        } else {
            this.ShowRestState()
        }
    }


    ShowRestState() {
        global UIColorBackground
        global UIColorPanel
        global UIColorSuccess
        global UIColorError

        global UIColorControlBorder
        global UIColorControlTop
        global UIColorControlBottom
        global UIColorControlHighlight

        global UIColorControlText
        global UIColorControlDisabledText


        SetUIProgressColor(
            this.Glow,
            UIColorBackground
        )


        SetUIProgressColor(
            this.Border,
            UIColorControlBorder
        )


        if this.IsEnabled {

            restTop := UIColorControlTop
            restBottom := UIColorControlBottom
            restHighlight := UIColorControlHighlight
            restBorder := UIColorControlBorder


            if this.Style = "Success" {
                restHighlight := UIColorSuccess
            }
            else if this.Style = "Danger" {
                restHighlight := UIColorError
            }
            else if this.Style = "Flat" {
                restBottom := restTop
            }
            else if this.Style = "ToggleOn" {
                restTop := BlendUIColors(UIColorControlTop, UIColorSuccess, 0.58)
                restBottom := BlendUIColors(UIColorControlBottom, UIColorSuccess, 0.44)
                restHighlight := UIColorSuccess
                restBorder := BlendUIColors(UIColorControlBorder, UIColorSuccess, 0.72)
            }
            else if this.Style = "ToggleOff" {
                restTop := BlendUIColors(UIColorControlTop, UIColorError, 0.58)
                restBottom := BlendUIColors(UIColorControlBottom, UIColorError, 0.44)
                restHighlight := UIColorError
                restBorder := BlendUIColors(UIColorControlBorder, UIColorError, 0.72)
            }


            SetUIProgressColor(
                this.Border,
                restBorder
            )


            SetUIProgressColor(
                this.Top,
                restTop
            )


            if !this.IsFlatFace {
                SetUIProgressColor(
                    this.Bottom,
                    restBottom
                )
            }


            SetUIProgressColor(
                this.Highlight,
                restHighlight
            )


            this.ApplyTextColor(UIColorControlText)
        }
        else {

            SetUIProgressColor(
                this.Top,
                UIColorPanel
            )


            if !this.IsFlatFace {
                SetUIProgressColor(
                    this.Bottom,
                    UIColorPanel
                )
            }


            SetUIProgressColor(
                this.Highlight,
                UIColorControlBorder
            )


            this.ApplyTextColor(UIColorControlDisabledText)
        }


        this.SetTextOffset(
            0
        )

    }


    SetTextOffset(
        offset
    ) {
        if this.LockTextOffset {
            offset := 0
        }


        finalOffset := this.BaseTextOffset + offset


        if finalOffset = this.LastTextOffset {
            return
        }


        this.LastTextOffset := finalOffset


        this.TextControl.Move(
            this.TextX,
            this.Y + finalOffset,
            this.TextWidth,
            this.Height
        )
    }


    IsAlive() {
        try guiHwnd := this.Gui.Hwnd
        catch {
            return false
        }


        ; WinExist() ignores hidden windows unless DetectHiddenWindows is on.
        ; Custom controls are created while their GUI is still hidden, so the
        ; hover timer could permanently drop them before the window was shown.
        ; IsWindow() checks whether the HWND itself is valid regardless of
        ; visibility, keeping every button/list registered consistently.
        return !!DllCall(
            "IsWindow",
            "Ptr",
            guiHwnd,
            "Int"
        )
    }
}


GetDarkButtonStyleForText(text) {
    normalized := StrUpper(Trim(text))


    if RegExMatch(normalized, ":\s*ON$") {
        return "ToggleOn"
    }


    if RegExMatch(normalized, ":\s*OFF$") {
        return "ToggleOff"
    }


    if RegExMatch(normalized, "^(RUN|START|SELECT|USE)(\s|$)") {
        return "Success"
    }


    if RegExMatch(normalized, "^CLOSE(\s|$)") {
        return "Danger"
    }


    return "Default"
}


class DarkList {

    __New(
        guiObject,
        x,
        y,
        width,
        height,
        items := "",
        rowHeight := 36
    ) {
        global UIDarkLists

        global UIColorControlBorder
        global UIColorPopupBackground
        global UIColorControlText
        global UIFontBody


        this.Gui := guiObject

        this.X := x
        this.Y := y
        this.Width := width
        this.Height := height

        this.RowHeight := rowHeight

        this.Items := []

        this.SelectedIndex := 0
        this.HoveredSlot := 0
        this.ScrollOffset := 0

        this.ChangeCallback := ""
        this.DoubleClickCallback := ""

        this._Visible := true


        this.Border := guiObject.Add(
            "Progress",
            "x"
            . (x - 1)
            . " y"
            . (y - 1)
            . " w"
            . (width + 2)
            . " h"
            . (height + 2)
            . " c"
            . UIColorControlBorder
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            100
        )


        this.Background := guiObject.Add(
            "Progress",
            "x"
            . x
            . " y"
            . y
            . " w"
            . width
            . " h"
            . height
            . " c"
            . UIColorPopupBackground
            . " Background"
            . UIColorPopupBackground
            . " Disabled",
            100
        )


        this.Rows := []


        this.MaxRows :=
            Max(
                1,
                Floor(
                    height
                    / rowHeight
                )
            )


        Loop this.MaxRows {

            slot :=
                A_Index


            rowY :=
                y
                + (
                    (slot - 1)
                    * rowHeight
                )


            rowBackground := guiObject.Add(
                "Progress",
                "x"
                . (x + 1)
                . " y"
                . rowY
                . " w"
                . (width - 2)
                . " h"
                . rowHeight
                . " c"
                . UIColorPopupBackground
                . " Background"
                . UIColorPopupBackground
                . " Disabled",
                100
            )


            guiObject.SetFont(
                "s10 Norm c"
                . UIColorControlText,
                UIFontBody
            )


            rowText := guiObject.Add(
                "Text",
                "x"
                . (x + 1)
                . " y"
                . rowY
                . " w"
                . (width - 2)
                . " h"
                . rowHeight
                . " +0x200 BackgroundTrans",
                ""
            )


            rowText.OnEvent(
                "Click",
                ObjBindMethod(
                    this,
                    "SelectSlot",
                    slot
                )
            )


            rowText.OnEvent(
                "DoubleClick",
                ObjBindMethod(
                    this,
                    "DoubleClickSlot",
                    slot
                )
            )


            this.Rows.Push(
                {
                    Background: rowBackground,
                    Text: rowText,
                    ItemIndex: 0
                }
            )
        }


        UIDarkLists.Push(
            this
        )


        StartUICustomControlSystem()


        if IsObject(
            items
        ) {

            this.Add(
                items
            )
        }


        this.RefreshRows()
    }


    Value {
        get => this.SelectedIndex
    }


    Text {
        get {
            if (
                this.SelectedIndex >= 1
                && this.SelectedIndex
                    <= this.Items.Length
            ) {

                return this.Items[
                    this.SelectedIndex
                ]
            }


            return ""
        }
    }


    Visible {
        get => this._Visible

        set {
            this._Visible := value

            this.Border.Visible := value
            this.Background.Visible := value


            this.RefreshRows()
        }
    }


    OnEvent(
        eventName,
        callback
    ) {
        if eventName = "Change" {

            this.ChangeCallback :=
                callback
        }
        else if eventName = "DoubleClick" {

            this.DoubleClickCallback :=
                callback
        }


        return this
    }


    Delete() {
        this.Items := []

        this.SelectedIndex := 0
        this.HoveredSlot := 0
        this.ScrollOffset := 0


        this.RefreshRows()


        return this
    }


    Add(
        items
    ) {
        if !IsObject(
            items
        ) {
            return this
        }


        for item in items {

            this.Items.Push(
                item
            )
        }


        this.RefreshRows()


        return this
    }


    Choose(
        index,
        fireChange := false
    ) {
        if this.Items.Length = 0 {

            this.SelectedIndex := 0
            this.ScrollOffset := 0

            this.RefreshRows()


            return this
        }


        if index < 1 {
            index := 1
        }


        if index > this.Items.Length {
            index := this.Items.Length
        }


        changed :=
            this.SelectedIndex
            != index


        this.SelectedIndex :=
            index


        this.EnsureSelectedVisible()


        this.RefreshRows()


        if (
            changed
            && fireChange
        ) {

            this.FireChange()
        }


        return this
    }


    SelectSlot(
        slot,
        *
    ) {
        if (
            slot < 1
            || slot > this.Rows.Length
        ) {
            return
        }


        itemIndex :=
            this.Rows[
                slot
            ].ItemIndex


        if itemIndex < 1 {
            return
        }


        changed :=
            this.SelectedIndex
            != itemIndex


        this.SelectedIndex :=
            itemIndex


        this.RefreshRows()


        if changed {

            this.FireChange()
        }
    }


    DoubleClickSlot(
        slot,
        *
    ) {
        if (
            slot < 1
            || slot > this.Rows.Length
        ) {
            return
        }


        itemIndex :=
            this.Rows[
                slot
            ].ItemIndex


        if itemIndex < 1 {
            return
        }


        this.SelectedIndex :=
            itemIndex


        this.RefreshRows()


        if this.DoubleClickCallback {

            try {
                this.DoubleClickCallback.Call(
                    this
                )
            }
        }
    }


    FireChange() {
        if !this.ChangeCallback {
            return
        }


        try {
            this.ChangeCallback.Call(
                this
            )
        }
    }


    Scroll(
        direction
    ) {
        maxOffset :=
            Max(
                0,
                this.Items.Length
                - this.MaxRows
            )


        if maxOffset = 0 {
            return
        }


        if direction > 0 {

            this.ScrollOffset--
        }
        else {

            this.ScrollOffset++
        }


        if this.ScrollOffset < 0 {
            this.ScrollOffset := 0
        }


        if this.ScrollOffset > maxOffset {
            this.ScrollOffset := maxOffset
        }


        this.HoveredSlot := 0


        this.RefreshRows()
    }


    EnsureSelectedVisible() {
        if this.SelectedIndex < 1 {
            return
        }


        if this.SelectedIndex
            <= this.ScrollOffset {

            this.ScrollOffset :=
                this.SelectedIndex
                - 1
        }


        if this.SelectedIndex
            > this.ScrollOffset
                + this.MaxRows {

            this.ScrollOffset :=
                this.SelectedIndex
                - this.MaxRows
        }


        maxOffset :=
            Max(
                0,
                this.Items.Length
                - this.MaxRows
            )


        if this.ScrollOffset > maxOffset {
            this.ScrollOffset := maxOffset
        }


        if this.ScrollOffset < 0 {
            this.ScrollOffset := 0
        }
    }


    UpdateHover(
        mouseX,
        mouseY
    ) {
        if !this._Visible {
            if this.HoveredSlot {
                this.HoveredSlot := 0
                this.RefreshRows()
            }
            return
        }


        newHoveredSlot := 0


        ; Test each visible row against its real HWND rectangle so list hover
        ; remains exact at any Windows display scaling level.
        for slot, row in this.Rows {
            if (
                row.ItemIndex > 0
                && row.Text.Visible
                && (
                    UIControlContainsScreenPoint(
                        row.Text,
                        mouseX,
                        mouseY
                    )
                    || UIControlContainsScreenPoint(
                        row.Background,
                        mouseX,
                        mouseY
                    )
                )
            ) {
                newHoveredSlot := slot
                break
            }
        }


        if newHoveredSlot
            = this.HoveredSlot {

            return
        }


        oldHoveredSlot := this.HoveredSlot
        this.HoveredSlot := newHoveredSlot

        ; Hover only changes row backgrounds. Rebuilding every row's text,
        ; font, and visibility on a 16 ms timer caused visible flashing when
        ; the cursor crossed rows quickly.
        if oldHoveredSlot {
            this.RefreshRowVisual(oldHoveredSlot)
        }

        if newHoveredSlot {
            this.RefreshRowVisual(newHoveredSlot)
        }
    }


    ContainsScreenPoint(
        mouseX,
        mouseY
    ) {
        if !this._Visible {
            return false
        }


        return UIControlContainsScreenPoint(
            this.Border,
            mouseX,
            mouseY
        )
    }


    GetClientPoint(
        screenX,
        screenY
    ) {
        if !this.IsAlive() {
            return false
        }


        point := Buffer(
            8,
            0
        )


        NumPut(
            "Int",
            screenX,
            point,
            0
        )


        NumPut(
            "Int",
            screenY,
            point,
            4
        )


        if !DllCall(
            "ScreenToClient",
            "Ptr",
            this.Gui.Hwnd,
            "Ptr",
            point.Ptr,
            "Int"
        ) {
            return false
        }


        return [
            NumGet(
                point,
                0,
                "Int"
            ),
            NumGet(
                point,
                4,
                "Int"
            )
        ]
    }


    RefreshRowVisual(slot) {
        global UIColorPopupBackground
        global UIColorControlHoverTop
        global UIColorControlSelected
        global UIColorControlSelectedHover

        if slot < 1 || slot > this.Rows.Length {
            return
        }

        row := this.Rows[slot]

        if row.ItemIndex < 1 || !row.Background.Visible {
            return
        }

        if (
            row.ItemIndex = this.SelectedIndex
            && slot = this.HoveredSlot
        ) {
            color := UIColorControlSelectedHover
        }
        else if row.ItemIndex = this.SelectedIndex {
            color := UIColorControlSelected
        }
        else if slot = this.HoveredSlot {
            color := UIColorControlHoverTop
        }
        else {
            color := UIColorPopupBackground
        }

        SetUIProgressColor(row.Background, color)
    }


    RefreshRows() {
        global UIColorPopupBackground
        global UIColorControlHoverTop
        global UIColorControlSelected
        global UIColorControlSelectedHover
        global UIColorControlText


        for slot, row in this.Rows {

            itemIndex :=
                this.ScrollOffset
                + slot


            if itemIndex
                <= this.Items.Length {

                row.ItemIndex :=
                    itemIndex


                row.Text.Text :=
                    "   "
                    . this.Items[
                        itemIndex
                    ]


                if (
                    itemIndex
                        = this.SelectedIndex
                    && slot
                        = this.HoveredSlot
                ) {

                    SetUIProgressColor(
                        row.Background,
                        UIColorControlSelectedHover
                    )
                }
                else if (
                    itemIndex
                        = this.SelectedIndex
                ) {

                    SetUIProgressColor(
                        row.Background,
                        UIColorControlSelected
                    )
                }
                else if (
                    slot
                        = this.HoveredSlot
                ) {

                    SetUIProgressColor(
                        row.Background,
                        UIColorControlHoverTop
                    )
                }
                else {

                    SetUIProgressColor(
                        row.Background,
                        UIColorPopupBackground
                    )
                }


                row.Text.SetFont(
                    "c"
                    . UIColorControlText
                )


                row.Background.Visible :=
                    this._Visible


                row.Text.Visible :=
                    this._Visible
            }
            else {

                row.ItemIndex := 0

                row.Text.Text := ""

                row.Background.Visible :=
                    false


                row.Text.Visible :=
                    false
            }
        }
    }


    IsAlive() {
        try guiHwnd := this.Gui.Hwnd
        catch {
            return false
        }


        ; WinExist() ignores hidden windows unless DetectHiddenWindows is on.
        ; Custom controls are created while their GUI is still hidden, so the
        ; hover timer could permanently drop them before the window was shown.
        ; IsWindow() checks whether the HWND itself is valid regardless of
        ; visibility, keeping every button/list registered consistently.
        return !!DllCall(
            "IsWindow",
            "Ptr",
            guiHwnd,
            "Int"
        )
    }
}


UIControlContainsScreenPoint(
    controlObject,
    screenX,
    screenY
) {
    try controlHwnd := controlObject.Hwnd
    catch {
        return false
    }


    rect := Buffer(16, 0)


    if !DllCall(
        "GetWindowRect",
        "Ptr", controlHwnd,
        "Ptr", rect.Ptr,
        "Int"
    ) {
        return false
    }


    left := NumGet(rect, 0, "Int")
    top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int")
    bottom := NumGet(rect, 12, "Int")


    return (
        screenX >= left
        && screenX < right
        && screenY >= top
        && screenY < bottom
    )
}


StartUICustomControlSystem() {
    global UICustomControlTimerStarted
    global UICustomControlMessagesStarted


    if !UICustomControlTimerStarted {

        UICustomControlTimerStarted :=
            true


        SetTimer(
            PollUICustomControls,
            16
        )
    }


    if !UICustomControlMessagesStarted {

        UICustomControlMessagesStarted :=
            true


        OnMessage(
            0x20A,
            UICustomControlMouseWheel
        )
    }
}


PollUICustomControls() {
    global UIDarkLists
    global UIDarkButtons
    global UIDarkActiveDropdown


    cursorPoint := Buffer(
        8,
        0
    )


    if !DllCall(
        "GetCursorPos",
        "Ptr",
        cursorPoint.Ptr,
        "Int"
    ) {
        return
    }


    mouseX :=
        NumGet(
            cursorPoint,
            0,
            "Int"
        )


    mouseY :=
        NumGet(
            cursorPoint,
            4,
            "Int"
        )


    ; An open dropdown only owns hover inside the popup rectangle itself.
    ; Controls elsewhere in the owner UI should continue responding normally.
    ; This prevents controls physically covered by the popup from highlighting
    ; through it without freezing unrelated controls around the dropdown.
    backgroundHoverBlocked := false

    if IsSet(UIDarkActiveDropdown) && IsObject(UIDarkActiveDropdown) {
        try {
            backgroundHoverBlocked := (
                UIDarkActiveDropdown.IsOpen
                && UIDarkActiveDropdown.PopupContainsScreenPoint(
                    mouseX,
                    mouseY
                )
            )
        }
    }

    hoverX := backgroundHoverBlocked ? -2147483648 : mouseX
    hoverY := backgroundHoverBlocked ? -2147483648 : mouseY


    activeButtons := []


    for button in UIDarkButtons {
        isAlive := false

        try isAlive := button.IsAlive()

        if !isAlive {
            continue
        }

        ; Keep a valid control registered even if one visual refresh happens
        ; during a GUI state transition. A transient draw/move error should not
        ; permanently remove a button from hover tracking.
        activeButtons.Push(button)

        try button.UpdateHover(hoverX, hoverY)
    }


    UIDarkButtons := activeButtons


    activeLists := []


    for list in UIDarkLists {
        isAlive := false

        try isAlive := list.IsAlive()

        if !isAlive {
            continue
        }

        ; As with buttons, only an invalid window handle removes a list from
        ; tracking. Temporary refresh errors no longer disable future hovers.
        activeLists.Push(list)

        try list.UpdateHover(
            hoverX,
            hoverY
        )
    }


    UIDarkLists :=
        activeLists
}


UICustomControlMouseWheel(
    wParam,
    lParam,
    msg,
    hwnd
) {
    global UIDarkLists


    cursorPoint := Buffer(
        8,
        0
    )


    if !DllCall(
        "GetCursorPos",
        "Ptr",
        cursorPoint.Ptr,
        "Int"
    ) {
        return
    }


    mouseX :=
        NumGet(
            cursorPoint,
            0,
            "Int"
        )


    mouseY :=
        NumGet(
            cursorPoint,
            4,
            "Int"
        )


    delta :=
        (
            wParam >> 16
        )
        & 0xFFFF


    if delta > 0x7FFF {
        delta -= 0x10000
    }


    for list in UIDarkLists {

        try {
            if (
                list.IsAlive()
                && list.ContainsScreenPoint(
                    mouseX,
                    mouseY
                )
            ) {

                list.Scroll(
                    delta
                )


                return 0
            }
        }
    }
}


BlendUIColors(
    colorA,
    colorB,
    amount
) {
    amount :=
        Max(
            0,
            Min(
                1,
                amount
            )
        )


    r1 :=
        Integer(
            "0x"
            . SubStr(
                colorA,
                1,
                2
            )
        )


    g1 :=
        Integer(
            "0x"
            . SubStr(
                colorA,
                3,
                2
            )
        )


    b1 :=
        Integer(
            "0x"
            . SubStr(
                colorA,
                5,
                2
            )
        )


    r2 :=
        Integer(
            "0x"
            . SubStr(
                colorB,
                1,
                2
            )
        )


    g2 :=
        Integer(
            "0x"
            . SubStr(
                colorB,
                3,
                2
            )
        )


    b2 :=
        Integer(
            "0x"
            . SubStr(
                colorB,
                5,
                2
            )
        )


    r :=
        Round(
            r1
            + (
                (r2 - r1)
                * amount
            )
        )


    g :=
        Round(
            g1
            + (
                (g2 - g1)
                * amount
            )
        )


    b :=
        Round(
            b1
            + (
                (b2 - b1)
                * amount
            )
        )


    return Format(
        "{:02X}{:02X}{:02X}",
        r,
        g,
        b
    )
}


SetUIProgressColor(
    progressControl,
    color
) {
    static colorCache := Map()

    try {
        hwnd := progressControl.Hwnd
        normalizedColor := StrUpper(color)

        if (
            colorCache.Has(hwnd)
            && colorCache[hwnd] = normalizedColor
        ) {
            return
        }

        colorCache[hwnd] := normalizedColor

        ; Keep AutoHotkey in charge of Progress styling. Direct PBM color
        ; messages can make themed Progress controls fall back to a flat gray
        ; surface after the first hover transition.
        progressControl.Opt(
            "c"
            . normalizedColor
            . " Background"
            . normalizedColor
        )

        progressControl.Value := 100
        progressControl.Redraw()
    }
}
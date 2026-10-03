#Requires AutoHotkey v2.0

; v3 file note: Draws and manages the custom dark button control.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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



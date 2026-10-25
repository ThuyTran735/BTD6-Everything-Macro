#Requires AutoHotkey v2.0

; The builder uses the launcher's actual controls. These small adapters add
; the sizing and selection methods that its resizable forms need.
class BuilderDarkDropdown extends DarkDropdown {
    __New(guiObject, x, y, width, items := "", chooseIndex := 1, maxVisibleRows := 5) {
        super.__New(guiObject, x, y, width, items, chooseIndex, maxVisibleRows)
        this.RemoveNativeFrames()
    }

    Hwnd {
        get => this.MainText.Hwnd
    }

    Type {
        get => "DropDownList"
    }

    Value {
        get => this.SelectedIndex
        set => this.Choose(value)
    }

    Text {
        get => super.Text
        set => this.Choose(value)
    }

    Visible {
        get => this._Visible
        set {
            value := !!value
            if value = this._Visible
                return
            super.Visible := value
        }
    }

    Enabled {
        get => this.IsEnabled
        set {
            value := !!value
            if value = this.IsEnabled
                return
            super.Enabled := value
        }
    }

    FindItem(text) {
        for index, item in this.Items {
            if item = text
                return index
        }
        return 0
    }

    Choose(index, fireChange := false) {
        if !IsInteger(index) {
            index := this.FindItem(index)
            if !index
                return this
        }
        return super.Choose(index, fireChange)
    }

    GetPos(&x?, &y?, &width?, &height?) {
        x := this.X
        y := this.Y
        width := this.Width
        height := this.Height
    }

    Move(x?, y?, width?, height?) {
        if (!IsSet(x) || x = this.X) && (!IsSet(y) || y = this.Y)
            && (!IsSet(width) || width = this.Width) && (!IsSet(height) || height = this.Height)
            return this
        ; Closing before a resize prevents the old popup from covering a field
        ; that has moved. The next open uses the trigger's current rectangle.
        this.Close()
        if IsSet(x)
            this.X := x
        if IsSet(y)
            this.Y := y
        if IsSet(width)
            this.Width := Max(40, width)
        if IsSet(height)
            this.Height := Max(24, height)

        topHeight := Ceil(this.Height / 2)
        this.Border.Move(this.X - 1, this.Y - 1, this.Width + 2, this.Height + 2)
        this.Top.Move(this.X, this.Y, this.Width, topHeight)
        this.Bottom.Move(this.X, this.Y + topHeight, this.Width, this.Height - topHeight)
        this.MainText.Move(this.X, this.Y, Max(1, this.Width - 38), this.Height)
        this.Arrow.Move(this.X + this.Width - 38, this.Y, 30, this.Height)

        contentWidth := this.GetContentWidth()
        for row in this.Rows {
            row.Background.Move(,, contentWidth, this.RowHeight)
            row.Text.Move(,, contentWidth, this.RowHeight)
        }
        this.UpdateScrollbar()
        this.RemoveNativeFrames()
        return this
    }

    RefreshMainVisual() {
        super.RefreshMainVisual()
        this.RemoveNativeFrames()
    }

    RemoveNativeFrames() {
        ; These surfaces provide their own outline. Some native redraws can
        ; restore an edge; only change controls whose style actually changed.
        surfaces := [this.Border, this.Top, this.Bottom, this.PopupBackground, this.ScrollTrack, this.ScrollThumb]
        for row in this.Rows
            surfaces.Push(row.Background)
        for surface in surfaces {
            style := DllCall("GetWindowLongPtr", "Ptr", surface.Hwnd, "Int", -16, "Ptr")
            extended := DllCall("GetWindowLongPtr", "Ptr", surface.Hwnd, "Int", -20, "Ptr")
            if (style & 0x800000) || (extended & 0x20200)
                surface.Opt("-0x800000 -E0x200 -E0x20000")
        }
    }

    Focus() {
        this.MainText.Focus()
    }

    SetFont(options := "", fontName := "") {
        if fontName != ""
            this.FontName := fontName
        if RegExMatch(options, "i)(?:^|\s)s(\d+(?:\.\d+)?)(?:\s|$)", &size)
            this.FontSize := size[1] + 0
        this.MainText.SetFont(options, fontName)
        this.Arrow.SetFont(options, fontName)
        return this
    }
}

class BuilderDarkButton extends DarkButton {
    ; Keep the launcher's press animation and label movement. The form batches
    ; its own redraws separately when an action changes the visible fields.
    __New(guiObject, x, y, width, height, text, fontSize := 8, style := "") {
        super.__New(guiObject, x, y, width, height, text, fontSize, style)
        ; Help badges narrow the caption, but the whole button should still
        ; accept clicks. Keep this stationary layer behind the animated text.
        this.HitControl := guiObject.AddText("x" x " y" y " w" width " h" height " BackgroundTrans", "")
        this.HitControl.OnEvent("Click", ObjBindMethod(this, "HandleClick"))
        DllCall("SetWindowPos", "Ptr", this.HitControl.Hwnd, "Ptr", this.TextControl.Hwnd,
            "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
    }

    Hwnd {
        get => this.TextControl.Hwnd
    }

    Type {
        get => "Button"
    }

    Visible {
        get => this._Visible
        set {
            value := !!value
            if value = this._Visible
                return
            super.Visible := value
            this.HitControl.Visible := value
        }
    }

    Enabled {
        get => this.IsEnabled
        set {
            value := !!value
            if value = this.IsEnabled
                return
            super.Enabled := value
            this.HitControl.Enabled := value
        }
    }

    GetPos(&x?, &y?, &width?, &height?) {
        x := this.X
        y := this.Y
        width := this.Width
        height := this.Height
    }

    Move(x?, y?, width?, height?) {
        if (!IsSet(x) || x = this.X) && (!IsSet(y) || y = this.Y)
            && (!IsSet(width) || width = this.Width) && (!IsSet(height) || height = this.Height)
            return this
        ; Preserve any space reserved for an overlapping ? badge. Its parent
        ; remains one button, including after the window becomes wider.
        leftInset := this.TextX - this.X
        rightInset := this.Width - leftInset - this.TextWidth
        if IsSet(x)
            this.X := x
        if IsSet(y)
            this.Y := y
        if IsSet(width)
            this.Width := Max(12, width)
        if IsSet(height)
            this.Height := Max(12, height)

        topHeight := this.IsFlatFace ? this.Height : Ceil(this.Height / 2)
        this.Glow.Move(this.X - 2, this.Y - 2, this.Width + 4, this.Height + 4)
        this.Border.Move(this.X - 1, this.Y - 1, this.Width + 2, this.Height + 2)
        this.Top.Move(this.X, this.Y, this.Width, topHeight)
        this.Bottom.Move(this.X, this.Y + Ceil(this.Height / 2), this.Width, Floor(this.Height / 2))
        this.Highlight.Move(this.X + 1, this.Y + 1, this.Width - 2, 2)
        this.HitControl.Move(this.X, this.Y, this.Width, this.Height)
        ; Native edges only need repair if a style actually changed. Forcing a
        ; frame recalculation on every layer makes even a small resize flash.
        for surface in [this.Glow, this.Border, this.Top, this.Bottom, this.Highlight] {
            nativeStyle := DllCall("GetWindowLongPtr", "Ptr", surface.Hwnd, "Int", -16, "Ptr")
            extended := DllCall("GetWindowLongPtr", "Ptr", surface.Hwnd, "Int", -20, "Ptr")
            if (nativeStyle & 0x800000) || (extended & 0x20200)
                surface.Opt("-0x800000 -E0x200 -E0x20000")
        }
        this.TextX := this.X + leftInset
        this.TextWidth := Max(1, this.Width - leftInset - rightInset)
        this.LastTextOffset := -999
        this.SetTextOffset(0)
        return this
    }

    Focus() {
        this.TextControl.Focus()
    }

    SetFont(options := "", fontName := "") {
        if fontName != ""
            this.FontName := fontName
        if RegExMatch(options, "i)(?:^|\s)s(\d+(?:\.\d+)?)(?:\s|$)", &size)
            this.FontSize := size[1] + 0
        this.TextControl.SetFont(options, fontName)
        return this
    }
}

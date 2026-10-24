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
        this.MainText.Move(this.X, this.Y, this.Width, this.Height)
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
        this.MainText.SetFont(options, fontName)
        this.Arrow.SetFont(options, fontName)
        return this
    }

    Open() {
        global UIDarkActiveDropdown
        if !this.IsEnabled || !this._Visible || this.Items.Length <= 1
            return

        CloseOtherDarkDropdowns(this)
        UIDarkActiveDropdown := this
        this.IsOpen := true
        this.EnsureSelectedVisible()
        this.RefreshRows()

        popupHeight := Min(this.Items.Length, this.MaxVisibleRows) * this.RowHeight + 2
        this.UpdateScrollbar(popupHeight)
        this.PopupBackground.Move(1, 1, this.Width - 2, popupHeight - 2)
        contentWidth := this.GetContentWidth()
        for row in this.Rows {
            row.Background.Move(,, contentWidth, this.RowHeight)
            row.Text.Move(,, contentWidth, this.RowHeight)
            row.Background.Visible := row.ItemIndex > 0
            row.Text.Visible := row.ItemIndex > 0
        }

        ; GetWindowRect uses screen pixels, while Gui layout uses DPI-scaled
        ; units. Anchoring to the real trigger avoids a shifted popup at 125%.
        rect := Buffer(16, 0)
        if !DllCall("GetWindowRect", "Ptr", this.MainText.Hwnd, "Ptr", rect, "Int") {
            this.Close()
            return
        }
        scale := DllCall("GetDpiForWindow", "Ptr", this.PopupGui.Hwnd, "UInt") / 96
        screenX := NumGet(rect, 0, "Int")
        screenY := NumGet(rect, 12, "Int") + Round(4 * scale)
        pixelHeight := Round(popupHeight * scale)
        pixelWidth := Round(this.Width * scale)

        ; Lower fields open upward when there is not enough room above the
        ; taskbar. Keep the entire menu on the builder's current monitor.
        monitor := DllCall("MonitorFromWindow", "Ptr", this.Gui.Hwnd, "UInt", 2, "Ptr")
        monitorInfo := Buffer(40, 0)
        NumPut("UInt", 40, monitorInfo)
        if DllCall("GetMonitorInfoW", "Ptr", monitor, "Ptr", monitorInfo, "Int") {
            workLeft := NumGet(monitorInfo, 20, "Int")
            workTop := NumGet(monitorInfo, 24, "Int")
            workRight := NumGet(monitorInfo, 28, "Int")
            workBottom := NumGet(monitorInfo, 32, "Int")
            screenX := Max(workLeft, Min(screenX, workRight - pixelWidth))
            if screenY + pixelHeight > workBottom
                screenY := NumGet(rect, 4, "Int") - pixelHeight - Round(4 * scale)
            screenY := Max(workTop, Min(screenY, workBottom - pixelHeight))
        }

        this.PopupGui.Show("NA x" screenX " y" screenY " w" this.Width " h" popupHeight)
        this.Arrow.Text := "▲"
        this.RefreshMainVisual()
    }
}

class BuilderDarkButton extends DarkButton {
    ; Keep the launcher's press animation and label movement. The form batches
    ; its own redraws separately when an action changes the visible fields.
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

    GetPos(&x?, &y?, &width?, &height?) {
        x := this.X
        y := this.Y
        width := this.Width
        height := this.Height
    }

    Move(x?, y?, width?, height?) {
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
        ; Resizing a Progress surface can restore its native edge. Keep the
        ; launcher's drawn borders, including between the two face layers.
        for surface in [this.Glow, this.Border, this.Top, this.Bottom, this.Highlight] {
            surface.Opt("-0x800000 -E0x200 -E0x20000")
            DllCall("SetWindowPos", "Ptr", surface.Hwnd, "Ptr", 0,
                "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x37)
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
        this.TextControl.SetFont(options, fontName)
        return this
    }
}

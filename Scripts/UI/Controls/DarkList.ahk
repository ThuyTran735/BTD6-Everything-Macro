#Requires AutoHotkey v2.0

; v3 file note: Draws and manages the custom dark list control.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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



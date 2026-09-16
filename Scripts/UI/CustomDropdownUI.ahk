#Requires AutoHotkey v2.0


global UIDarkDropdowns := []

global UIDarkDropdownTimerStarted := false
global UIDarkDropdownMouseWasDown := false
global UIDarkDropdownWheelHookStarted := false


CreateDarkDropdown(
    guiObject,
    x,
    y,
    width,
    items := "",
    chooseIndex := 1,
    maxVisibleRows := 5
) {
    return DarkDropdown(
        guiObject,
        x,
        y,
        width,
        items,
        chooseIndex,
        maxVisibleRows
    )
}


class DarkDropdown {

    __New(
        guiObject,
        x,
        y,
        width,
        items := "",
        chooseIndex := 1,
        maxVisibleRows := 5
    ) {
        global UIDarkDropdowns

        global UIColorControlBorder

        global UIColorControlTop
        global UIColorControlBottom

        global UIColorControlText

        global UIColorPopupBackground
        global UIColorAccent

        global UIFontBody


        this.Gui := guiObject

        this.X := x
        this.Y := y
        this.Width := width

        this.Height := 32
        this.RowHeight := 30

        ; Keep short lists compact. Longer lists show five rows and scroll.
        this.MaxVisibleRows :=
            Max(
                1,
                maxVisibleRows
            )

        this.ScrollbarWidth := 6
        this.ScrollbarGap := 5
        this.ScrollbarPadding := 4

        this.Items := []

        this.SelectedIndex := 0
        this.ScrollOffset := 0

        this.IsOpen := false
        this.IsEnabled := true
        this._Visible := true

        this.ChangeCallback := ""

        this.HoveredSlot := 0
        this.MainHovered := false


        this.Border := guiObject.Add(
            "Progress",
            "x"
            . (x - 1)
            . " y"
            . (y - 1)
            . " w"
            . (width + 2)
            . " h"
            . (this.Height + 2)
            . " c"
            . UIColorControlBorder
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            100
        )


        topHeight :=
            Ceil(
                this.Height / 2
            )


        bottomHeight :=
            this.Height
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


        guiObject.SetFont(
            "s10 Norm c"
            . UIColorControlText,
            UIFontBody
        )


        this.MainText := guiObject.Add(
            "Text",
            "x"
            . x
            . " y"
            . y
            . " w"
            . width
            . " h"
            . this.Height
            . " +0x200 BackgroundTrans",
            ""
        )


        this.Arrow := guiObject.Add(
            "Text",
            "x"
            . (x + width - 38)
            . " y"
            . y
            . " w30 h"
            . this.Height
            . " Center +0x200 BackgroundTrans",
            "▼"
        )


        this.MainText.OnEvent(
            "Click",
            ObjBindMethod(
                this,
                "Toggle"
            )
        )


        this.Arrow.OnEvent(
            "Click",
            ObjBindMethod(
                this,
                "Toggle"
            )
        )


        this.PopupGui := Gui(
            "+AlwaysOnTop -Caption +ToolWindow",
            ""
        )


        this.PopupGui.BackColor :=
            UIColorControlBorder


        this.PopupGui.MarginX := 0
        this.PopupGui.MarginY := 0


        ; Make the popup owned by the main launcher.
        try {
            DllCall(
                "SetWindowLongPtr",
                "Ptr",
                this.PopupGui.Hwnd,
                "Int",
                -8,
                "Ptr",
                guiObject.Hwnd,
                "Ptr"
            )
        }


        popupHeight :=
            (
                this.MaxVisibleRows
                * this.RowHeight
            )
            + 2


        this.PopupBackground :=
            this.PopupGui.Add(
                "Progress",
                "x1 y1 w"
                . (width - 2)
                . " h"
                . (popupHeight - 2)
                . " c"
                . UIColorPopupBackground
                . " Background"
                . UIColorPopupBackground
                . " Disabled",
                100
            )


        ; Scrollbar stays hidden for lists with five items or fewer.
        this.ScrollTrack :=
            this.PopupGui.Add(
                "Progress",
                "x"
                . (width - this.ScrollbarPadding - this.ScrollbarWidth)
                . " y"
                . this.ScrollbarPadding
                . " w"
                . this.ScrollbarWidth
                . " h"
                . Max(1, popupHeight - (this.ScrollbarPadding * 2))
                . " c"
                . UIColorControlBorder
                . " Background"
                . UIColorControlBorder
                . " Disabled",
                100
            )

        this.ScrollThumb :=
            this.PopupGui.Add(
                "Progress",
                "x"
                . (width - this.ScrollbarPadding - this.ScrollbarWidth)
                . " y"
                . this.ScrollbarPadding
                . " w"
                . this.ScrollbarWidth
                . " h20 c"
                . UIColorAccent
                . " Background"
                . UIColorAccent
                . " Disabled",
                100
            )

        this.ScrollTrack.Visible := false
        this.ScrollThumb.Visible := false


        this.Rows := []


        Loop this.MaxVisibleRows {

            slot :=
                A_Index


            rowY :=
                1
                + (
                    (slot - 1)
                    * this.RowHeight
                )


            rowBackground :=
                this.PopupGui.Add(
                    "Progress",
                    "x1 y"
                    . rowY
                    . " w"
                    . (width - 2)
                    . " h"
                    . this.RowHeight
                    . " c"
                    . UIColorPopupBackground
                    . " Background"
                    . UIColorPopupBackground
                    . " Disabled",
                    100
                )


            this.PopupGui.SetFont(
                "s9 Norm c"
                . UIColorControlText,
                UIFontBody
            )


            rowText :=
                this.PopupGui.Add(
                    "Text",
                    "x1 y"
                    . rowY
                    . " w"
                    . (width - 2)
                    . " h"
                    . this.RowHeight
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


            this.Rows.Push(
                {
                    Background: rowBackground,
                    Text: rowText,
                    ItemIndex: 0
                }
            )
        }


        this.PopupGui.Show(
            "Hide w"
            . width
            . " h"
            . popupHeight
        )


        UIDarkDropdowns.Push(
            this
        )


        StartDarkDropdownSystem()
        StartDarkDropdownWheelHook()


        if IsObject(
            items
        ) {
            this.Add(
                items
            )
        }


        if (
            this.Items.Length > 0
            && chooseIndex > 0
        ) {
            this.Choose(
                chooseIndex,
                false
            )
        }


        this.Close()
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
            this.Top.Visible := value
            this.Bottom.Visible := value
            this.MainText.Visible := value
            this.Arrow.Visible := value


            if !value {
                this.Close()
            }
        }
    }


    Enabled {
        get => this.IsEnabled

        set {
            this.IsEnabled := value


            if !value {
                this.Close()
            }


            this.RefreshMainVisual()
        }
    }


    OnEvent(
        eventName,
        callback
    ) {
        if eventName = "Change" {
            this.ChangeCallback := callback
        }


        return this
    }


    Delete() {
        this.Close()


        this.Items := []

        this.SelectedIndex := 0
        this.ScrollOffset := 0

        this.MainText.Text := ""


        this.RefreshRows()
        this.UpdateScrollbar()


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


        this.ClampScrollOffset()
        this.RefreshRows()
        this.UpdateScrollbar()


        return this
    }


    Choose(
        index,
        fireChange := false
    ) {
        if this.Items.Length = 0 {

            this.SelectedIndex := 0
            this.MainText.Text := ""

            return this
        }


        if index < 1 {
            index := 1
        }


        if index > this.Items.Length {
            index := this.Items.Length
        }


        oldIndex :=
            this.SelectedIndex


        this.SelectedIndex :=
            index


        this.MainText.Text :=
            "   "
            . this.Items[
                index
            ]


        this.EnsureSelectedVisible()


        this.RefreshRows()


        if (
            fireChange
            && oldIndex != index
        ) {
            this.FireChange()
        }


        return this
    }


    Toggle(*) {
        if !this.IsEnabled {
            return
        }


        if !this._Visible {
            return
        }


        ; A one-item list has nothing to choose. Keeping it closed avoids
        ; the tiny popup repeatedly appearing/disappearing and eliminates
        ; the single-item flicker while preserving the normal dropdown look.
        if this.Items.Length <= 1 {
            this.Close()
            return
        }


        if this.IsOpen {

            this.Close()
        }
        else {

            CloseOtherDarkDropdowns(
                this
            )


            this.Open()
        }
    }


    Open() {
        if this.Items.Length <= 1 {
            return
        }


        this.IsOpen := true


        this.EnsureSelectedVisible()


        this.RefreshRows()


        visibleRows :=
            Min(
                this.Items.Length,
                this.MaxVisibleRows
            )


        if visibleRows < 1 {
            visibleRows := 1
        }


        popupHeight :=
            (
                visibleRows
                * this.RowHeight
            )
            + 2


        this.UpdateScrollbar(
            popupHeight
        )


        this.PopupBackground.Move(
            1,
            1,
            this.Width - 2,
            popupHeight - 2
        )


        contentWidth :=
            this.GetContentWidth()


        for row in this.Rows {
            row.Background.Move(
                ,
                ,
                contentWidth,
                this.RowHeight
            )

            row.Text.Move(
                ,
                ,
                contentWidth,
                this.RowHeight
            )
        }


        point := Buffer(
            8,
            0
        )


        NumPut(
            "Int",
            this.X,
            point,
            0
        )


        NumPut(
            "Int",
            this.Y
                + this.Height
                + 4,
            point,
            4
        )


        DllCall(
            "ClientToScreen",
            "Ptr",
            this.Gui.Hwnd,
            "Ptr",
            point.Ptr
        )


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


        this.PopupGui.Show(
            "NA x"
            . screenX
            . " y"
            . screenY
            . " w"
            . this.Width
            . " h"
            . popupHeight
        )


        for row in this.Rows {

            if row.ItemIndex > 0 {

                row.Background.Visible := true
                row.Text.Visible := true
            }
            else {

                row.Background.Visible := false
                row.Text.Visible := false
            }
        }


        this.Arrow.Text :=
            "▲"


        this.RefreshMainVisual()
    }


    Close() {
        this.IsOpen := false
        this.HoveredSlot := 0


        try {
            this.PopupGui.Hide()
        }


        this.ScrollTrack.Visible := false
        this.ScrollThumb.Visible := false


        this.Arrow.Text :=
            "▼"


        this.RefreshMainVisual()
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
            itemIndex
            != this.SelectedIndex


        this.SelectedIndex :=
            itemIndex


        this.MainText.Text :=
            "   "
            . this.Items[
                itemIndex
            ]


        this.Close()


        if changed {
            this.FireChange()
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


    EnsureSelectedVisible() {
        if this.SelectedIndex < 1 {
            return
        }


        if (
            this.SelectedIndex
            <= this.ScrollOffset
        ) {

            this.ScrollOffset :=
                this.SelectedIndex
                - 1
        }


        if (
            this.SelectedIndex
            > this.ScrollOffset
                + this.MaxVisibleRows
        ) {

            this.ScrollOffset :=
                this.SelectedIndex
                - this.MaxVisibleRows
        }


        maxOffset :=
            Max(
                0,
                this.Items.Length
                - this.MaxVisibleRows
            )


        if this.ScrollOffset > maxOffset {
            this.ScrollOffset := maxOffset
        }


        if this.ScrollOffset < 0 {
            this.ScrollOffset := 0
        }
    }


    ClampScrollOffset() {
        maxOffset :=
            Max(
                0,
                this.Items.Length
                - this.MaxVisibleRows
            )

        if this.ScrollOffset < 0 {
            this.ScrollOffset := 0
        }

        if this.ScrollOffset > maxOffset {
            this.ScrollOffset := maxOffset
        }
    }


    GetContentWidth() {
        ; Every dropdown uses the same popup geometry as a scrollable list.
        ; Short lists keep the scrollbar gutter too, which prevents the rows
        ; from changing width/style depending on how many items are present.
        return Max(
            1,
            this.Width
            - 2
            - this.ScrollbarGap
            - this.ScrollbarWidth
            - this.ScrollbarPadding
        )
    }


    UpdateScrollbar(
        popupHeight := 0
    ) {
        if this.Items.Length = 0 {
            this.ScrollTrack.Visible := false
            this.ScrollThumb.Visible := false
            return
        }

        if popupHeight <= 0 {
            visibleRows :=
                Min(
                    this.Items.Length,
                    this.MaxVisibleRows
                )

            popupHeight :=
                (visibleRows * this.RowHeight)
                + 2
        }

        trackX :=
            this.Width
            - this.ScrollbarPadding
            - this.ScrollbarWidth

        trackY :=
            this.ScrollbarPadding

        trackHeight :=
            Max(
                1,
                popupHeight
                - (this.ScrollbarPadding * 2)
            )

        needsScroll :=
            this.Items.Length
            > this.MaxVisibleRows

        if needsScroll {
            thumbHeight :=
                Max(
                    22,
                    Floor(
                        trackHeight
                        * this.MaxVisibleRows
                        / this.Items.Length
                    )
                )

            thumbHeight :=
                Min(
                    trackHeight,
                    thumbHeight
                )

            maxOffset :=
                Max(
                    1,
                    this.Items.Length
                    - this.MaxVisibleRows
                )

            travel :=
                Max(
                    0,
                    trackHeight
                    - thumbHeight
                )

            thumbY :=
                trackY
                + Round(
                    travel
                    * this.ScrollOffset
                    / maxOffset
                )
        }
        else {
            ; Short lists still render the same scrollbar rail. A full-height
            ; thumb communicates that the entire list is already visible.
            thumbHeight := trackHeight
            thumbY := trackY
        }

        this.ScrollTrack.Move(
            trackX,
            trackY,
            this.ScrollbarWidth,
            trackHeight
        )

        this.ScrollThumb.Move(
            trackX,
            thumbY,
            this.ScrollbarWidth,
            thumbHeight
        )

        this.ScrollTrack.Visible := this.IsOpen
        this.ScrollThumb.Visible := this.IsOpen
    }


    Scroll(
        direction
    ) {
        if !this.IsOpen {
            return
        }


        maxOffset :=
            Max(
                0,
                this.Items.Length
                - this.MaxVisibleRows
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


        this.ClampScrollOffset()


        this.HoveredSlot := 0


        this.RefreshRows()
        this.UpdateScrollbar()
    }


    RefreshRows() {
        global UIColorPopupBackground
        global UIColorControlHoverTop
        global UIColorControlSelected
        global UIColorControlSelectedHover
        global UIColorControlText


        Loop this.Rows.Length {

            slot :=
                A_Index


            itemIndex :=
                this.ScrollOffset
                + slot


            row :=
                this.Rows[
                    slot
                ]


            if itemIndex <= this.Items.Length {

                row.ItemIndex :=
                    itemIndex


                row.Text.Text :=
                    "   "
                    . this.Items[
                        itemIndex
                    ]


                if (
                    itemIndex = this.SelectedIndex
                    && slot = this.HoveredSlot
                ) {

                    SetUIProgressColor(
                        row.Background,
                        UIColorControlSelectedHover
                    )
                }
                else if (
                    itemIndex = this.SelectedIndex
                ) {

                    SetUIProgressColor(
                        row.Background,
                        UIColorControlSelected
                    )
                }
                else if (
                    slot = this.HoveredSlot
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
            }
            else {

                row.ItemIndex := 0
                row.Text.Text := ""

                row.Background.Visible := false
                row.Text.Visible := false
            }
        }


        if this.IsOpen {
            this.UpdateScrollbar()
        }
    }


    UpdateHover(
        mouseWindow,
        mouseControl
    ) {
        mainHovered :=
            this._Visible
            && mouseWindow = this.Gui.Hwnd
            && (
                mouseControl
                    = this.MainText.Hwnd
                || mouseControl
                    = this.Arrow.Hwnd
            )


        if mainHovered != this.MainHovered {

            this.MainHovered :=
                mainHovered


            this.RefreshMainVisual()
        }


        if !this.IsOpen {

            this.HoveredSlot := 0

            return
        }


        newHoveredSlot := 0


        if mouseWindow = this.PopupGui.Hwnd {

            for slot, row in this.Rows {

                if (
                    row.ItemIndex > 0
                    && mouseControl
                        = row.Text.Hwnd
                ) {

                    newHoveredSlot :=
                        slot


                    break
                }
            }
        }


        if (
            newHoveredSlot
            = this.HoveredSlot
        ) {
            return
        }


        this.HoveredSlot :=
            newHoveredSlot


        this.RefreshRows()
    }


    RefreshMainVisual() {
        global UIColorControlBorder
        global UIColorAccent

        global UIColorControlTop
        global UIColorControlBottom

        global UIColorControlHoverTop
        global UIColorControlHoverBottom

        global UIColorControlActiveTop
        global UIColorControlActiveBottom

        global UIColorControlText
        global UIColorControlDisabledText

        global UIColorPanel


        if !this.IsEnabled {

            SetUIProgressColor(
                this.Border,
                UIColorControlBorder
            )


            SetUIProgressColor(
                this.Top,
                UIColorPanel
            )


            SetUIProgressColor(
                this.Bottom,
                UIColorPanel
            )


            this.MainText.SetFont(
                "c"
                . UIColorControlDisabledText
            )


            this.Arrow.SetFont(
                "c"
                . UIColorControlDisabledText
            )


            return
        }


        if this.IsOpen {

            SetUIProgressColor(
                this.Border,
                UIColorAccent
            )


            SetUIProgressColor(
                this.Top,
                UIColorControlActiveTop
            )


            SetUIProgressColor(
                this.Bottom,
                UIColorControlActiveBottom
            )
        }
        else if this.MainHovered {

            SetUIProgressColor(
                this.Border,
                UIColorAccent
            )


            SetUIProgressColor(
                this.Top,
                UIColorControlHoverTop
            )


            SetUIProgressColor(
                this.Bottom,
                UIColorControlHoverBottom
            )
        }
        else {

            SetUIProgressColor(
                this.Border,
                UIColorControlBorder
            )


            SetUIProgressColor(
                this.Top,
                UIColorControlTop
            )


            SetUIProgressColor(
                this.Bottom,
                UIColorControlBottom
            )
        }


        this.MainText.SetFont(
            "c"
            . UIColorControlText
        )


        this.Arrow.SetFont(
            "c"
            . UIColorControlText
        )
    }


    ContainsMouse(
        mouseWindow,
        mouseControl
    ) {
        if mouseWindow = this.PopupGui.Hwnd {
            return true
        }


        if (
            mouseWindow = this.Gui.Hwnd
            && (
                mouseControl
                    = this.MainText.Hwnd
                || mouseControl
                    = this.Arrow.Hwnd
            )
        ) {
            return true
        }


        return false
    }
}


StartDarkDropdownWheelHook() {
    global UIDarkDropdownWheelHookStarted

    if UIDarkDropdownWheelHookStarted {
        return
    }

    UIDarkDropdownWheelHookStarted := true

    ; WM_MOUSEWHEEL - reliable even though wheel buttons do not have a held state.
    OnMessage(
        0x020A,
        DarkDropdownMouseWheel
    )
}


DarkDropdownMouseWheel(
    wParam,
    lParam,
    msg,
    hwnd
) {
    global UIDarkDropdowns

    delta :=
        (wParam >> 16)
        & 0xFFFF

    if delta & 0x8000 {
        delta -= 0x10000
    }

    if delta = 0 {
        return
    }

    mouseWindow := 0

    try {
        MouseGetPos(
            ,
            ,
            &mouseWindow
        )
    }

    for dropdown in UIDarkDropdowns {
        if (
            dropdown.IsOpen
            && mouseWindow = dropdown.PopupGui.Hwnd
        ) {
            dropdown.Scroll(
                delta > 0 ? 1 : -1
            )
            return 0
        }
    }
}


StartDarkDropdownSystem() {
    global UIDarkDropdownTimerStarted


    if UIDarkDropdownTimerStarted {
        return
    }


    UIDarkDropdownTimerStarted :=
        true


    SetTimer(
        PollDarkDropdowns,
        30
    )
}


PollDarkDropdowns() {
    global UIDarkDropdowns
    global UIDarkDropdownMouseWasDown


    mouseWindow := 0
    mouseControl := 0


    try {
        MouseGetPos(
            ,
            ,
            &mouseWindow,
            &mouseControl,
            2
        )
    }


    for dropdown in UIDarkDropdowns {

        try {
            dropdown.UpdateHover(
                mouseWindow,
                mouseControl
            )
        }
    }


    leftDown :=
        GetKeyState(
            "LButton",
            "P"
        )


    if (
        leftDown
        && !UIDarkDropdownMouseWasDown
    ) {

        for dropdown in UIDarkDropdowns {

            if (
                dropdown.IsOpen
                && !dropdown.ContainsMouse(
                    mouseWindow,
                    mouseControl
                )
            ) {

                dropdown.Close()
            }
        }
    }


    UIDarkDropdownMouseWasDown :=
        leftDown


}


CloseOtherDarkDropdowns(
    exceptDropdown := ""
) {
    global UIDarkDropdowns


    for dropdown in UIDarkDropdowns {

        if (
            IsObject(
                exceptDropdown
            )
            && dropdown
                = exceptDropdown
        ) {
            continue
        }


        if dropdown.IsOpen {
            dropdown.Close()
        }
    }
}


CloseAllDarkDropdowns() {
    global UIDarkDropdowns


    for dropdown in UIDarkDropdowns {

        if dropdown.IsOpen {
            dropdown.Close()
        }
    }
}
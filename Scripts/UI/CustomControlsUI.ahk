#Requires AutoHotkey v2.0


global UIDarkLists := []

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

        this.ClickCallback := ""
        this.ClickExclusions := []

        this.IsEnabled := true
        this._Visible := true

        this.ActionPending := false
        this.LastTextOffset := -1


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
                    this.ShowRestState()
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


            this.Glow.Visible := value
            this.Border.Visible := value

            this.Top.Visible := value
            this.Bottom.Visible := value

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


        ; Always return to gray before the action fires.
        this.ShowRestState()


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
        global UIColorAccent
        global UIColorSuccess
        global UIColorError

        global UIColorControlPressedTop
        global UIColorControlPressedBottom
        global UIColorControlPressedHighlight

        global UIColorControlText


        accentColor := UIColorAccent
        pressedTop := UIColorControlPressedTop
        pressedBottom := UIColorControlPressedBottom
        pressedHighlight := UIColorControlPressedHighlight


        if this.Style = "Success" || this.Style = "ToggleOn" {
            accentColor := UIColorSuccess
            pressedTop := BlendUIColors("272C35", UIColorSuccess, 0.72)
            pressedBottom := BlendUIColors("1B1F26", UIColorSuccess, 0.58)
            pressedHighlight := UIColorSuccess
        }
        else if this.Style = "Danger" || this.Style = "ToggleOff" {
            accentColor := UIColorError
            pressedTop := BlendUIColors("272C35", UIColorError, 0.72)
            pressedBottom := BlendUIColors("1B1F26", UIColorError, 0.58)
            pressedHighlight := UIColorError
        }


        SetUIProgressColor(
            this.Glow,
            BlendUIColors(
                "101216",
                accentColor,
                0.72
            )
        )


        SetUIProgressColor(
            this.Border,
            accentColor
        )


        SetUIProgressColor(
            this.Top,
            pressedTop
        )


        SetUIProgressColor(
            this.Bottom,
            pressedBottom
        )


        SetUIProgressColor(
            this.Highlight,
            pressedHighlight
        )


        this.TextControl.SetFont(
            "Norm c"
            . UIColorControlText
        )


        this.SetTextOffset(
            1
        )
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
            else if this.Style = "ToggleOn" {
                restTop := BlendUIColors("272C35", UIColorSuccess, 0.58)
                restBottom := BlendUIColors("1B1F26", UIColorSuccess, 0.44)
                restHighlight := UIColorSuccess
                restBorder := BlendUIColors(UIColorControlBorder, UIColorSuccess, 0.72)
            }
            else if this.Style = "ToggleOff" {
                restTop := BlendUIColors("272C35", UIColorError, 0.58)
                restBottom := BlendUIColors("1B1F26", UIColorError, 0.44)
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


            SetUIProgressColor(
                this.Bottom,
                restBottom
            )


            SetUIProgressColor(
                this.Highlight,
                restHighlight
            )


            this.TextControl.SetFont(
                "Norm c"
                . UIColorControlText
            )
        }
        else {

            SetUIProgressColor(
                this.Top,
                UIColorPanel
            )


            SetUIProgressColor(
                this.Bottom,
                UIColorPanel
            )


            SetUIProgressColor(
                this.Highlight,
                UIColorControlBorder
            )


            this.TextControl.SetFont(
                "Norm c"
                . UIColorControlDisabledText
            )
        }


        this.SetTextOffset(
            0
        )
    }


    SetTextOffset(
        offset
    ) {
        if offset = this.LastTextOffset {
            return
        }


        this.LastTextOffset :=
            offset


        this.TextControl.Move(
            this.X,
            this.Y + offset,
            this.Width,
            this.Height
        )
    }


    IsAlive() {
        try {
            return !!WinExist(
                "ahk_id "
                . this.Gui.Hwnd
            )
        }


        return false
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
            return
        }


        point :=
            this.GetClientPoint(
                mouseX,
                mouseY
            )


        newHoveredSlot := 0


        if point {

            clientX :=
                point[1]


            clientY :=
                point[2]


            if (
                clientX >= this.X
                && clientX
                    < this.X
                        + this.Width
                && clientY >= this.Y
                && clientY
                    < this.Y
                        + this.Height
            ) {

                slot :=
                    Floor(
                        (
                            clientY
                            - this.Y
                        )
                        / this.RowHeight
                    )
                    + 1


                if (
                    slot >= 1
                    && slot <= this.Rows.Length
                    && this.Rows[
                        slot
                    ].ItemIndex > 0
                ) {

                    newHoveredSlot :=
                        slot
                }
            }
        }


        if newHoveredSlot
            = this.HoveredSlot {

            return
        }


        this.HoveredSlot :=
            newHoveredSlot


        this.RefreshRows()
    }


    ContainsScreenPoint(
        mouseX,
        mouseY
    ) {
        if !this._Visible {
            return false
        }


        point :=
            this.GetClientPoint(
                mouseX,
                mouseY
            )


        if !point {
            return false
        }


        clientX :=
            point[1]


        clientY :=
            point[2]


        return (
            clientX >= this.X
            && clientX
                < this.X
                    + this.Width
            && clientY >= this.Y
            && clientY
                < this.Y
                    + this.Height
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
        try {
            return !!WinExist(
                "ahk_id "
                . this.Gui.Hwnd
            )
        }


        return false
    }
}


StartUICustomControlSystem() {
    global UICustomControlTimerStarted
    global UICustomControlMessagesStarted


    if !UICustomControlTimerStarted {

        UICustomControlTimerStarted :=
            true


        SetTimer(
            PollUICustomControls,
            30
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


    activeLists := []


    for list in UIDarkLists {

        try {
            if !list.IsAlive() {
                continue
            }


            list.UpdateHover(
                mouseX,
                mouseY
            )


            activeLists.Push(
                list
            )
        }
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
    try {
        progressControl.Opt(
            "c"
            . color
            . " Background"
            . color
        )


        progressControl.Value := 100


        progressControl.Redraw()
    }
}
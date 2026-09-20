#Requires AutoHotkey v2.0


global UIFontHeading := LoadBundledUIHeadingFont()
global UIFontBody := "Segoe UI"

global UIColorBackground := "101216"
global UIColorPanel := "171A1F"
global UIColorPopupBackground := "14171C"

global UIColorAccent := "4C8DFF"
global UIColorWindowBorder := "252A33"

global UIColorControlBorder := "343A46"

global UIColorInputBorder := "303844"
global UIColorInputBackground := "0F1319"
global UIColorInputText := "F5F7FA"

global UIColorControlTop := "272C35"
global UIColorControlBottom := "1B1F26"

global UIColorControlHoverTop := "3A4351"
global UIColorControlHoverBottom := "272E39"

global UIColorControlActiveTop := "2F68BC"
global UIColorControlActiveBottom := "214D8E"

global UIColorControlPressedTop := "25589F"
global UIColorControlPressedBottom := "193E74"

global UIColorControlHighlight := "46505F"
global UIColorControlHoverHighlight := "79A9FF"
global UIColorControlPressedHighlight := "4C8DFF"

global UIColorControlSelected := "315FAF"
global UIColorControlSelectedHover := "3B73CE"

global UIColorControlText := "F5F7FA"
global UIColorControlDisabledText := "697382"

global UIColorPrimaryText := "F5F7FA"
global UIColorSecondaryText := "B8C0CC"
global UIColorLabelText := "D7DCE3"
global UIColorMutedText := "7F8998"

global UIColorHeadingText := "FFD34E"
global UIColorHeadingOutline := "17100A"

global UIColorSuccess := "4ADE80"
global UIColorWarning := "FBBF24"
global UIColorError := "FB7185"

global UIColorNativeText := "F5F7FA"


LoadBundledUIHeadingFont() {
    fontPath :=
        A_ScriptDir
        . "\Lib\Fonts\LuckiestGuy\LuckiestGuy-Regular.ttf"


    if !FileExist(
        fontPath
    ) {
        return "Segoe UI"
    }


    FR_PRIVATE := 0x10


    try {
        loaded := DllCall(
            "gdi32\AddFontResourceEx",
            "Str",
            fontPath,
            "UInt",
            FR_PRIVATE,
            "Ptr",
            0,
            "Int"
        )


        if loaded > 0 {
            return "Luckiest Guy"
        }
    }


    return "Segoe UI"
}


SetUIHeadingFont(
    guiObject,
    size := 12,
    color := ""
) {
    global UIFontHeading
    global UIColorPrimaryText


    if color = "" {
        color := UIColorPrimaryText
    }


    guiObject.SetFont(
        "s"
        . size
        . " Norm c"
        . color,
        UIFontHeading
    )
}


SetUIButtonFont(
    guiObject,
    size := 8
) {
    global UIFontHeading
    global UIColorControlText


    guiObject.SetFont(
        "s"
        . size
        . " Norm c"
        . UIColorControlText,
        UIFontHeading
    )
}


SetUIBodyFont(
    guiObject,
    size := 9,
    color := ""
) {
    global UIFontBody
    global UIColorPrimaryText


    if color = "" {
        color := UIColorPrimaryText
    }


    guiObject.SetFont(
        "s"
        . size
        . " Norm c"
        . color,
        UIFontBody
    )
}


SetUIBodyBoldFont(
    guiObject,
    size := 9,
    color := ""
) {
    global UIFontBody
    global UIColorPrimaryText


    if color = "" {
        color := UIColorPrimaryText
    }


    guiObject.SetFont(
        "s"
        . size
        . " Norm c"
        . color,
        UIFontBody
    )
}


SetUINativeControlFont(
    guiObject,
    size := 9,
    bold := false
) {
    global UIFontBody
    global UIColorNativeText


    ; Parameter retained so existing callers do not need to change.
    ; The v2.1 UI uses normal-weight text everywhere.
    weight := "Norm"


    guiObject.SetFont(
        "s"
        . size
        . " "
        . weight
        . " c"
        . UIColorNativeText,
        UIFontBody
    )
}


AddUIOutlinedText(
    guiObject,
    text,
    x,
    y,
    width,
    height,
    size := 12,
    alignment := "",
    visible := true,
    fillColor := "",
    outlineColor := ""
) {
    global UIFontHeading
    global UIColorHeadingText
    global UIColorHeadingOutline


    if fillColor = "" {
        fillColor := UIColorHeadingText
    }


    if outlineColor = "" {
        outlineColor := UIColorHeadingOutline
    }


    alignOption := ""


    if alignment != "" {
        alignOption :=
            " "
            . alignment
    }


    visibilityOption := ""


    if !visible {
        visibilityOption := " Hidden"
    }


    controls := []


    offsets := [
        [-1, -1],
        [0, -1],
        [1, -1],
        [-1, 0],
        [1, 0],
        [-1, 1],
        [0, 1],
        [1, 1]
    ]


    guiObject.SetFont(
        "s"
        . size
        . " Norm c"
        . outlineColor,
        UIFontHeading
    )


    for offset in offsets {

        outlineControl := guiObject.Add(
            "Text",
            "x"
            . (
                x
                + offset[1]
            )
            . " y"
            . (
                y
                + offset[2]
            )
            . " w"
            . width
            . " h"
            . height
            . alignOption
            . " BackgroundTrans"
            . visibilityOption,
            text
        )


        controls.Push(
            outlineControl
        )
    }


    guiObject.SetFont(
        "s"
        . size
        . " Norm c"
        . fillColor,
        UIFontHeading
    )


    mainControl := guiObject.Add(
        "Text",
        "x"
        . x
        . " y"
        . y
        . " w"
        . width
        . " h"
        . height
        . alignOption
        . " BackgroundTrans"
        . visibilityOption,
        text
    )


    controls.Push(
        mainControl
    )


    return UIOutlinedTextGroup(
        controls,
        mainControl
    )
}


class UIOutlinedTextGroup {

    __New(
        controls,
        mainControl
    ) {
        this.Controls := controls
        this.MainControl := mainControl
    }


    Visible {
        get => this.MainControl.Visible

        set {
            for control in this.Controls {
                control.Visible := value
            }
        }
    }


    Text {
        get => this.MainControl.Text

        set {
            for control in this.Controls {
                control.Text := value
            }
        }
    }
}
#Requires AutoHotkey v2.0


global UIFontHeading := LoadBundledUIHeadingFont()
global UIFontBody := "Segoe UI"

global UIColorBackground := "0D1117"
global UIColorPanel := "111820"
global UIColorPopupBackground := "10161E"

global UIColorAccent := "67B7FF"
global UIColorWindowBorder := "2A3441"
global UIColorPanelBorder := "26313D"
global UIColorPanelRaised := "0D1117"
global UIColorPanelSoft := "0D1117"
global UIColorAccentSoft := "15283A"

global UIColorControlBorder := "33404F"

global UIColorInputBorder := "33404F"
global UIColorInputBackground := "10161D"
global UIColorInputText := "F5F7FA"

global UIColorControlTop := "19212B"
global UIColorControlBottom := "171E27"

global UIColorControlHoverTop := "222E3A"
global UIColorControlHoverBottom := "1E2833"

global UIColorControlActiveTop := "245C8D"
global UIColorControlActiveBottom := "1A466D"

global UIColorControlPressedTop := "1E527F"
global UIColorControlPressedBottom := "163D5F"

global UIColorControlHighlight := "3B4856"
global UIColorControlHoverHighlight := "67B7FF"
global UIColorControlPressedHighlight := "67B7FF"

global UIColorControlSelected := "245A84"
global UIColorControlSelectedHover := "2E6F9F"

global UIColorControlText := "F5F7FA"
global UIColorControlDisabledText := "697382"

global UIColorPrimaryText := "F4F7FB"
global UIColorSecondaryText := "B3BFCC"
global UIColorLabelText := "D8E0E8"
global UIColorMutedText := "7D8B9C"

global UIColorHeadingText := "F4F7FB"
global UIColorHeadingOutline := "0D1117"

global UIColorSuccess := "4AD295"
global UIColorWarning := "F0BB5A"
global UIColorError := "F06D78"

global UIColorNativeText := "F4F7FB"


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


    if fillColor = "" {
        fillColor := UIColorHeadingText
    }


    alignOption := alignment != "" ? " " . alignment : ""
    visibilityOption := visible ? "" : " Hidden"


    guiObject.SetFont(
        "s" . size . " Norm c" . fillColor,
        UIFontHeading
    )


    mainControl := guiObject.Add(
        "Text",
        "x" . x
        . " y" . y
        . " w" . width
        . " h" . height
        . alignOption
        . " BackgroundTrans"
        . visibilityOption,
        text
    )


    return UIOutlinedTextGroup([mainControl], mainControl)
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
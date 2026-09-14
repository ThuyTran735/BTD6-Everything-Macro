#Requires AutoHotkey v2.0


CreateStartupLoadingUI(
    headingText := "STARTING MACRO",
    subtitleText := "Starting Macro",
    helperText := "Preparing everything for your run"
) {
    global StartupLoadingGui
    global StartupLoadingMessage
    global StartupLoadingPercent
    global StartupLoadingProgress

    global GuiWidth
    global GuiHeight

    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorMutedText
    global UIColorControlBorder


    if StartupLoadingGui {

        try {
            StartupLoadingGui.Destroy()
        }
    }


    StartupLoadingGui := ""
    StartupLoadingMessage := ""
    StartupLoadingPercent := ""
    StartupLoadingProgress := ""


    StartupLoadingGui :=
        Gui(
            "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
            "BTD6 Everything Macro"
        )


    StartupLoadingGui.BackColor :=
        UIColorBackground


    StartupLoadingGui.Add(
        "Progress",
        "x0 y0 w"
        . GuiWidth
        . " h5 Background"
        . UIColorAccent
        . " c"
        . UIColorAccent,
        100
    )


    AddUIOutlinedText(
        StartupLoadingGui,
        "BTD6 Everything Macro",
        20,
        18,
        350,
        35,
        14
    )


    SetUIBodyFont(
        StartupLoadingGui,
        7,
        UIColorMutedText
    )


    StartupLoadingGui.Add(
        "Text",
        "x21 y53 w205 h20 c"
        . UIColorMutedText
        . " BackgroundTrans",
        "Made By @Thuy_"
        . Chr(8202)
        . "_"
    )


    SetUIBodyFont(
        StartupLoadingGui,
        8,
        UIColorMutedText
    )


    StartupLoadingGui.Add(
        "Text",
        "x230 y53 w140 h20 Right c"
        . UIColorMutedText
        . " BackgroundTrans",
        subtitleText
    )


    StartupLoadingGui.Add(
        "Text",
        "x20 y79 w350 h1 0x10"
    )


    AddUIOutlinedText(
        StartupLoadingGui,
        headingText,
        20,
        108,
        350,
        40,
        14,
        "Center"
    )


    SetUIBodyBoldFont(
        StartupLoadingGui,
        10,
        UIColorPrimaryText
    )


    StartupLoadingMessage :=
        StartupLoadingGui.Add(
            "Text",
            "x25 y177 w340 h28 Center c"
            . UIColorPrimaryText
            . " BackgroundTrans",
            "INITIALIZING..."
        )


    StartupLoadingProgress :=
        StartupLoadingGui.Add(
            "Progress",
            "x35 y225 w320 h14 Range0-100 c"
            . UIColorAccent
            . " Background"
            . UIColorControlBorder,
            0
        )


    SetUIBodyBoldFont(
        StartupLoadingGui,
        9,
        UIColorSecondaryText
    )


    StartupLoadingPercent :=
        StartupLoadingGui.Add(
            "Text",
            "x35 y247 w320 h22 Center c"
            . UIColorSecondaryText
            . " BackgroundTrans",
            "0%"
        )


    SetUIBodyFont(
        StartupLoadingGui,
        8,
        UIColorMutedText
    )


    StartupLoadingGui.Add(
        "Text",
        "x35 y294 w320 h22 Center c"
        . UIColorMutedText
        . " BackgroundTrans",
        helperText
    )


    SetUIBodyBoldFont(
        StartupLoadingGui,
        9,
        UIColorAccent
    )


    StartupLoadingGui.Add(
        "Text",
        "x20 y356 w350 h20 Center c"
        . UIColorAccent
        . " BackgroundTrans",
        "PLEASE WAIT"
    )


    StartupLoadingGui.Show(
        "Hide w"
        . GuiWidth
        . " h"
        . GuiHeight
    )


    ApplyDarkWindowStyle(
        StartupLoadingGui
    )
}


GetStartupLoadingPosition() {
    global StartupLoadingGui
    global GuiWidth
    global GuiHeight


    screenLeft := 0
    screenTop := 0
    screenRight := 1920
    screenBottom := 1080


    windowWidth :=
        GuiWidth


    windowHeight :=
        GuiHeight


    rect :=
        Buffer(
            16,
            0
        )


    gotRect :=
        DllCall(
            "GetWindowRect",
            "Ptr",
            StartupLoadingGui.Hwnd,
            "Ptr",
            rect.Ptr,
            "Int"
        )


    if gotRect {

        rectLeft :=
            NumGet(
                rect,
                0,
                "Int"
            )


        rectTop :=
            NumGet(
                rect,
                4,
                "Int"
            )


        rectRight :=
            NumGet(
                rect,
                8,
                "Int"
            )


        rectBottom :=
            NumGet(
                rect,
                12,
                "Int"
            )


        measuredWidth :=
            rectRight
            - rectLeft


        measuredHeight :=
            rectBottom
            - rectTop


        if measuredWidth > 0 {

            windowWidth :=
                measuredWidth
        }


        if measuredHeight > 0 {

            windowHeight :=
                measuredHeight
        }
    }


    loadingX :=
        screenLeft


    loadingY :=
        screenBottom
        - windowHeight


    if loadingX < screenLeft {

        loadingX :=
            screenLeft
    }


    if loadingY < screenTop {

        loadingY :=
            screenTop
    }


    if loadingX + windowWidth > screenRight {

        loadingX :=
            screenRight
            - windowWidth
    }


    if loadingY + windowHeight > screenBottom {

        loadingY :=
            screenBottom
            - windowHeight
    }


    return [
        Round(
            loadingX
        ),
        Round(
            loadingY
        )
    ]
}


ShowStartupLoadingUI() {
    global StartupLoadingGui
    global GuiWidth
    global GuiHeight


    position :=
        GetStartupLoadingPosition()


    loadingX :=
        position[1]


    loadingY :=
        position[2]


    StartupLoadingGui.Show(
        "x"
        . loadingX
        . " y"
        . loadingY
        . " w"
        . GuiWidth
        . " h"
        . GuiHeight
    )


    Sleep(
        10
    )
}


CloseStartupLoadingUI() {
    global StartupLoadingGui
    global StartupLoadingMessage
    global StartupLoadingPercent
    global StartupLoadingProgress


    if StartupLoadingGui {

        try {
            StartupLoadingGui.Destroy()
        }
    }


    StartupLoadingGui := ""
    StartupLoadingMessage := ""
    StartupLoadingPercent := ""
    StartupLoadingProgress := ""
}


SetStartupLoadingMessage(
    text
) {
    global StartupLoadingMessage


    if !StartupLoadingMessage {

        return
    }


    StartupLoadingMessage.Text :=
        text
}


RunFakeLoadingAnimation(
    headingText,
    subtitleText,
    helperText,
    messages
) {
    global StartupLoadingActive

    global StartupLoadingProgress
    global StartupLoadingPercent

    global UIColorSecondaryText
    global UIColorSuccess


    StartupLoadingActive :=
        true


    CreateStartupLoadingUI(
        headingText,
        subtitleText,
        helperText
    )


    ShowStartupLoadingUI()


    StartupLoadingProgress.Value :=
        0


    StartupLoadingPercent.SetFont(
        "c"
        . UIColorSecondaryText
    )


    StartupLoadingPercent.Text :=
        "0%"


    messageIndex :=
        1


    Loop 21 {

        percent :=
            (A_Index - 1)
            * 5


        if percent > 100 {

            percent :=
                100
        }


        StartupLoadingProgress.Value :=
            percent


        StartupLoadingPercent.Text :=
            percent
            . "%"


        while (
            messageIndex <= messages.Length
            && percent
                >= messages[
                    messageIndex
                ].percent
        ) {

            SetStartupLoadingMessage(
                messages[
                    messageIndex
                ].text
            )


            messageIndex++
        }


        if percent = 100 {

            StartupLoadingPercent.SetFont(
                "c"
                . UIColorSuccess
            )
        }


        Sleep(
            5
        )
    }


    Sleep(
        25
    )


    CloseStartupLoadingUI()


    StartupLoadingActive :=
        false
}


RunMainStartupLoadingAnimation() {
    messages := [
        {
            percent: 0,
            text: "BOOTING EVERYTHING MACRO..."
        },
        {
            percent: 10,
            text: "LOADING USER INTERFACE..."
        },
        {
            percent: 20,
            text: "SCANNING MAP FOLDERS..."
        },
        {
            percent: 30,
            text: "LOADING STRATEGIES..."
        },
        {
            percent: 40,
            text: "CHECKING CONFIGURATION..."
        },
        {
            percent: 50,
            text: "COUNTING BANANAS..."
        },
        {
            percent: 60,
            text: "CALIBRATING DARTS..."
        },
        {
            percent: 70,
            text: "WAKING UP MONKEYS..."
        },
        {
            percent: 80,
            text: "CHECKING MONKEY BUSINESS..."
        },
        {
            percent: 90,
            text: "FINALIZING LAUNCHER..."
        },
        {
            percent: 100,
            text: "READY!"
        }
    ]


    RunFakeLoadingAnimation(
        "STARTING UP",
        "Loading Macro",
        "Preparing BTD6 Everything Macro",
        messages
    )
}


RunStartupLoadingAnimation() {
    messages := [
        {
            percent: 0,
            text: "INITIALIZING MACRO..."
        },
        {
            percent: 10,
            text: "LOADING STRATEGY..."
        },
        {
            percent: 25,
            text: "CHECKING MAP DATA..."
        },
        {
            percent: 40,
            text: "SYNCING CONTROLS..."
        },
        {
            percent: 50,
            text: "COUNTING BANANAS..."
        },
        {
            percent: 65,
            text: "POLISHING DARTS..."
        },
        {
            percent: 80,
            text: "GETTING MONKEYS READY..."
        },
        {
            percent: 90,
            text: "FINALIZING..."
        },
        {
            percent: 100,
            text: "READY!"
        }
    ]


    RunFakeLoadingAnimation(
        "STARTING MACRO",
        "Starting Macro",
        "Preparing everything for your run",
        messages
    )
}
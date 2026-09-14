#Requires AutoHotkey v2.0


CreateCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText
    global CycleCancelButton

    global CycleProgressText
    global CycleProgressBar
    global CycleProgressBackground

    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorControlBorder


    if CycleStatusGui {

        try {
            if WinExist(
                "ahk_id "
                . CycleStatusGui.Hwnd
            ) {
                return
            }
        }
    }


    CycleStatusGui := Gui(
        "+AlwaysOnTop -Caption +ToolWindow",
        ""
    )


    CycleStatusGui.BackColor :=
        UIColorBackground


    ; Thin blue accent across the top.
    CycleStatusGui.Add(
        "Progress",
        "x0 y0 w238 h3 c"
        . UIColorAccent
        . " Background"
        . UIColorAccent
        . " Disabled",
        100
    )


    ; Keep the current cycle information grouped
    ; together instead of spreading it across the HUD.
    SetUIHeadingFont(
        CycleStatusGui,
        8,
        UIColorPrimaryText
    )


    CycleProgressText :=
        CycleStatusGui.Add(
            "Text",
            "x12 y8 w214 h18 Center c"
            . UIColorPrimaryText
            . " BackgroundTrans",
            "CYCLE 1 / 1"
        )


    ; Remaining cycle number.
    SetUIHeadingFont(
        CycleStatusGui,
        13,
        UIColorPrimaryText
    )


    CycleStatusText :=
        CycleStatusGui.Add(
            "Text",
            "x12 y28 w34 h25 Center c"
            . UIColorPrimaryText
            . " BackgroundTrans",
            "0"
        )


    ; LEFT label directly beside the number.
    SetUIBodyBoldFont(
        CycleStatusGui,
        7,
        UIColorSecondaryText
    )


    CycleStatusGui.Add(
        "Text",
        "x49 y34 w30 h18 c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "LEFT"
    )


    ; Small compact progress bar.
    CycleProgressBackground :=
        CycleStatusGui.Add(
            "Progress",
            "x84 y38 w52 h5 c"
            . UIColorControlBorder
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            100
        )


    CycleProgressBar :=
        CycleStatusGui.Add(
            "Progress",
            "x84 y38 w52 h5 Range0-100 c"
            . UIColorAccent
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            0
        )


    ; Smaller cancel button so it does not dominate the HUD.
    CycleCancelButton :=
        CreateDarkButton(
            CycleStatusGui,
            146,
            25,
            80,
            28,
            "CANCEL",
            7
        )


    CycleCancelButton.OnEvent(
        "Click",
        CancelRepeatCycles
    )


    CycleStatusGui.Show(
        "Hide w238 h60"
    )


    ApplyDarkWindowStyle(
        CycleStatusGui
    )
}


ShowCycleStatusUI() {
    global CycleStatusGui


    CreateCycleStatusUI()


    UpdateCycleStatusUI()


    hudWidth := 238
    hudHeight := 60


    hudX :=
        Floor(
            (1920 - hudWidth) / 2
        )


    hudY := 6


    CycleStatusGui.Show(
        "NA x"
        . hudX
        . " y"
        . hudY
        . " w"
        . hudWidth
        . " h"
        . hudHeight
    )
}


HideCycleStatusUI() {
    global CycleStatusGui


    if !CycleStatusGui {
        return
    }


    try {
        CycleStatusGui.Hide()
    }
}


UpdateCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText
    global CycleProgressText
    global CycleProgressBar

    global RepeatRunTotal
    global RepeatRunCompleted


    if !CycleStatusGui {
        return
    }


    cyclesLeft :=
        RepeatRunTotal
        - RepeatRunCompleted


    if cyclesLeft < 0 {
        cyclesLeft := 0
    }


    CycleStatusText.Text :=
        ""
        . cyclesLeft


    if RepeatRunTotal > 0 {

        currentRun :=
            RepeatRunCompleted
            + 1


        if currentRun > RepeatRunTotal {
            currentRun :=
                RepeatRunTotal
        }


        if currentRun < 1 {
            currentRun := 1
        }


        CycleProgressText.Text :=
            "CYCLE "
            . currentRun
            . " / "
            . RepeatRunTotal


        progressPercent :=
            Floor(
                (
                    RepeatRunCompleted
                    / RepeatRunTotal
                )
                * 100
            )


        if progressPercent < 0 {
            progressPercent := 0
        }


        if progressPercent > 100 {
            progressPercent := 100
        }


        CycleProgressBar.Value :=
            progressPercent
    }
    else {

        CycleProgressText.Text :=
            "CYCLE 0 / 0"


        CycleProgressBar.Value :=
            0
    }
}


CompleteCycleStatusUI() {
    global CycleStatusText
    global CycleProgressText
    global CycleProgressBar

    global RepeatRunTotal


    if CycleStatusText {
        CycleStatusText.Text :=
            "0"
    }


    if CycleProgressText {

        CycleProgressText.Text :=
            "CYCLE "
            . RepeatRunTotal
            . " / "
            . RepeatRunTotal
    }


    if CycleProgressBar {
        CycleProgressBar.Value :=
            100
    }
}


CancelRepeatCycles(*) {
    global MacroRunning
    global RunningPid

    global ForceLauncherVisible

    global UIColorWarning


    MacroRunning :=
        false


    if RunningPid {

        try {
            if ProcessExist(
                RunningPid
            ) {

                ProcessClose(
                    RunningPid
                )
            }
        }
    }


    RunningPid :=
        0


    ClearRepeatRunState()
    ClearCycleStopRequest()


    HideCycleStatusUI()


    ForceLauncherVisible :=
        true


    UpdateStatus(
        "CYCLES CANCELLED",
        UIColorWarning
    )


    ShowLauncher(
        true
    )
}


ShowCycleInputPrompt() {
    global CycleInputGui
    global CycleInputEdit
    global CycleInputErrorText
    global CycleInputResult
    global CycleInputFinished

    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorError
    global UIColorControlBorder
    global UIColorControlBottom


    CloseCycleInputUI()


    CycleInputResult :=
        0


    CycleInputFinished :=
        false


    CycleInputGui :=
        Gui(
            "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
            "Run Macro"
        )


    CycleInputGui.BackColor :=
        UIColorBackground


    CycleInputGui.Add(
        "Progress",
        "x0 y0 w400 h4 c"
        . UIColorAccent
        . " Background"
        . UIColorAccent
        . " Disabled",
        100
    )


    SetUIHeadingFont(
        CycleInputGui,
        12,
        UIColorPrimaryText
    )


    CycleInputGui.Add(
        "Text",
        "x20 y17 w360 h28 Center c"
        . UIColorPrimaryText
        . " BackgroundTrans",
        "RUN CYCLES"
    )


    SetUIBodyFont(
        CycleInputGui,
        9,
        UIColorSecondaryText
    )


    CycleInputGui.Add(
        "Text",
        "x20 y51 w360 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "How many times should this strategy run?"
    )


    SetUIBodyBoldFont(
        CycleInputGui,
        8,
        UIColorAccent
    )


    CycleInputGui.Add(
        "Text",
        "x20 y75 w360 h18 Center c"
        . UIColorAccent
        . " BackgroundTrans",
        "VALID RANGE  •  1 - 1,000,000"
    )


    CycleInputGui.Add(
        "Progress",
        "x19 y101 w362 h44 c"
        . UIColorControlBorder
        . " Background"
        . UIColorControlBorder
        . " Disabled",
        100
    )


    SetUIBodyBoldFont(
        CycleInputGui,
        13,
        UIColorPrimaryText
    )


    CycleInputEdit :=
        CycleInputGui.Add(
            "Edit",
            "x21 y103 w358 h40 Center Limit7 c"
            . UIColorPrimaryText
            . " Background"
            . UIColorControlBottom,
            "1"
        )


    ApplyDarkControlTheme(
        CycleInputEdit
    )


    CycleInputEdit.OnEvent(
        "Change",
        CycleInputChanged
    )


    SetUIBodyFont(
        CycleInputGui,
        8,
        UIColorError
    )


    CycleInputErrorText :=
        CycleInputGui.Add(
            "Text",
            "x20 y150 w360 h18 Center c"
            . UIColorError
            . " BackgroundTrans",
            ""
        )


    runButton :=
        CreateDarkButton(
            CycleInputGui,
            20,
            177,
            174,
            40,
            "RUN MACRO",
            8
        )


    cancelButton :=
        CreateDarkButton(
            CycleInputGui,
            206,
            177,
            174,
            40,
            "CANCEL",
            8
        )


    runButton.OnEvent(
        "Click",
        SubmitCycleInput
    )


    cancelButton.OnEvent(
        "Click",
        CancelCycleInput
    )


    CycleInputGui.OnEvent(
        "Close",
        CancelCycleInput
    )


    CycleInputGui.OnEvent(
        "Escape",
        CancelCycleInput
    )


    ApplyDarkWindowStyle(
        CycleInputGui
    )


    dialogWidth := 400
    dialogHeight := 237


    dialogX :=
        Floor(
            (1920 - dialogWidth) / 2
        )


    dialogY :=
        Floor(
            (1080 - dialogHeight) / 2
        )


    CycleInputGui.Show(
        "x"
        . dialogX
        . " y"
        . dialogY
        . " w"
        . dialogWidth
        . " h"
        . dialogHeight
    )


    while !CycleInputFinished {
        Sleep(25)
    }


    result :=
        CycleInputResult


    CloseCycleInputUI()


    return result
}


SubmitCycleInput(*) {
    global CycleInputEdit
    global CycleInputErrorText
    global CycleInputResult
    global CycleInputFinished


    inputValue :=
        Trim(
            CycleInputEdit.Value
        )


    if !RegExMatch(
        inputValue,
        "^\d+$"
    ) {

        CycleInputErrorText.Text :=
            "INVALID AMOUNT — ENTER A WHOLE NUMBER AND RETRY"


        return
    }


    runCount :=
        inputValue
        + 0


    if (
        runCount < 1
        || runCount > 1000000
    ) {

        CycleInputErrorText.Text :=
            "INVALID AMOUNT — USE 1 THROUGH 1,000,000 AND RETRY"


        return
    }


    CycleInputResult :=
        runCount


    CycleInputFinished :=
        true
}


CancelCycleInput(*) {
    global CycleInputResult
    global CycleInputFinished


    CycleInputResult :=
        0


    CycleInputFinished :=
        true
}


CycleInputChanged(*) {
    global CycleInputErrorText


    if CycleInputErrorText {

        CycleInputErrorText.Text :=
            ""
    }
}


CloseCycleInputUI() {
    global CycleInputGui
    global CycleInputEdit
    global CycleInputErrorText


    if CycleInputGui {

        try {
            CycleInputGui.Destroy()
        }
    }


    CycleInputGui :=
        ""


    CycleInputEdit :=
        ""


    CycleInputErrorText :=
        ""
}
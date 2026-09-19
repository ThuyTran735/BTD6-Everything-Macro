#Requires AutoHotkey v2.0


global CycleProgressText := ""
global CycleProgressBar := ""
global CycleProgressBackground := ""

global CycleStatusLastX := ""
global CycleStatusLastY := ""

global CycleInputGui := ""
global CycleInputEdit := ""
global CycleInputErrorText := ""
global CycleInputResult := 0
global CycleInputFinished := false


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
            CycleStatusGui.Destroy()
        }
    }


    CycleStatusGui := ""
    CycleStatusText := ""
    CycleProgressText := ""
    CycleProgressBar := ""
    CycleProgressBackground := ""
    CycleCancelButton := ""


    hudWidth := 348
    hudHeight := 78


    CycleStatusGui :=
        Gui(
            "+AlwaysOnTop -Caption +ToolWindow +Border",
            ""
        )


    CycleStatusGui.BackColor :=
        UIColorBackground


    CycleStatusGui.MarginX :=
        0


    CycleStatusGui.MarginY :=
        0


    ; Left accent.
    CycleStatusGui.Add(
        "Progress",
        "x0 y0 w4 h"
        . hudHeight
        . " c"
        . UIColorAccent
        . " Background"
        . UIColorAccent
        . " Disabled",
        100
    )


    ; Cycle number.
    SetUIBodyBoldFont(
        CycleStatusGui,
        10,
        UIColorPrimaryText
    )


    CycleStatusText :=
        CycleStatusGui.Add(
            "Text",
            "x16 y10 w205 h22 Center c"
            . UIColorPrimaryText
            . " BackgroundTrans",
            "CYCLE 1 / 1"
        )


    ; Cycles remaining.
    SetUIBodyFont(
        CycleStatusGui,
        8,
        UIColorSecondaryText
    )


    CycleProgressText :=
        CycleStatusGui.Add(
            "Text",
            "x16 y35 w205 h18 Center c"
            . UIColorSecondaryText
            . " BackgroundTrans",
            "1 CYCLE LEFT"
        )


    ; Progress background.
    CycleProgressBackground :=
        CycleStatusGui.Add(
            "Progress",
            "x16 y59 w205 h8 c"
            . UIColorControlBorder
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            100
        )


    ; Progress fill.
    CycleProgressBar :=
        CycleStatusGui.Add(
            "Progress",
            "x16 y59 w205 h8 Range0-100 c"
            . UIColorAccent
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            0
        )


    ; Cancel button.
    CycleCancelButton :=
        CreateDarkButton(
            CycleStatusGui,
            242,
            18,
            92,
            42,
            "CLOSE RUN",
            7
        )


    CreateHelpBadgeForButton(
        CycleStatusGui,
        CycleCancelButton,
        "CLOSE RUN",
        "Stops the active run.`n`nIf a queue is running, the entire queue stops and later jobs will not start."
    )


    CycleCancelButton.OnEvent(
        "Click",
        RequestCancelMacroCycles
    )


    CycleStatusGui.Show(
        "Hide w"
        . hudWidth
        . " h"
        . hudHeight
    )


    ApplyDarkWindowStyle(
        CycleStatusGui
    )
}


ShowCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusLastX
    global CycleStatusLastY


    if !CycleStatusGui {

        CreateCycleStatusUI()
    }


    SetTimer(
        UpdateCycleStatusPosition,
        0
    )


    hudWidth := 348
    hudHeight := 78


    ; Original top-center position.
    hudX :=
        Floor(
            (1920 - hudWidth) / 2
        )


    hudY :=
        8


    ; Gui.Show controls the actual client size.
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


    CycleStatusLastX :=
        hudX


    CycleStatusLastY :=
        hudY


    UpdateCycleStatusUI()


    SetTimer(
        UpdateCycleStatusPosition,
        100
    )
}


UpdateCycleStatusPosition() {
    global CycleStatusGui
    global CycleStatusLastX
    global CycleStatusLastY


    if !CycleStatusGui {
        return
    }


    if !WinExist(
        "ahk_id "
        . CycleStatusGui.Hwnd
    ) {
        return
    }


    hudWidth := 348


    centerX :=
        Floor(
            (1920 - hudWidth) / 2
        )


    hudX :=
        centerX


    hudY :=
        8


    panelSide :=
        GetUpgradePanelSide()


    if panelSide = "Right" {

        ; The right-side tower panel moves
        ; BTD6's round display inward.
        ;
        ; Temporarily move the cycle tracker
        ; farther left until the panel closes.
        hudX :=
            centerX
            - 360
    }


    if (
        hudX = CycleStatusLastX
        && hudY = CycleStatusLastY
    ) {
        return
    }


    ; Only move the window.
    ;
    ; Do NOT resize it with WinMove because
    ; that changes the outer window dimensions
    ; and can clip the GUI client area.
    try {
        WinMove(
            hudX,
            hudY,
            ,
            ,
            "ahk_id "
            . CycleStatusGui.Hwnd
        )
    }


    CycleStatusLastX :=
        hudX


    CycleStatusLastY :=
        hudY
}


UpdateCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText

    global CycleProgressText
    global CycleProgressBar

    global RepeatRunTotal
    global RepeatRunCompleted

    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs
    global QueueTotalRuns
    global QueueCompletedRuns
    global QueueCurrentRetryCount


    if !CycleStatusGui {
        return
    }


    if RepeatRunTotal < 1 {
        return
    }


    currentCycle :=
        RepeatRunCompleted
        + 1


    if currentCycle > RepeatRunTotal {

        currentCycle :=
            RepeatRunTotal
    }


    if currentCycle < 1 {

        currentCycle :=
            1
    }


    if QueueRunning {

        runsLeft :=
            QueueTotalRuns
            - QueueCompletedRuns


        if runsLeft < 0 {
            runsLeft := 0
        }


        if QueueTotalRuns > 0 {

            progress :=
                Floor(
                    (
                        QueueCompletedRuns
                        / QueueTotalRuns
                    )
                    * 100
                )
        }
        else {

            progress := 0
        }


        CycleStatusText.Text :=
            "JOB "
            . QueueActiveJobIndex
            . " / "
            . QueueTotalJobs
            . "  -  CYCLE "
            . currentCycle
            . " / "
            . RepeatRunTotal


        if QueueCurrentRetryCount > 0 {
            CycleStatusText.Text .=
                "  -  RETRY "
                . QueueCurrentRetryCount
                . " / "
                . GetQueueRetryLimit()
        }


        if runsLeft = 1 {

            CycleProgressText.Text :=
                "1 TOTAL RUN LEFT"
        }
        else {

            CycleProgressText.Text :=
                runsLeft
                . " TOTAL RUNS LEFT"
        }
    }
    else {

        cyclesLeft :=
            RepeatRunTotal
            - RepeatRunCompleted


        if cyclesLeft < 0 {

            cyclesLeft :=
                0
        }


        progress :=
            Floor(
                (
                    RepeatRunCompleted
                    / RepeatRunTotal
                )
                * 100
            )


        CycleStatusText.Text :=
            "CYCLE "
            . currentCycle
            . " / "
            . RepeatRunTotal


        if cyclesLeft = 1 {

            CycleProgressText.Text :=
                "1 CYCLE LEFT"
        }
        else {

            CycleProgressText.Text :=
                cyclesLeft
                . " CYCLES LEFT"
        }
    }


    if progress < 0 {

        progress :=
            0
    }


    if progress > 100 {

        progress :=
            100
    }


    CycleProgressBar.Value :=
        progress
}


CompleteCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusText

    global CycleProgressText
    global CycleProgressBar

    global RepeatRunTotal

    global QueueRunning
    global QueueTotalRuns


    if !CycleStatusGui {
        return
    }


    if RepeatRunTotal < 1 {
        return
    }


    if QueueRunning {

        CycleStatusText.Text :=
            "QUEUE COMPLETE"


        CycleProgressText.Text :=
            QueueTotalRuns
            . " RUN"
            . (
                QueueTotalRuns = 1
                ? ""
                : "S"
            )
            . " COMPLETE"
    }
    else {

        CycleStatusText.Text :=
            "CYCLE "
            . RepeatRunTotal
            . " / "
            . RepeatRunTotal


        CycleProgressText.Text :=
            "COMPLETE"
    }


    ; Always visibly finish the bar before
    ; the cycle tracker closes.
    CycleProgressBar.Value :=
        100
}


HideCycleStatusUI() {
    global CycleStatusGui
    global CycleStatusLastX
    global CycleStatusLastY


    SetTimer(
        UpdateCycleStatusPosition,
        0
    )


    CycleStatusLastX :=
        ""


    CycleStatusLastY :=
        ""


    if !CycleStatusGui {
        return
    }


    try {
        CycleStatusGui.Hide()
    }
}


RequestCancelMacroCyclesIfStillActive(*) {
    global MacroRunning
    global RunningPid
    global QueueRunning


    if !MacroRunning && !QueueRunning && !RunningPid {
        return
    }


    CancelMacroCycles()
}


RequestCancelMacroCycles(*) {
    global MacroRunning
    global RunningPid
    global QueueRunning
    global CycleStatusGui


    if !MacroRunning && !QueueRunning && !RunningPid {
        return
    }


    actionText :=
        QueueRunning
        ? "the entire active queue"
        : "the active run"


    ShowThemedConfirmation(
        "CLOSE ACTIVE RUN?",
        "Stop " . actionText . " now?`n`nCurrent progress will stop and later queued runs will not start automatically.",
        "CLOSE RUN",
        RequestCancelMacroCyclesIfStillActive,
        CycleStatusGui,
        "Stops the current run.`n`nIf a queue is active, the whole queue stops and later jobs will not start."
    )
}


CancelMacroCycles(*) {
    global MacroRunning
    global RunningPid
    global ActiveRunToken

    global CycleStatusGui
    global CycleStatusText
    global CycleProgressText

    global RepeatRunRemaining
    global ForceLauncherVisible

    global QueueRunning

    global UIColorWarning


    ; Cancel any queued next cycle.
    SetTimer(
        StartNextQueuedRun,
        0
    )


    SetTimer(
        StartNextQueueJob,
        0
    )


    ClearMacroContinuation()


    queueWasRunning :=
        QueueRunning


    RepeatRunRemaining :=
        0


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


    ClearChildRunResult(ActiveRunToken)
    ActiveRunToken := ""


    if CycleStatusGui {

        CycleStatusText.Text :=
            queueWasRunning
            ? "QUEUE CANCELLED"
            : "CYCLES CANCELLED"


        CycleProgressText.Text :=
            "STOPPED"
    }


    Sleep(
        250
    )


    HideCycleStatusUI()


    ClearRepeatRunState()
    ClearQueueExecutionState()


    try {
        ClearCycleStopRequest()
    }


    ForceLauncherVisible :=
        true


    ClearLauncherReturnPending()
    SetLauncherRunSuppressed(false)


    UpdateStatus(
        queueWasRunning
        ? "QUEUE CANCELLED"
        : "CYCLES CANCELLED",
        UIColorWarning
    )


    ShowLauncher(
        true
    )
}


ShowCycleInputPrompt(context := "run", initialValue := 1) {
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
    global UIColorInputBorder
    global UIColorInputBackground
    global UIColorInputText


    CloseCycleInputUI()


    CycleInputResult :=
        0


    CycleInputFinished :=
        false


    dialogWidth := 440
    dialogHeight := 280


    isQueuePrompt := (context = "queue" || context = "editqueue")
    isEditQueuePrompt := context = "editqueue"


    CycleInputGui :=
        Gui(
            "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
            isEditQueuePrompt
            ? "Edit Queue Job"
            : (isQueuePrompt ? "Add to Queue" : "Run Macro")
        )


    CycleInputGui.BackColor :=
        UIColorBackground


    CycleInputGui.MarginX :=
        0


    CycleInputGui.MarginY :=
        0


    CycleInputGui.Add(
        "Progress",
        "x0 y0 w"
        . dialogWidth
        . " h4 c"
        . UIColorAccent
        . " Background"
        . UIColorAccent
        . " Disabled",
        100
    )


    SetUIHeadingFont(
        CycleInputGui,
        13,
        UIColorPrimaryText
    )


    CycleInputGui.Add(
        "Text",
        "x20 y20 w400 h30 Center c"
        . UIColorPrimaryText
        . " BackgroundTrans",
        isEditQueuePrompt
        ? "SAVE CHANGES"
        : (isQueuePrompt ? "ADD TO QUEUE" : "RUN CYCLES")
    )


    SetUIBodyFont(
        CycleInputGui,
        9,
        UIColorSecondaryText
    )


    CycleInputGui.Add(
        "Text",
        "x20 y59 w400 h22 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        isEditQueuePrompt
        ? "How many times should this edited job run?"
        : (isQueuePrompt
            ? "How many times should this script run in the queue?"
            : "How many times should this strategy run?")
    )


    SetUIBodyBoldFont(
        CycleInputGui,
        8,
        UIColorAccent
    )


    CycleInputGui.Add(
        "Text",
        "x20 y88 w400 h20 Center c"
        . UIColorAccent
        . " BackgroundTrans",
        "VALID RANGE  -  1 TO 1,000,000"
    )


    CycleInputGui.Add(
        "Progress",
        "x29 y120 w382 h48 c"
        . UIColorInputBorder
        . " Background"
        . UIColorInputBorder
        . " Disabled",
        100
    )


    SetUIBodyBoldFont(
        CycleInputGui,
        14,
        UIColorPrimaryText
    )


    CycleInputEdit :=
        CycleInputGui.Add(
            "Edit",
            "x31 y122 w378 h44 Center Limit7 c"
            . UIColorInputText
            . " Background"
            . UIColorInputBackground,
            initialValue
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
            "x20 y176 w400 h20 Center c"
            . UIColorError
            . " BackgroundTrans",
            ""
        )


    runButton :=
        CreateDarkButton(
            CycleInputGui,
            30,
            211,
            184,
            44,
            isEditQueuePrompt
            ? "SAVE CHANGES"
            : (isQueuePrompt ? "ADD TO QUEUE" : "START RUN"),
            8
        )


    cancelButton :=
        CreateDarkButton(
            CycleInputGui,
            226,
            211,
            184,
            44,
            "CLOSE",
            8
        )


    CreateHelpBadgeForButton(
        CycleInputGui,
        runButton,
        isEditQueuePrompt
        ? "SAVE CHANGES"
        : (isQueuePrompt ? "ADD TO QUEUE" : "START RUN"),
        isEditQueuePrompt
        ? "Saves the edited job with this run count.`n`nEnter a whole number from 1 to 1,000,000."
        : (isQueuePrompt
            ? "Sets how many times this queued job should run.`n`nEnter a whole number from 1 to 1,000,000."
            : "Sets how many times the selected script should run.`n`nEnter a whole number from 1 to 1,000,000.")
    )


    CreateHelpBadgeForButton(
        CycleInputGui,
        cancelButton,
        "CLOSE",
        "Closes this prompt without starting, adding, or saving the pending run."
    )


    runButton.OnEvent(
        "Click",
        ConfirmCycleInput
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


    CycleInputEdit.Focus()


    while !CycleInputFinished {

        Sleep(
            25
        )
    }


    result :=
        CycleInputResult


    CloseCycleInputUI()


    return result
}


ConfirmCycleInput(*) {
    global CycleInputEdit
    global CycleInputErrorText

    global CycleInputResult
    global CycleInputFinished


    if !CycleInputEdit {
        return
    }


    inputValue :=
        Trim(
            CycleInputEdit.Value
        )


    if inputValue = "" {

        CycleInputErrorText.Text :=
            "ENTER A CYCLE AMOUNT AND RETRY"


        return
    }


    if !RegExMatch(
        inputValue,
        "^\d+$"
    ) {

        CycleInputErrorText.Text :=
            "ENTER A WHOLE NUMBER AND RETRY"


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
            "USE A NUMBER FROM 1 TO 1,000,000"


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
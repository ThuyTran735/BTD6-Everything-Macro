#Requires AutoHotkey v2.0


global CycleProgressText := ""
global CycleProgressBar := ""
global CycleProgressBackground := ""

global CycleStatusLastX := ""
global CycleStatusLastY := ""
global CycleStatusRightPanelOpen := false
global CycleStatusRightPanelMisses := 0

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
    global UIColorPanelBorder


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


    hudWidth := 420
    hudHeight := 98


    CycleStatusGui :=
        Gui(
            "+AlwaysOnTop -Caption +ToolWindow -Border",
            ""
        )


    CycleStatusGui.BackColor :=
        UIColorBackground


    CycleStatusGui.MarginX := 0
    CycleStatusGui.MarginY := 0


    AddCustomWindowBorder(CycleStatusGui, hudWidth, hudHeight, 3)
    AddUICard(CycleStatusGui, 8, 8, 404, 82)


    ; Keep the run information together in one compact status block.
    SetUIHeadingFont(
        CycleStatusGui,
        9,
        UIColorPrimaryText
    )


    CycleStatusText :=
        CycleStatusGui.Add(
            "Text",
            "x20 y17 w248 h24 Center +0x200 c"
            . UIColorPrimaryText
            . " BackgroundTrans",
            "CYCLE 1 / 1"
        )


    SetUIBodyFont(
        CycleStatusGui,
        8,
        UIColorSecondaryText
    )


    CycleProgressText :=
        CycleStatusGui.Add(
            "Text",
            "x20 y42 w248 h18 Center +0x200 c"
            . UIColorSecondaryText
            . " BackgroundTrans",
            "1 CYCLE LEFT"
        )


    CycleProgressBackground :=
        CycleStatusGui.Add(
            "Progress",
            "x20 y68 w248 h8 c"
            . UIColorControlBorder
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            100
        )


    CycleProgressBar :=
        CycleStatusGui.Add(
            "Progress",
            "x20 y68 w248 h8 Range0-100 c"
            . UIColorAccent
            . " Background"
            . UIColorControlBorder
            . " Disabled",
            0
        )


    ; Quiet divider between run progress and the stop action.
    CycleStatusGui.Add(
        "Progress",
        "x278 y18 w1 h62 c"
        . UIColorPanelBorder
        . " Background"
        . UIColorPanelBorder
        . " Disabled",
        100
    )


    CycleCancelButton :=
        CreateDarkButton(
            CycleStatusGui,
            292,
            26,
            104,
            46,
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
    global CycleStatusRightPanelOpen
    global CycleStatusRightPanelMisses


    if !CycleStatusGui {

        CreateCycleStatusUI()
    }


    CycleStatusRightPanelOpen := false
    CycleStatusRightPanelMisses := 0


    SetTimer(
        UpdateCycleStatusPosition,
        0
    )


    hudWidth := 420
    hudHeight := 98


    ; Center when safe, but never cover the round-number OCR region. This
    ; also handles a right-side upgrade panel immediately when the HUD opens.
    hudX := GetCycleStatusTargetX(hudWidth)
    hudY := 8


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


    CycleStatusLastX := hudX
    CycleStatusLastY := hudY


    UpdateCycleStatusUI()


    ; Panel detection uses FindText and can take longer than normal UI hover
    ; work. Give this timer a lower thread priority so it cannot interrupt a
    ; custom-control paint halfway through and expose a gray intermediate
    ; Progress layer for a frame.
    SetTimer(
        UpdateCycleStatusPosition,
        100,
        -10
    )
}


IsRightUpgradePanelOpen() {
    global SellButtonPattern


    ; Detect the visible right-side upgrade panel directly, but only search
    ; the portion of the screen where that panel can actually exist. The Cycle
    ; HUD lives at the very top of the screen, so excluding that area prevents
    ; FindText from repeatedly capturing/scanning the HUD itself and cuts the
    ; amount of work substantially.
    searchLeft := Floor(A_ScreenWidth * 0.58)
    searchTop := Floor(A_ScreenHeight * 0.20)


    return !!FindText(
        &X,
        &Y,
        searchLeft,
        searchTop,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        SellButtonPattern
    )
}


UpdateCycleStatusRightPanelState() {
    global CycleStatusRightPanelOpen
    global CycleStatusRightPanelMisses


    if IsRightUpgradePanelOpen() {
        CycleStatusRightPanelOpen := true
        CycleStatusRightPanelMisses := 0
        return true
    }


    if CycleStatusRightPanelOpen {
        CycleStatusRightPanelMisses++

        ; FindText can miss a single frame while the game animates. Keep the
        ; HUD left through short misses so it does not blink back over the round
        ; number and then immediately move left again.
        if CycleStatusRightPanelMisses < 6 {
            return true
        }
    }


    CycleStatusRightPanelOpen := false
    CycleStatusRightPanelMisses := 0
    return false
}


GetCycleStatusTargetX(hudWidth, refreshPanelState := true) {
    global CycleStatusRightPanelOpen


    minX := 8
    maxX := Max(minX, A_ScreenWidth - hudWidth - 8)


    centerX := Floor((A_ScreenWidth - hudWidth) / 2)
    hudX := centerX


    rightPanelOpen := refreshPanelState
        ? UpdateCycleStatusRightPanelState()
        : CycleStatusRightPanelOpen


    if rightPanelOpen {
        hudX := centerX - 360
    }


    return Max(minX, Min(hudX, maxX))
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


    hudWidth := 420


    hudX := GetCycleStatusTargetX(hudWidth)
    hudY := 8


    if (
        hudX = CycleStatusLastX
        && hudY = CycleStatusLastY
    ) {
        return
    }


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


    CycleStatusLastX := hudX
    CycleStatusLastY := hudY
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


        if QueueCurrentRetryCount > 0 {
            CycleStatusText.Text .=
                "  -  RETRY "
                . QueueCurrentRetryCount
                . " / "
                . GetQueueRetryLimit()
        }


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
    global CycleStatusRightPanelOpen
    global CycleStatusRightPanelMisses


    SetTimer(
        UpdateCycleStatusPosition,
        0
    )


    CycleStatusLastX :=
        ""


    CycleStatusLastY :=
        ""


    CycleStatusRightPanelOpen := false
    CycleStatusRightPanelMisses := 0


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

        ; Record the user's explicit stop request in the child run log
        ; before terminating the strategy process.
        LogManualRunStopByPid(
            RunningPid,
            "USER CLOSED RUN MANUALLY"
        )


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


    CycleInputResult := 0
    CycleInputFinished := false


    dialogWidth := 460
    dialogHeight := 326


    isQueuePrompt := (context = "queue" || context = "editqueue")
    isEditQueuePrompt := context = "editqueue"


    actionTitle := isEditQueuePrompt
        ? "SAVE CHANGES"
        : (isQueuePrompt ? "ADD TO QUEUE" : "RUN CYCLES")


    actionDescription := isEditQueuePrompt
        ? "Choose how many times this edited queue job should run"
        : (isQueuePrompt
            ? "Choose how many times this script should run in the queue"
            : "Choose how many times this strategy should run")


    CycleInputGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        isEditQueuePrompt
        ? "Edit Queue Job"
        : (isQueuePrompt ? "Add to Queue" : "Run Cycles")
    )


    CycleInputGui.BackColor := UIColorBackground
    CycleInputGui.MarginX := 0
    CycleInputGui.MarginY := 0


    EnableCustomWindowChrome(CycleInputGui)
    AddCustomWindowBorder(CycleInputGui, dialogWidth, dialogHeight)


    AddUIOutlinedText(
        CycleInputGui,
        actionTitle,
        20,
        18,
        420,
        30,
        12,
        "Center"
    )


    SetUIBodyFont(CycleInputGui, 9, UIColorSecondaryText)
    CycleInputGui.Add(
        "Text",
        "x20 y52 w420 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        actionDescription
    )


    ; Run-count card.
    AddUICard(CycleInputGui, 16, 82, 428, 138)
    AddUIOutlinedText(
        CycleInputGui,
        "RUN COUNT",
        30,
        92,
        400,
        20,
        9,
        "Center"
    )


    SetUIBodyFont(CycleInputGui, 8, UIColorAccent)
    CycleInputGui.Add(
        "Text",
        "x30 y117 w400 h18 Center c"
        . UIColorAccent
        . " BackgroundTrans",
        "WHOLE NUMBER  -  1 TO 1,000,000"
    )


    CycleInputGui.Add(
        "Progress",
        "x30 y143 w400 h50 c"
        . UIColorInputBorder
        . " Background"
        . UIColorInputBorder
        . " Disabled",
        100
    )


    SetUIBodyFont(CycleInputGui, 14, UIColorPrimaryText)
    CycleInputEdit := CycleInputGui.Add(
        "Edit",
        "x32 y145 w396 h46 Center Limit7 c"
        . UIColorInputText
        . " Background"
        . UIColorInputBackground,
        initialValue
    )


    ApplyDarkControlTheme(CycleInputEdit)
    CycleInputEdit.OnEvent("Change", CycleInputChanged)


    SetUIBodyFont(CycleInputGui, 8, UIColorError)
    CycleInputErrorText := CycleInputGui.Add(
        "Text",
        "x30 y196 w400 h18 Center c"
        . UIColorError
        . " BackgroundTrans",
        ""
    )


    ; Action card keeps the two choices aligned with the rest of the UI.
    AddUICard(CycleInputGui, 16, 230, 428, 80)


    runButton := CreateDarkButton(
        CycleInputGui,
        30,
        247,
        194,
        44,
        isEditQueuePrompt
        ? "SAVE CHANGES"
        : (isQueuePrompt ? "ADD TO QUEUE" : "START RUN"),
        8
    )


    cancelButton := CreateDarkButton(
        CycleInputGui,
        236,
        247,
        194,
        44,
        "CANCEL",
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
        "CANCEL",
        "Returns without starting, adding, or saving the pending run."
    )


    runButton.OnEvent("Click", ConfirmCycleInput)
    cancelButton.OnEvent("Click", CancelCycleInput)
    CycleInputGui.OnEvent("Close", CancelCycleInput)
    CycleInputGui.OnEvent("Escape", CancelCycleInput)


    CycleInputGui.Show(
        "Hide w"
        . dialogWidth
        . " h"
        . dialogHeight
    )


    ApplyDarkWindowStyle(CycleInputGui)


    dialogX := Floor((A_ScreenWidth - dialogWidth) / 2)
    dialogY := Floor((A_ScreenHeight - dialogHeight) / 2)


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
        Sleep(25)
    }


    result := CycleInputResult
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
#Requires AutoHotkey v2.0

; Shared run-count prompt for starting a strategy and adding or editing a job.
; The caller receives zero on cancellation and a validated count on confirmation.

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
    dialogHeight := 316


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
        24,
        24,
        412,
        28,
        12,
        "Center"
    )


    SetUIBodyFont(CycleInputGui, 9, UIColorSecondaryText)
    CycleInputGui.Add(
        "Text",
        "x24 y60 w412 h20 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        actionDescription
    )


    ; Run-count card.
    AddUICard(CycleInputGui, 24, 96, 412, 136)
    AddUIOutlinedText(
        CycleInputGui,
        "RUN COUNT",
        40,
        108,
        380,
        20,
        9,
        "Center"
    )


    SetUIBodyFont(CycleInputGui, 8, UIColorSecondaryText)
    CycleInputGui.Add(
        "Text",
        "x40 y132 w380 h18 Center c"
        . UIColorSecondaryText
        . " BackgroundTrans",
        "Whole number from 1 to 1,000,000"
    )


    CycleInputGui.Add(
        "Progress",
        "x40 y160 w380 h44 c"
        . UIColorInputBorder
        . " Background"
        . UIColorInputBorder
        . " Disabled",
        100
    )


    SetUIBodyFont(CycleInputGui, 14, UIColorPrimaryText)
    CycleInputEdit := CycleInputGui.Add(
        "Edit",
        "x42 y162 w376 h40 Center Limit7 c"
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
        "x40 y212 w380 h16 Center c"
        . UIColorError
        . " BackgroundTrans",
        ""
    )


    ; Both choices share the same baseline and outer margin.


    runButton := CreateDarkButton(
        CycleInputGui,
        24,
        248,
        200,
        44,
        isEditQueuePrompt
        ? "SAVE CHANGES"
        : (isQueuePrompt ? "ADD TO QUEUE" : "START RUN"),
        8
    )


    cancelButton := CreateDarkButton(
        CycleInputGui,
        236,
        248,
        200,
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

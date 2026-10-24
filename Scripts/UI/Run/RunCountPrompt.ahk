#Requires AutoHotkey v2.0

; Shared run-count prompt for starting a strategy and adding or editing a job.
; Zero means cancelled, -1 means Infinite, and positive values are finite counts.

NormalizeStoredRunCount(value) {
    return value = -1 ? -1 : Max(1, Integer(value))
}

FormatRunCount(value) {
    return value = -1 ? "INFINITE" : value
}

CombineRunCounts(total, count) {
    return total = -1 || count = -1 ? -1 : total + count
}

ShowCycleInputPrompt(context := "run", initialValue := 1) {
    global CycleInputGui
    global CycleInputEdit
    global CycleInputInfiniteCheckbox
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
    dialogHeight := 360


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
    AddUICard(CycleInputGui, 24, 96, 412, 180)
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
        "Choose a count or keep running until stopped"
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
        initialValue = -1 ? 1 : initialValue
    )


    ApplyDarkControlTheme(CycleInputEdit)
    CycleInputEdit.OnEvent("Change", CycleInputChanged)

    SetUIBodyFont(CycleInputGui, 10, UIColorPrimaryText)
    CycleInputInfiniteCheckbox := CycleInputGui.Add(
        "Checkbox", "x44 y214 w338 h24", "Infinite (until stopped)"
    )
    CycleInputInfiniteCheckbox.Value := initialValue = -1
    CycleInputInfiniteCheckbox.OnEvent("Click", CycleInputChanged)
    CycleInputEdit.Enabled := !CycleInputInfiniteCheckbox.Value
    CreateHelpBadge(
        CycleInputGui, 400, 218, "INFINITE RUNS",
        "Keeps running this strategy until you stop it. Normal failure and retry limits still apply."
        . (isQueuePrompt ? "`n`nAn infinite queue job keeps later jobs waiting until you stop the queue." : "")
    )


    SetUIBodyFont(CycleInputGui, 8, UIColorError)
    CycleInputErrorText := CycleInputGui.Add(
        "Text",
        "x40 y250 w380 h16 Center c"
        . UIColorError
        . " BackgroundTrans",
        ""
    )


    ; Both choices share the same baseline and outer margin.


    runButton := CreateDarkButton(
        CycleInputGui,
        24,
        292,
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
        292,
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
        ? "Saves the edited job with this run count.`n`nEnter a whole number from 1 to 1,000,000, or select Infinite. An infinite job keeps later jobs waiting until you stop the queue."
        : (isQueuePrompt
            ? "Sets how many times this queued job should run.`n`nEnter a whole number from 1 to 1,000,000, or select Infinite. An infinite job keeps later jobs waiting until you stop the queue."
            : "Sets how many times the selected script should run.`n`nEnter a whole number from 1 to 1,000,000, or select Infinite to keep running until you stop it.")
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


    if CycleInputInfiniteCheckbox.Value
        CycleInputInfiniteCheckbox.Focus()
    else
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
    global CycleInputInfiniteCheckbox
    global CycleInputErrorText

    global CycleInputResult
    global CycleInputFinished


    if !CycleInputEdit {
        return
    }

    if CycleInputInfiniteCheckbox && CycleInputInfiniteCheckbox.Value {
        CycleInputResult := -1
        CycleInputFinished := true
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
    global CycleInputEdit, CycleInputInfiniteCheckbox

    if CycleInputEdit && CycleInputInfiniteCheckbox
        CycleInputEdit.Enabled := !CycleInputInfiniteCheckbox.Value

    if CycleInputErrorText {

        CycleInputErrorText.Text :=
            ""
    }
}


CloseCycleInputUI() {
    global CycleInputGui
    global CycleInputEdit
    global CycleInputInfiniteCheckbox
    global CycleInputErrorText

    CloseContextHelp()

    if CycleInputGui {

        try {
            CycleInputGui.Destroy()
        }
    }


    CycleInputGui :=
        ""


    CycleInputEdit :=
        ""

    CycleInputInfiniteCheckbox := ""

    CycleInputErrorText :=
        ""
}

#Requires AutoHotkey v2.0

; These prompts own their buttons and return a decision, leaving the caller to
; save or replace data. Closing a prompt never means discarding work.
AskBuilderSaveChanges(reason) {
    return AskBuilderChoice("UNSAVED WORK", "Save your work before " . reason . "?`n`nSave keeps the complete draft, including unfinished fields. You can choose any folder; UserData is the default. Discard continues without saving these changes.", ["Save", "Discard", "Cancel"], "Cancel")
}

AskBuilderChoice(title, message, choices, defaultChoice := "Cancel") {
    global MainGui, BuilderHeadingFont
    CloseBuilderDropdowns()
    result := Map("done", false, "choice", defaultChoice)
    dialog := Gui("-Caption +Border +Owner" . MainGui.Hwnd, "Strategy Builder - " . title)
    dialog.BackColor := "0D1117"
    CreateStrategyBuilderBorder(dialog, 580, 310)
    dialog.SetFont("s14 Norm cF4F7FB", BuilderHeadingFont)
    dialog.AddText("x24 y24 w532 h40", title)
    dialog.SetFont("s10 Norm cD8E0E8", "Segoe UI")
    dialog.AddText("x24 y80 w532 h154", message)
    buttons := []
    width := Floor((532 - (choices.Length - 1) * 12) / choices.Length)
    for index, choice in choices {
        button := BuilderDarkButton(dialog, 24 + (index - 1) * (width + 12), 254, width, 32, StrUpper(choice) . " (" . StrUpper(SubStr(choice, 1, 1)) . ")", 9, choice = "Save" || choice = "Restore" ? "Success" : "Normal")
        button.OnEvent("Click", FinishBuilderChoice.Bind(result, choice))
        buttons.Push(button)
    }
    dialog.OnEvent("Close", FinishBuilderChoice.Bind(result, defaultChoice))
    dialog.OnEvent("Escape", FinishBuilderChoice.Bind(result, defaultChoice))
    ; Letter keys and Enter work even though the themed buttons are owner-drawn.
    ; Keep these shortcuts scoped to this prompt, never the game or another app.
    keyBindings := Map()
    for choice in choices
        keyBindings[StrLower(SubStr(choice, 1, 1))] := FinishBuilderChoice.Bind(result, choice)
    keyBindings["Enter"] := FinishBuilderChoice.Bind(result, defaultChoice)
    HotIfWinActive("ahk_id " . dialog.Hwnd)
    for key, callback in keyBindings
        Hotkey(key, callback, "On")
    HotIf()
    MainGui.Opt("+Disabled")
    try {
        dialog.Show("w580 h310")
        while !result["done"]
            Sleep(25)
        return result["choice"]
    } finally {
        HotIfWinActive("ahk_id " . dialog.Hwnd)
        for key, callback in keyBindings
            Hotkey(key, "Off")
        HotIf()
        for button in buttons
            button.ActionPending := false
        dialog.Destroy()
        MainGui.Opt("-Disabled")
        ; The parent was only disabled. Show() would grow its custom frame.
        WinActivate("ahk_id " . MainGui.Hwnd)
    }
}

FinishBuilderChoice(result, choice, *) {
    result["choice"] := choice
    result["done"] := true
}

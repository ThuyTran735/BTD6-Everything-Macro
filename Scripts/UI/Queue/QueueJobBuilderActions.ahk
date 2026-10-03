#Requires AutoHotkey v2.0

; v3 file note: Adds the selected job and handles closing/destroying the builder.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

AddQueueBuilderSelection(*) {
    global QueueBuilderJobTypeDropdown
    global QueueBuilderIsEditing
    global QueueBuilderEditIndex
    global MacroJobQueue
    global QueueBuilderStrategyDropdown
    global QueueBuilderMapStrategies

    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global QueueBuilderExpScripts

    global UIColorError


    if QueueBuilderJobTypeDropdown.Text
        = "Map Script" {

        selectedName :=
            QueueBuilderStrategyDropdown.Text


        for strategy in QueueBuilderMapStrategies {
            if strategy.name = selectedName {
                path := strategy.path
                label := strategy.label


                if QueueBuilderIsEditing {
                    currentRuns := MacroJobQueue[QueueBuilderEditIndex].runs
                    editIndex := QueueBuilderEditIndex
                    DestroyQueueJobBuilder(false)
                    runCount := ShowCycleInputPrompt("editqueue", currentRuns)

                    if runCount < 1 {
                        ShowQueueManager()
                        return false
                    }

                    MacroJobQueue[editIndex] := {
                        path: path,
                        label: label,
                        mode: "Default",
                        runs: runCount
                    }

                    SetQueueHistorySource()
                    UpdateQueueLauncherButton()
                    ShowQueueManager()
                    return true
                }

                CloseQueueJobBuilder()


                return AddJobToQueue(
                    path,
                    label,
                    "Default"
                )
            }
        }


        UpdateStatus(
            "SELECT A VALID STRATEGY",
            UIColorError
        )


        return false
    }


    towerType :=
        QueueBuilderExpTypeDropdown.Text


    selectedName :=
        QueueBuilderExpScriptDropdown.Text


    for script in QueueBuilderExpScripts {
        if script.name = selectedName {
            path := script.path
            label :=
                towerType
                . " - "
                . script.name


            if QueueBuilderIsEditing {
                currentRuns := MacroJobQueue[QueueBuilderEditIndex].runs
                editIndex := QueueBuilderEditIndex
                DestroyQueueJobBuilder(false)
                runCount := ShowCycleInputPrompt("editqueue", currentRuns)

                if runCount < 1 {
                    ShowQueueManager()
                    return false
                }

                MacroJobQueue[editIndex] := {
                    path: path,
                    label: label,
                    mode: "Monkey EXP Grind",
                    runs: runCount
                }

                SetQueueHistorySource()
                UpdateQueueLauncherButton()
                ShowQueueManager()
                return true
            }

            CloseQueueJobBuilder()


            return AddJobToQueue(
                path,
                label,
                "Monkey EXP Grind"
            )
        }
    }


    UpdateStatus(
        "SELECT A VALID TOWER SCRIPT",
        UIColorError
    )


    return false
}


CloseQueueJobBuilder(*) {
    global QueueBuilderIsEditing

    returnToQueue := QueueBuilderIsEditing
    DestroyQueueJobBuilder(false)

    if returnToQueue {
        ShowQueueManager()
    } else {
        ShowLauncher(true)
    }
}


DestroyQueueJobBuilder(returnToQueue := false) {
    global QueueBuilderGui
    global QueueBuilderJobTypeDropdown
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyDropdown
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global QueueBuilderMapStrategies
    global QueueBuilderExpScripts
    global QueueBuilderMapFavoriteButton
    global QueueBuilderExpFavoriteButton
    global QueueBuilderMapFavoriteHelp
    global QueueBuilderExpFavoriteHelp
    global QueueBuilderEditIndex
    global QueueBuilderIsEditing

    CloseAllDarkDropdowns()

    try {
        if QueueBuilderGui
            QueueBuilderGui.Destroy()
    }

    QueueBuilderGui := ""
    QueueBuilderJobTypeDropdown := ""
    QueueBuilderCategoryDropdown := ""
    QueueBuilderMapDropdown := ""
    QueueBuilderStrategyDropdown := ""
    QueueBuilderExpTypeDropdown := ""
    QueueBuilderExpScriptDropdown := ""
    QueueBuilderMapStrategies := []
    QueueBuilderExpScripts := []
    QueueBuilderMapFavoriteButton := ""
    QueueBuilderExpFavoriteButton := ""
    QueueBuilderMapFavoriteHelp := ""
    QueueBuilderExpFavoriteHelp := ""
    QueueBuilderEditIndex := 0
    QueueBuilderIsEditing := false

    if returnToQueue {
        ShowQueueManager()
    }
}
#Requires AutoHotkey v2.0

; Refreshes queue totals and chooses the launcher primary action.
; An existing queue takes priority over the selected launcher mode.

RefreshQueueManager() {
    global QueueGui
    updatingGui := QueueGui
    BeginUIUpdate(updatingGui)
    try RefreshQueueManagerControls()
    finally EndUIUpdate(updatingGui)
}

RefreshQueueManagerControls() {
    global MacroJobQueue
    global QueueGui
    global QueueList
    global QueueCountText
    global QueueStartButton


    if !QueueGui {
        return
    }


    if !QueueList {
        return
    }


    selectedIndex :=
        QueueList.Value


    rows := []
    totalRuns := 0


    for index, job in MacroJobQueue {

        totalRuns := CombineRunCounts(totalRuns, job.runs)


        rows.Push(
            index
            . ".  "
            . job.label
            . "    x"
            . FormatRunCount(job.runs)
        )
    }


    ; Rebuild the labels, then restore a valid row near the previous selection.
    QueueList.Delete()


    if rows.Length > 0 {

        QueueList.Add(
            rows
        )


        if selectedIndex < 1 {
            selectedIndex := 1
        }


        if selectedIndex > rows.Length {
            selectedIndex := rows.Length
        }


        QueueList.Choose(
            selectedIndex
        )
    }


    if QueueCountText {

        QueueCountText.Text :=
            MacroJobQueue.Length
            . " JOB"
            . (
                MacroJobQueue.Length = 1
                ? ""
                : "S"
            )
            . "  -  "
            . FormatRunCount(totalRuns)
            . " TOTAL RUN"
            . (
                totalRuns = 1
                ? ""
                : "S"
            )
    }


    if QueueStartButton {

        QueueStartButton.Enabled :=
            MacroJobQueue.Length > 0
    }
}


UpdateQueueLauncherButton() {
    global MacroJobQueue
    global QueueButton
    global RunButton
    global CurrentMode
    global MonkeyExpTypeDropdown

    UpdateLauncherActionLayout()

    if QueueButton {

        QueueButton.Text :=
            "QUEUE ("
            . MacroJobQueue.Length
            . ")"
    }


    if !RunButton {
        return
    }


    ; Event mode runs independently of jobs kept for the other modes.
    if CurrentMode = "Auto Collection Event" {
        RunButton.Text := "START EVENT"
        RunButton.Enabled := DiscoverCollectionEventStrategies().Length > 0
        return
    }

    ; For the other modes, a populated queue owns the primary Run action.
    if MacroJobQueue.Length > 0 {

        RunButton.Text :=
            "START QUEUE"


        RunButton.Enabled :=
            true


        return
    }


    if CurrentMode = "Default" {

        RunButton.Text :=
            "SELECT SCRIPT"
    }
    else if CurrentMode = "Monkey EXP Grind" {

        RunButton.Text :=
            "START EXP GRIND"
    }
    else {

        RunButton.Text :=
            "MODE UNAVAILABLE"
    }


    if CurrentMode = "Monkey Money Grind" {

        RunButton.Enabled :=
            false


        return
    }

    if CurrentMode = "Monkey EXP Grind" {

        if MonkeyExpTypeDropdown {
            RunButton.Enabled :=
                GetMonkeyExpScripts(
                    MonkeyExpTypeDropdown.Text
                ).Length > 0
        }
        else {
            RunButton.Enabled := false
        }


        return
    }


    RunButton.Enabled :=
        true
}



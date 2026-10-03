#Requires AutoHotkey v2.0

; v3 file note: Refreshes the queue list and launcher queue button.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

RefreshQueueManager() {
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

        totalRuns +=
            job.runs


        rows.Push(
            index
            . ".  "
            . job.label
            . "    x"
            . job.runs
        )
    }


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
            . totalRuns
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


    if QueueButton {

        QueueButton.Text :=
            "QUEUE ("
            . MacroJobQueue.Length
            . ")"
    }


    if !RunButton {
        return
    }


    ; A populated queue always owns the primary Run action, even
    ; if the launcher is currently displaying a mode that cannot
    ; run by itself yet.
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



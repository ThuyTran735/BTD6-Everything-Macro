#Requires AutoHotkey v2.0

; Closes the current queue window before opening the next screen.
; Destroying these controls does not clear the saved in-memory jobs.

OpenQueueProfilesFromQueue(*) {
    CloseQueueManager()
    ShowQueueProfilesManager()
}


CloseQueueManagerAndReturnToLauncher(*) {
    CloseQueueManager()
    ShowLauncher(true)
}


CloseQueueManager(*) {
    global QueueGui
    global QueueList
    global QueueCountText
    global QueueStartButton


    try {
        if QueueGui
            QueueGui.Destroy()
    }


    QueueGui := ""
    QueueList := ""
    QueueCountText := ""
    QueueStartButton := ""
}



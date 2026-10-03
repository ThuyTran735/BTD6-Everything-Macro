#Requires AutoHotkey v2.0

; v3 file note: Moves between Queue Manager, Queue Profiles, and the launcher.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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



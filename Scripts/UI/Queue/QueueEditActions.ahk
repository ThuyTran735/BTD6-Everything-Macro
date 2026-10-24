#Requires AutoHotkey v2.0

; Edits the in-memory queue and keeps the highlighted row in a useful place.
; Clearing the whole queue goes through confirmation before removing jobs.

MoveQueueJob(
    direction
) {
    global MacroJobQueue
    global QueueList


    if !QueueList {
        return
    }


    selectedIndex :=
        QueueList.Value


    if selectedIndex < 1 {
        return
    }


    targetIndex :=
        selectedIndex
        + direction


    if (
        targetIndex < 1
        || targetIndex > MacroJobQueue.Length
    ) {
        return
    }


    temp :=
        MacroJobQueue[
            selectedIndex
        ]


    MacroJobQueue[
        selectedIndex
    ] :=
        MacroJobQueue[
            targetIndex
        ]


    MacroJobQueue[
        targetIndex
    ] :=
        temp


    SetQueueHistorySource()


    RefreshQueueManager()


    QueueList.Choose(
        targetIndex
    )
}


EditSelectedQueueJob(*) {
    global MacroJobQueue
    global QueueList

    if !QueueList {
        return
    }

    selectedIndex := QueueList.Value

    if (
        selectedIndex < 1
        || selectedIndex > MacroJobQueue.Length
    ) {
        return
    }

    OpenQueueJobBuilderForEdit(
        selectedIndex
    )
}


RemoveSelectedQueueJob(*) {
    global MacroJobQueue
    global QueueList


    if !QueueList {
        return
    }


    selectedIndex :=
        QueueList.Value


    if (
        selectedIndex < 1
        || selectedIndex > MacroJobQueue.Length
    ) {
        return
    }


    MacroJobQueue.RemoveAt(
        selectedIndex
    )


    SetQueueHistorySource()


    RefreshQueueManager()
    UpdateQueueLauncherButton()
}


ClearMacroQueue(*) {
    global MacroJobQueue
    global QueueGui


    if MacroJobQueue.Length = 0 {
        return
    }


    ShowThemedConfirmation(
        "CLEAR QUEUE?",
        "Remove all " . MacroJobQueue.Length . " queued job(s)?`n`nThis only clears the current queue. Saved Queue Profiles are not deleted.",
        "CLEAR QUEUE",
        ClearMacroQueueConfirmed,
        QueueGui,
        "Removes every job from the current queue. Saved Queue Profiles and .ahk files remain unchanged."
    )
}


ClearMacroQueueConfirmed(*) {
    global MacroJobQueue


    MacroJobQueue := []


    SetQueueHistorySource()


    RefreshQueueManager()
    UpdateQueueLauncherButton()
}



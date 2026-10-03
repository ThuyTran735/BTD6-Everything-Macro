#Requires AutoHotkey v2.0

; v3 file note: Moves, edits, removes, and clears jobs in the current queue.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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



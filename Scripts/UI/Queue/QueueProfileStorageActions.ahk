#Requires AutoHotkey v2.0

; v3 file note: Saves, loads, updates, and duplicates Queue Profiles.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

SaveCurrentQueueProfile(*) {
    global MacroJobQueue
    global QueueProfileDropdown
    global QueueProfileRecords
    global UIColorError
    global UIColorSuccess

    if MacroJobQueue.Length = 0 {
        SetQueueProfileStatus("QUEUE IS EMPTY", UIColorError)
        return
    }

    profileName := PromptQueueProfileName("Enter a name for this queue profile.")
    if profileName = "" {
        return
    }

    if FindQueueProfileRecord(profileName) {
        SetQueueProfileStatus("PROFILE EXISTS - USE UPDATE", UIColorError)
        return
    }

    savedPath := WriteQueueProfile(profileName, MacroJobQueue)
    if !savedPath {
        SetQueueProfileStatus("COULD NOT SAVE PROFILE", UIColorError)
        return
    }

    savedJobs := ReadQueueProfileJobs(savedPath)
    if savedJobs.Length != MacroJobQueue.Length {
        SetQueueProfileStatus("PROFILE SAVE VERIFY FAILED", UIColorError)
        return
    }

    RefreshQueueProfilesManager(false)
    names := []
    for record in QueueProfileRecords {
        names.Push(record.name)
    }

    index := FindTextIndex(names, profileName)
    if index > 0 {
        QueueProfileDropdown.Choose(index, true)
    }

    SetQueueProfileStatus("PROFILE SAVED", UIColorSuccess)
}


LoadSelectedQueueProfile(*) {
    global MacroJobQueue
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    jobs := ReadQueueProfileJobs(record.path)
    if jobs.Length = 0 {
        SetQueueProfileStatus("PROFILE HAS NO JOBS", UIColorError)
        return
    }

    repeatCount := GetQueueProfileRepeatCount(record.path)
    expanded := []

    Loop repeatCount {
        for job in jobs {
            expanded.Push(CloneQueueProfileJob(job))
        }
    }

    MacroJobQueue := expanded

    SetQueueHistorySource(
        "PROFILE: " . record.name
    )

    RefreshQueueManager()
    UpdateQueueLauncherButton()

    SetQueueProfileStatus(
        "PROFILE LOADED - " . repeatCount . " PASS" . (repeatCount = 1 ? "" : "ES"),
        UIColorSuccess
    )
}


UpdateSelectedQueueProfile(*) {
    global MacroJobQueue
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    if MacroJobQueue.Length = 0 {
        SetQueueProfileStatus("QUEUE IS EMPTY", UIColorError)
        return
    }

    if !WriteQueueProfile(record.name, MacroJobQueue, record.path) {
        SetQueueProfileStatus("COULD NOT UPDATE PROFILE", UIColorError)
        return
    }

    RefreshQueueProfilesManager(true)
    SetQueueProfileStatus("PROFILE UPDATED", UIColorSuccess)
}


DuplicateSelectedQueueProfile(*) {
    global QueueProfileDropdown
    global QueueProfileRecords
    global UIColorError
    global UIColorSuccess

    record := GetSelectedQueueProfileRecord()
    if !record {
        SetQueueProfileStatus("NO PROFILE SELECTED", UIColorError)
        return
    }

    newName := PromptQueueProfileName("Enter a name for the duplicated profile.", record.name . " Copy")
    if newName = "" {
        return
    }

    if FindQueueProfileRecord(newName) {
        SetQueueProfileStatus("PROFILE NAME ALREADY EXISTS", UIColorError)
        return
    }

    jobs := ReadQueueProfileJobs(record.path)
    newPath := WriteQueueProfile(newName, jobs)
    if !newPath {
        SetQueueProfileStatus("COULD NOT DUPLICATE PROFILE", UIColorError)
        return
    }

    SetQueueProfileDetails(
        newPath,
        GetQueueProfileDescription(record.path),
        GetQueueProfileRepeatCount(record.path)
    )
    SetQueueProfileFavorite(newPath, record.favorite)

    RefreshQueueProfilesManager(false)
    names := []
    for profile in QueueProfileRecords {
        names.Push(profile.name)
    }

    index := FindTextIndex(names, newName)
    if index > 0 {
        QueueProfileDropdown.Choose(index, true)
    }

    SetQueueProfileStatus("PROFILE DUPLICATED", UIColorSuccess)
}



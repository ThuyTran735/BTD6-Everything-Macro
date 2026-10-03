#Requires AutoHotkey v2.0

; v3 file note: Handles profile summaries, notes scrolling, repeat count, and autosave.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

CloneQueueProfileJob(job) {
    cloned := {
        path: job.path,
        label: job.HasOwnProp("label") ? job.label : job.path,
        mode: job.HasOwnProp("mode") ? job.mode : "",
        runs: job.HasOwnProp("runs") ? Max(1, job.runs) : 1
    }

    if job.HasOwnProp("enabled") {
        cloned.enabled := job.enabled
    }

    return cloned
}


RefreshQueueProfileSummary(repeatOverride := "") {
    global QueueProfileSummaryText

    if !QueueProfileSummaryText {
        return
    }

    record := GetSelectedQueueProfileRecord()
    if !record {
        QueueProfileSummaryText.Text := "NO PROFILE SELECTED"
        return
    }

    summary := GetQueueProfileSummary(record.path, repeatOverride)

    QueueProfileSummaryText.Text :=
        summary.jobsPerPass
        . " JOB" . (summary.jobsPerPass = 1 ? "" : "S")
        . "  x" . summary.repeatCount
        . "  =  " . summary.queueJobs
        . " QUEUE JOB" . (summary.queueJobs = 1 ? "" : "S")
        . "  -  " . summary.totalRuns
        . " TOTAL RUN" . (summary.totalRuns = 1 ? "" : "S")
}



QueueProfileNotesChanged(*) {
    UpdateQueueProfileNotesScrollbar()
    QueueProfileDetailsChanged()
}


ScrollQueueProfileNotesToTop() {
    global QueueProfileDescriptionEdit

    if !QueueProfileDescriptionEdit {
        return
    }

    try DllCall(
        "SendMessage",
        "Ptr",
        QueueProfileDescriptionEdit.Hwnd,
        "UInt",
        0x00B6,
        "Ptr",
        0,
        "Ptr",
        -32767,
        "Ptr"
    )
}


QueueProfileNotesMouseWheel(wParam, lParam, msg, hwnd) {
    global QueueProfileDescriptionEdit

    if !QueueProfileDescriptionEdit || !QueueProfileDescriptionEdit.Enabled {
        return
    }

    if hwnd != QueueProfileDescriptionEdit.Hwnd {
        return
    }

    delta := (wParam >> 16) & 0xFFFF
    if delta > 32767 {
        delta -= 65536
    }

    lines := delta > 0 ? -2 : 2

    try DllCall(
        "SendMessage",
        "Ptr",
        QueueProfileDescriptionEdit.Hwnd,
        "UInt",
        0x00B6,
        "Ptr",
        0,
        "Ptr",
        lines,
        "Ptr"
    )

    SetTimer(UpdateQueueProfileNotesScrollbar, -10)
    return 0
}


UpdateQueueProfileNotesScrollbar(*) {
    global QueueProfileDescriptionEdit
    global QueueProfileNotesScrollTrack
    global QueueProfileNotesScrollThumb

    if !QueueProfileDescriptionEdit || !QueueProfileNotesScrollTrack || !QueueProfileNotesScrollThumb {
        return
    }

    if !QueueProfileDescriptionEdit.Enabled {
        QueueProfileNotesScrollTrack.Visible := false
        QueueProfileNotesScrollThumb.Visible := false
        return
    }

    lineCount := 1
    firstVisible := 0

    try lineCount := DllCall(
        "SendMessage",
        "Ptr",
        QueueProfileDescriptionEdit.Hwnd,
        "UInt",
        0x00BA,
        "Ptr",
        0,
        "Ptr",
        0,
        "Ptr"
    )

    try firstVisible := DllCall(
        "SendMessage",
        "Ptr",
        QueueProfileDescriptionEdit.Hwnd,
        "UInt",
        0x00CE,
        "Ptr",
        0,
        "Ptr",
        0,
        "Ptr"
    )

    visibleLines := 2
    needsScroll := lineCount > visibleLines

    QueueProfileNotesScrollTrack.Visible := needsScroll
    QueueProfileNotesScrollThumb.Visible := needsScroll

    if !needsScroll {
        return
    }

    trackY := 223
    trackHeight := 38
    thumbHeight := Max(14, Floor(trackHeight * visibleLines / lineCount))
    thumbHeight := Min(trackHeight, thumbHeight)
    maxFirst := Max(1, lineCount - visibleLines)
    travel := Max(0, trackHeight - thumbHeight)
    thumbY := trackY + Round(travel * Min(firstVisible, maxFirst) / maxFirst)

    QueueProfileNotesScrollThumb.Move(630, thumbY, 6, thumbHeight)
}


AdjustQueueProfileRepeat(delta, *) {
    global QueueProfileRepeatEdit

    if !QueueProfileRepeatEdit || !QueueProfileRepeatEdit.Enabled {
        return
    }

    rawRepeat := Trim(QueueProfileRepeatEdit.Value)
    current := RegExMatch(rawRepeat, "^\d+$")
        ? Integer(rawRepeat)
        : 1

    nextValue := Max(1, Min(99, current + delta))

    if nextValue = current {
        return
    }

    QueueProfileRepeatEdit.Value := nextValue
    QueueProfileRepeatChanged()
    QueueProfileRepeatEdit.Focus()
}


PreviewQueueProfileRepeatChanged(*) {
    global QueueProfileRepeatEdit

    if !QueueProfileRepeatEdit {
        return
    }

    rawRepeat := Trim(QueueProfileRepeatEdit.Value)
    if rawRepeat = "" || !RegExMatch(rawRepeat, "^\d+$") {
        return
    }

    repeatCount := Integer(rawRepeat)
    if repeatCount < 1 || repeatCount > 99 {
        return
    }

    RefreshQueueProfileSummary(repeatCount)
}


QueueProfileRepeatChanged(*) {
    PreviewQueueProfileRepeatChanged()
    QueueProfileDetailsChanged()
}


QueueProfileDetailsChanged(*) {
    global QueueProfileDetailsLoading

    if QueueProfileDetailsLoading {
        return
    }

    AutoSaveSelectedQueueProfileDetails()
}


AutoSaveSelectedQueueProfileDetails(*) {
    global QueueProfileDescriptionEdit
    global QueueProfileRepeatEdit
    global QueueProfileDetailsLoading
    global UIColorError
    global UIColorSuccess

    if QueueProfileDetailsLoading {
        return
    }

    record := GetSelectedQueueProfileRecord()
    if !record {
        return
    }

    rawRepeat := Trim(QueueProfileRepeatEdit.Value)
    if rawRepeat = "" || !RegExMatch(rawRepeat, "^\d+$") {
        SetQueueProfileStatus("REPEAT COUNT MUST BE 1 - 99", UIColorError)
        return
    }

    repeatCount := Integer(rawRepeat)
    if repeatCount < 1 || repeatCount > 99 {
        SetQueueProfileStatus("REPEAT COUNT MUST BE 1 - 99", UIColorError)
        return
    }

    if !SetQueueProfileDetails(record.path, QueueProfileDescriptionEdit.Value, repeatCount) {
        SetQueueProfileStatus("COULD NOT SAVE PROFILE DETAILS", UIColorError)
        return
    }

    record.description := QueueProfileDescriptionEdit.Value
    record.repeatCount := repeatCount
    RefreshQueueProfileSummary(repeatCount)
    SetQueueProfileStatus("CHANGES SAVED AUTOMATICALLY", UIColorSuccess)
}



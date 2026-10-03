#Requires AutoHotkey v2.0

; v3 file note: Updates status, selection, favorites, and the selected profile details.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

SetQueueProfileStatus(text, color := "") {
    global QueueProfileStatusText
    global UIColorSuccess

    if !QueueProfileStatusText {
        return
    }

    if color = "" {
        color := UIColorSuccess
    }

    QueueProfileStatusText.SetFont("c" . color)
    QueueProfileStatusText.Text := text
}


RefreshQueueProfilesManager(keepSelection := true) {
    global QueueProfileDropdown
    global QueueProfileRecords

    if !QueueProfileDropdown {
        return
    }

    selectedName := keepSelection ? QueueProfileDropdown.Text : ""
    QueueProfileRecords := GetQueueProfileRecords()
    names := []

    for record in QueueProfileRecords {
        names.Push(record.name)
    }

    QueueProfileDropdown.Delete()

    if names.Length = 0 {
        QueueProfileDropdown.Add(["No saved profiles"])
        QueueProfileDropdown.Choose(1)
    }
    else {
        QueueProfileDropdown.Add(names)
        selectedIndex := FindTextIndex(names, selectedName)
        QueueProfileDropdown.Choose(selectedIndex > 0 ? selectedIndex : 1)
    }

    QueueProfileSelectionChanged()
}


GetSelectedQueueProfileRecord() {
    global QueueProfileDropdown
    global QueueProfileRecords

    if !QueueProfileDropdown {
        return false
    }

    selectedName := QueueProfileDropdown.Text
    for record in QueueProfileRecords {
        if record.name = selectedName {
            return record
        }
    }

    return false
}


QueueProfileSelectionChanged(*) {
    UpdateQueueProfileFavoriteButton()
    RefreshSelectedQueueProfileDetails()
}


UpdateQueueProfileFavoriteButton(*) {
    global QueueProfileFavoriteButton

    if !QueueProfileFavoriteButton {
        return
    }

    record := GetSelectedQueueProfileRecord()
    QueueProfileFavoriteButton.Enabled := record ? true : false
    SetFavoriteButtonState(QueueProfileFavoriteButton, record ? record.favorite : false)
}


ToggleSelectedQueueProfileFavorite(*) {
    record := GetSelectedQueueProfileRecord()
    if !record {
        return
    }

    SetQueueProfileFavorite(record.path, !record.favorite)
    RefreshQueueProfilesManager(true)
}


RefreshSelectedQueueProfileDetails() {
    global QueueProfileSummaryText
    global QueueProfileDescriptionEdit
    global QueueProfileRepeatEdit
    global QueueProfileRepeatMinusButton
    global QueueProfileRepeatPlusButton
    global QueueProfileDetailsLoading

    QueueProfileDetailsLoading := true

    record := GetSelectedQueueProfileRecord()

    if !record {
        if QueueProfileSummaryText
            QueueProfileSummaryText.Text := "NO PROFILE SELECTED"
        if QueueProfileDescriptionEdit {
            QueueProfileDescriptionEdit.Value := ""
            QueueProfileDescriptionEdit.Enabled := false
            UpdateQueueProfileNotesScrollbar()
        }
        if QueueProfileRepeatEdit {
            QueueProfileRepeatEdit.Value := "1"
            QueueProfileRepeatEdit.Enabled := false
        }
        if QueueProfileRepeatMinusButton
            QueueProfileRepeatMinusButton.Enabled := false
        if QueueProfileRepeatPlusButton
            QueueProfileRepeatPlusButton.Enabled := false
        QueueProfileDetailsLoading := false
        return
    }

    QueueProfileDescriptionEdit.Enabled := true
    QueueProfileRepeatEdit.Enabled := true
    QueueProfileRepeatMinusButton.Enabled := true
    QueueProfileRepeatPlusButton.Enabled := true
    QueueProfileDescriptionEdit.Value := GetQueueProfileDescription(record.path)
    ScrollQueueProfileNotesToTop()
    UpdateQueueProfileNotesScrollbar()
    QueueProfileRepeatEdit.Value := GetQueueProfileRepeatCount(record.path)
    QueueProfileDetailsLoading := false
    RefreshQueueProfileSummary()
}



#Requires AutoHotkey v2.0

; v3 file note: Handles the top-level job/category/map field changes.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

QueueBuilderJobTypeChanged(*) {
    global QueueBuilderJobTypeDropdown

    global QueueBuilderCategoryLabel
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapLabel
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyLabel
    global QueueBuilderStrategyDropdown

    global QueueBuilderExpTypeLabel
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptLabel
    global QueueBuilderExpScriptDropdown

    global QueueBuilderCategoryHelp
    global QueueBuilderMapHelp
    global QueueBuilderStrategyHelp
    global QueueBuilderExpTypeHelp
    global QueueBuilderExpScriptHelp
    global QueueBuilderMapFavoriteButton
    global QueueBuilderExpFavoriteButton
    global QueueBuilderMapFavoriteHelp
    global QueueBuilderExpFavoriteHelp


    isMap :=
        QueueBuilderJobTypeDropdown.Text
        = "Map Script"


    QueueBuilderCategoryLabel.Visible := isMap
    QueueBuilderCategoryDropdown.Visible := isMap
    QueueBuilderMapLabel.Visible := isMap
    QueueBuilderMapDropdown.Visible := isMap
    QueueBuilderStrategyLabel.Visible := isMap
    QueueBuilderStrategyDropdown.Visible := isMap

    QueueBuilderCategoryHelp.Visible := isMap
    QueueBuilderMapHelp.Visible := isMap
    QueueBuilderMapFavoriteHelp.Visible := isMap
    QueueBuilderStrategyHelp.Visible := isMap
    QueueBuilderMapFavoriteButton.Visible := isMap


    QueueBuilderExpTypeLabel.Visible := !isMap
    QueueBuilderExpTypeDropdown.Visible := !isMap
    QueueBuilderExpScriptLabel.Visible := !isMap
    QueueBuilderExpScriptDropdown.Visible := !isMap

    QueueBuilderExpTypeHelp.Visible := !isMap
    QueueBuilderExpScriptHelp.Visible := !isMap
    QueueBuilderExpFavoriteHelp.Visible := !isMap
    QueueBuilderExpFavoriteButton.Visible := !isMap


    if isMap {
        UpdateQueueBuilderMapFavoriteButton()
    }
    else {
        UpdateQueueBuilderExpFavoriteButton()
    }


    CloseAllDarkDropdowns()
}


QueueBuilderCategoryChanged(*) {
    RefreshQueueBuilderMapFavorites(false)
}


QueueBuilderMapChanged(*) {
    UpdateQueueBuilderMapFavoriteButton()
    RefreshQueueBuilderMapStrategies()
}



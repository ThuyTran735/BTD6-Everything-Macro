#Requires AutoHotkey v2.0

; Switches between map and tower fields and refreshes dependent choices.
; Hidden controls keep their state so changing job type does not rebuild the window.

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



#Requires AutoHotkey v2.0

; v3 file note: Keeps Queue Job Builder globals and its simple open/edit entry points.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.


global QueueBuilderGui := ""
global QueueBuilderJobTypeDropdown := ""
global QueueBuilderCategoryDropdown := ""
global QueueBuilderMapDropdown := ""
global QueueBuilderStrategyDropdown := ""
global QueueBuilderExpTypeDropdown := ""
global QueueBuilderExpScriptDropdown := ""
global QueueBuilderMapStrategies := []
global QueueBuilderExpScripts := []

global QueueBuilderCategoryLabel := ""
global QueueBuilderMapLabel := ""
global QueueBuilderStrategyLabel := ""
global QueueBuilderExpTypeLabel := ""
global QueueBuilderExpScriptLabel := ""

global QueueBuilderCategoryHelp := ""
global QueueBuilderMapHelp := ""
global QueueBuilderMapFavoriteHelp := ""
global QueueBuilderStrategyHelp := ""
global QueueBuilderExpTypeHelp := ""
global QueueBuilderExpScriptHelp := ""
global QueueBuilderExpFavoriteHelp := ""

global QueueBuilderMapFavoriteButton := ""
global QueueBuilderExpFavoriteButton := ""

global QueueBuilderEditIndex := 0
global QueueBuilderIsEditing := false


ShowQueueJobBuilder(*) {
    OpenQueueJobBuilder(0)
}


OpenQueueJobBuilderForEdit(editIndex) {
    OpenQueueJobBuilder(editIndex)
}



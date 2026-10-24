#Requires AutoHotkey v2.0

; Shared controls and edit state for the queue-job window.
; The edit index distinguishes replacing an existing job from appending a new one.


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



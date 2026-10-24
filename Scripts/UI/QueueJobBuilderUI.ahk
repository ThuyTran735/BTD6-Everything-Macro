#Requires AutoHotkey v2.0

; Loads the shared Add/Edit Queue Job window and its selection helpers.
; State is included first so both new-job and edit-job entry points use the same controls.

#Include Queue\QueueJobBuilderState.ahk
#Include Queue\QueueJobBuilderWindow.ahk
#Include Queue\QueueJobBuilderEvents.ahk
#Include Queue\QueueJobBuilderData.ahk
#Include Queue\QueueJobBuilderEditState.ahk
#Include Queue\QueueJobBuilderActions.ahk
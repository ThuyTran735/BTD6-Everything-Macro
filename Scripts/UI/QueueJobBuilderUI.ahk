#Requires AutoHotkey v2.0

; v3 file note: Add/Edit Queue Job is split into its window, selection refresh code, edit initialization, and final actions so it is easier to trace.
; The split is organization-only; callers can keep including this file like before.

#Include Queue\QueueJobBuilderState.ahk
#Include Queue\QueueJobBuilderWindow.ahk
#Include Queue\QueueJobBuilderEvents.ahk
#Include Queue\QueueJobBuilderData.ahk
#Include Queue\QueueJobBuilderEditState.ahk
#Include Queue\QueueJobBuilderActions.ahk
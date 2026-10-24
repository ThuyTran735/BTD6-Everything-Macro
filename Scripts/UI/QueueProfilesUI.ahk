#Requires AutoHotkey v2.0

; Loads the profile manager and its selection, storage, and dialog helpers.
; Keep this entry point stable for callers that open or close profile tools.

#Include Queue\QueueProfileWindow.ahk
#Include Queue\QueueProfileSelection.ahk
#Include Queue\QueueProfileNotes.ahk
#Include Queue\QueueProfileStorageActions.ahk
#Include Queue\QueueProfileMoreActions.ahk
#Include Queue\QueueProfileNameDialog.ahk
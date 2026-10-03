#Requires AutoHotkey v2.0

; v3 file note: Queue Profiles is split by screen state, details, saving/loading, extra actions, and the name dialog. This wrapper keeps callers unchanged.
; The split is organization-only; callers can keep including this file like before.

#Include Queue\QueueProfileWindow.ahk
#Include Queue\QueueProfileSelection.ahk
#Include Queue\QueueProfileNotes.ahk
#Include Queue\QueueProfileStorageActions.ahk
#Include Queue\QueueProfileMoreActions.ahk
#Include Queue\QueueProfileNameDialog.ahk
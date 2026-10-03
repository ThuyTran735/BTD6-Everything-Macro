#Requires AutoHotkey v2.0

; v3 file note: Queue Manager is split into state/window, list refresh, editing, profile navigation, and execution pieces. Existing callers still include QueueUI.ahk.
; The split is organization-only; callers can keep including this file like before.

#Include Queue\QueueState.ahk
#Include Queue\QueueWindow.ahk
#Include Queue\QueueRefresh.ahk
#Include Queue\QueueEditActions.ahk
#Include Queue\QueueNavigation.ahk
#Include Queue\QueueExecution.ahk
#Include Queue\QueueJobExecution.ahk
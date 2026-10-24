#Requires AutoHotkey v2.0

; Loads the queue modules in one place for existing launcher callers.
; State and drawing are separate from editing and execution so UI changes stay local.

#Include Queue\QueueState.ahk
#Include Queue\QueueWindow.ahk
#Include Queue\QueueRefresh.ahk
#Include Queue\QueueEditActions.ahk
#Include Queue\QueueNavigation.ahk
#Include Queue\QueueExecution.ahk
#Include Queue\QueueJobExecution.ahk
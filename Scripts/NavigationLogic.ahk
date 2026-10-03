#Requires AutoHotkey v2.0

; v3 file note: Navigation is split into map selection, mode selection, prompts, and load helpers now. Keeping this wrapper means old includes do not need to change.
; The split is organization-only; callers can keep including this file like before.

#Include Navigation\NavigationPatterns.ahk
#Include Navigation\MapNavigation.ahk
#Include Navigation\ModeSelection.ahk
#Include Navigation\NavigationPrompts.ahk
#Include Navigation\GameLoadNavigation.ahk
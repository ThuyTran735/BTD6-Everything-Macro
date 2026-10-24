#Requires AutoHotkey v2.0

; Load the complete Home-to-map navigation flow through one stable include. Patterns, selection clicks, prompts, and load waits stay separate below.

#Include Navigation\NavigationPatterns.ahk
#Include Navigation\MapNavigation.ahk
#Include Navigation\ModeSelection.ahk
#Include Navigation\NavigationPrompts.ahk
#Include Navigation\GameLoadNavigation.ahk
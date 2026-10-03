#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

; v3 file note: Hero selection is split into patterns, the main selection flow, fallback handling, and click helpers. The old file name stays as the public entry point.
; The split is organization-only; callers can keep including this file like before.

#Include Navigation\Heroes\HeroPatterns.ahk
#Include Navigation\Heroes\HeroSelectionFlow.ahk
#Include Navigation\Heroes\HeroUnlockHandling.ahk
#Include Navigation\Heroes\HeroFallback.ahk
#Include Navigation\Heroes\HeroClickHelpers.ahk
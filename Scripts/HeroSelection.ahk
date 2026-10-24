#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

; Hero selection includes its own unlock and fallback handling, so callers only need this entry point when preparing a configured hero.

#Include Navigation\Heroes\HeroPatterns.ahk
#Include Navigation\Heroes\HeroSelectionFlow.ahk
#Include Navigation\Heroes\HeroUnlockHandling.ahk
#Include Navigation\Heroes\HeroFallback.ahk
#Include Navigation\Heroes\HeroClickHelpers.ahk
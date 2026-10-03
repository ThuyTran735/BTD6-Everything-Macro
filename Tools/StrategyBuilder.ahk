#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\Scripts\Version.ahk

; v3 file note: This is the small entry file for Strategy Builder now. The editor pieces are split up below so one tool file isn't a mile long.
; The split is organization-only; callers can keep including this file like before.

#Include StrategyBuilder\BuilderWindow.ahk
#Include StrategyBuilder\EntityEditor.ahk
#Include StrategyBuilder\ActionEditor.ahk
#Include StrategyBuilder\TemplateOutput.ahk
#Include StrategyBuilder\StrategyImport.ahk
#Include StrategyBuilder\OverlayHelpers.ahk
#Include StrategyBuilder\WindowChrome.ahk
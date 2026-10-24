#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\Scripts\Version.ahk
#Include ..\Scripts\UI\UITheme.ahk
#Include ..\Scripts\UI\CustomControlsUI.ahk
#Include ..\Scripts\UI\CustomDropdownUI.ahk
#Include StrategyBuilder\BuilderControls.ahk

; The standalone tool runs from Tools, one folder below the launcher.
UIFontHeading := LoadBuilderHeadingFont()

; Starts the standalone editor and loads its placement, action, import, and export helpers.
; Keep this entry point stable so launcher shortcuts can continue opening the same file.

#Include StrategyBuilder\BuilderWindow.ahk
#Include StrategyBuilder\EntityEditor.ahk
#Include StrategyBuilder\ActionEditor.ahk
#Include StrategyBuilder\BuilderValidation.ahk
#Include StrategyBuilder\TemplateOutput.ahk
#Include StrategyBuilder\StrategyImport.ahk
#Include StrategyBuilder\OverlayHelpers.ahk
#Include StrategyBuilder\WindowChrome.ahk
#Include StrategyBuilder\BuilderHelp.ahk

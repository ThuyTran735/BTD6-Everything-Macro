#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk
#Include Version.ahk


; v3 file note: Handles the IncludeAll part of the macro. Keep this focused so run bugs are easier to trace later.

global RunConfig := {
    category: "",
    map: "",
    difficulty: "",
    gameMode: "",
    hero: ""
}


; Empty default so shared logic can safely
; reference TowerSetup before a map strategy
; replaces it with its real setup.
global TowerSetup := Map()


#Include TowerData.ahk
#Include Monkey Logic\FarmLogic.ahk
#Include MapData.ahk
#Include InputHelpers.ahk
#Include CycleStatusClickGuard.ahk


#Include PlacementLogic.ahk
#Include UpgradeLogic.ahk
#Include SellLogic.ahk
#Include TargetingLogic.ahk
#Include Monkey Logic\SubMonkeyLogic.ahk
#Include SpecialTargetingLogic.ahk
#Include Monkey Logic\DartlingLogic.ahk
#Include Monkey Logic\HeliLogic.ahk
#Include Monkey Logic\MermonkeyLogic.ahk
#Include Monkey Logic\MortarLogic.ahk
#Include Monkey Logic\SpikeFactoryLogic.ahk


#Include HeroSelection.ahk
#Include NavigationLogic.ahk


#Include Logs.ahk
#Include Setup.ahk


#Include GameStateLogic.ahk
#Include RoundLogic.ahk
#Include GameSpeedLogic.ahk
#Include StrategyLogic.ahk


#Include GameModeUnlockLogic.ahk
#Include MapRunner.ahk


#Include DailyChestLogic.ahk
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
#Include MapData.ahk
#Include InputHelpers.ahk


#Include PlacementLogic.ahk
#Include UpgradeLogic.ahk
#Include SellLogic.ahk
#Include TargetingLogic.ahk
#Include SubMonkeyLogic.ahk
#Include SpecialTargetingLogic.ahk
#Include DartlingLogic.ahk
#Include HeliLogic.ahk
#Include MermonkeyLogic.ahk
#Include MortarLogic.ahk
#Include SpikeFactoryLogic.ahk


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
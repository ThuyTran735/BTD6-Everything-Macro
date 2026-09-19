#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk
#Include Version.ahk


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


#Include PlacementLogic.ahk
#Include UpgradeLogic.ahk
#Include TargetingLogic.ahk
#Include SubMonkeyLogic.ahk
#Include SpecialTargetingLogic.ahk
#Include DartlingLogic.ahk
#Include HeliLogic.ahk
#Include MermonkeyLogic.ahk
#Include MortarLogic.ahk


#Include HeroSelection.ahk
#Include NavigationLogic.ahk


#Include Logs.ahk
#Include Setup.ahk


#Include GameStateLogic.ahk
#Include RoundLogic.ahk
#Include StrategyLogic.ahk


#Include GameModeUnlockLogic.ahk
#Include MapRunner.ahk


#Include DailyChestLogic.ahk
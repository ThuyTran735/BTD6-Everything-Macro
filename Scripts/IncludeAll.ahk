#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

global RunConfig := {
    category: "",
    map: "",
    difficulty: "",
    gameMode: "",
    hero: ""
}

#Include TowerData.ahk
#Include MapData.ahk

#Include PlacementLogic.ahk
#Include UpgradeLogic.ahk
#Include HeroSelection.ahk
#Include NavigationLogic.ahk
#Include Logs.ahk
#Include Setup.ahk
#Include GameStateLogic.ahk
#Include RoundLogic.ahk
#Include StrategyLogic.ahk
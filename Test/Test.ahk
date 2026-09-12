#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk
#Include ..\Scripts\IncludeAll.ahk


; Test code
Sleep(3000)
TowerSetup := Map(
    "Druid A", {
        type: "Druid",
        x: 919,
        y: 440,
        placed: false,
        upgrades: [0, 0, 0]
    },

    "Sniper", {
        type: "Sniper",
        x: 1276,
        y: 826,
        placed: false,
        upgrades: [0, 0, 0]
    }
)

PlaceTower(TowerSetup["Druid A"])
UpgradeTower(TowerSetup["Druid A"], "100")

PlaceTower(TowerSetup["Sniper"])
UpgradeTower(TowerSetup["Sniper"], "102")

UpgradeTower(TowerSetup["Druid A"], "130")
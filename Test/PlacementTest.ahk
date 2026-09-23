#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\Scripts\IncludeAll.ahk

; Manual placement test.
; Start inside a loaded BTD6 game with enough cash for the selected tower.

global RunConfig := {
    category: "Beginner",
    map: "Placement Test",
    difficulty: "Easy",
    gameMode: "Standard",
    hero: "Quincy",
    wingmonkeyMK: false
}

global TowerSetup := Map(
    "Hero", {
        type: "Hero",
        x: 1532,
        y: 595,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Ace A", {
        type: "Ace",
        x: 1373,
        y: 592,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Ace B", {
        type: "Ace",
        x: 1373,
        y: 498,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Village A", {
        type: "Village",
        x: 1517,
        y: 464,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Alchemist A", {
        type: "Alchemist",
        x: 1383,
        y: 424,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    }
)

global TowerNames := []
global CurrentTowerIndex := 1

for towerName, tower in TowerSetup
    TowerNames.Push(towerName)

ResetTowerSetup()
ShowCurrentTower()

Space:: {
    global TowerSetup, TowerNames, CurrentTowerIndex, TowerHotkeys

    towerName := TowerNames[CurrentTowerIndex]
    tower := TowerSetup[towerName]

    if !TowerHotkeys.Has(tower.type) {
        MsgBox("No hotkey configured for:`n" tower.type)
        return
    }

    ToolTip(
        "Placing: " towerName
        "`nType: " tower.type
        "`nHotkey: " TowerHotkeys[tower.type]
        "`nX: " tower.x
        "`nY: " tower.y
    )
    Sleep(300)

    result := PlaceTower(tower)

    if !result {
        ToolTip(
            "FAILED"
            "`nTower: " towerName
            "`nReason: " GetRunFailureReason("Placement failed")
        )
        return
    }

    ToolTip(
        "Placed: " towerName
        "`nType: " tower.type
        "`nX: " tower.x
        "`nY: " tower.y
        "`n`nLeft/Right = Select | Space = Place | R = Reset | Esc = Exit"
    )
}

Right::SelectTower(1)
Left::SelectTower(-1)
R:: {
    ResetTowerSetup()
    ShowCurrentTower()
}
Esc::ExitApp()

SelectTower(delta) {
    global CurrentTowerIndex, TowerNames

    CurrentTowerIndex += delta
    if CurrentTowerIndex > TowerNames.Length
        CurrentTowerIndex := 1
    else if CurrentTowerIndex < 1
        CurrentTowerIndex := TowerNames.Length

    ShowCurrentTower()
}

ShowCurrentTower() {
    global TowerSetup, TowerNames, CurrentTowerIndex, TowerHotkeys

    if TowerNames.Length = 0
        return

    towerName := TowerNames[CurrentTowerIndex]
    tower := TowerSetup[towerName]
    hotkey := TowerHotkeys.Has(tower.type) ? TowerHotkeys[tower.type] : "NOT CONFIGURED"

    ToolTip(
        "BTD6 " . GetAppVersionLabel() . " Placement Test"
        "`nSelected: " towerName
        "`nType: " tower.type
        "`nHotkey: " hotkey
        "`nX: " tower.x
        "`nY: " tower.y
        "`nPlaced: " (tower.placed ? "YES" : "NO")
        "`n`nSpace = Place"
        "`nLeft/Right = Select"
        "`nR = Reset tower state"
        "`nEsc = Exit"
    )
}
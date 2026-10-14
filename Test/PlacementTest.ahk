#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\Scripts\IncludeAll.ahk

; v3 file note: Quick manual test for Placement. It stays separate from the normal launcher.

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
    "Dart A", {
            type: "Dart",
            x: 1019,
            y: 185,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
    },
    "Dart B", {
        type: "Dart",
        x: 289,
        y: 667,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Dart C", {
        type: "Dart",
        x: 873,
        y: 990,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Dart D", {
        type: "Dart",
        x: 218,
        y: 489,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Dart E", {
        type: "Dart",
        x: 1072,
        y: 1026,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Dart F", {
        type: "Dart",
        x: 265,
        y: 724,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Dart G", {
        type: "Dart",
        x: 812,
        y: 966,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Hero", {
        type: "Hero",
        x: 1337,
        y: 280,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "SpikeFactory A", {
        type: "SpikeFactory",
        x: 670,
        y: 820,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "Normal"
    },
    "Druid A", {
        type: "Druid",
        x: 704,
        y: 113,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Glue A", {
        type: "Glue",
        x: 1067,
        y: 338,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "SpikeFactory B", {
        type: "SpikeFactory",
        x: 334,
        y: 829,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "Normal"
    },
    "Village A", {
        type: "Village",
        x: 539,
        y: 853,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Alchemist A", {
        type: "Alchemist",
        x: 342,
        y: 982,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Alchemist B", {
        type: "Alchemist",
        x: 505,
        y: 774,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Wizard A", {
        type: "Wizard",
        x: 451,
        y: 814,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Ice A", {
        type: "Ice",
        x: 744,
        y: 803,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Ice B", {
        type: "Ice",
        x: 328,
        y: 764,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Ace A", {
        type: "Ace",
        x: 374,
        y: 911,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "Circle"
    },
    "Village B", {
        type: "Village",
        x: 230,
        y: 847,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Glue B", {
        type: "Glue",
        x: 748,
        y: 167,
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
#Requires AutoHotkey v2.0

#Include ..\Scripts\IncludeAll.ahk


global TowerSetup := Map(
    "Desperado A", {
        type: "Desperado",
        x: 834,
        y: 673,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },

    "Desperado B", {
        type: "Desperado",
        x: 1290,
        y: 568,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },

    "Desperado C", {
        type: "Desperado",
        x: 839,
        y: 324,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
)


global TowerNames := []
global CurrentTowerIndex := 1


for towerName, tower in TowerSetup
    TowerNames.Push(towerName)


ShowCurrentTower()


; Space = place the selected tower.
Space:: {
    global TowerSetup
    global TowerNames
    global CurrentTowerIndex
    global TowerHotkeys


    towerName := TowerNames[
        CurrentTowerIndex
    ]


    tower := TowerSetup[
        towerName
    ]


    if !TowerHotkeys.Has(tower.type) {
        MsgBox(
            "No hotkey configured for:"
            "`n" tower.type
        )

        return
    }


    hotkey := TowerHotkeys[
        tower.type
    ]


    ToolTip(
        "Placing: " towerName
        "`nType: " tower.type
        "`nHotkey: " hotkey
        "`nX: " tower.x
        "`nY: " tower.y
    )


    Sleep(500)


    result := PlaceTower(
        tower
    )


    if !result {
        ToolTip(
            "FAILED"
            "`nTower: " towerName
            "`nType: " tower.type
            "`nHotkey: " hotkey
        )

        return
    }


    ToolTip(
        "Placed: " towerName
        "`nType: " tower.type
        "`nHotkey: " hotkey
        "`nX: " tower.x
        "`nY: " tower.y
    )
}


; Right Arrow = next tower.
Right:: {
    global CurrentTowerIndex
    global TowerNames


    CurrentTowerIndex++


    if CurrentTowerIndex > TowerNames.Length
        CurrentTowerIndex := 1


    ShowCurrentTower()
}


; Left Arrow = previous tower.
Left:: {
    global CurrentTowerIndex
    global TowerNames


    CurrentTowerIndex--


    if CurrentTowerIndex < 1
        CurrentTowerIndex := TowerNames.Length


    ShowCurrentTower()
}


; Escape = close test.
Esc::ExitApp()


ShowCurrentTower() {
    global TowerSetup
    global TowerNames
    global CurrentTowerIndex
    global TowerHotkeys


    if TowerNames.Length = 0
        return


    towerName := TowerNames[
        CurrentTowerIndex
    ]


    tower := TowerSetup[
        towerName
    ]


    hotkey := TowerHotkeys.Has(tower.type)
        ? TowerHotkeys[tower.type]
        : "NOT CONFIGURED"


    ToolTip(
        "Selected: " towerName
        "`nType: " tower.type
        "`nHotkey: " hotkey
        "`nX: " tower.x
        "`nY: " tower.y
        "`n"
        "`nSpace = Place"
        "`nLeft = Previous"
        "`nRight = Next"
        "`nEsc = Exit"
    )
}
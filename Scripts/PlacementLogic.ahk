#Requires AutoHotkey v2.0

#Include TowerData.ahk

PlaceTower(tower) {
    global TowerHotkeys

    if !HasProp(tower, "type")
        throw Error("Tower is missing a type.")

    if !HasProp(tower, "x") || !HasProp(tower, "y")
        throw Error("Tower is missing coordinates.")

    if !TowerHotkeys.Has(tower.type) {
        ToolTip("Unknown tower: " tower.type)
        Sleep(1500)
        ToolTip()
        return false
    }

    hotkey := TowerHotkeys[tower.type]

    ; Select tower
    Send(hotkey)
    Sleep(150)

    ; Move to placement location
    MouseMove(tower.x, tower.y)
    Sleep(100)

    ; Place tower
    Click()
    Sleep(150)

    ; Initialize tower state
    tower.placed := true

    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]

    return true
}
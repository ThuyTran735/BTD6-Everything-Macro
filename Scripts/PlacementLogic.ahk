#Requires AutoHotkey v2.0

PlaceTower(tower) {
    global TowerHotkeys

    if !HasProp(tower, "type")
        throw Error("Tower is missing a type.")

    if !HasProp(tower, "x") || !HasProp(tower, "y")
        throw Error("Tower is missing coordinates.")

    if !TowerHotkeys.Has(tower.type)
        return false

    hotkey := TowerHotkeys[tower.type]

    ; Hero needs SendEvent for BTD6 to recognize the hotkey.
    if tower.type = "Hero" {
        SendEvent("{u down}")
        Sleep(100)
        SendEvent("{u up}")
    } else {
        Send(hotkey)
    }

    Sleep(250)

    MouseMove(tower.x, tower.y, 0)
    Sleep(250)

    Click(tower.x, tower.y)
    Sleep(250)

    tower.placed := true

    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]

    return true
}
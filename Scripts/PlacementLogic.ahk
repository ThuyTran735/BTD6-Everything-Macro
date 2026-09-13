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


    ; Hero requires SendEvent in BTD6.
    if tower.type = "Hero" {
        SendEvent("{u down}")
        Sleep(35)
        SendEvent("{u up}")

        Sleep(70)
    } else {
        ; Normal tower.
        Send(hotkey)

        Sleep(40)
    }


    MouseMove(tower.x, tower.y, 0)

    Sleep(20)

    Click(tower.x, tower.y)

    Sleep(40)


    tower.placed := true


    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]


    ; Forget any old panel-side information.
    ; This matters after a restart/replacement.
    if HasProp(tower, "panelSide")
        tower.panelSide := false


    return true
}
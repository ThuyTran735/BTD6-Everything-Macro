#Requires AutoHotkey v2.0


; v3 file note: Handles the Placement part of the macro. Keep this focused so run bugs are easier to trace later.

PlaceTower(tower) {
    global TowerHotkeys


    if !HasProp(tower, "type")
        throw Error("Tower is missing a type.")


    if !HasProp(tower, "x") || !HasProp(tower, "y")
        throw Error("Tower is missing coordinates.")


    if !TowerHotkeys.Has(tower.type)
        return SetRunFailureReason("PLACEMENT FAILED", "Unknown tower type: " . tower.type)


    hotkey := TowerHotkeys[tower.type]


    LogStrategyAction(
        "Place "
        . GetTowerLogName(tower)
        . " ("
        . tower.type
        . ") at "
        . tower.x
        . ", "
        . tower.y
    )


    ; Move to the intended empty placement point before sending the
    ; tower hotkey so placement starts from the requested coordinate.
    MouseMove(
        tower.x,
        tower.y,
        0
    )


    ; Hero requires SendEvent in BTD6.
    ; Give the game a little more time to accept the hero
    ; hotkey before the placement click. This is especially
    ; important for the first round-0 action on maps/modes
    ; that finish loading a little later than others.
    if tower.type = "Hero" {
        Sleep(60)

        SendEvent("{u down}")
        Sleep(40)

        SendEvent("{u up}")
        Sleep(140)


    } else {
        ; Send the configured tower hotkey as-is. The three newer monkeys use
        ; dedicated F-keys so we do not have to depend on Shift staying held.
        Send(hotkey)
        Sleep(40)
    }


    ; Give BTD6 a little time after moving
    ; before confirming the placement.
    Sleep(50)


    Click(
        tower.x,
        tower.y
    )


    ; Give BTD6 time to finish the placement
    ; before another strategy action happens.
    Sleep(200)


    tower.placed := true


    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]


    ; Forget any old panel-side information.
    ; Important after restarting/replacing towers.
    if HasProp(tower, "panelSide")
        tower.panelSide := false


    return true
}
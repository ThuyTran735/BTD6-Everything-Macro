#Requires AutoHotkey v2.0


; Place at the scripted point, then check that the tower can be selected.
; Retrying a click is safe at that same point; repeating the buy key is not.

PlaceTower(tower) {
    global TowerHotkeys


    if !HasProp(tower, "type")
        throw Error("Tower is missing a type.")


    if !HasProp(tower, "x") || !HasProp(tower, "y")
        throw Error("Tower is missing coordinates.")


    if !TowerHotkeys.Has(tower.type)
        return SetRunFailureReason("PLACEMENT FAILED", "Unknown tower type: " . tower.type)

    if HasProp(tower, "placed") && tower.placed
        return true

    if !IsTowerInputActive()
        return SetRunFailureReason("PLACEMENT FAILED", "BTD6 lost focus before placement")

    placementKey := TowerHotkeys[tower.type]


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


    ; If the placement point is under or close to the Cycle HUD, hide the
    ; HUD before moving the cursor or sending the tower hotkey. Waiting until
    ; the final click was too late for some placements.
    RequestCycleStatusHideForPoint(
        tower.x,
        tower.y,
        1100
    )


    ; Move to the intended empty placement point before sending the
    ; tower hotkey so placement starts from the requested coordinate.
    MouseMove(
        tower.x,
        tower.y,
        0
    )


    ; Heroes need SendEvent too. Use the same held input for every binding,
    ; including the newer monkeys' F-keys, and allow the placement cursor to load.
    if !SendGameKey(placementKey)
        return SetRunFailureReason("PLACEMENT FAILED", "BTD6 lost focus while selecting the tower")

    Sleep(tower.type = "Hero" ? 180 : 120)

    if !ClickTowerPoint(tower.x, tower.y)
        return SetRunFailureReason("PLACEMENT FAILED", "BTD6 lost focus before the placement click")

    Sleep(200)

    ; A delayed first click may still be placing the tower. The selection
    ; helper clicks only this coordinate and waits for the panel to appear.
    ; It never sends the placement key again or shifts to a neighboring point.
    panelSide := false
    result := EnsureUpgradePanelOpen(tower, &panelSide, tower.x, tower.y, true)

    if result = "Victory" || result = "Defeat"
        return result

    if result = false {
        return SetRunFailureReason("PLACEMENT FAILED",
            "Could not confirm " . GetTowerLogName(tower) . " at " . tower.x . ", " . tower.y)
    }

    if !IsTowerInputActive()
        return SetRunFailureReason("PLACEMENT FAILED", "BTD6 lost focus while confirming placement")

    tower.placed := true


    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]


    ; Forget any old panel-side information.
    ; Important after restarting/replacing towers.
    if HasProp(tower, "panelSide")
        tower.panelSide := false

    ; This action opened a confirmed panel. Close it before the next placement.
    SendEscapeAndWait()

    return true
}

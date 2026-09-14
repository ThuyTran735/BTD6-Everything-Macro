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


    ; Shift-modified tower hotkeys.
    ;
    ; Example:
    ; "Desperado", "+q"
    ;
    ; BTD6 can occasionally miss Shift if the
    ; modifier and tower key are sent too quickly.
    ;
    ; Send the entire sequence manually and give
    ; BTD6 enough time to register each state.
    } else if SubStr(hotkey, 1, 1) = "+" {
        key := SubStr(hotkey, 2)


        ; Start from a known Shift state.
        SendEvent("{Shift up}")
        Sleep(40)


        ; Press and hold Shift.
        SendEvent("{Shift down}")
        Sleep(80)


        ; Press the tower hotkey while Shift
        ; is definitely being held.
        SendEvent("{" key " down}")
        Sleep(80)


        ; Release the tower hotkey while
        ; continuing to hold Shift.
        SendEvent("{" key " up}")
        Sleep(100)


        ; Release Shift.
        SendEvent("{Shift up}")


        ; Give BTD6 time to enter placement mode
        ; for the Shift-modified tower.
        Sleep(120)


    } else {
        ; Normal tower hotkey.
        Send(hotkey)

        Sleep(40)
    }


    ; Move to the requested placement position.
    MouseMove(
        tower.x,
        tower.y,
        0
    )


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
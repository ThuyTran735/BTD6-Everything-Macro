#Requires AutoHotkey v2.0


PlaceTower(tower) {
    global TowerHotkeys


    if !HasProp(tower, "type")
        throw Error("Tower is missing a type.")


    if !HasProp(tower, "x") || !HasProp(tower, "y")
        throw Error("Tower is missing coordinates.")


    if !TowerHotkeys.Has(tower.type)
        return SetRunFailureReason("PLACEMENT FAILED", "Unknown tower type: " . tower.type)


    hotkey := TowerHotkeys[tower.type]


    ; A previous UpgradeTower() may have intentionally left its panel open.
    ; Close the cached panel first.
    CloseCachedUpgradePanel()


    ; Shift-modified tower hotkeys are the only placement path where we have
    ; seen an unrelated recovery click leave a real tower panel open without
    ; populating SelectedUpgradeTower. Check for that real panel here, at the
    ; last possible moment before entering placement mode.
    ;
    ; Keep this out of CloseCachedUpgradePanel(): that helper also runs before
    ; round waits, where a screen-wide Sell-button match can send an unwanted
    ; Esc and interfere with Hero placement.
    if SubStr(hotkey, 1, 1) = "+" {
        if GetUpgradePanelSide() {
            Send("{Esc}")
            Sleep(25)
            ClearSelectedUpgradeTower()
        }
    }


    ; Move to the intended empty placement point before sending the
    ; tower hotkey. This keeps Shift-modified hotkeys (such as
    ; Mermonkey +W) from being triggered while the cursor is still
    ; sitting over an already-placed tower, which can leave that
    ; tower selected instead of entering placement mode.
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
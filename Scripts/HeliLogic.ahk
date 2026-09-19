#Requires AutoHotkey v2.0


EnsureHeliSelected(tower) {
    if IsUpgradeTowerSelected(tower)
        return true

    ClearSelectedUpgradeTower()
    Click(tower.x, tower.y)
    Sleep(35)

    CacheSelectedUpgradeTower(
        tower,
        GetExpectedUpgradePanelSide(tower)
    )

    return true
}


GetHeliDefaultTargeting() {
    return "Follow Mouse"
}


NormalizeHeliTargetingState(tower) {
    if !HasProp(tower, "targeting") {
        tower.targeting := GetHeliDefaultTargeting()
        return tower.targeting
    }

    ; Older map/reset code used generic First/Last/Close/Strong targeting
    ; for every tower. Helis do not use those modes, so treat them as the
    ; Heli default instead of throwing.
    if (
        tower.targeting = "First"
        || tower.targeting = "Last"
        || tower.targeting = "Close"
        || tower.targeting = "Strong"
    )
        tower.targeting := GetHeliDefaultTargeting()

    return tower.targeting
}


LockHeliInPlace(tower, lockX, lockY) {
    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "Heli"
        throw Error("LockHeliInPlace() can only be used with Heli Pilots.")

    NormalizeHeliTargetingState(tower)

    EnsureHeliSelected(tower)

    ; Base Helis start on Follow Mouse. Lock in Place is the next mode.
    ; A 2xx+ Heli automatically switches to Pursuit when Pursuit is bought;
    ; from Pursuit, two forward Tab presses wrap through Follow Mouse and then
    ; enter Lock in Place without entering Patrol Points.
    if tower.targeting = "Follow Mouse" {
        Send("{Tab}")
        Sleep(35)
        tower.targeting := "Lock in Place"
    } else if tower.targeting = "Pursuit" {
        Send("{Tab}")
        Sleep(35)
        Send("{Tab}")
        Sleep(35)
        tower.targeting := "Lock in Place"
    } else if tower.targeting = "Patrol Points" {
        ; Reverse one targeting step to avoid opening a new Patrol setup.
        Send("^{Tab}")
        Sleep(35)
        tower.targeting := "Lock in Place"
    } else if tower.targeting != "Lock in Place" {
        throw Error(
            "Unknown Heli targeting mode '" tower.targeting "'. "
            . "Expected Follow Mouse, Lock in Place, Patrol Points, or Pursuit."
        )
    }

    return ClickHeliLockPoint(tower, lockX, lockY)
}


RetargetHeli(tower, lockX, lockY) {
    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "Heli"
        throw Error("RetargetHeli() can only be used with Heli Pilots.")

    NormalizeHeliTargetingState(tower)

    if tower.targeting != "Lock in Place"
        return LockHeliInPlace(tower, lockX, lockY)

    EnsureHeliSelected(tower)
    return ClickHeliLockPoint(tower, lockX, lockY)
}


ClickHeliLockPoint(tower, lockX, lockY) {
    ; PgDn activates the Heli set-target action while Lock in Place is active.
    ; BTD6 then expects a screen click for the new hover position.
    ClickSpecialTargetPoint(lockX, lockY)

    tower.lockX := lockX
    tower.lockY := lockY
    tower.targeting := "Lock in Place"

    ; The set-target click can dismiss/rearrange the panel, so do not reuse
    ; the selected-monkey cache after setting a Heli hover point.
    ClearSelectedUpgradeTower()

    return true
}
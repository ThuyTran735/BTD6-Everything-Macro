#Requires AutoHotkey v2.0


GetDartlingTargetingOrder(tower) {
    if tower.type != "Dartling"
        throw Error("GetDartlingTargetingOrder() can only be used with Dartling Gunners.")

    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]

    ; BADS / BEZ (xx4+) gain Target Independent in addition to
    ; the normal mouse-following and locked targeting modes.
    if tower.upgrades[3] >= 4 {
        return [
            "Normal",
            "Locked",
            "Target Independent"
        ]
    }

    return [
        "Normal",
        "Locked"
    ]
}


EnsureDartlingSelected(tower) {
    if IsUpgradeTowerSelected(tower)
        return true

    ClearSelectedUpgradeTower()
    Click(tower.x, tower.y)
    Sleep(35)

    ; Reuse the normal upgrade-panel side cache so a following
    ; upgrade can still benefit from selected-monkey handling.
    CacheSelectedUpgradeTower(
        tower,
        GetExpectedUpgradePanelSide(tower)
    )

    return true
}


SetDartlingTargeting(tower, targetMode, aimX := "", aimY := "") {
    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "Dartling"
        throw Error("SetDartlingTargeting() can only be used with Dartling Gunners.")

    if !HasProp(tower, "targeting")
        tower.targeting := "Normal"

    targetingOrder := GetDartlingTargetingOrder(tower)

    currentIndex := 0
    targetIndex := 0

    for index, mode in targetingOrder {
        if mode = tower.targeting
            currentIndex := index

        if mode = targetMode
            targetIndex := index
    }

    if currentIndex = 0 {
        tower.targeting := targetingOrder[1]
        currentIndex := 1
    }

    if targetIndex = 0 {
        throw Error(
            "Dartling targeting mode '" targetMode "' is not available at the current upgrade level."
        )
    }

    ; If already Locked and a new point was supplied, use Dartling's
    ; dedicated retarget hotkey instead of cycling away and back.
    if tower.targeting = "Locked" && targetMode = "Locked" {
        if aimX != "" && aimY != ""
            return RetargetDartling(tower, aimX, aimY)

        return true
    }

    EnsureDartlingSelected(tower)

    ; When entering Locked targeting for the first time, the current
    ; cursor position becomes the initial lock direction. Move there
    ; before cycling Normal -> Locked.
    if targetMode = "Locked" && aimX != "" && aimY != "" {
        MouseMove(aimX, aimY, 0)
        Sleep(20)
    }

    profileLength := targetingOrder.Length
    forwardSteps := Mod(
        targetIndex - currentIndex + profileLength,
        profileLength
    )

    Loop forwardSteps {
        Send("{Tab}")
        Sleep(35)
    }

    tower.targeting := targetMode

    if targetMode = "Locked" && aimX != "" && aimY != "" {
        return ClickDartlingAimPoint(tower, aimX, aimY)
    }

    ; Normal and Target Independent do not need a fixed cursor point.
    if targetMode != "Locked" {
        Send("{Esc}")
        ClearSelectedUpgradeTower()
        Sleep(20)
    }

    return true
}


AimDartling(tower, aimX, aimY) {
    ; AimDartling always means "keep this barrel locked on this point".
    ; If the Dartling is not Locked yet, SetDartlingTargeting() enters
    ; Locked mode using the requested point. If it is already Locked,
    ; RetargetDartling() uses PgDn + click to move the lock point.
    return SetDartlingTargeting(
        tower,
        "Locked",
        aimX,
        aimY
    )
}


RetargetDartling(tower, aimX, aimY) {
    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "Dartling"
        throw Error("RetargetDartling() can only be used with Dartling Gunners.")

    if !HasProp(tower, "targeting")
        tower.targeting := "Normal"

    if tower.targeting != "Locked" {
        return SetDartlingTargeting(
            tower,
            "Locked",
            aimX,
            aimY
        )
    }

    EnsureDartlingSelected(tower)
    return ClickDartlingAimPoint(tower, aimX, aimY)
}


ClickDartlingAimPoint(tower, aimX, aimY) {
    ; PgDn activates Dartling's set-target action while it is Locked.
    ; BTD6 then expects a screen click for the new barrel aim point.
    ClickSpecialTargetPoint(aimX, aimY)

    tower.aimX := aimX
    tower.aimY := aimY

    ; The set-target click may dismiss/rearrange the tower panel, so do
    ; not trust the selected-monkey cache after an aim-point click.
    ClearSelectedUpgradeTower()

    return true
}
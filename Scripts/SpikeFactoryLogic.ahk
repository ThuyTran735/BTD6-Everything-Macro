#Requires AutoHotkey v2.0


; v3 file note: Handles the SpikeFactory part of the macro. Keep this focused so run bugs are easier to trace later.

GetSpikeFactoryTargetingOrder(tower) {
    if tower.type != "SpikeFactory"
        throw Error("GetSpikeFactoryTargetingOrder() can only be used with Spike Factories.")

    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]

    ; xx2 Smart Spikes unlocks Spike Factory's special targeting modes.
    if tower.upgrades[3] >= 2 {
        return [
            "Normal",
            "Close",
            "Smart",
            "Automatic",
            "Set Target"
        ]
    }

    return ["Normal"]
}


NormalizeSpikeFactoryTargetingState(tower) {
    if !HasProp(tower, "targeting") {
        tower.targeting := "Normal"
        return tower.targeting
    }

    ; Older strategy/reset code used generic targeting values for every tower.
    ; Spike Factory uses its own targeting profile instead.
    if (
        tower.targeting = "First"
        || tower.targeting = "Last"
        || tower.targeting = "Strong"
    )
        tower.targeting := "Normal"

    return tower.targeting
}


EnsureSpikeFactorySelected(tower) {
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


SetSpikeFactoryTargeting(tower, targetMode, targetX := "", targetY := "") {
    actionText :=
        "Spike Factory "
        . GetTowerLogName(tower)
        . " targeting -> "
        . targetMode

    if targetMode = "Set Target" && targetX != "" && targetY != ""
        actionText .= " at " . targetX . ", " . targetY

    LogStrategyAction(actionText)

    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "SpikeFactory"
        throw Error("SetSpikeFactoryTargeting() can only be used with Spike Factories.")

    NormalizeSpikeFactoryTargetingState(tower)
    targetingOrder := GetSpikeFactoryTargetingOrder(tower)

    currentIndex := 0
    targetIndex := 0

    for index, mode in targetingOrder {
        if mode = tower.targeting
            currentIndex := index

        if mode = targetMode
            targetIndex := index
    }

    if currentIndex = 0 {
        tower.targeting := "Normal"
        currentIndex := 1
    }

    if targetIndex = 0 {
        throw Error(
            "Spike Factory targeting mode '" targetMode
            . "' is not available at the current upgrade level. "
            . "Close, Smart, Automatic, and Set Target require xx2 Smart Spikes."
        )
    }

    ; Retarget an already-directed Spike Factory without cycling away.
    if tower.targeting = "Set Target" && targetMode = "Set Target" {
        if targetX != "" && targetY != ""
            return RetargetSpikeFactory(tower, targetX, targetY)

        return true
    }

    EnsureSpikeFactorySelected(tower)

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

    if targetMode = "Set Target" {
        if targetX != "" && targetY != ""
            return ClickSpikeFactoryTargetPoint(tower, targetX, targetY)

        ; The targeting mode can be selected without immediately changing
        ; the target point. Close the panel and leave the mode synchronized.
        Send("{Esc}")
        ClearSelectedUpgradeTower()
        Sleep(20)
        return true
    }

    Send("{Esc}")
    ClearSelectedUpgradeTower()
    Sleep(20)

    return true
}


SetSpikeFactoryTarget(tower, targetX, targetY) {
    return SetSpikeFactoryTargeting(
        tower,
        "Set Target",
        targetX,
        targetY
    )
}


RetargetSpikeFactory(tower, targetX, targetY) {
    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "SpikeFactory"
        throw Error("RetargetSpikeFactory() can only be used with Spike Factories.")

    NormalizeSpikeFactoryTargetingState(tower)

    if tower.targeting != "Set Target" {
        return SetSpikeFactoryTarget(
            tower,
            targetX,
            targetY
        )
    }

    EnsureSpikeFactorySelected(tower)
    return ClickSpikeFactoryTargetPoint(tower, targetX, targetY)
}


ClickSpikeFactoryTargetPoint(tower, targetX, targetY) {
    ; PgDn activates the special Set Target action. BTD6 then expects a
    ; screen click on a valid track point inside the Spike Factory's range.
    ClickSpecialTargetPoint(targetX, targetY)

    tower.targeting := "Set Target"
    tower.targetX := targetX
    tower.targetY := targetY

    ; Manual target placement can dismiss/rearrange the upgrade panel.
    ClearSelectedUpgradeTower()

    return true
}
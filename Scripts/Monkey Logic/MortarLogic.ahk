#Requires AutoHotkey v2.0


; Select a Mortar, place its manual target, and remember the last requested point.

EnsureMortarSelected(tower) {
    ClickMapPoint(tower.x, tower.y)
    Sleep(35)

    return true
}


SetMortarTarget(tower, targetX, targetY) {
    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "Mortar"
        throw Error("SetMortarTarget() can only be used with Mortar Monkeys.")

    if !EnsureMortarSelected(tower)
        return false

    ; The shared helper owns PgDn timing and closes the panel after the target click.
    ClickSpecialTargetPoint(targetX, targetY)

    tower.targeting := "Target"
    tower.targetSet := true
    tower.targetX := targetX
    tower.targetY := targetY

    ; Manual target placement can dismiss/rearrange the upgrade panel.
    return true
}


RetargetMortar(tower, targetX, targetY) {
    return SetMortarTarget(tower, targetX, targetY)
}

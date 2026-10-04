#Requires AutoHotkey v2.0


; v3 file note: Handles the Mortar part of the macro. Keep this focused so run bugs are easier to trace later.

EnsureMortarSelected(tower) {
    Click(tower.x, tower.y)
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
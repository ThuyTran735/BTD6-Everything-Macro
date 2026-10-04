#Requires AutoHotkey v2.0


; v3 file note: Handles the Mermonkey part of the macro. Keep this focused so run bugs are easier to trace later.

EnsureMermonkeySelected(tower) {
    Click(tower.x, tower.y)
    Sleep(35)

    return true
}


CanPlaceMermonkeyTotem(tower) {
    if tower.type != "Mermonkey"
        return false

    if !HasProp(tower, "upgrades")
        return false

    ; Symphonic Resonance (xx4) unlocks the Allure Totem.
    ; The Final Harmonic (xx5) keeps it and removes the local-range limit.
    return tower.upgrades[3] >= 4
}


PlaceMermonkeyTotem(tower, totemX, totemY) {
    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "Mermonkey"
        throw Error("PlaceMermonkeyTotem() can only be used with Mermonkeys.")

    if !CanPlaceMermonkeyTotem(tower) {
        throw Error(
            "Mermonkey must be upgraded to xx4 or xx5 before placing the Allure Totem."
        )
    }

    if !EnsureMermonkeySelected(tower)
        return false

    return ClickMermonkeyTotemPoint(tower, totemX, totemY)
}


RetargetMermonkeyTotem(tower, totemX, totemY) {
    ; Manual Targeting uses the same PgDn + click flow when moving the
    ; Allure Totem to a new position.
    return PlaceMermonkeyTotem(tower, totemX, totemY)
}


ClickMermonkeyTotemPoint(tower, totemX, totemY) {
    ; PgDn is BTD6's special/manual-targeting hotkey. For xx4+ Mermonkeys
    ; it activates Allure Totem placement, then BTD6 expects a map click.
    ClickSpecialTargetPoint(totemX, totemY)

    tower.totemPlaced := true
    tower.totemX := totemX
    tower.totemY := totemY

    ; The shared helper closes any panel still visible after the target click.
    return true
}
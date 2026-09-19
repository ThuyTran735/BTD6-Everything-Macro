#Requires AutoHotkey v2.0


EnsureMermonkeySelected(tower) {
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

    EnsureMermonkeySelected(tower)
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

    ; Manual-target placement can dismiss or rearrange the upgrade panel,
    ; so the selected-monkey cache is no longer trusted after the click.
    ClearSelectedUpgradeTower()

    return true
}
#Requires AutoHotkey v2.0


; v3 file note: Handles selling towers. BTD6 already has a sell hotkey, so keep this simple.

SellTower(
    tower,
    overrideX := "",
    overrideY := ""
) {
    LogStrategyAction(
        "Sell " . GetTowerLogName(tower)
    )


    if (
        !HasProp(
            tower,
            "placed"
        )
        || !tower.placed
    ) {
        return SetRunFailureReason(
            "SELL FAILED",
            "Tower has not been placed"
        )
    }


    hasCoordinateOverride :=
        overrideX != ""
        || overrideY != ""


    if (
        hasCoordinateOverride
        && (
            overrideX = ""
            || overrideY = ""
        )
    ) {
        throw Error(
            "Sell coordinate override requires both X and Y."
        )
    }


    clickX :=
        hasCoordinateOverride
            ? overrideX
            : tower.x


    clickY :=
        hasCoordinateOverride
            ? overrideY
            : tower.y


    ; If an upgrade just happened on this same tower, its panel may already
    ; be open. Otherwise click it first, including moving-map overrides.
    if (
        hasCoordinateOverride
        || !IsUpgradeTowerSelected(
            tower
        )
    ) {
        ClearSelectedUpgradeTower()


        Click(
            clickX,
            clickY
        )


        Sleep(90)
    }


    ; Backspace is BTD6's default sell hotkey. We still check that a tower
    ; panel is actually open first so a missed click does not fake a sale.
    if !GetUpgradePanelSide() {
        ClearSelectedUpgradeTower()


        return SetRunFailureReason(
            "SELL FAILED",
            "Could not select tower for selling"
        )
    }


    Send(
        "{Backspace}"
    )


    Sleep(180)


    ClearSelectedUpgradeTower()


    tower.placed :=
        false


    tower.upgrades :=
        [0, 0, 0]


    try tower.targeting :=
        GetDefaultTargeting(
            tower
        )


    if HasProp(
        tower,
        "submerged"
    ) {
        tower.submerged :=
            false
    }


    if HasProp(
        tower,
        "targetingBeforeSubmerge"
    ) {
        tower.targetingBeforeSubmerge :=
            tower.targeting
    }


    if HasProp(
        tower,
        "panelSide"
    ) {
        tower.panelSide :=
            false
    }


    return true
}
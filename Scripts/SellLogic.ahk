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


    Click(
        clickX,
        clickY
    )


    Sleep(90)


    ; Backspace sells the tower we just clicked. Do not wait on upgrade-panel
    ; detection here; the click itself is all we need before sending the hotkey.
    Send(
        "{Backspace}"
    )


    Sleep(180)


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
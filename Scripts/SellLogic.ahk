#Requires AutoHotkey v2.0


SellTower(
    tower,
    overrideX := "",
    overrideY := ""
) {
    global SellButtonPattern


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


    panelSide :=
        GetExpectedUpgradePanelSideFromX(
            clickX
        )


    ; UpgradeTower intentionally keeps a selected tower's panel open for
    ; reuse. Reuse that panel only when this sell uses the tower's normal
    ; saved coordinates. A moving-map override must always reselect the tower.
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


        Sleep(
            90
        )
    }


    if !FindSellButton(
        &sellX,
        &sellY,
        panelSide
    ) {
        Send(
            "{Esc}"
        )


        ClearSelectedUpgradeTower()


        return SetRunFailureReason(
            "SELL FAILED",
            "Could not find Sell button"
        )
    }


    Click(
        sellX,
        sellY
    )


    Sleep(
        180
    )


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


FindSellButton(
    &sellX,
    &sellY,
    panelSide := false
) {
    global SellButtonPattern


    if panelSide = "Left" {
        x1 := 0
        x2 := A_ScreenWidth // 2
    }
    else if panelSide = "Right" {
        x1 := A_ScreenWidth // 2
        x2 := A_ScreenWidth
    }
    else {
        x1 := 0
        x2 := A_ScreenWidth
    }


    if FindText(
        &sellX,
        &sellY,
        x1,
        0,
        x2,
        A_ScreenHeight,
        0,
        0,
        SellButtonPattern
    ) {
        return true
    }


    ; Fallback for unusual panel layouts where the expected side heuristic
    ; is wrong. Selling is infrequent, so one full-screen fallback scan is
    ; preferable to silently clicking the wrong location.
    if (
        x1 != 0
        || x2 != A_ScreenWidth
    ) {
        return !!FindText(
            &sellX,
            &sellY,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            SellButtonPattern
        )
    }


    return false
}

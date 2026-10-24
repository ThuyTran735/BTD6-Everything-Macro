#Requires AutoHotkey v2.0

; Estimates the upgrade-panel side and provides focused victory and defeat checks.
; The estimate comes from the tower position; a detected Sell button gives the actual side.

GetExpectedUpgradePanelSide(tower) {
    if !HasProp(tower, "x") {
        return false
    }


    return GetExpectedUpgradePanelSideFromX(
        tower.x
    )
}


GetExpectedUpgradePanelSideFromX(x) {
    ; BTD6 places the upgrade panel on the opposite side of the selected
    ; monkey so it does not cover the tower itself. Accepting a raw X value
    ; lets UpgradeTower() use an optional moving-map coordinate override.
    return x < A_ScreenWidth // 2
        ? "Right"
        : "Left"
}


GetUpgradePanelSide() {
    global SellButtonPattern

    if SellButtonPattern = ""
        return false

    ; In the supported 1920x1080 layout, Sell belongs to the lower side panel.
    ; Leave vertical room around the bottom upgrade row, but exclude the map
    ; center and tower shop where similar shapes are not panel evidence.
    FindText().ScreenShot(0, 740, 1640, 1079)

    leftMatch := FindText(
        &X,
        &Y,
        0,
        740,
        400,
        1079,
        0,
        0,
        SellButtonPattern,
        0,
        0
    )

    rightMatch := FindText(
        &X,
        &Y,
        1280,
        740,
        1640,
        1079,
        0,
        0,
        SellButtonPattern,
        0,
        0
    )

    ; Both searches use the same frame. A match on each side is ambiguous;
    ; callers should retry selection rather than assume either panel is open.
    if !!leftMatch = !!rightMatch
        return false

    return leftMatch ? "Left" : "Right"
}


IsUpgradeWaitDefeatVisible() {
    global GameStatePatterns


    if !GameStatePatterns.Has("Restart") {
        return false
    }


    pattern := GameStatePatterns["Restart"]


    if pattern = "" {
        return false
    }


    return !!FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        pattern
    )
}


IsUpgradeWaitVictoryVisible() {
    global GameStatePatterns


    if !GameStatePatterns.Has("VictoryNext") {
        return false
    }


    pattern := GameStatePatterns["VictoryNext"]


    if pattern = "" {
        return false
    }


    return !!FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        pattern
    )
}



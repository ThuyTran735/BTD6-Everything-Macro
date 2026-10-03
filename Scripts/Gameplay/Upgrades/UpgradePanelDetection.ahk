#Requires AutoHotkey v2.0

; v3 file note: Figures out which side the upgrade panel is on and checks end-screen interruptions.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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


    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        SellButtonPattern
    ) {

        return false
    }


    return X < A_ScreenWidth // 2
        ? "Left"
        : "Right"
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



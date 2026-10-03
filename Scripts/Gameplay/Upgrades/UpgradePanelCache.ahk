#Requires AutoHotkey v2.0

; v3 file note: Tracks which monkey panel is already open so repeat upgrades can reuse it.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

ClearSelectedUpgradeTower() {
    global SelectedUpgradeTower
    global SelectedUpgradePanelSide

    SelectedUpgradeTower := false
    SelectedUpgradePanelSide := false

    return true
}


CloseCachedUpgradePanel(settleMs := 25) {
    global SelectedUpgradeTower

    ; We intentionally leave the panel open after an upgrade so the same
    ; monkey can be reused. Before a placement action, close that cached
    ; panel first so it cannot interfere with the next tower hotkey.
    ;
    ; Do not scan the whole screen for a visible panel here. This helper is
    ; also called before round waits, and a false-positive Sell-button match
    ; can send Esc at the wrong time and break actions such as Hero placement.
    if IsObject(SelectedUpgradeTower) {
        Send("{Esc}")
        Sleep(settleMs)
    }

    return ClearSelectedUpgradeTower()
}


CacheSelectedUpgradeTower(tower, panelSide := false) {
    global SelectedUpgradeTower
    global SelectedUpgradePanelSide

    SelectedUpgradeTower := tower
    SelectedUpgradePanelSide := panelSide

    return true
}


IsUpgradeTowerSelected(tower) {
    global SelectedUpgradeTower

    return (
        IsObject(SelectedUpgradeTower)
        && ObjPtr(SelectedUpgradeTower) = ObjPtr(tower)
    )
}


TryReuseSelectedUpgradeTower(tower, &panelSide) {
    global SelectedUpgradePanelSide

    if !IsUpgradeTowerSelected(tower) {
        return false
    }

    panelSide := SelectedUpgradePanelSide

    if !panelSide {
        panelSide := GetExpectedUpgradePanelSide(tower)
    }

    return true
}


global UpgradePoints := Map(
    "Left", Map(
        "Top", [260, 486],
        "Middle", [258, 639],
        "Bottom", [262, 791]
    ),

    "Right", Map(
        "Top", [1483, 487],
        "Middle", [1484, 638],
        "Bottom", [1483, 786]
    )
)


global UpgradeHotkeys := Map(
    "Top", ",",
    "Middle", ".",
    "Bottom", "/"
)


IsFastDeflationPregameUpgrade() {
    global IsPregame
    global RunConfig

    try {
        return IsPregame && RunConfig.gameMode = "Deflation"
    }

    return false
}



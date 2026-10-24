#Requires AutoHotkey v2.0

; Banana Farm collection support.
; Collection is opt-in per strategy and only runs while the strategy is already
; waiting for a future round / otherwise idle.
;
; BTD6 collects every loose banana from a Farm when the mouse briefly hovers
; over the Farm itself, so no collection grid is needed. Each eligible Farm is
; visited one at a time. Each idle collection step hovers one eligible Farm
; for 300 ms, then normal round / popup / strategy logic gets control again.

global BananaCollectionEnabled := false
global BananaCollectionHoverMs := 300
global BananaCollectionFarmIndex := 1


ResetBananaCollection() {
    global BananaCollectionEnabled
    global BananaCollectionFarmIndex

    BananaCollectionEnabled := false
    BananaCollectionFarmIndex := 1
    return true
}


EnableBananaCollection() {
    global BananaCollectionEnabled
    global BananaCollectionFarmIndex

    BananaCollectionEnabled := true
    BananaCollectionFarmIndex := 1

    LogStrategyAction(
        "Enable Banana Farm collection"
    )

    return true
}


DisableBananaCollection() {
    global BananaCollectionEnabled
    global BananaCollectionFarmIndex

    BananaCollectionEnabled := false
    BananaCollectionFarmIndex := 1

    LogStrategyAction(
        "Disable Banana Farm collection"
    )

    return true
}


IsBananaFarmTower(tower) {
    if !IsObject(tower) || !HasProp(tower, "type") {
        return false
    }

    return (
        tower.type = "Farm"
        || tower.type = "Banana Farm"
    )
}


FarmNeedsBananaCollection(tower) {
    if !IsBananaFarmTower(tower) {
        return false
    }

    if !HasProp(tower, "placed") || !tower.placed {
        return false
    }

    if !HasProp(tower, "upgrades") {
        return true
    }

    middlePath :=
        tower.upgrades.Length >= 2
            ? tower.upgrades[2]
            : 0

    bottomPath :=
        tower.upgrades.Length >= 3
            ? tower.upgrades[3]
            : 0

    ; Monkey Bank and higher store income instead of dropping normal bananas.
    if middlePath >= 3 {
        return false
    }

    ; Marketplace and higher collect their own bananas automatically.
    if bottomPath >= 3 {
        return false
    }

    return true
}


GetBananaCollectionFarms() {
    global TowerSetup

    farms := []

    for name, tower in TowerSetup {
        if !FarmNeedsBananaCollection(tower) {
            continue
        }

        farms.Push({
            name: name,
            tower: tower
        })
    }

    return farms
}


CollectBananasWhileIdle() {
    global BananaCollectionEnabled
    global BananaCollectionHoverMs
    global BananaCollectionFarmIndex

    if !BananaCollectionEnabled {
        return false
    }

    ; Rebuild on each idle step because upgrades and sales can change eligibility.
    farms := GetBananaCollectionFarms()

    if farms.Length = 0 {
        BananaCollectionFarmIndex := 1
        return false
    }

    ; Farms can become ineligible after an upgrade. Keep the rotating index
    ; inside the current eligible list so collection continues cleanly.
    if BananaCollectionFarmIndex > farms.Length {
        BananaCollectionFarmIndex := 1
    }

    farmEntry := farms[BananaCollectionFarmIndex]
    farm := farmEntry.tower

    ; Borrow screen coordinates only for this hover; finally restores the caller.
    previousCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")

    try {
        ; Use the same Cycle HUD click guard used by tower placement. If a
        ; Farm is under or close to the HUD, hide the HUD before the mouse
        ; moves onto the Farm so it cannot block banana collection.
        RequestCycleStatusHideForPoint(
            farm.x,
            farm.y,
            350
        )

        MouseMove(
            farm.x,
            farm.y,
            0
        )

        ; Stay on one Farm long enough to collect its loose bananas, then
        ; immediately return control to WaitForRound(). That lets round,
        ; popup, placement, upgrade, and other strategy actions take priority
        ; before the next Farm is visited.
        Sleep(BananaCollectionHoverMs)
    }
    finally {
        CoordMode("Mouse", previousCoordMode)
    }

    BananaCollectionFarmIndex += 1

    if BananaCollectionFarmIndex > farms.Length {
        BananaCollectionFarmIndex := 1
    }

    return true
}

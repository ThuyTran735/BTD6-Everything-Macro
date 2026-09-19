#Requires AutoHotkey v2.0


SetSubmerge(tower, shouldSubmerge := true) {
    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type != "Sub"
        throw Error("SetSubmerge() can only be used with Monkey Subs.")

    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]

    if tower.upgrades[1] < 3 {
        throw Error(
            "Monkey Sub must be upgraded to 3xx or higher before using Submerge."
        )
    }

    if !HasProp(tower, "submerged")
        tower.submerged := false

    if !HasProp(tower, "targeting")
        tower.targeting := "First"

    if !HasProp(tower, "targetingBeforeSubmerge")
        tower.targetingBeforeSubmerge := tower.targeting

    if tower.submerged = shouldSubmerge
        return true


    ; Going from surfaced -> submerged.
    if shouldSubmerge {
        ; Remember the normal targeting mode.
        tower.targetingBeforeSubmerge := tower.targeting

        if !IsUpgradeTowerSelected(tower) {
            ClearSelectedUpgradeTower()
            Click(tower.x, tower.y)
            Sleep(250)
        }

        ; Page Down toggles Submerge.
        Send("{PgDn}")

        Sleep(30)

        tower.submerged := true

        Send("{Esc}")
        ClearSelectedUpgradeTower()
        Sleep(20)

        return true
    }


    ; Going from submerged -> surfaced.
    if !IsUpgradeTowerSelected(tower) {
        ClearSelectedUpgradeTower()
        Click(tower.x, tower.y)
        Sleep(250)
    }

    ; Page Down toggles back to surfaced.
    Send("{PgDn}")

    Sleep(30)

    tower.submerged := false

    ; BTD6 returns to the targeting mode that was
    ; active before the Sub submerged.
    tower.targeting := tower.targetingBeforeSubmerge

    Send("{Esc}")
    ClearSelectedUpgradeTower()
    Sleep(20)

    return true
}
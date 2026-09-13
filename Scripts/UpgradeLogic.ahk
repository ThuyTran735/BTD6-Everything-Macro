#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

global SellButtonPattern := "|<>*160$71.zk0zw3z0Ts1zy01zU1y0zk3zs03y01w1zU7zU07s03s3z0Dz00DU03k7y0Tw00T007UDw1zs3zw0kD0Ts3zk7zs3kC0zk7zU7zkDUQ1zUDzU0D0T0k3z0Tz00C001U7y0zz00Q0030Dw1zz00s00C0zs3zzU1k0zw1zk7zzw3UDzs03U0Dzw30Dzk0700T7k70D7U0C00y00C00D00Q01w00S00y00s03k01w01w01k07U03w03s03U0DU0Tw07kDz1zzk1zy0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

; Approximate affordable green color.
global UpgradeGreenColor := 0x4FD500

; Known affordable-green sample points.
global UpgradePoints := Map(
    "Left", Map(
        "Top",    [260, 486],
        "Middle", [258, 639],
        "Bottom", [262, 791]
    ),

    "Right", Map(
        "Top",    [1483, 487],
        "Middle", [1484, 638],
        "Bottom", [1483, 786]
    )
)

; Upgrade hotkeys.
global UpgradeHotkeys := Map(
    "Top",    ",",
    "Middle", ".",
    "Bottom", "/"
)

UpgradeTower(tower, target) {
    if !HasProp(tower, "placed") || !tower.placed {
        ToolTip("Tower has not been placed yet.")
        Sleep(1500)
        ToolTip()
        return false
    }

    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]

    ; Example target:
    ; "025" = 0 top, 2 middle, 5 bottom
    if StrLen(target) != 3
        throw Error("Upgrade target must be 3 digits, for example: 025")

    targetTop    := Integer(SubStr(target, 1, 1))
    targetMiddle := Integer(SubStr(target, 2, 1))
    targetBottom := Integer(SubStr(target, 3, 1))

    ; Re-select tower
    Click(tower.x, tower.y)
    Sleep(200)

    panelSide := GetUpgradePanelSide()

    if !panelSide {
        ToolTip("Could not detect upgrade panel.")
        Sleep(1500)
        ToolTip()
        return false
    }

    ; Top path
    while tower.upgrades[1] < targetTop {
        if !WaitForUpgrade("Top", panelSide)
            return false

        BuyUpgrade("Top")
        tower.upgrades[1]++
    }

    ; Middle path
    while tower.upgrades[2] < targetMiddle {
        if !WaitForUpgrade("Middle", panelSide)
            return false

        BuyUpgrade("Middle")
        tower.upgrades[2]++
    }

    ; Bottom path
    while tower.upgrades[3] < targetBottom {
        if !WaitForUpgrade("Bottom", panelSide)
            return false

        BuyUpgrade("Bottom")
        tower.upgrades[3]++
    }

    ; Close upgrade panel so the next upgrade can safely re-select the tower.
    Send("{Esc}")
    Sleep(200)

    return true
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

    ; Sell button on left half => left panel
    ; Sell button on right half => right panel
    return X < A_ScreenWidth // 2 ? "Left" : "Right"
}

WaitForUpgrade(path, panelSide) {
    global UpgradePoints

    if !UpgradePoints.Has(panelSide)
        throw Error("Unknown panel side: " panelSide)

    if !UpgradePoints[panelSide].Has(path)
        throw Error("Unknown upgrade path: " path)

    point := UpgradePoints[panelSide][path]

    Loop {
        if IsUpgradeGreen(point[1], point[2])
            return true

        Sleep(100)
    }
}

IsUpgradeGreen(x, y, tolerance := 10) {
    global UpgradeGreenColor

    color := PixelGetColor(x, y)

    r1 := (color >> 16) & 0xFF
    g1 := (color >> 8) & 0xFF
    b1 := color & 0xFF

    r2 := (UpgradeGreenColor >> 16) & 0xFF
    g2 := (UpgradeGreenColor >> 8) & 0xFF
    b2 := UpgradeGreenColor & 0xFF

    return (
        Abs(r1 - r2) <= tolerance
        && Abs(g1 - g2) <= tolerance
        && Abs(b1 - b2) <= tolerance
    )
}

BuyUpgrade(path) {
    global UpgradeHotkeys

    if !UpgradeHotkeys.Has(path)
        throw Error("Unknown upgrade path: " path)

    Send(UpgradeHotkeys[path])
    Sleep(200)

    return true
}
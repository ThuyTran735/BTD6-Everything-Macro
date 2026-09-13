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


global UpgradeHotkeys := Map(
    "Top",    ",",
    "Middle", ".",
    "Bottom", "/"
)


UpgradeTower(tower, target) {
    global IsPregame


    if !HasProp(tower, "placed") || !tower.placed
        return false


    if !HasProp(tower, "upgrades")
        tower.upgrades := [0, 0, 0]


    if StrLen(target) != 3
        throw Error("Upgrade target must be 3 digits, for example: 025")


    targetTop    := Integer(SubStr(target, 1, 1))
    targetMiddle := Integer(SubStr(target, 2, 1))
    targetBottom := Integer(SubStr(target, 3, 1))


    Click(tower.x, tower.y)

    Sleep(250)


    panelSide := GetUpgradePanelSide()


    if !panelSide {
        if !IsPregame {
            state := CheckGameState()

            if state = "Victory"
                return "Victory"

            if state = "Defeat"
                return "Defeat"
        }

        return false
    }


    while tower.upgrades[1] < targetTop {
        result := WaitForUpgrade(
            "Top",
            panelSide
        )


        if result = "Victory"
            return "Victory"

        if result = "Defeat"
            return "Defeat"

        if result = false
            return false


        if !BuyUpgrade("Top")
            return false


        tower.upgrades[1]++


        UpdateTargetingAfterUpgrade(
            tower,
            "Top"
        )
    }


    while tower.upgrades[2] < targetMiddle {
        result := WaitForUpgrade(
            "Middle",
            panelSide
        )


        if result = "Victory"
            return "Victory"

        if result = "Defeat"
            return "Defeat"

        if result = false
            return false


        if !BuyUpgrade("Middle")
            return false


        tower.upgrades[2]++


        UpdateTargetingAfterUpgrade(
            tower,
            "Middle"
        )
    }


    while tower.upgrades[3] < targetBottom {
        result := WaitForUpgrade(
            "Bottom",
            panelSide
        )


        if result = "Victory"
            return "Victory"

        if result = "Defeat"
            return "Defeat"

        if result = false
            return false


        if !BuyUpgrade("Bottom")
            return false


        tower.upgrades[3]++


        UpdateTargetingAfterUpgrade(
            tower,
            "Bottom"
        )
    }


    Send("{Esc}")
    Sleep(20)


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


    return X < A_ScreenWidth // 2
        ? "Left"
        : "Right"
}


WaitForUpgrade(path, panelSide) {
    global UpgradePoints
    global IsPregame


    if !UpgradePoints.Has(panelSide)
        throw Error("Unknown panel side: " panelSide)


    if !UpgradePoints[panelSide].Has(path)
        throw Error("Unknown upgrade path: " path)


    point := UpgradePoints[panelSide][path]


    lastStateCheck := A_TickCount


    Loop {
        if IsUpgradeGreen(
            point[1],
            point[2]
        ) {
            return true
        }


        if !IsPregame {
            if A_TickCount - lastStateCheck >= 200 {
                lastStateCheck := A_TickCount


                state := CheckGameState()


                if state = "Victory"
                    return "Victory"


                if state = "Defeat"
                    return "Defeat"
            }
        }


        Sleep(10)
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

    Sleep(20)


    return true
}


UpdateTargetingAfterUpgrade(tower, upgradedPath) {
    global EliteSniperActive


    if tower.type = "Sniper" {
        if (
            upgradedPath = "Middle"
            && tower.upgrades[2] = 5
        ) {
            EliteSniperActive := true

            tower.targeting := "Elite"
        }
    }


    if tower.type = "Ace" {
        if (
            upgradedPath = "Bottom"
            && tower.upgrades[3] = 2
        ) {
            tower.targeting := "Centered Path"
        }
    }


    return true
}
#Requires AutoHotkey v2.0

; v3 file note: Deals with locked upgrade paths and the unlock prompt.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

HandleLockedUpgrade(
    tower,
    path,
    &panelSide
) {
    global UpgradePoints
    global UnlockUpgradePattern
    global ConfirmUpgradeUnlockPattern


    if UnlockUpgradePattern = "" {
        return "NotLocked"
    }


    if ConfirmUpgradeUnlockPattern = "" {
        return "NotLocked"
    }


    if !UpgradePoints.Has(
        panelSide
    ) {

        return "Failed"
    }


    if !UpgradePoints[
        panelSide
    ].Has(
        path
    ) {

        return "Failed"
    }


    point :=
        UpgradePoints[
            panelSide
        ][
            path
        ]


    searchRadiusX :=
        120


    searchRadiusY :=
        55


    x1 :=
        Max(
            0,
            point[1]
            - searchRadiusX
        )


    y1 :=
        Max(
            0,
            point[2]
            - searchRadiusY
        )


    x2 :=
        Min(
            A_ScreenWidth,
            point[1]
            + searchRadiusX
        )


    y2 :=
        Min(
            A_ScreenHeight,
            point[2]
            + searchRadiusY
        )


    ; Keep all FindText-based locked-upgrade verification inside one
    ; short shared window. The initial lock scan and every confirmation
    ; scan below all count toward the same 150 ms budget.
    scanBudgetMs := 150
    scanDeadline := A_TickCount + scanBudgetMs


    if !FindText(
        &X,
        &Y,
        x1,
        y1,
        x2,
        y2,
        0,
        0,
        UnlockUpgradePattern
    ) {

        return "NotLocked"
    }


    Click(
        X,
        Y
    )


    while A_TickCount < scanDeadline {

        if FindText(
            &UnlockX,
            &UnlockY,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            ConfirmUpgradeUnlockPattern
        ) {

            Click(
                UnlockX,
                UnlockY
            )


            Sleep(
                500
            )


            Send(
                "{Esc}"
            )


            ClearSelectedUpgradeTower()


            Sleep(
                350
            )


            panelResult :=
                EnsureUpgradePanelOpen(
                    tower,
                    &panelSide
                )


            if panelResult = "Victory" {
                return "Victory"
            }


            if panelResult = "Defeat" {
                return "Defeat"
            }


            if panelResult = false {
                return "Failed"
            }


            return "Unlocked"
        }


        remainingMs := scanDeadline - A_TickCount

        if remainingMs <= 0 {
            break
        }


        Sleep(
            Min(10, remainingMs)
        )
    }


    Send(
        "{Esc}"
    )


    ClearSelectedUpgradeTower()


    Sleep(
        350
    )


    EnsureUpgradePanelOpen(
        tower,
        &panelSide
    )


    return "Failed"
}



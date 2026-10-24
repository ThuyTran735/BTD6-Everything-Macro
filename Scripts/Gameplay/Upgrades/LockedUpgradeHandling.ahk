#Requires AutoHotkey v2.0

; Handles the locked-upgrade prompt after a purchase needs extra verification.
; All lock and confirmation scans share one short time budget to keep normal upgrades responsive.

HandleLockedUpgrade(
    tower,
    path,
    &panelSide,
    clickX := "",
    clickY := ""
) {
    global UpgradePoints
    global UnlockUpgradePattern
    global ConfirmUpgradeUnlockPattern

    if !IsTowerInputActive()
        return "Failed"


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


    if !IsTowerInputActive()
        return "Failed"
    Click(
        X,
        Y
    )


    while A_TickCount < scanDeadline {

        if !IsTowerInputActive()
            return "Failed"

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

            if !IsTowerInputActive()
                return "Failed"
            Click(
                UnlockX,
                UnlockY
            )


            Sleep(
                500
            )


            if !IsTowerInputActive()
                return "Failed"
            SendEscapeAndWait(350)


            panelResult :=
                EnsureUpgradePanelOpen(
                    tower,
                    &panelSide,
                    clickX,
                    clickY,
                    true
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


    if !IsTowerInputActive()
        return "Failed"
    SendEscapeAndWait(350)


    EnsureUpgradePanelOpen(
        tower,
        &panelSide,
        clickX,
        clickY,
        true
    )


    return "Failed"
}

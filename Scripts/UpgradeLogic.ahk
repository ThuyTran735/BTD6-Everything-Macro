#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

global SellButtonPattern := "|<>*160$71.zk0zw3z0Ts1zy01zU1y0zk3zs03y01w1zU7zU07s03s3z0Dz00DU03k7y0Tw00T007UDw1zs3zw0kD0Ts3zk7zs3kC0zk7zU7zkDUQ1zUDzU0D0T0k3z0Tz00C001U7y0zz00Q0030Dw1zz00s00C0zs3zzU1k0zw1zk7zzw3UDzs03U0Dzw30Dzk0700T7k70D7U0C00y00C00D00Q01w00S00y00s03k01w01w01k07U03w03s03U0DU0Tw07kDz1zzk1zy0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

global UnlockUpgradePattern := "|<>FFFFFF-0.90$59.00zzzzzy0001zzzzzw0007zzzzzw000Tzzzzzw000zzzzzzs003zzzzzzs007zzzzzzs00Tzzzzzzk00zzzzzzzk03zzzzzzzk07zzzzzzzU0Tzzzzzzz00zzzzzzzz03zzzzzzzz07zzzzzzzy0Dzzzzzzzw0zzzzzzzzs1zzzzzzzzk3zzzzzzzzV"

global ConfirmUpgradeUnlockPattern := "|<>*154$127.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007zzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"

; Approximate affordable green color.
global UpgradeGreenColor := 0x4FD500


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


UpgradeTower(
    tower,
    target
) {
    global IsPregame


    if (
        !HasProp(
            tower,
            "placed"
        )
        || !tower.placed
    ) {

        return false
    }


    if !HasProp(
        tower,
        "upgrades"
    ) {

        tower.upgrades :=
            [0, 0, 0]
    }


    if StrLen(
        target
    ) != 3 {

        throw Error(
            "Upgrade target must be 3 digits, for example: 025"
        )
    }


    targetTop :=
        Integer(
            SubStr(
                target,
                1,
                1
            )
        )


    targetMiddle :=
        Integer(
            SubStr(
                target,
                2,
                1
            )
        )


    targetBottom :=
        Integer(
            SubStr(
                target,
                3,
                1
            )
        )


    ; Select the tower immediately.
    ;
    ; Do not wait for round OCR before doing this.
    Click(
        tower.x,
        tower.y
    )


    Sleep(
        120
    )


    panelSide :=
        GetUpgradePanelSide()


    if !panelSide {

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
            return false
        }
    }


    while tower.upgrades[1] < targetTop {

        result :=
            WaitForUpgrade(
                tower,
                "Top",
                &panelSide
            )


        if result = "Victory" {
            return "Victory"
        }


        if result = "Defeat" {
            return "Defeat"
        }


        if result = false {
            return false
        }


        buyResult :=
            BuyUpgrade(
                tower,
                "Top",
                &panelSide
            )


        if buyResult = "Victory" {
            return "Victory"
        }


        if buyResult = "Defeat" {
            return "Defeat"
        }


        if buyResult = false {
            return false
        }


        tower.upgrades[1]++


        UpdateTargetingAfterUpgrade(
            tower,
            "Top"
        )
    }


    while tower.upgrades[2] < targetMiddle {

        result :=
            WaitForUpgrade(
                tower,
                "Middle",
                &panelSide
            )


        if result = "Victory" {
            return "Victory"
        }


        if result = "Defeat" {
            return "Defeat"
        }


        if result = false {
            return false
        }


        buyResult :=
            BuyUpgrade(
                tower,
                "Middle",
                &panelSide
            )


        if buyResult = "Victory" {
            return "Victory"
        }


        if buyResult = "Defeat" {
            return "Defeat"
        }


        if buyResult = false {
            return false
        }


        tower.upgrades[2]++


        UpdateTargetingAfterUpgrade(
            tower,
            "Middle"
        )
    }


    while tower.upgrades[3] < targetBottom {

        result :=
            WaitForUpgrade(
                tower,
                "Bottom",
                &panelSide
            )


        if result = "Victory" {
            return "Victory"
        }


        if result = "Defeat" {
            return "Defeat"
        }


        if result = false {
            return false
        }


        buyResult :=
            BuyUpgrade(
                tower,
                "Bottom",
                &panelSide
            )


        if buyResult = "Victory" {
            return "Victory"
        }


        if buyResult = "Defeat" {
            return "Defeat"
        }


        if buyResult = false {
            return false
        }


        tower.upgrades[3]++


        UpdateTargetingAfterUpgrade(
            tower,
            "Bottom"
        )
    }


    Send(
        "{Esc}"
    )


    Sleep(
        200
    )


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


WaitForUpgrade(
    tower,
    path,
    &panelSide
) {
    global UpgradePoints
    global IsPregame


    if !UpgradePoints.Has(
        panelSide
    ) {

        throw Error(
            "Unknown panel side: "
            . panelSide
        )
    }


    if !UpgradePoints[
        panelSide
    ].Has(
        path
    ) {

        throw Error(
            "Unknown upgrade path: "
            . path
        )
    }


    lastStateCheck :=
        A_TickCount


    lastPanelCheck :=
        A_TickCount


    lastRoundHealth :=
        "Readable"


    Loop {

        if !UpgradePoints.Has(
            panelSide
        ) {

            return false
        }


        if !UpgradePoints[
            panelSide
        ].Has(
            path
        ) {

            return false
        }


        point :=
            UpgradePoints[
                panelSide
            ][
                path
            ]


        ; Keep normal upgrade handling first.
        ;
        ; A temporary OCR miss must never delay an
        ; affordable upgrade while this panel exists.
        if IsUpgradeGreen(
            point[1],
            point[2]
        ) {

            lockResult :=
                HandleLockedUpgrade(
                    tower,
                    path,
                    &panelSide
                )


            if lockResult = "Victory" {
                return "Victory"
            }


            if lockResult = "Defeat" {
                return "Defeat"
            }


            if lockResult = "Unlocked" {

                Sleep(
                    150
                )


                continue
            }


            if lockResult = "Failed" {
                return false
            }


            return true
        }


        if !IsPregame {

            if (
                A_TickCount
                - lastStateCheck
                >= 200
            ) {

                lastStateCheck :=
                    A_TickCount


                state :=
                    CheckGameState()


                if state = "Victory" {
                    return "Victory"
                }


                if state = "Defeat" {
                    return "Defeat"
                }


                lastRoundHealth :=
                    CheckRoundReadRecovery()


                if lastRoundHealth = "Recovered" {

                    ; The three fallback clicks will have
                    ; closed the currently selected panel.
                    ;
                    ; Immediately reselect THIS monkey.
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
                        return false
                    }


                    lastRoundHealth :=
                        "Readable"


                    continue
                }
            }
        }


        if (
            A_TickCount
            - lastPanelCheck
            >= 200
        ) {

            lastPanelCheck :=
                A_TickCount


            currentPanelSide :=
                GetUpgradePanelSide()


            if currentPanelSide {

                if currentPanelSide != panelSide {

                    panelSide :=
                        currentPanelSide
                }
            }
            else {

                ; If the round is also missing, an unknown
                ; popup may be covering the screen.
                ;
                ; In that specific case, wait for the
                ; 10-second fallback instead of clicking
                ; random locations behind the popup.
                if (
                    !IsPregame
                    && lastRoundHealth = "Waiting"
                ) {

                    Sleep(
                        10
                    )


                    continue
                }


                ; The game is otherwise normal, so restore
                ; the panel immediately.
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
                    return false
                }


                continue
            }
        }


        Sleep(
            10
        )
    }
}


EnsureUpgradePanelOpen(
    tower,
    &panelSide
) {
    global IsPregame


    currentPanelSide :=
        GetUpgradePanelSide()


    if currentPanelSide {

        panelSide :=
            currentPanelSide


        return true
    }


    ; Fast path.
    ;
    ; This is the important part that fixes the delay:
    ; immediately attempt to select the monkey several
    ; times without waiting for round OCR.
    Loop 3 {

        Click(
            tower.x,
            tower.y
        )


        Sleep(
            120
        )


        currentPanelSide :=
            GetUpgradePanelSide()


        if currentPanelSide {

            panelSide :=
                currentPanelSide


            return true
        }


        if !IsPregame {

            state :=
                CheckGameState()


            if state = "Victory" {
                return "Victory"
            }


            if state = "Defeat" {
                return "Defeat"
            }
        }


        Sleep(
            50
        )
    }


    ; Pregame should not have the unknown mid-match
    ; hero unlock popup.
    if IsPregame {
        return false
    }


    ; Only reach this slower path when several immediate
    ; tower selections failed.
    ;
    ; At this point an interruption may really be
    ; covering the game.
    startTick :=
        A_TickCount


    lastTowerRetry :=
        0


    timeoutMs :=
        12000


    Loop {

        state :=
            CheckGameState()


        if state = "Victory" {
            return "Victory"
        }


        if state = "Defeat" {
            return "Defeat"
        }


        roundHealth :=
            CheckRoundReadRecovery()


        if roundHealth = "Recovered" {

            ; Unknown popup recovery just clicked
            ; 1598,1043 three times.
            ;
            ; Re-select the monkey immediately.
            Click(
                tower.x,
                tower.y
            )


            Sleep(
                120
            )


            currentPanelSide :=
                GetUpgradePanelSide()


            if currentPanelSide {

                panelSide :=
                    currentPanelSide


                return true
            }


            lastTowerRetry :=
                A_TickCount
        }
        else if roundHealth = "Readable" {

            ; No blocking popup is present.
            ;
            ; Retry the monkey quickly.
            if (
                A_TickCount
                - lastTowerRetry
                >= 250
            ) {

                lastTowerRetry :=
                    A_TickCount


                Click(
                    tower.x,
                    tower.y
                )


                Sleep(
                    120
                )


                currentPanelSide :=
                    GetUpgradePanelSide()


                if currentPanelSide {

                    panelSide :=
                        currentPanelSide


                    return true
                }
            }
        }


        ; If roundHealth = "Waiting", do not click
        ; behind a likely unknown popup. The round
        ; recovery timer will clear it after 10 seconds.
        if (
            A_TickCount
            - startTick
            >= timeoutMs
        ) {

            return false
        }


        Sleep(
            80
        )
    }
}


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


    Sleep(
        500
    )


    Loop 20 {

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


        Sleep(
            100
        )
    }


    Send(
        "{Esc}"
    )


    Sleep(
        350
    )


    EnsureUpgradePanelOpen(
        tower,
        &panelSide
    )


    return "Failed"
}


IsUpgradeGreen(
    x,
    y,
    tolerance := 10
) {
    global UpgradeGreenColor


    color :=
        PixelGetColor(
            x,
            y
        )


    r1 :=
        (color >> 16)
        & 0xFF


    g1 :=
        (color >> 8)
        & 0xFF


    b1 :=
        color
        & 0xFF


    r2 :=
        (UpgradeGreenColor >> 16)
        & 0xFF


    g2 :=
        (UpgradeGreenColor >> 8)
        & 0xFF


    b2 :=
        UpgradeGreenColor
        & 0xFF


    return (
        Abs(r1 - r2) <= tolerance
        && Abs(g1 - g2) <= tolerance
        && Abs(b1 - b2) <= tolerance
    )
}


BuyUpgrade(
    tower,
    path,
    &panelSide
) {
    global UpgradeHotkeys


    if !UpgradeHotkeys.Has(
        path
    ) {

        throw Error(
            "Unknown upgrade path: "
            . path
        )
    }


    ; Usually this returns immediately because the panel
    ; is already open. It only performs recovery if the
    ; panel disappeared between waiting and buying.
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
        return false
    }


    Send(
        UpgradeHotkeys[
            path
        ]
    )


    Sleep(
        200
    )


    return true
}


UpdateTargetingAfterUpgrade(
    tower,
    upgradedPath
) {
    global EliteSniperActive


    if tower.type = "Sniper" {

        if (
            upgradedPath = "Middle"
            && tower.upgrades[2] = 5
        ) {

            EliteSniperActive :=
                true


            tower.targeting :=
                "Elite"
        }
    }


    if tower.type = "Ace" {

        if (
            upgradedPath = "Bottom"
            && tower.upgrades[3] = 2
        ) {

            tower.targeting :=
                "Centered Path"
        }
    }


    return true
}
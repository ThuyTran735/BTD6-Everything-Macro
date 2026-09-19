#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

global SellButtonPattern := "|<>*160$71.zk0zw3z0Ts1zy01zU1y0zk3zs03y01w1zU7zU07s03s3z0Dz00DU03k7y0Tw00T007UDw1zs3zw0kD0Ts3zk7zs3kC0zk7zU7zkDUQ1zUDzU0D0T0k3z0Tz00C001U7y0zz00Q0030Dw1zz00s00C0zs3zzU1k0zw1zk7zzw3UDzs03U0Dzw30Dzk0700T7k70D7U0C00y00C00D00Q01w00S00y00s03k01w01w01k07U03w03s03U0DU0Tw07kDz1zzk1zy0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

global UnlockUpgradePattern := "|<>FFFFFF-0.90$59.00zzzzzy0001zzzzzw0007zzzzzw000Tzzzzzw000zzzzzzs003zzzzzzs007zzzzzzs00Tzzzzzzk00zzzzzzzk03zzzzzzzk07zzzzzzzU0Tzzzzzzz00zzzzzzzz03zzzzzzzz07zzzzzzzy0Dzzzzzzzw0zzzzzzzzs1zzzzzzzzk3zzzzzzzzV"

global ConfirmUpgradeUnlockPattern := "|<>*154$127.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007zzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"

; Approximate affordable green color.
global UpgradeGreenColor := 0x4FD500

; Deflation pregame should never stall forever waiting for an upgrade.
global DeflationUpgradeWaitTimeoutMs := 5000


; Tracks the tower whose upgrade panel is intentionally left open between
; strategy actions. Reusing this selection avoids redundant monkey clicks
; when multiple upgrades target the same tower on later rounds.
global SelectedUpgradeTower := false
global SelectedUpgradePanelSide := false


ClearSelectedUpgradeTower() {
    global SelectedUpgradeTower
    global SelectedUpgradePanelSide

    SelectedUpgradeTower := false
    SelectedUpgradePanelSide := false

    return true
}


CloseCachedUpgradePanel() {
    global SelectedUpgradeTower

    ; We intentionally leave the panel open after an upgrade so the same
    ; monkey can be reused. Before a placement action, close that panel
    ; first so its Sell button/panel cannot be mistaken for the new tower.
    if IsObject(SelectedUpgradeTower) {
        Send("{Esc}")
        Sleep(25)
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

        return SetRunFailureReason("UPGRADE FAILED", "Tower has not been placed")
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


    ; Reuse an already-selected monkey whenever its upgrade panel was
    ; intentionally left open by the previous strategy action.
    panelSide := false


    if !TryReuseSelectedUpgradeTower(
        tower,
        &panelSide
    ) {

        Click(
            tower.x,
            tower.y
        )


        Sleep(
            IsFastDeflationPregameUpgrade() ? 25 : 35
        )


        ; Start affordability polling immediately after selection.
        ; The saved tower X position reliably predicts the normal panel side,
        ; and WaitForUpgrade() can still correct it later if needed. Avoiding
        ; a full-screen FindText here makes the first upgrade start faster.
        panelSide :=
            GetExpectedUpgradePanelSide(tower)


        CacheSelectedUpgradeTower(
            tower,
            panelSide
        )
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


        if result = "DeflationTimeout" {
            ; In Deflation pregame, an unavailable upgrade should not
            ; block the rest of the setup. Close the panel and let the
            ; next scripted action run.
            Send("{Esc}")
            ClearSelectedUpgradeTower()
            Sleep(45)
            return true
        }


        if result = false {
            return SetRunFailureReason("UPGRADE FAILED", "Could not afford or detect Top path upgrade")
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
            return SetRunFailureReason("UPGRADE FAILED", "Failed to buy Top path upgrade")
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


        if result = "DeflationTimeout" {
            ; In Deflation pregame, an unavailable upgrade should not
            ; block the rest of the setup. Close the panel and let the
            ; next scripted action run.
            Send("{Esc}")
            ClearSelectedUpgradeTower()
            Sleep(45)
            return true
        }


        if result = false {
            return SetRunFailureReason("UPGRADE FAILED", "Could not afford or detect Middle path upgrade")
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
            return SetRunFailureReason("UPGRADE FAILED", "Failed to buy Middle path upgrade")
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


        if result = "DeflationTimeout" {
            ; In Deflation pregame, an unavailable upgrade should not
            ; block the rest of the setup. Close the panel and let the
            ; next scripted action run.
            Send("{Esc}")
            ClearSelectedUpgradeTower()
            Sleep(45)
            return true
        }


        if result = false {
            return SetRunFailureReason("UPGRADE FAILED", "Could not afford or detect Bottom path upgrade")
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
            return SetRunFailureReason("UPGRADE FAILED", "Failed to buy Bottom path upgrade")
        }


        tower.upgrades[3]++


        UpdateTargetingAfterUpgrade(
            tower,
            "Bottom"
        )
    }


    ; Leave this tower selected so a later UpgradeTower() call for the
    ; same monkey can immediately reuse the open upgrade panel.
    CacheSelectedUpgradeTower(
        tower,
        panelSide
    )


    return true
}


GetExpectedUpgradePanelSide(tower) {
    if !HasProp(tower, "x") {
        return false
    }


    ; BTD6 places the upgrade panel on the opposite side of the selected
    ; monkey so it does not cover the tower itself. Using the saved X
    ; coordinate avoids an expensive full-screen FindText scan on every
    ; normal upgrade selection.
    return tower.x < A_ScreenWidth // 2
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


WaitForUpgrade(
    tower,
    path,
    &panelSide
) {
    global UpgradePoints
    global IsPregame
    global RunConfig
    global DeflationUpgradeWaitTimeoutMs


    waitStartTick := A_TickCount


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


        ; Keep the normal purchase path as fast as possible.
        ;
        ; Once the upgrade is green, return immediately so BuyUpgrade()
        ; can send the comma/period/slash hotkey without first running
        ; any FindText-based unlock detection. Locked-upgrade recovery
        ; now happens only if the post-hotkey button signature does not
        ; change.
        if IsUpgradeGreen(
            point[1],
            point[2]
        ) {
            return true
        }


        if (
            !IsPregame
            && A_TickCount - waitStartTick >= 300
        ) {

            if (
                A_TickCount
                - lastStateCheck
                >= 70
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
                    CheckRoundReadRecovery(650)


                if lastRoundHealth = "Recovered" {

                    ; The five fallback clicks will have
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
            A_TickCount - waitStartTick >= 300
            && A_TickCount
            - lastPanelCheck
            >= (IsFastDeflationPregameUpgrade() ? 75 : 100)
        ) {

            lastPanelCheck :=
                A_TickCount


            ; Sell-button detection is advisory only. FindText can miss
            ; while the upgrade panel is actually open, so never reselect
            ; the monkey solely because this scan returned false.
            currentPanelSide :=
                GetUpgradePanelSide()


            if currentPanelSide {

                if currentPanelSide != panelSide {
                    panelSide :=
                        currentPanelSide
                }


                CacheSelectedUpgradeTower(
                    tower,
                    panelSide
                )
            }
        }


        ; Deflation begins with a fixed amount of cash. If a scripted
        ; pregame upgrade is not obtainable, do not wait forever. After
        ; 5000 ms, skip the rest of this UpgradeTower action and allow
        ; the strategy to continue toward StartGame().
        if (
            IsPregame
            && RunConfig.gameMode = "Deflation"
            && A_TickCount - waitStartTick >= DeflationUpgradeWaitTimeoutMs
        ) {
            LogMessage(
                "WARN",
                "Deflation upgrade timed out after "
                . DeflationUpgradeWaitTimeoutMs
                . " ms; skipping this upgrade action"
            )

            return "DeflationTimeout"
        }


        Sleep(
            IsFastDeflationPregameUpgrade() ? 5 : 10
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


        CacheSelectedUpgradeTower(
            tower,
            panelSide
        )


        return true
    }


    ; Selection is no longer confirmed. Recovery will cache it again
    ; immediately after the correct panel is found.
    ClearSelectedUpgradeTower()


    ; A level-up screen can appear just after the
    ; first-time balloon info screen is dismissed.
    ; Clear it before any click tries to reselect the tower.
    if !IsPregame {

        ; One immediate popup check only. Never block the normal monkey
        ; selection path for the old 2500 ms level-up timeout.
        WaitForLevelUpAfterNewBloon(0)
    }


    ; Fast path.
    ;
    ; This is the important part that fixes the delay:
    ; immediately attempt to select the monkey several
    ; times without waiting for round OCR.
    Loop 3 {

        if !IsPregame {

            WaitForLevelUpAfterNewBloon(0)
        }

        Click(
            tower.x,
            tower.y
        )


        Sleep(
            IsFastDeflationPregameUpgrade() ? 25 : 35
        )


        currentPanelSide :=
            GetUpgradePanelSide()


        if currentPanelSide {

            panelSide :=
                currentPanelSide


            CacheSelectedUpgradeTower(
                tower,
                panelSide
            )


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
            IsFastDeflationPregameUpgrade() ? 10 : 15
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


        WaitForLevelUpAfterNewBloon(100)


        roundHealth :=
            CheckRoundReadRecovery(650)


        if roundHealth = "Recovered" {

            ; Unknown popup recovery just clicked
            ; 1598,1043 five times.
            ;
            ; Re-select the monkey immediately.
            Click(
                tower.x,
                tower.y
            )


            Sleep(
                55
            )


            currentPanelSide :=
                GetUpgradePanelSide()


            if currentPanelSide {

                panelSide :=
                    currentPanelSide


                CacheSelectedUpgradeTower(
                    tower,
                    panelSide
                )


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
                >= 70
            ) {

                lastTowerRetry :=
                    A_TickCount


                Click(
                    tower.x,
                    tower.y
                )


                Sleep(
                    55
                )


                currentPanelSide :=
                    GetUpgradePanelSide()


                if currentPanelSide {

                    panelSide :=
                        currentPanelSide


                    CacheSelectedUpgradeTower(
                        tower,
                        panelSide
                    )


                    return true
                }
            }
        }


        ; If roundHealth = "Waiting", do not click
        ; behind a likely unknown popup. The round
        ; recovery timer will clear it after the configured recovery delay.
        if (
            A_TickCount
            - startTick
            >= timeoutMs
        ) {

            return false
        }


        Sleep(
            25
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


        Sleep(
            100
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
    global UpgradePoints


    if !UpgradeHotkeys.Has(
        path
    ) {

        throw Error(
            "Unknown upgrade path: "
            . path
        )
    }


    if (
        !UpgradePoints.Has(panelSide)
        || !UpgradePoints[panelSide].Has(path)
    ) {
        return false
    }


    point :=
        UpgradePoints[panelSide][path]


    ; Capture a tiny visual signature before the purchase. This is cheap
    ; compared with FindText and lets the common path send the hotkey
    ; immediately.
    beforeSignature :=
        CaptureUpgradeButtonSignature(
            point[1],
            point[2]
        )


    Send(
        UpgradeHotkeys[
            path
        ]
    )


    ; Intentionally 35 ms slower than the previous 100 ms hotkey settle.
    ; The first hotkey now starts sooner, while consecutive upgrade presses
    ; are spaced out a little more for reliability.
    Sleep(
        135
    )


    afterSignature :=
        CaptureUpgradeButtonSignature(
            point[1],
            point[2]
        )


    if afterSignature != beforeSignature {
        return true
    }


    ; The button did not visibly change. Only now pay the cost of the
    ; locked-upgrade FindText recovery path. Normal successful purchases
    ; never reach this scan.
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


    if lockResult = "Failed" {
        return false
    }


    if lockResult = "Unlocked" {
        ; The unlock flow re-opened this tower's panel. Purchase the
        ; originally requested upgrade once, then use the same 135 ms
        ; hotkey settle.
        Send(
            UpgradeHotkeys[
                path
            ]
        )


        Sleep(
            135
        )


        return true
    }


    ; If no lock was found, trust the original hotkey. A successful buy can
    ; occasionally leave sampled pixels unchanged when the next tier uses a
    ; very similar button state; sending the key a second time could purchase
    ; an unintended extra tier.
    return true
}


CaptureUpgradeButtonSignature(
    x,
    y
) {
    offsets := [
        [-48, -18], [-24, -18], [0, -18], [24, -18], [48, -18],
        [-48, 0],   [-24, 0],   [0, 0],   [24, 0],   [48, 0],
        [-48, 18],  [-24, 18],  [0, 18],  [24, 18],  [48, 18]
    ]


    signature :=
        ""


    for offset in offsets {
        sampleX :=
            Max(
                0,
                Min(
                    A_ScreenWidth - 1,
                    x + offset[1]
                )
            )


        sampleY :=
            Max(
                0,
                Min(
                    A_ScreenHeight - 1,
                    y + offset[2]
                )
            )


        signature .=
            Format(
                "{:06X}",
                PixelGetColor(
                    sampleX,
                    sampleY
                ) & 0xFFFFFF
            )
    }


    return signature
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
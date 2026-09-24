#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

global SellButtonPattern := "|<>*160$71.zk0zw3z0Ts1zy01zU1y0zk3zs03y01w1zU7zU07s03s3z0Dz00DU03k7y0Tw00T007UDw1zs3zw0kD0Ts3zk7zs3kC0zk7zU7zkDUQ1zUDzU0D0T0k3z0Tz00C001U7y0zz00Q0030Dw1zz00s00C0zs3zzU1k0zw1zk7zzw3UDzs03U0Dzw30Dzk0700T7k70D7U0C00y00C00D00Q01w00S00y00s03k01w01w01k07U03w03s03U0DU0Tw07kDz1zzk1zy0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

global UnlockUpgradePattern := "|<>FFFFFF-0.90$59.00zzzzzy0001zzzzzw0007zzzzzw000Tzzzzzw000zzzzzzs003zzzzzzs007zzzzzzs00Tzzzzzzk00zzzzzzzk03zzzzzzzk07zzzzzzzU0Tzzzzzzz00zzzzzzzz03zzzzzzzz07zzzzzzzy0Dzzzzzzzw0zzzzzzzzs1zzzzzzzzk3zzzzzzzzV"

global ConfirmUpgradeUnlockPattern := "|<>*154$127.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007zzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"

; Approximate affordable green color.
global UpgradeGreenColor := 0x4FD500

; Keep consecutive upgrade hotkeys at least 250 ms apart. This is a total
; hotkey-to-hotkey spacing budget, so the 50 ms visual settle and any
; verification work performed after a purchase count toward the same window.
global UpgradePurchaseSpacingMs := 250
global LastUpgradePurchaseTick := 0

; Deflation pregame should never stall forever waiting for an upgrade.
global DeflationUpgradeWaitTimeoutMs := 5000


; Tracks the tower whose upgrade panel is intentionally left open between
; strategy actions. Reusing this selection avoids redundant monkey clicks
; when multiple upgrades target the same tower on later rounds.
global SelectedUpgradeTower := false
global SelectedUpgradePanelSide := false


GetUpgradeTowerLogName(tower) {
    global TowerSetup

    try {
        for towerName, configuredTower in TowerSetup {
            if (
                IsObject(configuredTower)
                && ObjPtr(configuredTower) = ObjPtr(tower)
            ) {
                return towerName
            }
        }
    }

    try {
        if HasProp(tower, "type") {
            return tower.type
        }
    }

    return "Unknown Tower"
}


CreateUpgradeActionTiming(tower, target) {
    global CurrentStrategyTargetRound
    global CurrentStrategyRoundDetectedTick
    global CurrentStrategyRoundDetectedTimestamp

    roundTick := CurrentStrategyRoundDetectedTick
    roundTimestamp := CurrentStrategyRoundDetectedTimestamp

    if !roundTick {
        roundTick := A_TickCount
        roundTimestamp := GetLogTimestampMs()
    }

    return {
        towerName: GetUpgradeTowerLogName(tower),
        target: target,
        targetRound: CurrentStrategyTargetRound,
        roundTick: roundTick,
        roundTimestamp: roundTimestamp,
        selectedTick: 0,
        selectedTimestamp: "",
        selectionReused: false,
        firstGreenTick: 0,
        firstGreenTimestamp: "",
        firstHotkeyTick: 0,
        firstHotkeyTimestamp: "",
        finalConfirmedTick: 0,
        finalConfirmedTimestamp: "",
        stepCount: 0
    }
}


MarkUpgradeMonkeySelected(timing, reused := false) {
    if !IsObject(timing) {
        return
    }

    timing.selectedTick := A_TickCount
    timing.selectedTimestamp := GetLogTimestampMs()
    timing.selectionReused := reused
}


BeginUpgradeStepTiming(actionTiming, path, level) {
    if !IsObject(actionTiming) {
        return false
    }

    actionTiming.stepCount++

    return {
        action: actionTiming,
        path: path,
        level: level,
        greenTick: 0,
        greenTimestamp: "",
        hotkeyTick: 0,
        hotkeyTimestamp: "",
        confirmedTick: 0,
        confirmedTimestamp: ""
    }
}


MarkUpgradeGreen(timingStep) {
    if !IsObject(timingStep) || timingStep.greenTick {
        return
    }

    timingStep.greenTick := A_TickCount
    timingStep.greenTimestamp := GetLogTimestampMs()

    actionTiming := timingStep.action
    if IsObject(actionTiming) && !actionTiming.firstGreenTick {
        actionTiming.firstGreenTick := timingStep.greenTick
        actionTiming.firstGreenTimestamp := timingStep.greenTimestamp
    }
}


MarkUpgradeHotkey(timingStep) {
    if !IsObject(timingStep) {
        return
    }

    timingStep.hotkeyTick := A_TickCount
    timingStep.hotkeyTimestamp := GetLogTimestampMs()

    actionTiming := timingStep.action
    if IsObject(actionTiming) && !actionTiming.firstHotkeyTick {
        actionTiming.firstHotkeyTick := timingStep.hotkeyTick
        actionTiming.firstHotkeyTimestamp := timingStep.hotkeyTimestamp
    }
}


MarkUpgradeConfirmed(timingStep) {
    if !IsObject(timingStep) {
        return
    }

    timingStep.confirmedTick := A_TickCount
    timingStep.confirmedTimestamp := GetLogTimestampMs()

    actionTiming := timingStep.action
    if IsObject(actionTiming) {
        actionTiming.finalConfirmedTick := timingStep.confirmedTick
        actionTiming.finalConfirmedTimestamp := timingStep.confirmedTimestamp
    }
}


UpgradeTimingDelta(fromTick, toTick) {
    if !fromTick || !toTick {
        return "n/a"
    }

    return (toTick - fromTick) . "ms"
}


LogUpgradeStepTiming(timingStep, outcome := "Confirmed") {
    if !IsObject(timingStep) {
        return
    }

    actionTiming := timingStep.action
    if !IsObject(actionTiming) {
        return
    }

    LogMessage(
        "TIMING",
        "Upgrade step | "
        . actionTiming.towerName
        . " target "
        . actionTiming.target
        . " | "
        . timingStep.path
        . " "
        . timingStep.level
        . " | green="
        . (timingStep.greenTimestamp != "" ? timingStep.greenTimestamp : "n/a")
        . " | hotkey="
        . (timingStep.hotkeyTimestamp != "" ? timingStep.hotkeyTimestamp : "n/a")
        . " | confirmed="
        . (timingStep.confirmedTimestamp != "" ? timingStep.confirmedTimestamp : "n/a")
        . " | green->hotkey="
        . UpgradeTimingDelta(timingStep.greenTick, timingStep.hotkeyTick)
        . " | hotkey->confirm="
        . UpgradeTimingDelta(timingStep.hotkeyTick, timingStep.confirmedTick)
        . " | outcome="
        . outcome
    )
}


LogUpgradeActionTiming(timing, outcome := "Success") {
    if !IsObject(timing) {
        return
    }

    selectionLabel := timing.selectionReused
        ? timing.selectedTimestamp . " (cached)"
        : timing.selectedTimestamp

    LogMessage(
        "TIMING",
        timing.towerName
        . " "
        . timing.target
        . " | round "
        . timing.targetRound
        . " detected="
        . timing.roundTimestamp
        . " | monkey selected="
        . (selectionLabel != "" ? selectionLabel : "n/a")
        . " | first green="
        . (timing.firstGreenTimestamp != "" ? timing.firstGreenTimestamp : "n/a")
        . " | first hotkey="
        . (timing.firstHotkeyTimestamp != "" ? timing.firstHotkeyTimestamp : "n/a")
        . " | final confirmed="
        . (timing.finalConfirmedTimestamp != "" ? timing.finalConfirmedTimestamp : "n/a")
        . " | round->select="
        . UpgradeTimingDelta(timing.roundTick, timing.selectedTick)
        . " | select->green="
        . UpgradeTimingDelta(timing.selectedTick, timing.firstGreenTick)
        . " | green->hotkey="
        . UpgradeTimingDelta(timing.firstGreenTick, timing.firstHotkeyTick)
        . " | hotkey->confirm="
        . UpgradeTimingDelta(timing.firstHotkeyTick, timing.finalConfirmedTick)
        . " | total="
        . UpgradeTimingDelta(timing.roundTick, timing.finalConfirmedTick)
        . " | steps="
        . timing.stepCount
        . " | outcome="
        . outcome
    )
}


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
    ; monkey can be reused. Before a placement action, close that panel
    ; first so its Sell button/panel cannot be mistaken for the new tower.
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


    upgradeTiming :=
        CreateUpgradeActionTiming(
            tower,
            target
        )


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


    if TryReuseSelectedUpgradeTower(
        tower,
        &panelSide
    ) {

        MarkUpgradeMonkeySelected(
            upgradeTiming,
            true
        )
    }
    else {

        Click(
            tower.x,
            tower.y
        )


        Sleep(
            IsFastDeflationPregameUpgrade() ? 25 : 35
        )


        MarkUpgradeMonkeySelected(
            upgradeTiming
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

        stepTiming :=
            BeginUpgradeStepTiming(
                upgradeTiming,
                "Top",
                tower.upgrades[1] + 1
            )


        result :=
            WaitForUpgrade(
                tower,
                "Top",
                &panelSide,
                stepTiming
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
                &panelSide,
                stepTiming
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

        stepTiming :=
            BeginUpgradeStepTiming(
                upgradeTiming,
                "Middle",
                tower.upgrades[2] + 1
            )


        result :=
            WaitForUpgrade(
                tower,
                "Middle",
                &panelSide,
                stepTiming
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
                &panelSide,
                stepTiming
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

        stepTiming :=
            BeginUpgradeStepTiming(
                upgradeTiming,
                "Bottom",
                tower.upgrades[3] + 1
            )


        result :=
            WaitForUpgrade(
                tower,
                "Bottom",
                &panelSide,
                stepTiming
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
                &panelSide,
                stepTiming
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


    LogUpgradeActionTiming(
        upgradeTiming
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
    &panelSide,
    timingStep := false
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


    ; Affordability is the hot path. Keep it completely free of FindText,
    ; round OCR, popup recovery, and panel-side scans so a green upgrade
    ; can trigger its hotkey within a few milliseconds instead of waiting
    ; for an unrelated full-screen scan to finish.
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


        if IsUpgradeGreen(
            point[1],
            point[2]
        ) {
            MarkUpgradeGreen(timingStep)
            CacheSelectedUpgradeTower(tower, panelSide)
            return true
        }


        ; The tower-X heuristic is only a fast guess. Towers near the middle
        ; of the map can open their upgrade panel on the opposite side from
        ; that guess (for example Skywarden on Monkey Meadow). Probe the
        ; other calibrated affordability pixel too. This is only one extra
        ; PixelGetColor per 5 ms loop and avoids any FindText scan.
        otherSide := panelSide = "Left" ? "Right" : "Left"


        if (
            UpgradePoints.Has(otherSide)
            && UpgradePoints[otherSide].Has(path)
        ) {
            otherPoint := UpgradePoints[otherSide][path]


            if IsUpgradeGreen(
                otherPoint[1],
                otherPoint[2]
            ) {
                panelSide := otherSide
                CacheSelectedUpgradeTower(tower, panelSide)
                MarkUpgradeGreen(timingStep)
                return true
            }
        }


        ; Deflation begins with a fixed amount of cash. If a scripted
        ; pregame upgrade is not obtainable, do not wait forever.
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


        ; A small button-area PixelSearch is cheap enough to poll quickly.
        ; Five milliseconds keeps CPU usage reasonable while making the
        ; visible-green -> hotkey delay effectively immediate.
        Sleep(5)
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


IsUpgradeGreen(
    x,
    y,
    tolerance := 12
) {
    global UpgradeGreenColor


    ; Use the calibrated affordability pixel directly. This is the same
    ; signal the original upgrade logic relied on, but it is now polled by
    ; the lightweight 5 ms wait loop instead of being surrounded by slow
    ; full-screen scans.
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


WaitForUpgradePurchaseSlot() {
    global UpgradePurchaseSpacingMs
    global LastUpgradePurchaseTick

    if LastUpgradePurchaseTick <= 0 {
        return
    }

    elapsed := A_TickCount - LastUpgradePurchaseTick
    remaining := UpgradePurchaseSpacingMs - elapsed

    if remaining > 0 {
        Sleep(remaining)
    }
}


MarkUpgradePurchaseSent() {
    global LastUpgradePurchaseTick

    LastUpgradePurchaseTick := A_TickCount
}


BuyUpgrade(
    tower,
    path,
    &panelSide,
    timingStep := false
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


    ; Enforce the configured hotkey-to-hotkey spacing first. The button may
    ; have briefly appeared green during the previous tier's purchase
    ; animation, so always re-confirm affordability after the spacing wait
    ; and immediately before sending the next upgrade hotkey.
    WaitForUpgradePurchaseSlot()


    if !IsUpgradeGreen(
        point[1],
        point[2]
    ) {
        waitResult :=
            WaitForUpgrade(
                tower,
                path,
                &panelSide,
                timingStep
            )


        if (
            waitResult = "Victory"
            || waitResult = "Defeat"
            || waitResult = "DeflationTimeout"
            || waitResult = false
        ) {
            return waitResult
        }


        ; Panel-side recovery can update the point used for this path.
        if (
            !UpgradePoints.Has(panelSide)
            || !UpgradePoints[panelSide].Has(path)
        ) {
            return false
        }


        point := UpgradePoints[panelSide][path]
    }


    ; Capture the button immediately before the hotkey so the confirmation
    ; compares the actual pre-purchase state, not a stale animation frame.
    beforeSignature :=
        CaptureUpgradeButtonSignature(
            point[1],
            point[2]
        )


    MarkUpgradeHotkey(timingStep)


    Send(
        UpgradeHotkeys[
            path
        ]
    )


    MarkUpgradePurchaseSent()


    ; Keep upgrade hotkeys fast while leaving a short settle window for
    ; the game to register each comma/period/slash purchase.
    Sleep(
        50
    )


    afterSignature :=
        CaptureUpgradeButtonSignature(
            point[1],
            point[2]
        )


    if afterSignature = beforeSignature {
        ; Some upgrade panels update a little later than the 50 ms key settle.
        ; Give the button one more cheap visual check. This remains inside the
        ; existing 250 ms hotkey-to-hotkey spacing window.
        Sleep(40)

        afterSignature :=
            CaptureUpgradeButtonSignature(
                point[1],
                point[2]
            )
    }


    if afterSignature != beforeSignature {
        MarkUpgradeConfirmed(timingStep)
        LogUpgradeStepTiming(timingStep)
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
        LogUpgradeStepTiming(timingStep, "Victory")
        return "Victory"
    }


    if lockResult = "Defeat" {
        LogUpgradeStepTiming(timingStep, "Defeat")
        return "Defeat"
    }


    if lockResult = "Failed" {
        LogUpgradeStepTiming(timingStep, "Failed")
        return false
    }


    if lockResult = "Unlocked" {
        ; The unlock flow re-opened this tower's panel. Purchase the
        ; originally requested upgrade once, then use the same 50 ms
        ; hotkey settle.
        WaitForUpgradePurchaseSlot()


        MarkUpgradeHotkey(timingStep)


        Send(
            UpgradeHotkeys[
                path
            ]
        )


        MarkUpgradePurchaseSent()


        Sleep(
            50
        )


        MarkUpgradeConfirmed(timingStep)
        LogUpgradeStepTiming(timingStep, "ConfirmedAfterUnlock")


        return true
    }


    ; If no lock was found, trust the original hotkey. A successful buy can
    ; occasionally leave sampled pixels unchanged when the next tier uses a
    ; very similar button state; sending the key a second time could purchase
    ; an unintended extra tier.
    MarkUpgradeConfirmed(timingStep)
    LogUpgradeStepTiming(timingStep, "AssumedConfirmed")
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


    ; Buying Pursuit (2xx) automatically switches a Heli Pilot to Pursuit.
    ; Keep our stored targeting state synchronized so a later
    ; LockHeliInPlace() knows how many targeting steps are needed.
    if tower.type = "Heli" {

        if (
            upgradedPath = "Top"
            && tower.upgrades[1] = 2
        ) {

            tower.targeting :=
                "Pursuit"
        }
    }


    return true
}
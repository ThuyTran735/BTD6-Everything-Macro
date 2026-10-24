#Requires AutoHotkey v2.0

; Polls affordability while keeping defeat, victory, and panel recovery checks alive.
; Cheap green-pixel checks run often; heavier screen scans are spaced out independently.

WaitForUpgrade(
    tower,
    path,
    &panelSide,
    timingStep := false,
    clickX := "",
    clickY := ""
) {
    global UpgradePoints
    global IsPregame
    global RunConfig
    global DeflationUpgradeWaitTimeoutMs


    waitStartTick := A_TickCount


    ; Keep terminal-state detection alive while waiting for cash without
    ; repeatedly running the much heavier CheckGameState() popup scans.
    ; Fast/affordable upgrades get a short grace period with zero FindText
    ; work, then defeat is checked frequently and victory less often.
    lastDefeatCheck := A_TickCount
    lastVictoryCheck := A_TickCount
    lastRoundTrackCheck := A_TickCount
    lastPanelCheck := A_TickCount
    missingPanelChecks := 0


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


    ; Affordability is the hot path. Check it first on every loop so a green
    ; upgrade can trigger its hotkey within a few milliseconds. Expensive
    ; game-state scans are throttled separately below while we are still
    ; waiting for the upgrade to become affordable.
    Loop {

        if !IsTowerInputActive()
            return false

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


        if !IsPregame {
            waitedMs := A_TickCount - waitStartTick


            ; Long cash waits can span multiple rounds. Keep the lightweight
            ; round OCR tracker current after the fast 750 ms grace period so
            ; the strategy never needs to make a dangerous multi-round catch-up
            ; after the upgrade finally becomes affordable.
            if (
                waitedMs >= 750
                && A_TickCount - lastRoundTrackCheck >= 500
            ) {
                lastRoundTrackCheck := A_TickCount
                GetValidatedRoundForStrategy()
            }


            ; Do not interrupt quick upgrade chains with any full-screen
            ; FindText work. If we are genuinely waiting for cash, keep
            ; defeat detection responsive with one pattern instead of the
            ; five-pattern CheckGameState() scan.
            if (
                waitedMs >= 750
                && A_TickCount - lastDefeatCheck >= 500
            ) {
                lastDefeatCheck := A_TickCount


                if IsUpgradeWaitDefeatVisible() {
                    return "Defeat"
                }
            }


            ; Victory while blocked on an upgrade is uncommon, so check it
            ; less often to keep the affordability hot path fast.
            if (
                waitedMs >= 1000
                && A_TickCount - lastVictoryCheck >= 1000
            ) {
                lastVictoryCheck := A_TickCount


                if IsUpgradeWaitVictoryVisible() {
                    return "Victory"
                }
            }
        }


        ; A missed click or popup can leave the green-pixel wait with no panel.
        ; Keep this scan off the fast path and require two consecutive misses
        ; so one animation frame cannot cause an unnecessary reselection.
        if A_TickCount - lastPanelCheck >= 1000 {
            lastPanelCheck := A_TickCount
            detectedSide := GetUpgradePanelSide()
            if !IsTowerInputActive()
                return false
            if detectedSide {
                panelSide := detectedSide
                missingPanelChecks := 0
            }
            else {
                missingPanelChecks++
                if missingPanelChecks >= 2 {
                    panelResult := EnsureUpgradePanelOpen(tower, &panelSide, clickX, clickY)
                    if panelResult != true
                        return panelResult
                    missingPanelChecks := 0
                    lastPanelCheck := A_TickCount
                }
            }
        }

        ; A small button-area PixelSearch is cheap enough to poll quickly.
        ; Five milliseconds keeps CPU usage reasonable while making the
        ; visible-green -> hotkey delay effectively immediate.
        Sleep(5)
    }
}


EnsureUpgradePanelOpen(
    tower,
    &panelSide,
    clickX := "",
    clickY := "",
    forceReselect := false
) {
    global IsPregame

    if (clickX = "") != (clickY = "")
        return false
    if clickX = "" {
        clickX := tower.x
        clickY := tower.y
    }
    if !IsTowerInputActive()
        return false

    ; Ordinary recovery may reuse a visible panel. A fresh UpgradeTower action
    ; must click its requested coordinates before accepting any panel.
    if !forceReselect {
        currentPanelSide := GetUpgradePanelSide()
        if !IsTowerInputActive()
            return false
        if currentPanelSide {
            panelSide := currentPanelSide
            return true
        }
    }

    recoveryDeadline := A_TickCount + 12000
    Loop 3 {
        if !IsTowerInputActive()
            return false
        ; The last click may finish rendering while popup recovery is running.
        ; Only the first forced attempt must click before accepting a panel.
        if A_Index > 1 {
            currentPanelSide := GetUpgradePanelSide()
            if !IsTowerInputActive()
                return false
            if currentPanelSide {
                panelSide := currentPanelSide
                return true
            }
        }
        if !IsPregame
            WaitForLevelUpAfterNewBloon(0)
        if !IsTowerInputActive()
            return false
        if !ClickTowerPoint(clickX, clickY)
            return false

        ; Wait for rendering before another click. Repeated clicks during the
        ; same delayed frame can close the panel just as it finally opens.
        Loop 3 {
            Sleep(150)
            if !IsTowerInputActive()
                return false
            currentPanelSide := GetUpgradePanelSide()
            if !IsTowerInputActive()
                return false
            if currentPanelSide {
                panelSide := currentPanelSide
                return true
            }
        }

        if IsPregame {
            if A_Index = 3
                return false
            continue
        }

        ; Keep known overlays and terminal states responsive after a failed
        ; selection. Unknown-popup recovery is bounded, and never adds extra
        ; tower clicks beyond the three attempts above.
        state := CheckGameState()
        if state = "Victory" || state = "Defeat"
            return state
        if !IsTowerInputActive()
            return false
        if A_Index = 3
            return false

        while A_TickCount < recoveryDeadline {
            if !IsTowerInputActive()
                return false
            WaitForLevelUpAfterNewBloon(100)
            if !IsTowerInputActive()
                return false
            roundHealth := CheckRoundReadRecovery(650)
            if !IsTowerInputActive()
                return false
            if roundHealth = "Recovered" || roundHealth = "Readable"
                break

            Sleep(150)
            if !IsTowerInputActive()
                return false
            state := CheckGameState()
            if state = "Victory" || state = "Defeat"
                return state
        }
        if A_TickCount >= recoveryDeadline
            return false
    }
    return false
}

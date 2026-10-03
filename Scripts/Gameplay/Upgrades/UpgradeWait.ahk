#Requires AutoHotkey v2.0

; v3 file note: Waits for an upgrade to become buyable and makes sure the right panel is open.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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


    ; Keep terminal-state detection alive while waiting for cash without
    ; repeatedly running the much heavier CheckGameState() popup scans.
    ; Fast/affordable upgrades get a short grace period with zero FindText
    ; work, then defeat is checked frequently and victory less often.
    lastDefeatCheck := A_TickCount
    lastVictoryCheck := A_TickCount
    lastRoundTrackCheck := A_TickCount


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



#Requires AutoHotkey v2.0

; v3 file note: Runs the main UpgradeTower flow and decides what still needs to be bought.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

UpgradeTower(
    tower,
    target,
    overrideX := "",
    overrideY := ""
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


    LogStrategyAction(
        "Upgrade "
        . GetTowerLogName(tower)
        . " -> "
        . target
    )


    hasCoordinateOverride :=
        overrideX != ""
        || overrideY != ""


    if (
        hasCoordinateOverride
        && (
            overrideX = ""
            || overrideY = ""
        )
    ) {

        throw Error(
            "Upgrade coordinate override requires both X and Y."
        )
    }


    clickX :=
        hasCoordinateOverride
            ? overrideX
            : tower.x


    clickY :=
        hasCoordinateOverride
            ? overrideY
            : tower.y



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


    ; Select the requested tower fresh for every UpgradeTower() action.
    ; There is no selected-tower cache and no proactive Esc/panel scan here.
    panelSide := false


    Click(
        clickX,
        clickY
    )


    Sleep(
        IsFastDeflationPregameUpgrade() ? 25 : 35
    )


    MarkUpgradeMonkeySelected(
        upgradeTiming
    )


    ; Start affordability polling immediately after selection. The saved tower
    ; X still gives us a fast first guess; WaitForUpgrade() corrects the side
    ; if BTD6 opened the panel on the opposite side.
    panelSide :=
        GetExpectedUpgradePanelSideFromX(
            clickX
        )



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
            SendEscapeAndWait()
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
            SendEscapeAndWait()
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
            SendEscapeAndWait()
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


    ; This UpgradeTower() selected the tower itself, so close that known panel
    ; exactly once. Do not scan the screen or send an extra Esc later.
    SendEscapeAndWait()


    LogUpgradeActionTiming(
        upgradeTiming
    )


    return true
}
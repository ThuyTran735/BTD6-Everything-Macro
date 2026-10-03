#Requires AutoHotkey v2.0

; v3 file note: Keeps upgrade globals and timing/log helpers together.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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



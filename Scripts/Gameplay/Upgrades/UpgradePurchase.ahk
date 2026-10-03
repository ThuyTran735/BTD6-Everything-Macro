#Requires AutoHotkey v2.0

; v3 file note: Checks green buttons, spaces purchase hotkeys, and performs the actual buy.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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



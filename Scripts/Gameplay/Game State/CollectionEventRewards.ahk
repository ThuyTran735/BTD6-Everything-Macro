#Requires AutoHotkey v2.0

; Claim collection rewards before the launcher starts its next cycle. Collect
; identifies this screen on its own; Back needs the collection title as well.

FindCollectionRewardScreen(captureFrame := true) {
    global CollectionRewardPatterns

    screen := {title: false, collect: false, back: false, invalidPatterns: []}
    if !IsSet(CollectionRewardPatterns) || !(CollectionRewardPatterns is Map) {
        screen.invalidPatterns := ["Title", "Collect", "Back"]
        return screen
    }
    if captureFrame
        FindText().ScreenShot(0, 0, 1919, 1079)

    regions := Map(
        "Title", {left: 400, top: 0, right: 1500, bottom: 230},
        "Collect", {left: 800, top: 600, right: 1120, bottom: 760},
        "Back", {left: 0, top: 0, right: 160, bottom: 160}
    )
    for key in ["Title", "Collect", "Back"] {
        if !CollectionRewardPatterns.Has(key) {
            screen.invalidPatterns.Push(key)
            continue
        }
        pattern := CollectionRewardPatterns[key]
        if Type(pattern) != "String" || Trim(pattern) = "" || !InStr(pattern, "$") {
            screen.invalidPatterns.Push(key)
            continue
        }
        region := regions[key]
        try {
            matches := FindText(&matchX, &matchY, region.left, region.top, region.right, region.bottom,
                0, 0, pattern, 0, 1)
            ; Ambiguous buttons cannot provide a safe click target.
            match := matches && matches.Length = 1 ? {x: matchX, y: matchY} : false
            if key = "Title"
                screen.title := !!match
            else if key = "Collect"
                screen.collect := match
            else
                screen.back := match
        }
        catch {
            screen.invalidPatterns.Push(key)
        }
    }
    return screen
}


HasInvalidCollectionRewardActionPattern(screen) {
    ; Title is optional when Collect is visible, but both action patterns are
    ; needed to finish the flow without guessing which button is on screen.
    for key in screen.invalidPatterns {
        if key = "Collect" || key = "Back"
            return true
    }
    return false
}


HandleCollectionEventRewards(isCurrent := false) {
    static handlingRewards := false

    ; A stopped caller must not inherit another invocation's pending result.
    if !IsHomePopupActionCurrent(isCurrent)
        return CollectionRewardResult("cancelled", "Collection reward handling cancelled")
    if handlingRewards
        return CollectionRewardResult("busy", "Collection rewards are already being handled")

    handlingRewards := true
    try {
        ; A background game is not evidence of a reward failure. Once a reward
        ; screen is recognized, losing focus must stop its owned input sequence.
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption.status = "cancelled" ? interruption
                : CollectionRewardResult("not-present", "BTD6 is not active")
        homeVisible := IsHomeScreenVisible()
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption.status = "cancelled" ? interruption
                : CollectionRewardResult("not-present", "BTD6 is not active")
        if homeVisible
            return CollectionRewardResult("not-present", "Home is already visible")

        ; The status panel can cover the title, so hide it before establishing
        ; reward ownership. Keep it hidden through the entry animation wait.
        RequestCycleStatusHide(3500)
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption.status = "cancelled" ? interruption
                : CollectionRewardResult("not-present", "BTD6 is not active")

        screen := FindCollectionRewardScreen()
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption.status = "cancelled" || screen.title || screen.collect ? interruption
                : CollectionRewardResult("not-present", "BTD6 is not active")
        if !screen.title && !screen.collect
            return CollectionRewardResult("not-present", "Collection reward title and Collect are not visible")
        if HasInvalidCollectionRewardActionPattern(screen)
            return CollectionRewardResult("failed", "A collection reward detection pattern is missing or invalid")

        overallDeadline := A_TickCount + 180000
        entryDeadline := A_TickCount + 3000
        while !screen.collect && !(screen.title && screen.back) {
            ; The title can arrive before its buttons finish animating. Wait
            ; briefly for a complete entry match without guessing reveal clicks.
            if A_TickCount >= entryDeadline
                return CollectionRewardResult("failed", "Collection reward action buttons did not appear")
            interruption := WaitCollectionRewardAction(150, isCurrent)
            if interruption
                return interruption
            homeVisible := IsHomeScreenVisible()
            interruption := GetCollectionRewardInterruption(isCurrent)
            if interruption
                return interruption
            if homeVisible
                return CollectionRewardResult("not-present", "Home appeared before collection reward entry")
            screen := FindCollectionRewardScreen()
            interruption := GetCollectionRewardInterruption(isCurrent)
            if interruption
                return interruption
            if HasInvalidCollectionRewardActionPattern(screen)
                return CollectionRewardResult("failed", "A collection reward detection pattern is missing or invalid")
        }

        interruption := GetCollectionRewardInterruption(isCurrent, true)
        if interruption
            return interruption

        stallDeadline := A_TickCount + 60000
        ; The last two points cover the wider spacing of the two-card layout.
        rewardPoints := [[701, 537], [961, 540], [1204, 542], [810, 540], [1110, 540]]
        pointIndex := 1
        awaitingCollectGone := false
        collectAttempts := 0
        lastCollectClickTick := 0

        Loop {
            interruption := GetCollectionRewardInterruption(isCurrent)
            if interruption
                return interruption
            homeVisible := IsHomeScreenVisible()
            interruption := GetCollectionRewardInterruption(isCurrent)
            if interruption
                return interruption
            if homeVisible
                return CollectionRewardResult("handled", "Collection rewards returned to Home")

            screen := FindCollectionRewardScreen()
            interruption := GetCollectionRewardInterruption(isCurrent)
            if interruption
                return interruption
            if HasInvalidCollectionRewardActionPattern(screen)
                return CollectionRewardResult("failed", "A collection reward detection pattern is missing or invalid")
            if A_TickCount >= overallDeadline
                return CollectionRewardResult("failed", "Collection rewards exceeded the total wait limit")

            ; A click is not progress by itself. Only seeing Collect disappear
            ; confirms that its claim transition began and renews the stall budget.
            if awaitingCollectGone && !screen.collect {
                awaitingCollectGone := false
                stallDeadline := A_TickCount + 60000
                pointIndex := 1
                collectAttempts := 0
            }
            if A_TickCount >= stallDeadline
                return CollectionRewardResult("failed", "Collection rewards stopped making progress")

            if screen.collect {
                ; A dropped click gets two bounded retries, using a fresh
                ; Collect match at least a second apart. These attempts never
                ; renew the stall deadline while the same button stays visible.
                if awaitingCollectGone && (collectAttempts >= 3 || A_TickCount - lastCollectClickTick < 1000) {
                    interruption := WaitCollectionRewardAction(100, isCurrent)
                    if interruption
                        return interruption
                    continue
                }
                clickResult := ClickCollectionRewardPoint(screen.collect.x, screen.collect.y, isCurrent)
                if clickResult.status = "home"
                    return CollectionRewardResult("handled", "Home appeared before a reward click")
                if clickResult.status != "clicked"
                    return clickResult
                awaitingCollectGone := true
                collectAttempts++
                lastCollectClickTick := A_TickCount
                pointIndex := 1
                interruption := WaitCollectionRewardAction(700, isCurrent)
                if interruption
                    return interruption
                continue
            }

            ; Once a reward screen establishes this flow, Back can end it even
            ; if the title is absent. Click it once and wait for verified Home.
            if screen.back {
                clickResult := ClickCollectionRewardPoint(screen.back.x, screen.back.y, isCurrent)
                if clickResult.status = "home"
                    return CollectionRewardResult("handled", "Home appeared before a reward click")
                if clickResult.status != "clicked"
                    return clickResult
                return WaitForCollectionRewardHome(isCurrent, Min(overallDeadline, A_TickCount + 8000))
            }

            ; Reaching this point requires a fresh frame with neither action
            ; button. The click helper rechecks Home before every reveal point.
            point := rewardPoints[pointIndex]
            clickResult := ClickCollectionRewardPoint(point[1], point[2], isCurrent)
            if clickResult.status = "home"
                return CollectionRewardResult("handled", "Home appeared before a reward click")
            if clickResult.status != "clicked"
                return clickResult
            pointIndex := Mod(pointIndex, rewardPoints.Length) + 1
            interruption := WaitCollectionRewardAction(300, isCurrent)
            if interruption
                return interruption
        }
    }
    catch as err {
        return CollectionRewardResult("failed", "Collection reward handling failed: " . err.Message)
    }
    finally {
        handlingRewards := false
    }
}


GetCollectionRewardInterruption(isCurrent, requireFullscreen := false) {
    if !IsHomePopupActionCurrent(isCurrent)
        return CollectionRewardResult("cancelled", "Collection reward handling cancelled")
    if !WinActive("ahk_exe BloonsTD6.exe")
        return CollectionRewardResult("failed", "BTD6 lost focus during collection rewards")
    if requireFullscreen {
        WinGetClientPos(&gameX, &gameY, &gameWidth, &gameHeight, "ahk_exe BloonsTD6.exe")
        if !IsHomePopupActionCurrent(isCurrent)
            return CollectionRewardResult("cancelled", "Collection reward handling cancelled")
        if !WinActive("ahk_exe BloonsTD6.exe")
            return CollectionRewardResult("failed", "BTD6 lost focus during collection rewards")
        if gameX != 0 || gameY != 0 || gameWidth != 1920 || gameHeight != 1080
            return CollectionRewardResult("failed", "Collection rewards need BTD6 fullscreen at 1920x1080")
    }
    return false
}


ClickCollectionRewardPoint(x, y, isCurrent) {
    interruption := GetCollectionRewardInterruption(isCurrent, true)
    if interruption
        return interruption
    RequestCycleStatusHide(1500)
    interruption := GetCollectionRewardInterruption(isCurrent, true)
    if interruption
        return interruption
    homeVisible := IsHomeScreenVisible()
    interruption := GetCollectionRewardInterruption(isCurrent)
    if interruption
        return interruption
    if homeVisible
        return CollectionRewardResult("home", "Home is visible")

    previousMouseMode := A_CoordModeMouse
    try {
        CoordMode("Mouse", "Screen")
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption
        Click(x, y)
        return CollectionRewardResult("clicked", "Collection reward input sent")
    }
    finally {
        CoordMode("Mouse", previousMouseMode)
    }
}


WaitCollectionRewardAction(durationMs, isCurrent) {
    remaining := durationMs
    while remaining > 0 {
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption
        slice := Min(50, remaining)
        Sleep(slice)
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption
        remaining -= slice
    }
    return false
}


WaitForCollectionRewardHome(isCurrent, deadline) {
    interruption := WaitCollectionRewardAction(Min(700, Max(0, deadline - A_TickCount)), isCurrent)
    if interruption
        return interruption
    Loop {
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption
        homeVisible := IsHomeScreenVisible()
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption
        if homeVisible
            return CollectionRewardResult("handled", "Collection rewards returned to Home")
        ; Back can reach Home underneath its known animated-series promo.
        ; Hand that recognized popup to the outer Home handler without any
        ; further reward input or a recursive call into the popup loop.
        homePromo := FindAnimatedSeriesPopupClose()
        interruption := GetCollectionRewardInterruption(isCurrent)
        if interruption
            return interruption
        if homePromo
            return CollectionRewardResult("handled", "Collection rewards returned to the Home animated-series popup")
        if A_TickCount >= deadline
            return CollectionRewardResult("failed", "Collection reward Back did not return to Home")
        interruption := WaitCollectionRewardAction(Min(150, deadline - A_TickCount), isCurrent)
        if interruption
            return interruption
    }
}


CollectionRewardResult(status, reason) {
    return {status: status, reason: reason}
}

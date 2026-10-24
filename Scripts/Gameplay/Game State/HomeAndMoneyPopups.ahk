#Requires AutoHotkey v2.0

; Dismisses supported money, DLC, Boss Rush, animated-series, and login interruptions.
; Gameplay checks wait for the round display to return before the caller resumes its work.

global LastHomeMenuInterruptionReason := ""

HandleMonkeyMoneyPopup() {
    global GameStatePatterns


    if !GameStatePatterns.Has(
        "MonkeyMoney"
    ) {
        return false
    }


    pattern :=
        GameStatePatterns["MonkeyMoney"]


    if pattern = "" {
        return false
    }


    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        pattern
    ) {
        return false
    }


    ; Only dismiss the Monkey Money popup here.
    ;
    ; Do not select a tower in GameStateLogic.
    ; UpgradeLogic handles restoring the currently
    ; selected tower only when an upgrade is active.
    Click(
        X,
        Y
    )


    Sleep(
        500
    )


    return true
}


IsGameplayScreenVisible() {
    global NavigationPatterns


    if !IsSet(
        NavigationPatterns
    ) {
        return false
    }


    if !NavigationPatterns.Has(
        "Settings"
    ) {
        return false
    }


    settingsPattern :=
        NavigationPatterns["Settings"]


    if settingsPattern = "" {
        return false
    }


    return !!FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        settingsPattern
    )
}


WaitForGameplayAfterPopup(
    timeoutMs := 4000
) {
    startTick :=
        A_TickCount


    Loop {

        if IsGameplayScreenVisible() {
            return true
        }


        if (
            A_TickCount
            - startTick
            >= timeoutMs
        ) {
            return false
        }


        Sleep(
            100
        )
    }
}


HandleHomeMenuInterruptions(isCurrent := false) {
    global LastHomeMenuInterruptionReason

    handledAny := false
    reasonInitialized := false


    Loop 4 {

        ; Launcher scans can yield to Stop while a popup is fading out.
        if !IsHomePopupActionCurrent(isCurrent)
            break

        ; Rewards can cover Home completely. Finish their full sequence before
        ; looking for ordinary promos or allowing navigation to continue.
        rewardResult := HandleCollectionEventRewards(isCurrent)
        if !IsHomePopupActionCurrent(isCurrent)
            return handledAny
        if rewardResult.status = "busy"
            return "pending"
        if !reasonInitialized {
            LastHomeMenuInterruptionReason := ""
            reasonInitialized := true
        }
        if rewardResult.status = "cancelled"
            return handledAny
        if rewardResult.status = "failed" {
            LastHomeMenuInterruptionReason := "COLLECTION REWARDS FAILED"
                . (rewardResult.reason != "" ? ": " . rewardResult.reason : "")
            SetRunFailureReason("COLLECTION REWARDS FAILED", rewardResult.reason)
            return "blocked"
        }
        if rewardResult.status = "handled" {
            handledAny := true
            continue
        }

        if !WinActive("ahk_exe BloonsTD6.exe")
            break

        if HandleAnimatedSeriesPopup(isCurrent) {
            handledAny := true
            continue
        }

        if !IsHomePopupActionCurrent(isCurrent)
            break

        if HandleCloseDLCPopup() {
            handledAny := true
            continue
        }

        if !IsHomePopupActionCurrent(isCurrent) || !WinActive("ahk_exe BloonsTD6.exe")
            break

        if HandleBossRushPopup() {
            handledAny := true
            continue
        }


        break
    }


    return handledAny
}

GetHomeMenuInterruptionReason(defaultReason := "COLLECTION REWARDS FAILED") {
    global LastHomeMenuInterruptionReason

    ; The launcher survives many runs; its general first-failure log may belong
    ; to an earlier attempt. This reason belongs to the latest blocked screen.
    return LastHomeMenuInterruptionReason != "" ? LastHomeMenuInterruptionReason : defaultReason
}

IsHomePopupActionCurrent(isCurrent) {
    ; Direct strategy calls need no launcher callback; their process owns the run.
    if !IsObject(isCurrent)
        return true
    try return !!isCurrent.Call()
    catch
        return false
}

FindAnimatedSeriesPopupClose(captureFrame := true) {
    global GameStatePatterns

    for key in ["AnimatedSeriesTitle", "AnimatedSeriesClose"] {
        if !GameStatePatterns.Has(key) || GameStatePatterns[key] = ""
            return false
    }

    ; Both shapes must come from one frame. A generic X on its own could belong
    ; to a different menu. These bounds use the project's 1920x1080 layout.
    if captureFrame
        FindText().ScreenShot(250, 70, 1500, 300)
    titles := FindText(&titleX, &titleY, 450, 80, 1450, 230,
        0, 0, GameStatePatterns["AnimatedSeriesTitle"], 0, 1)
    if !titles || titles.Length != 1
        return false

    ; Look beside the detected banner, then click the actual X match rather
    ; than guessing its position from a fixed screen coordinate.
    buttons := FindText(&closeX, &closeY, titleX - 441, titleY + 3,
        titleX - 361, titleY + 63, 0, 0, GameStatePatterns["AnimatedSeriesClose"], 0, 1)
    if !buttons || buttons.Length != 1
        return false
    return {x: closeX, y: closeY}
}

HandleAnimatedSeriesPopup(isCurrent := false) {
    if !IsHomePopupActionCurrent(isCurrent) || !WinActive("ahk_exe BloonsTD6.exe")
        return false
    closeButton := FindAnimatedSeriesPopupClose()
    if !closeButton || !IsHomePopupActionCurrent(isCurrent) || !WinActive("ahk_exe BloonsTD6.exe")
        return false

    ReleaseMacroModifierKeys()
    if !IsHomePopupActionCurrent(isCurrent) || !WinActive("ahk_exe BloonsTD6.exe")
        return false
    previousMouseMode := A_CoordModeMouse
    try {
        CoordMode("Mouse", "Screen")
        Click(closeButton.x, closeButton.y)
    }
    finally {
        CoordMode("Mouse", previousMouseMode)
    }
    LogMessage("INFO", "Closed the animated-series Home popup")
    Sleep(700)
    return true
}


HandleCloseDLCPopup() {
    global GameStatePatterns


    if !GameStatePatterns.Has(
        "CloseDLC"
    ) {
        return false
    }


    pattern :=
        GameStatePatterns["CloseDLC"]


    if pattern = "" {
        return false
    }


    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        pattern
    ) {
        return false
    }


    ReleaseMacroModifierKeys()


    ; Close DLC is detected by its pattern, but its
    ; dismiss target is the fixed close coordinate.
    Click(
        232,
        175
    )


    Sleep(
        700
    )


    return true
}


HandleBossRushPopup() {
    global GameStatePatterns


    if !GameStatePatterns.Has(
        "BossRush"
    ) {
        return false
    }


    pattern :=
        GameStatePatterns["BossRush"]


    if pattern = "" {
        return false
    }


    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        pattern
    ) {
        return false
    }


    ReleaseMacroModifierKeys()


    ; The Boss Rush capture is the button to dismiss,
    ; so click the detected pattern itself.
    Click(
        X,
        Y
    )


    Sleep(
        700
    )


    return true
}


HandleLoginNotNowPrompt(
    timeoutMs := 3000
) {
    global GameStatePatterns


    if !GameStatePatterns.Has(
        "LoginNotNow"
    ) {
        return false
    }


    notNowPattern :=
        GameStatePatterns["LoginNotNow"]


    if notNowPattern = "" {
        return false
    }


    startTick :=
        A_TickCount


    homeSeenTick :=
        0


    Loop {

        if FindText(
            &X,
            &Y,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            notNowPattern
        ) {

            ReleaseMacroModifierKeys()


            Click(
                X,
                Y
            )


            Sleep(
                700
            )


            return true
        }


        ; Home can appear briefly before the login
        ; popup renders, so give it a short grace period.
        if IsHomeScreenVisible() {

            if homeSeenTick = 0 {

                homeSeenTick :=
                    A_TickCount
            }
            else if (
                A_TickCount
                - homeSeenTick
                >= 700
            ) {

                return false
            }
        }
        else {

            homeSeenTick :=
                0
        }


        if (
            A_TickCount
            - startTick
            >= timeoutMs
        ) {
            return false
        }


        Sleep(
            100
        )
    }
}



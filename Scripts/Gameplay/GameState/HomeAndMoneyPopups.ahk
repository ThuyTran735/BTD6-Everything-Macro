#Requires AutoHotkey v2.0

; v3 file note: Handles Monkey Money plus home-screen/DLC/login style interruptions.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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


HandleHomeMenuInterruptions() {
    handledAny := false


    Loop 4 {

        if HandleCloseDLCPopup() {
            handledAny := true
            continue
        }


        if HandleBossRushPopup() {
            handledAny := true
            continue
        }


        break
    }


    return handledAny
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



#Requires AutoHotkey v2.0

; v3 file note: Handles level-up, unlock, and new-bloon popups that can interrupt a run.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

HandleLevelUpPopup() {
    global GameStatePatterns


    if !GameStatePatterns.Has(
        "LevelUp"
    ) {
        return false
    }


    levelUpPattern :=
        GameStatePatterns["LevelUp"]


    if levelUpPattern = "" {
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
        levelUpPattern
    ) {
        return false
    }


    Click(
        X,
        Y
    )


    Sleep(
        500
    )


    HandleMonkeyUnlockAfterLevelUp()


    WaitForGameplayAfterPopup(
        4000
    )


    return true
}


HandleMonkeyUnlockAfterLevelUp() {
    global GameStatePatterns


    if !GameStatePatterns.Has(
        "MonkeyUnlock"
    ) {
        return true
    }


    monkeyUnlockPattern :=
        GameStatePatterns["MonkeyUnlock"]


    ; Players who already have every monkey unlocked
    ; will never see this screen.
    if monkeyUnlockPattern = "" {
        return true
    }


    Loop 30 {

        if IsGameplayScreenVisible() {
            return true
        }


        if FindText(
            &X,
            &Y,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            monkeyUnlockPattern
        ) {

            Click(
                X,
                Y
            )


            Sleep(
                500
            )


            continue
        }


        Sleep(
            100
        )
    }


    return true
}


HandleNewBloonPopup() {
    global GameStatePatterns
    global LastNewBloonPopupTick


    if !GameStatePatterns.Has(
        "NewBloonOK"
    ) {
        return false
    }


    pattern :=
        GameStatePatterns["NewBloonOK"]


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


    ; Only dismiss the popup here.
    ;
    ; If this happened during UpgradeTower(),
    ; UpgradeLogic will restore the same tower's
    ; upgrade panel afterward.
    Click(
        X,
        Y
    )


    ; UpgradeLogic uses this timestamp to briefly wait
    ; for a level-up screen before it reselects the tower.
    ; That screen can animate in just after this OK closes.
    LastNewBloonPopupTick :=
        A_TickCount


    Sleep(
        500
    )


    return true
}


WaitForLevelUpAfterNewBloon(
    timeoutMs := 2500
) {
    global LastNewBloonPopupTick


    if LastNewBloonPopupTick = 0 {
        return false
    }


    ; Ignore an old balloon-info dismissal. Only the
    ; immediate follow-up screen can block tower recovery.
    if (
        A_TickCount
        - LastNewBloonPopupTick
        > 4500
    ) {

        LastNewBloonPopupTick := 0


        return false
    }


    startTick :=
        A_TickCount


    Loop {

        if HandleLevelUpPopup() {

            LastNewBloonPopupTick := 0


            return true
        }


        if (
            A_TickCount
            - startTick
            >= timeoutMs
        ) {

            LastNewBloonPopupTick := 0


            return false
        }


        Sleep(
            100
        )
    }
}



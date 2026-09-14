#Requires AutoHotkey v2.0


global DailyChestPatterns := Map(
    "Available", "|<>*125$55.U0000001zk0000000zs0000000Ts000000M60000000000000000y00000000zU0E030M0zs0800S20zw0401zkUzy0301zw0TzU001zz0Tzk000zzkDzs000Tzs7zw000Tzy3zy000Dzz1zz0007zzUzzU003zzsTzk001zzs7zs000Tzw3zs000Dzy1zs0007zz0Ts0401zzUDkDy00zzU1UDz007zU00DzU01zVs0Dzk00000UDzw000000Tzz0k0000zzzvy0003zzzU",

    "Close", "|<>*108$41.00000k000003k01U00Ds07k00zs0Tk03zs1zk0Dzw7zk0zzwDzk3zzwzzsDzzvzzszzzjzzvzzyDzzzzzsDzzzzzkDzzzzz0Tzzzzw0Tzzzzs0TzzzzU0Tzzzy00Tzzzs00TzzzU00Tzzz000Tzzw001zzzs003zzzk00Dzzzk00zzzzk01zzzzk07zzzzk0TzzzzU0zzzzzU3zzzzzU7zzzzzUTzyTzz1zzsTzz3zzUDzz3zy0Dzw1zk07zk1z007z01w003w01k003k0100030E"
)


CollectDailyChest() {
    global DailyChestPatterns


    if !DailyChestPatterns.Has("Available")
        return false


    availablePattern :=
        DailyChestPatterns["Available"]


    if availablePattern = "" {
        ToolTip(
            "Daily Chest Available pattern "
            "has not been captured."
        )

        Sleep(2000)
        ToolTip()

        return false
    }


    ; Give the home screen a moment to settle.
    Sleep(500)


    ; If the chest is not available,
    ; there is nothing to collect today.
    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        availablePattern
    ) {
        ToolTip(
            "Daily chest is not available."
        )

        Sleep(1000)
        ToolTip()

        return "Unavailable"
    }


    ; Open the daily chest.
    Click(X, Y)

    Sleep(1000)


    ; Different rewards can show different screens.
    ;
    ; Click the middle of the screen several times
    ; to advance through all reward screens.
    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2


    Loop 5 {
        Click(
            centerX,
            centerY
        )

        Sleep(700)
    }


    ; Give the final reward screen time to settle.
    Sleep(500)


    ; Close the final screen if the Close
    ; button is visible.
    if DailyChestPatterns.Has("Close") {
        closePattern :=
            DailyChestPatterns["Close"]


        if closePattern != "" {
            WaitAndClickDailyChestPattern(
                closePattern,
                5000
            )
        }
    }


    ToolTip(
        "Daily chest collected."
    )

    Sleep(1000)
    ToolTip()


    return true
}


WaitAndClickDailyChestPattern(
    pattern,
    timeout := 5000
) {
    startTime :=
        A_TickCount


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
            pattern
        ) {
            Click(X, Y)

            Sleep(500)

            return true
        }


        if (
            A_TickCount
            - startTime
            >= timeout
        ) {
            return false
        }


        Sleep(150)
    }
}
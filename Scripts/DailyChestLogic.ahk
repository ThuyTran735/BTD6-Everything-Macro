#Requires AutoHotkey v2.0


global DailyChestPatterns := Map(
    "Available", "|<>*125$55.U0000001zk0000000zs0000000Ts000000M60000000000000000y00000000zU0E030M0zs0800S20zw0401zkUzy0301zw0TzU001zz0Tzk000zzkDzs000Tzs7zw000Tzy3zy000Dzz1zz0007zzUzzU003zzsTzk001zzs7zs000Tzw3zs000Dzy1zs0007zz0Ts0401zzUDkDy00zzU1UDz007zU00DzU01zVs0Dzk00000UDzw000000Tzz0k0000zzzvy0003zzzU",

)


CollectDailyChest(silent := false) {
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
        if !silent {
            ToolTip(
                "Daily chest is not available."
            )

            Sleep(1000)
            ToolTip()
        }

        return "Unavailable"
    }


    ; Open the daily chest.
    Click(X, Y)

    Sleep(1000)


    ; Different rewards can show different screens.
    ; Advance through them using the known screen coordinate.
    ClickDailyChestRewardScreens()


    ; The ten reward clicks advance through and close the Daily Chest flow.
    ; Keep only a tiny settle before continuing.
    Sleep(100)


    if !silent {
        ToolTip(
            "Daily chest collected."
        )

        Sleep(1000)
        ToolTip()
    }


    return true
}


ClickDailyChestRewardScreens() {
    previousMouseCoordMode := A_CoordModeMouse

    try {
        CoordMode("Mouse", "Screen")

        Loop 10 {
            Click(583, 388)

            if A_Index < 10
                Sleep(325)
        }
    }
    finally {
        CoordMode("Mouse", previousMouseCoordMode)
    }
}


GetDailyChestSettingsFilePath() {
    return GetMacroProjectRoot() . "\\UserData\\Settings.ini"
}


IsPreRunDailyChestEnabled() {
    path := GetDailyChestSettingsFilePath()

    try {
        value := IniRead(path, "DailyChest", "BeforeEachCycle", "0")
        return value != "0"
    }

    return false
}


SetPreRunDailyChestEnabled(enabled) {
    settingsDir := GetMacroProjectRoot() . "\\UserData"

    try {
        if !DirExist(settingsDir)
            DirCreate(settingsDir)

        IniWrite(
            enabled ? "1" : "0",
            GetDailyChestSettingsFilePath(),
            "DailyChest",
            "BeforeEachCycle"
        )

        return true
    }

    return false
}


RunPreMapDailyChestIfEnabled() {
    if !IsPreRunDailyChestEnabled()
        return false

    try {
        result := CollectDailyChest(true)

        return result
    }

    return false
}
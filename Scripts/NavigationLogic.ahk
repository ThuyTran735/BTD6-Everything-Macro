#Requires AutoHotkey v2.0

global NavigationPatterns := Map(
    ; Home screen
    "Play", "|<>*214$80.zz0000Dzzzzzzzzk0001zzzzzzzzw00007zzzzzzzz00000zzzzzzzzk00007zzzzzzzs00000Tzzzzzzy000003zzzzzzzU00000Tzzzzzzs000001zzzzzzy000000DzzzzzzU000001zzzzzzs000000Dzzzzzy0000001zzzzzzU0000007zzzzzs0000000zzzzzy00000007zzzzzU0000000zzzzzs00000007zzzzy00000000zzzzzU00000007zzzzs00000000zzzzy000000007zzzzU00000000zzzzs000000007zzzy000000000zzzzU00000000Dzzzs000000001zzzy000000000DzzzU000000003zzzs000000000zzzy000000000DzzzU000000003zzzs000000000zzzy000000000TzzzU00000000Dzzzs000000003zzzy000000001zzzzU00000000zzzzs00000000Tzzzy00000000DzzzzU00000003zzzzs00000001zzzzy00000000zzzzzU0000000Tzzzzs0000000Dzzzzy00000007zzzzzU0000003zzzzzs0000001zzzzzy0000000zzzzzzU000000Tzzzzzs000000Dzzzzzy0000007zzzzzzk000003zzzzzzw000001zzzzzzz000001zzzzzzzk00000zzzzzzzw00000Tzzzzzzz00000Dzzzzzzzk00007zzzzzzzy00007zzzzzzzzU0003zzzzzzzzs0001zzzzzzzzy0001zzzzzzzzzU000zzzzzzzs",

    ; Something that is always visible on the map selection screen (Back Button)
    "MapScreen", "|<>*197$38.0000000000000000000000000000000000000000000000DzzU003zzw000zzzU00Dzzs003zzz0U0zzzkA0Dzzw3k3zzz0y0zzzkDkDzzw3z3zzy0zszzzUDzzzzs3zzzzw0zzzzz0Dzzz003zzzk00zzzs00Dzzy003zzzU00zzzs00Tzzw006",

    ; Map categories
    "Beginner", "|<>*146$35.00zzw207zzs40Tzzs01zzzk07zzzU0TzzzU1zzzz03zzzy0Dzzzw0zzzzw1zzzzs7zzzzkDzzzzV",
    "Intermediate", "|<>*137$34.00zy000zzzU0Tzzzk7zzzzkzzzzzjzzzzyzzzzzvzzzzzjzzzzyzzzzznzzzzzDzzzzwzzzzzXzzzzyDzzzzkzzzzz3zzzzsDzzzzUzzzzw3zzzzUTzzzy3zzzzkTzzzy3zzy3szzz01zzzk01zs",
    "Advanced", "|<>*148$36.3z70077yS0037ws0077tk03zDlU0zzDU0DzzT00zzzy01zzzw07zzzw0Dzzzs0Tzzzk0Tzzzk0TzzzU0Tzzz00Dzzz00Dzzz007zzz007zzz003zzz003zzz001zzz001zzz000zzz000Tzz000Dzz0007zz0003zzU001zzU000zzU000Tzk000Dzk0003zs0000zs0000Dw00001U",
    "Expert", "|<>*147$31.y001zz000Tz000Dz0003z0000z0000D00001U0000E0D0000Dk000Dw001zzw01zzy00zzzU0zzzk0Tzzs0Tzzy0Dw7z07s0z00k0D00000000000000000000000000000000000000000U0200E0300M01k0A0E",

    ; Difficulties
    "Easy", "|<>*140$33.DzzzztzzzzzDzzzztzzzzzDzzzztzzzzzDzzzzsTzzzz0zzzDzvzztzzzzz7z7vzsz03Xz3s033kT00A01s00E0700100s0040300000M0S0010Ds0003zU000Ty0000zk0003z004",
    "Medium", "|<>*139$38.000000000000400000z00007zk000Tzw001zzz001zzzk0zzzzw1zzzzz7zzzzzrzzzzznzzzyzwzzzk3zDzzw0TXzzz03szzzU0SDzzs03U0Ty00M00z006003k00000000000000000000000000000D000007s00001z00000TU00007k00001wk0000Tw00007z00001zs0000Ty0008",
    "Hard", "|<>*121$43.1zzzzzzUzzzzzzkTzzzzzsTzzzzzwTzzzzzyTzzzzzzDzzzzzzjzzzzzzrzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzwzzzzzzyTzzzzzzDzzzzzzbzzzzzzXzzzzzzlzzzzzzkzzzzzzsTzzzzzsDzzzzzw7zzzzzw3zzzzzy1zzzzzy0zzzzzz0Tzzzzz0DzzzzzU3zzzzzU0zzzzzU0Dzzzzk03zzzzk0E",

    ; Game modes
    "Standard", "|<>*210$40.000000000000000000000000000000000000000000000000000000000001000000A000001k00000D000001w00000Dk00001z00000Tw00003zk0000Tz00003zw0000Tzk0003zz0000Tzw0003zzk000zzz0007zzy",
    "Primary Only", "|<>*61$58.zzzy00Tzzzzzzy07zzzzzzzw1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzznzzzzzzzzwDzzzzzzzz0zzzzzzzzk3zzzzzzzw0Dzzzzzzzk0zzzzzzzzU3zzzzzzzz0Dzzzzzzzy0zzzzzzzzw3zzzzzzzzsDzzzzzzzzkzzzzzzzzzXzzzzzzzzzDzzzzzzzzyzzzzzzzzzzzzzyDzzzzzzzzkzzzzzzzzy1zzzzzzzzU3zzzzzzzw0DzzzzzzzU0Tzzzzzzs00zzzzzzz001zzzzzzw007zzzzzzU00Dzzzzzw000Tzzzzzk001zzzXzz0003zzUDzw0007zU0zzk000Ts1zzz0000s3zzzy00007zzzzy0007zzzzzzs0zzzzs",


    ; Map pages
    "NextPage", "|<>*180$41.y00007zw00007zs00007zk00007zU00007z000007y000007w000007s000007k00000DU00000T000000y000001w000003s00000Dk00000Tk00001zU00007z00000Ty00001zw00007zs0000Tzk0001zk",
    "PreviousPage", "|<>*181$42.zk0000DzU0000Dz00000Dy00000Dw00000Ds00000Dk00000Dk00000DU00000DU00000DU00000Dk00000Ds00000Ds00000Tw00000Ty00000Tz00000TzU0000Tzk0000TU",

    ; Settings button
    "Settings", "|<>*200$28.zk0zzz03zzw0Dyzk0Tnz01wDw000zk003z0000s00001zU00DzU00zz007zy00zzw03zzk0Tzz01zzw07zzkkTzz31zzwA3zzksDzz30zzs81zzU01zw001z0000000000y",

    ; OK button
    "OK", "|<>*125$78.000000000000000000000000000000000000000000000000000000000000000000000007w1w000000000Dzzzy00000000Dzzzy000003zkC0T0T00000DzwC0S0D00000z1zA0Q0D00001w0Dg0Q0S00003k03w0M0w00007U01w0k1w00007000w0k1s0000C000w003k0000C000Q007k0000Q000Q007U0000Q0Q0Q00D00000Q0y0A00S00000M1z0A00S00000s1z0A00Q00000s1z0A00Q00000s1r0Q00C00000s1z0Q00D00000w0y0Q00700000Q0Q0Q007U0000Q000Q003U0000S000w001k0000C000w0U1k0000D001w0k0s00007U03w0s0w00007s07w0s0Q00003y0Tw1w0Q00001zzzQ1y7y00000zzyQ1zzw00000TzwTzzzw000007zkTzzzs00000000Tzry000U"
)


global CurrentMapPage := 0


NavigateToMap(category, mapName, difficulty, gameMode, hero := false) {
    if !OpenPlayMenu() {
        ToolTip("Could not reach map selection screen.")
        return false
    }


    ; Only enter hero selection when a hero was requested.
    if hero {
        if !OpenHeroSelection() {
            ToolTip("Could not open hero selection.")
            return false
        }

        if !SelectHero(hero) {
            ToolTip("Could not select hero: " hero)
            return false
        }

        ; Return to map selection.
        Send("{Esc}")

        ; Give map screen time to return.
        Sleep(1000)
    }


    ; Check the current page first.
    ;
    ; If the requested map is already visible,
    ; click it without touching the category button.
    if !TryClickCurrentMap(mapName) {

        ; Map isn't visible.
        ; Click its category to return to that
        ; category's starting page.
        if !ResetToCategory(category) {
            ToolTip("Could not reset to category: " category)
            return false
        }


        ; Navigate forward to the map's configured page
        ; and select it.
        if !FindAndClickMap(mapName) {
            ToolTip("Could not find map: " mapName)
            return false
        }
    }


    ; Wait for difficulty screen.
    Sleep(500)


    if !SelectDifficulty(difficulty) {
        ToolTip("Could not select difficulty: " difficulty)
        return false
    }


    ; Wait for game-mode screen.
    Sleep(500)


    if !SelectGameMode(gameMode) {
        ToolTip("Could not select game mode: " gameMode)
        return false
    }


    ; Some maps may have an existing saved game.
    ; If the OK prompt appears, handle it.
    if !HandleSavePrompt()
        return false


    return true
}


OpenPlayMenu() {
    global NavigationPatterns

    if NavigationPatterns.Has("MapScreen") {
        if PatternExists(NavigationPatterns["MapScreen"])
            return true
    }

    if !NavigationPatterns.Has("Play") {
        ToolTip("Play pattern is missing.")
        return false
    }

    playPattern := NavigationPatterns["Play"]

    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        playPattern
    ) {
        ToolTip("Could not find Play button.")
        return false
    }

    Click(X, Y)
    Sleep(700)

    if NavigationPatterns.Has("MapScreen") {
        Loop 10 {
            if PatternExists(NavigationPatterns["MapScreen"])
                return true

            Sleep(200)
        }

        ToolTip("Play was clicked, but map screen was not detected.")
        return false
    }

    return true
}


OpenHeroSelection() {
    Click(97, 991)
    Sleep(500)

    return true
}


TryClickCurrentMap(mapName) {
    global MapData

    if !MapData.Has(mapName) {
        ToolTip("Unknown map: " mapName)
        return false
    }

    mapPattern := MapData[mapName].pattern

    if FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        mapPattern
    ) {
        Click(X, Y)
        Sleep(600)

        return true
    }

    return false
}


ResetToCategory(category) {
    global NavigationPatterns
    global CategoryStartPages
    global CurrentMapPage

    if !NavigationPatterns.Has(category) {
        ToolTip("Unknown map category: " category)
        return false
    }

    if !CategoryStartPages.Has(category) {
        ToolTip("No starting page configured for: " category)
        return false
    }

    pattern := NavigationPatterns[category]

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
        ToolTip("Could not find category: " category)
        return false
    }

    Click(X, Y)
    Sleep(1000)

    CurrentMapPage := CategoryStartPages[category]

    return true
}


FindAndClickMap(mapName) {
    global MapData
    global CurrentMapPage

    if !MapData.Has(mapName) {
        ToolTip("Unknown map: " mapName)
        return false
    }

    mapInfo := MapData[mapName]

    if mapInfo.page <= 0 {
        ToolTip("No page configured for map: " mapName)
        return false
    }

    targetPage := mapInfo.page
    mapPattern := mapInfo.pattern

    if CurrentMapPage = 0 {
        ToolTip("Current map page is unknown.")
        return false
    }

    if CurrentMapPage > targetPage {
        ToolTip(
            "Map page error."
            "`nCurrent page: " CurrentMapPage
            "`nTarget page: " targetPage
        )

        return false
    }

    while CurrentMapPage < targetPage {
        if !GoToNextMapPage()
            return false
    }

    Sleep(500)

    if FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        mapPattern
    ) {
        Click(X, Y)
        Sleep(600)

        return true
    }

    ToolTip(
        "Map was not found on expected page."
        "`nMap: " mapName
        "`nCurrent Page: " CurrentMapPage
        "`nTarget Page: " targetPage
    )

    return false
}


GoToNextMapPage() {
    global NavigationPatterns
    global CurrentMapPage

    if !NavigationPatterns.Has("NextPage") {
        ToolTip("Next-page pattern is missing.")
        return false
    }

    nextPattern := NavigationPatterns["NextPage"]

    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        nextPattern
    ) {
        ToolTip(
            "Could not find Next Page button."
            "`nCurrent page: " CurrentMapPage
        )

        return false
    }

    Click(X, Y)
    Sleep(500)

    CurrentMapPage++

    return true
}


SelectDifficulty(difficulty) {
    global NavigationPatterns

    if !NavigationPatterns.Has(difficulty) {
        ToolTip("Unknown difficulty: " difficulty)
        return false
    }

    pattern := NavigationPatterns[difficulty]

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
        ToolTip("Could not find difficulty: " difficulty)
        return false
    }

    Click(X, Y)
    Sleep(600)

    return true
}


SelectGameMode(gameMode) {
    global NavigationPatterns

    if !NavigationPatterns.Has(gameMode) {
        ToolTip("Unknown game mode: " gameMode)
        return false
    }

    pattern := NavigationPatterns[gameMode]

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
        ToolTip("Could not find game mode: " gameMode)
        return false
    }

    Click(X, Y)
    Sleep(600)

    return true
}


HandleSavePrompt() {
    global NavigationPatterns

    if !NavigationPatterns.Has("OK")
        return true

    okPattern := NavigationPatterns["OK"]

    Sleep(500)

    if FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        okPattern
    ) {
        Click(X, Y)
        Sleep(500)
    }

    return true
}


WaitForGameLoad(timeout := 15000) {
    global NavigationPatterns

    if !NavigationPatterns.Has("Settings") {
        ToolTip("Settings pattern is missing.")
        return false
    }

    pattern := NavigationPatterns["Settings"]
    startTime := A_TickCount

    Loop {
        if PatternExists(pattern) {
            ; Settings is visible, so we're in-game.
            ; Give the map/UI another second to fully settle.
            Sleep(1000)

            return true
        }

        if A_TickCount - startTime >= timeout {
            ToolTip("Game failed to load.")
            return false
        }

        Sleep(200)
    }
}


PatternExists(pattern) {
    return !!FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        pattern
    )
}


ClickPattern(pattern, delay := 500) {
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

    Click(X, Y)
    Sleep(delay)

    return true
}
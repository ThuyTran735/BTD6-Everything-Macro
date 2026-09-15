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
    "Deflation", "|<>*144$40.zzzz003zzzy00Dzzzw00zzzzs03zzzzk0DzzzzU0zzzzz03zzzzy0Dzzzzw0zzzzzs3zzzzzkDzzzzzUzzzzzz3zzzzzyDzzzzzwzzzzzzzzzzzzzzzzzzzzkTzzzzy0zzzzzk1zzzzz07zzzzw0Dzzzzk0Tzzzz01zzzzw03zzzzk07zzzz00Tzzzw00zzzzs01zzzzU07zzzz00DzUTw00Ts0Ts01z00zU03s01y007003w00Q00Dk00U00TU00001z000003w00000Ds00000zU00003y00000Dw00000zk00003zU00008",

    "Military Only", "|<>*110$59.000000000y00000001zw0000003zzs000007zzzk0000TzzzzU007zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk",
    "Apopalypse", "|<>*107$50.zzw00zy0Dzz001w03zzU00000zzs00000Dzy000003zz000000zzU00000Dzs000003zw000000zy000000Dy0000003y00000030000000Dk000001zw000003zz000000zzk000007zw000001zz000000Dzk000303zw0003k0Tz0600w07zkTU0D01zxzs03k0Dzzy00y03zzzU07U0zvzs01s0Dyzy00S07zjzU07k7znzw01w7zwzz00T7zzjzk03zzzvzw00zzzyzz00Tzzzbzk1zzzzxzzzzzzzzDzzzzzzzXzzzzzzzkzzzzzzzkU",
    "Reverse", "|<>*204$51.3zzzzzzzsTzzzzzzz1zzzzzzzsDzzzzzzz1zzzzzzzk7zzzzzzw0zzzzzzy07zzzzzzU0zzzzzzk03zzzzzw00Tzzzzz003zzzzzk00Tzzzzs003zzzzy000TzzzzU001zzzzs000Dzzzy0001zzzz0000Dzzzk0001zzzw0000Dzzz00001zzzk0000Dzzw00001zzz000007zzk00000zzw000007zz000000zzs000007zy000000zzU000007zw000000zz0000007zk000000zy0000007zs000000zz0000007zw000000zzk000007zy000000zzs000007zzU00000zzy000007zzs00000zzzU00007zzy00000zzzs00007zzzU0000zzzy00007zzzs0000zzzzU0007zzzy0000zzzzs0007zzzzU000zzzzy0007zzzzw000zzzzzk007zzzzz000zzzzzw007zzzzzs00zzzzzzU07zzzzzy00zzzzzzw07zzzzzzk0zzzzzzz07zzzzzzs1zzzzzzz0Dzzzzzzs1zzzzzzzU",

    "Magic Monkeys Only", "|<>*117$29.DzzzyTzzzwTzzzszzzzlzzzz3zzzy7zzzwDzzzsTzzzkzzzzUzzzz1zzzy3zzzw7zzzsDzzzkTzzzUzzzz1zzzy3zzzw7zzzu",
    "Double HP MOABs", "|<>*102$36.s03zzzs01zzzs00zzzs00Tzzs00Dzzs007zzs003zzs001zzw000zzw000Tzw000Drw0007kw0003s00003z00001z00000z00000T000003U",
    "Half Cash", "|<>*152$41.00001s000003k000007U00000D000000S000000y000000y000001y000001y400001w800001wM00001sk00003lk00007Xk0000D7k0000TDU0000yDU0000wDU0001sT00003kT00007UT0000D0y0000T0zs000y0zs000w1zs001s1zs003k1bs007U07k00DU07k00T007k00y00Dk01w00DU07k00DU0DU00DU0y000T03s000T07k000T0T0000T0w0000y1s0000w3k0001s7UU",
    "Alternate Bloons Rounds", "|<>*121$47.Tzzzzzy1zzzzzzznzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzUDzzzzzy00zzzzzy00Dzzzzy003zzzzz007zzzzzU0DzzzzzU0Tzzzzzk0zzzzzzk1zzzzzzk3zzzzzzk7zzzzzzkDzzzzzzkTzzzzzzkzzzzzzzlzzzzzzznzzzzzzzo",
    "Impoppable", "|<>*201$67.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz007zzzzzw00000Tzzzzk000003zzzzU000000zzzzU000000DzzzU0000003zzzU0000000zzzU0000000DzzU00000007zzU00000001zzk00000000zzk00000000Dzs000000007zw000000003zy000000000zy000000000Tz000000000DzU000000007zk000000003zs000000000zs000000000Tw000000000Dy0000000007z0000000003zU000000001zk000000000zs000000000Tw000000000Dy000000000Dz0000000007zk000000003zs000000001zw000000001zy000000000zzU00000000Tzk00000000Tzw00000000Dzy00000000DzzU0000000Dzzs0000000Dzzy0000000DzzzU001",
    "CHIMPS", "|<>*72$35.001zU0007y0000Ts0001zU0007y0000Ts0000zU0003y0000Ds0000zU0003y0000Ds0000zU0003y0000Ds0000zU0003y0000Ds0000zk0003z0000Dw0000zk0003z0000Dw0000zk0003z0000Ds0000zU0003y0000Ds0000zU0003y0000Ds2",

    ; Map pages
    "NextPage", "|<>*180$41.y00007zw00007zs00007zk00007zU00007z000007y000007w000007s000007k00000DU00000T000000y000001w000003s00000Dk00000Tk00001zU00007z00000Ty00001zw00007zs0000Tzk0001zk",
    "PreviousPage", "|<>*181$42.zk0000DzU0000Dz00000Dy00000Dw00000Ds00000Dk00000Dk00000DU00000DU00000DU00000Dk00000Ds00000Ds00000Tw00000Ty00000Tz00000TzU0000Tzk0000TU",

    ; Settings button
    "Settings", "|<>*200$28.zk0zzz03zzw0Dyzk0Tnz01wDw000zk003z0000s00001zU00DzU00zz007zy00zzw03zzk0Tzz01zzw07zzkkTzz31zzwA3zzksDzz30zzs81zzU01zw001z0000000000y",

    ; OK button
    "OK", "|<>*125$78.000000000000000000000000000000000000000000000000000000000000000000000007w1w000000000Dzzzy00000000Dzzzy000003zkC0T0T00000DzwC0S0D00000z1zA0Q0D00001w0Dg0Q0S00003k03w0M0w00007U01w0k1w00007000w0k1s0000C000w003k0000C000Q007k0000Q000Q007U0000Q0Q0Q00D00000Q0y0A00S00000M1z0A00S00000s1z0A00Q00000s1z0A00Q00000s1r0Q00C00000s1z0Q00D00000w0y0Q00700000Q0Q0Q007U0000Q000Q003U0000S000w001k0000C000w0U1k0000D001w0k0s00007U03w0s0w00007s07w0s0Q00003y0Tw1w0Q00001zzzQ1y7y00000zzyQ1zzw00000TzwTzzzw000007zkTzzzs00000000Tzry000U",

    ; CHIMPS OK button
    "CHIMPS OK", "|<>*187$72.zzzzzzzzzzzzzzzzzzw1w0zzzzzzzzs1w0zzzzzw3zs1s1zzzzzk0Ts1k3zzzzz00Ds1k3zzzzy007s3U7zzzzy003s30Dzzzzw001s30Tzzzzs001s00Tzzzzs1s0s00zzzzzs3w0s01zzzzzk7y0s01zzzzzk7y0s03zzzzzk7y0s01zzzzzk7y0s00zzzzzk7y0s00zzzzzs3w0s00Tzzzzs1w1s00Tzzzzs001s20Dzzzzw003s20Dzzzzw003s307zzzzy007s3U3zzzzz00Ds3k3zzzzzk0Ts3k1zzU",
)


global GameModeLockPatterns := Map(
    ; Each lock pattern should be UNIQUE to that
    ; specific locked game mode.
    ;
    ; This means Sandbox being locked elsewhere on
    ; the screen will not affect detection.

    "Primary Only", "|<>*88$62.0003z000000000zs000000007y000000001zk00Tzk000Ty01zzw0007zk3zzz0000zyDzzzk000Dzzzzzw0003zzzzzz0000zzzzzzk000Dzzzzzw0003zzzzzz0000zzzzzzk000Tzzzzzw0007zzzzzz0001zzzzzzk000Tzzzzzw000Dzzzzzz0003zzzzzzk000zzzzzzw000Tzzzzzz0007zzzzzzk003zzzzzzw001zzzzzzz000zzzzzzzk00Tzzzzzzw00Tzzzzzzz00zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz0Tzzzzzzzzk7zzzzzzzzw1zzzzzzzzz0zzzzzzzzzkDzzzzzzzzw3zzzzzzzzz1zzzzzzzzzs",
    "Deflation", "|<>*109$66.00Tzzzzzzzz00Tzzzzzzzz00Tzzzzzzzz00Tzzzzzzzz00Tzzzzzzzz00Tzzzzzzzz00Tzzzzzzzz00Tzzzzzzzz00Tzzzzzzzz00zzzzzzzzz00zzzzzzzzz00zzzzzzz7z01zzzzzzw1z01zzzzzzw0z03zzzzzzs0T03zzzzzzs0707zzzzzzs010Dzzzzzzs000zzzzzzzs003zzzzzzzs00zzzzzzzzw00zzzzzzzzy00zzzzzzzzy00zzzzzzzzz00zzzzzzzzzk0zzzzzzzzzs0zzzzzzzzzw0zzzzzzzzzw0zzzzzzzzzy0zzzzzzzzzzUzzzzzzzzzzkzzzzzzzzzzszzzzzzzzzzwU",

    "Military Only", "|<>*132$58.001zzzzzw0007zzzzzk000Tzzzzz0001zzzzzw0007zzzzzU008Tzzzzy001XzzzzzU004Dzzzzw000EzzzzzU0037zzzzw000MTzzzzk0033zzzzzU00QDzzzzy0071zzzzzs0DsDzzzzzU0w1zzzzzz000Dzzzzzw003zzzzzzk0zzzzzzzzU3zzzzzzzy0Dzzzzzzzs0zzzzzzzzk3zzzzzzzz0Tzzzzzzzw7zzzzzzzzkzzzzzzzzzjs",
    "Apopalypse", "|<>*103$69.00C00000000000k0000000000600000000000k0000000000600000000000s0000000000300000000000M0000000000300000000s00s0000000T00700000007s00k0000003z0060000000Ts00k0000007z00CU7z0001zs01w7zzU00Dz00DXzzzU03zs03szzzy00Tz00TDzzzs07zs07vzzzzU0zz00zTzzzy0Dzs0Drzzzzs1zz03yzzzzz0Dzs0zbzzzzw1zz0TxzzzzzUDzszzDzzzzw1zzzzlzzzzzUDzzzwDzzzzw1zzzz3zzzzzkDzzz0Tzzzzy0zzz03zzzzzk7zw00Tzzzzy0TzU03zzzzzk1zw00Tzzzzw07zU03zzzzzU0Ty00Dzzzzw00zk01zzzzzU01y00Dzzzzw000k01zzzzz0006007zzzzs000U",
    "Reverse", "|<>*145$69.000zzzzzzzzs007zzzzzzzz000zzzzzzzzs017zzzzzzzz00Mzzzzzzzzs037zzzzzzzz00Mzzzzzzzzs037zzzzzzzz00lzzzzzzzzs06Dzzzzzzzz01lzzzzzzzzs0ATzzzzzzzz03Xzzzzzzzzs0sTzzzzzzzz0S7zzzzzzzzzzVzzzzzzzzzzkTzzzzzzzzzk7zzzzzzzzz03zzzzzzzzzs3zzzzzzzzzzzzzzzy7zzzzzzzzzz0TzzzzzzzzzU3zzzzzzzzzk0Dzzzzzzzzs01zzzzzzzzy00Dzzzzzzzz000zzzzzzzzk007zzzzzzzs000zzzzzzzy0007zzzzzzzU000Tzzzzzzk0003zzzzzzw0000Tzzzzzz00003zzzzzzk0000Tzzzzzw00001zzzzzy00000DzzzzzU00001zzzzzs00000Dzzzzy000001zzzyzU00000Dzzzbs000001zzzsy000000Dzzy7U000001zzzUs000000Dzzs60000000zzy0U0000007zzU00000000zzs000000007zz000000000zzk0U",

    "Magic Monkeys Only", "|<>*102$63.001U00Tzzzs0060s1zzzz000sDU7zzzs0071w0Dzzw001wTU0Tzy000DXw00Dw0001yTk0000000Dnz00000001zzz0000000Tzzw0000003zzzs000000TDzzs003007tzzzs03s00z7zzzzzz00Dkzzzzzzs01y7zzzzzz00TkTzzzzzs07w3zzzzzz01z0Tzzzzzs0zs3zzzzzz1zy0TzzzzzzzzU3Dzzzzzzzs0NzzzzzsTw037zzzzzzy00MTzzzzs00031zzzzz0000M7zzzzs00030Tzzzz0000s1zzzzs000607zzzz0000k0Tzzzs000C03zzzz0001U0Tzzzs000Q03zzzz000700Tzzzs000s03zzzz000C00Tzzzs003U03zzzz000s00Dzzzs00S001zzzzU",
    "Double HP MOABs", "|<>*102$42.01zU00000zU00000zk00000zk00001zk00001zk00001zs00001zs00001zw00003xw00003ty00003szU0007szk0007sTs000DkTy000DkDzU00TkDzw00zU7zzz1zU7zzz7z03zzzzy01zzzzw00zzzzs00Tzzzk00Tzzz000Tbzk000zDz0000yTz0000yTz0000yTz0000yTz0000wTz0000wTz0000yTz0000yTz0000yTz001zyDzU",
    "Half Cash", "|<>*132$26.00DrE03yQ00zj00Dbk03lw0Ew50AT0E27k40Vw00Mz00ADk067s03Vy03UzU3kTk0UDw007y007zU0zzk0Dzs03zy00zzk0Dzy03wTk003y000Tk003y000Tk003w000T0003s003w000z000rk00zy00zjk0Txw8",
    "Alternate Bloons Rounds", "|<>*107$34.007y0400Tw0E01zs1007zU000Tz0001zy0007zs000Tzk001zz0007zy000Tzs001zzU007zz000zzw003zzk00DzzY01zzyE07zzv00zzzw07zzzk0zzzz07zzzw0zzzzkTzzzzU",
    "Impoppable", "|<>*112$38.00Dzzzk03zzzw00zzzz00Dzzzk03zzzw00zzzz00Dzzzk07zzzw01zzzz00Tzzzk07zzzw03zzzz00zzzzk0Tzzzw0Dzzzz07zzzzk3zzzzw1zzzzz3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU07zzy000zzw000Dzy0003zz0000zz00008",
    "CHIMPS", "|<>*115$31.00D0000700003k0001s0000w0000T0000DU0007k0003s0001w0000y0000z0000T0000DU0007k0006s0003Q0003g0003a0003X0003V0003bU00Dzw01zzz00zzzs0Tzzy0TzUzUDy0DsDkA1yD000TX0007xU001zk000Ts0007w0001y0000D00003k"
)


NavigateToMap(
    category,
    mapName,
    difficulty,
    gameMode,
    hero := false
) {
    if !OpenPlayMenu() {
        ToolTip(
            "Could not reach map selection screen."
        )

        return false
    }

    if hero {
        if !OpenHeroSelection() {
            ToolTip(
                "Could not open hero selection."
            )

            return false
        }

        if !SelectHero(hero) {
            ToolTip(
                "Could not select hero: "
                hero
            )

            return false
        }

        Send("{Esc}")

        Sleep(1000)
    }

    if !FindAndClickMap(
        category,
        mapName,
        15
    ) {
        return false
    }

    Sleep(500)

    if !SelectDifficulty(difficulty) {
        ToolTip(
            "Could not select difficulty: "
            difficulty
        )

        return false
    }

    HandleSavePrompt(700)

    Sleep(150)

    modeResult := SelectGameMode(
        gameMode
    )

    if modeResult = "Locked" {
        ToolTip(
            "Game mode is locked:"
            "`n" gameMode
        )

        Sleep(1200)

        ToolTip()

        return "Locked"
    }

    if modeResult = false {
        ToolTip(
            "Could not select game mode: "
            gameMode
        )

        return false
    }

    HandleSavePrompt(4000)

    if !HandleModePrompt(
        gameMode
    ) {
        return false
    }

    return true
}

OpenPlayMenu() {
    global NavigationPatterns

    ; Clear Home-menu interruptions before trying Play.
    ; This returns immediately when no configured popup
    ; pattern is visible.
    HandleHomeMenuInterruptions()

    if NavigationPatterns.Has(
        "MapScreen"
    ) {
        if PatternExists(
            NavigationPatterns[
                "MapScreen"
            ]
        ) {
            return true
        }
    }

    if !NavigationPatterns.Has(
        "Play"
    ) {
        ToolTip(
            "Play pattern is missing."
        )

        return false
    }

    playPattern :=
        NavigationPatterns[
            "Play"
        ]

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
        ToolTip(
            "Could not find Play button."
        )

        return false
    }

    Click(X, Y)

    Sleep(700)

    if NavigationPatterns.Has(
        "MapScreen"
    ) {
        Loop 10 {
            if PatternExists(
                NavigationPatterns[
                    "MapScreen"
                ]
            ) {
                return true
            }

            Sleep(200)
        }

        ToolTip(
            "Play was clicked, but map screen "
            "was not detected."
        )

        return false
    }

    return true
}

OpenHeroSelection() {
    Click(
        97,
        991
    )

    Sleep(500)

    return true
}

TryClickCurrentMap(mapName) {
    global MapData

    if !MapData.Has(
        mapName
    ) {
        ToolTip(
            "Unknown map: "
            mapName
        )

        return false
    }

    mapPattern :=
        MapData[
            mapName
        ].pattern

    Loop 4 {
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

        Sleep(200)
    }

    return false
}

FindAndClickMap(
    category,
    mapName,
    maxPageChanges := 15
) {
    global MapData
    global NavigationPatterns

    if !MapData.Has(
        mapName
    ) {
        ToolTip(
            "Unknown map: "
            . mapName
        )

        RequestLauncherCycleStop()

        Sleep(1800)
        ToolTip()

        return false
    }

    if !NavigationPatterns.Has(
        category
    ) {
        ToolTip(
            "Could not find map category control."
            . "`nCategory: "
            . category
        )

        RequestLauncherCycleStop()

        Sleep(1800)
        ToolTip()

        return false
    }

    ; Search the page the user is currently on first.
    if TryClickCurrentMap(
        mapName
    ) {
        return true
    }

    categoryPattern :=
        NavigationPatterns[
            category
        ]

    ; Never use the left/right map arrows.
    ; Clicking the category icon cycles through
    ; that category's map pages and wraps around.
    Loop maxPageChanges {
        if !FindText(
            &X,
            &Y,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            categoryPattern
        ) {
            ToolTip(
                "Could not find category button: "
                . category
            )

            RequestLauncherCycleStop()

            Sleep(1800)
            ToolTip()

            return false
        }

        Click(X, Y)

        Sleep(550)

        if TryClickCurrentMap(
            mapName
        ) {
            return true
        }
    }

    ToolTip(
        "Could not find map: "
        . mapName
        . "`nStopped after "
        . maxPageChanges
        . " page changes."
    )

    RequestLauncherCycleStop()

    Sleep(2200)
    ToolTip()

    return false
}

SelectDifficulty(difficulty) {
    global NavigationPatterns

    if !NavigationPatterns.Has(
        difficulty
    ) {
        ToolTip(
            "Unknown difficulty: "
            difficulty
        )

        return false
    }

    pattern :=
        NavigationPatterns[
            difficulty
        ]

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
        ToolTip(
            "Could not find difficulty: "
            difficulty
        )

        return false
    }

    Click(X, Y)

    Sleep(500)

    return true
}

SelectGameMode(gameMode) {
    global NavigationPatterns

    if !NavigationPatterns.Has(
        gameMode
    ) {
        ToolTip(
            "Unknown game mode: "
            gameMode
        )

        return false
    }

    pattern :=
        NavigationPatterns[
            gameMode
        ]

    lockedHits := 0

    Loop 30 {
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

            Sleep(700)

            return true
        }

        if A_Index >= 5 {
            if IsGameModeLocked(
                gameMode
            ) {
                lockedHits++

                if lockedHits >= 3
                    return "Locked"
            }
            else {
                lockedHits := 0
            }
        }

        Sleep(150)
    }

    ToolTip(
        "Could not find game mode: "
        gameMode
    )

    return false
}

IsGameModeLocked(gameMode) {
    global GameModeLockPatterns

    if !GameModeLockPatterns.Has(
        gameMode
    ) {
        return false
    }

    pattern :=
        GameModeLockPatterns[
            gameMode
        ]

    if pattern = ""
        return false

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

HandleSavePrompt(
    timeout := 4000
) {
    global NavigationPatterns

    if !NavigationPatterns.Has(
        "OK"
    ) {
        return true
    }

    pattern :=
        NavigationPatterns[
            "OK"
        ]

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

            Loop 20 {
                Sleep(100)

                if !FindText(
                    &CheckX,
                    &CheckY,
                    0,
                    0,
                    A_ScreenWidth,
                    A_ScreenHeight,
                    0,
                    0,
                    pattern
                ) {
                    Sleep(300)

                    return true
                }
            }

            Click(X, Y)

            Sleep(500)

            return true
        }

        if (
            A_TickCount
            - startTime
            >= timeout
        ) {
            return true
        }

        Sleep(100)
    }
}

HandleModePrompt(gameMode) {
    global NavigationPatterns

    if (
        gameMode != "CHIMPS"
        && gameMode != "Deflation"
    ) {
        return true
    }

    if !NavigationPatterns.Has(
        "CHIMPS OK"
    ) {
        ToolTip(
            "Mode confirmation pattern is missing."
        )

        return false
    }

    pattern :=
        NavigationPatterns[
            "CHIMPS OK"
        ]

    Sleep(250)

    Loop 30 {
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

            Sleep(700)

            return true
        }

        Sleep(150)
    }

    ToolTip(
        "Could not find mode confirmation OK."
        . "`nMode: "
        . gameMode
    )

    Sleep(1500)

    ToolTip()

    return false
}

WaitForGameLoad(
    timeout := 15000
) {
    global NavigationPatterns

    if !NavigationPatterns.Has(
        "Settings"
    ) {
        ToolTip(
            "Settings pattern is missing."
        )

        return false
    }

    pattern :=
        NavigationPatterns[
            "Settings"
        ]

    startTime :=
        A_TickCount

    Loop {
        if PatternExists(
            pattern
        ) {
            Sleep(1000)

            return true
        }

        if (
            A_TickCount
            - startTime
            >= timeout
        ) {
            ToolTip(
                "Game failed to load."
            )

            return false
        }

        Sleep(200)
    }
}

RequestLauncherCycleStop() {
    stopFile :=
        A_Temp
        . "\BTD6EverythingMacro_StopCycles.flag"

    try {
        FileDelete(
            stopFile
        )
    }

    try {
        FileAppend(
            "STOP",
            stopFile,
            "UTF-8"
        )
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

ClickPattern(
    pattern,
    delay := 500
) {
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
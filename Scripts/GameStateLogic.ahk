global GameStatePatterns := Map(
    "VictoryNext", "|<>*168$107.zU0TU7k00DU3U7U003z00T0D000DU60T0007y00y0S000T040y000Dw00w0w0Q0z003w000zs01s1k1w1y007zs0zzk01k3U7s1y00Tzk1zzU030D0Dk3w01zzU3zz0020S0TU7w03zz07zy0000w000Dw0Dzy0Dzw0E01k000Ts0Tzw0Tzs0U03U001zU0zzs0zzk3U07003zz00zzk1zzU700D07zzw00zzU3zz0C00S0Tzzk01zz07zy0S00w0TzzU01zy0Dzw0w01s0TXy003zw0Tzk1w03s087s0k3zs0zzU3s07k00Dk1U3zk1zz07k0DU00z07U7zk3z",
    "VictoryHome", "|<>*198$71.zzzzU0Tzzzzzzzzy00Tzzzzzzzzs00TzzzzzzzzU00Tzzzzzzzy000Tzzzzzzzw000Tzzzzzzzk000zzzzzzzz0000zzzzzzzw0000zzzzzzzk0000zzzzzzzU0001zzzzzzy00001zzzzzzs00001zzzzzzU00001zzzzzy000001zzzzzw000003zzzzzk000003zzzzz0000003zzzzw0000003zzzzs0000007zzzzU0000007zzzy00000007zzzs00000007zzzk0000000Dzzz00000000Dzzw00000000Dzzk00000000DzzU00000000Dzy000000000Tzs000000000Tzk000000000Tz0000000000Tw0000000000zs0000000000zk0000000000zU0000000000z00001zs0001y0001zzk0003w0003zzU000Dzz007zz001zzzy00Dzy007zzzw00Tzw00Dzzzs00zzs00zzzzk01zzk01zzzzU03zzU03zzzz003zz007zzzy007zy00Dzzzw00Dzw00Tzzzs00Tzs00zzzzs00zzk01zzzzk01zzU03zzzzU03zy007zzzz007zw00Tzzzy00Dzs00zzzzw0000001zzzzs0000003zzzzk0000007zzzzU000000DzzzzU000000Tzzzz0000001zzzzy0000003zzzzz0000zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",

    "Defeat", "|<>*69$440.zk00003z0000Dy00000TzzzU7zw00000DzzzzU00007zzzs1zzs000000000007y0Ds00003zzw00000zU0001zU00003zzzU1zz000003zzzzs00000zzzs0Tzw000000000001zU3y00000zzz00000DU0000Ts00000TzzU0Tzk00000zzzzz000007zzs07zz000000000000Ts0zU0000Dzzk00003U00007z000001zz007zw00000Dzzzzk00000Tzs01zzk000000000007z0Ds00003zzw00000000001zk000007z001zz000003zzzzw000001zk00Tzs000000000000zk3y00000zzz00000000000Tw0000000000Tzk00000zzzzz00000000007zy000000000000Dw0zU0000Dzzk00000000007zU0000000007zw00000Dzzzzs0000000001zzU000000000003z0Dw00003zzw00000000001zs0000000001zz000003zzzzy0000000000Tzk000000000000Ts3z00000zzz00000000000Ty0000000000zzk00000zzk3zU0000000007zw0000000000007y0zk0000Dyzk00000000007zk000000000Dzw00000Dz00zw0000000001zz0000000000001zUDw00003zjw00000000003zw0000000003zz000003zk07z0000000000zzU000000000000Tw3z00000zvz00000000001zz0000000000zzk00000zw01zs000000000Dzs0000000000003z0zk0000Dyzk0000000000zzs000000000Dzw00000Dz00Ty0000000003zy0000000000000zkDw00003zjw0000000000Dzy0000000003zz000003zk03zk000000000zzU000000000000Dw3z00000zvz00000000007zzk000000000zzk00000zw00zw000000000Dzk0000000000001zUzk0000Dyzk0000000003zzw000000000Dzw00000Dz00Dz0000000003zw0000000000000TsDw00003zjw0000000001zzzU000000003zz000003zk01zs000000000zz00000000000007y3z00000zvz0000000001zzzw000000000zzk00000zw00Tz000000000DzU00000Tz000000zkzk0000Dyzk000000000zzzz000000000Dzw00000Dz007zk000000003zs00000Dzs00000DwDw00003zjs000000000Tzzzs000000007zz000003zk00zy000000000zy000003zy000003z3z00000zvy000000000Dzzzz000000001zzk00000zw00Dzk00000000Dz000000zzU00000zkzk0000DyzU00000000Dzzzzk00000000Tzw00000Dz001zy000000007zk00000Tzw000007y7w00003zjs000000007zzxzy000000007zz000003zk00Tzk00000001zw000007zz000001zVz00000zvy000000007zzyTzk00000001zzk00000zw003zw00000000Ty000001zzk00000TsTk0000DyU",

    "Restart", "|<>*220$72.zzzs00003zzzzzzk00000Tzzzzz000000Dzzzzy0000003zzzzw0000001zzzzs0000000zzzzk0000000Tz7zU0000000Dz0T000000007z07000000003z00000Dy0001z00000zzU000z00003zzs000T0000Dzzy000TU000Tzzz000DU000zzzzU007U000zzzzk007k000Dzzzs003k0001zzzw003k0000zzzy001k0000Dzzy001s00007zzz001s00003zzzU00s00001zzzU00w00001zzzk00w00003zzzk00w0000Dzzzs00y0000Tzzzs00y0001zzzzs00y0007zzzzs00y000Tzzzzw00z000zzzzzw00z003zzzzzw00z00Dzzzzzw00zU0zzzzzzw00zU3zzzzzzw00zUDzzzzzzw00zkzzzzzzzw00zzzzzzzzzw00zzzzzzzzzw00zzzzzzzzzs00zzzzzzzzzs00zzzzzzzzzs00zzzzzzzzzk00zzzzzzzzzk00zzzzzzzzzU00zzzzzzzzzU01zzzzzzzzz001zzzzzzzzz003zzzzzzzzy003zzzzzzzzw007zzzzzzzzs007zzzzzzzzs00DzzzzzzzzU00Dzzw7zzzz000Tzzs1zzzy000Tzzs0Dzzs000zzzk00Dy0001zzzk00000003zzzk00000007zzzk00000007zzzk0000000Dzzzk0000000zzzzk0000001zzzzs0000003zzU",
    "Restart Confirm", "|<>*156$52.s00zDU3tzU00xw07ji001zU0Dwk003w00TX000DU01wA0w0Q003Uk3s1k00C30DU70C0sA0y0s1w3Uk3s3U7kC30DUC0z0sA0w0s003Uk003U00D3000S000yA001s01zwk00TU7zzz001y0Tzzs",

    "LevelUp", "|<>*155$149.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzs7zw03zzzzzzzzw03zzzzk1zy01zs07zzzzzzU3k03zw7zU1zk01zk0Dzzz07y07001w07y03z001zU0Tzzy03w0A003w0Dw0Dw001z00zzzw0Ds0E003s0Ts0Tk001y03zzzk0Tk0U007k0zk0zU003w07zzzU0zU10007U0zU3y0003s0Dzzz01z02000DU1y07s0007k0Tzzy03y04000T03w0Dk000DU0zzzw07w081w0S07s0TU0w0D01zzzs0Ds0E7s0y07k1y03w0S03zzzk0zk0UDs1w0D03w0Ds0w07zzzU1zU10zk3w0S07s0Tk1s0Dzzz03z021z07s0w0Dk0zU3k0Tzzy07y04100Dk0s0z01U07U0zzzw0Dw08000Tk1U1y0000D01zzzs0Ts0E000zU303w0000S07zzzk0zk0U001z0207s0001w0DzzzU1zU1000zz040Tk000Ts0Tzzz03y0603zzy000zU01zzk0zzzy07w0A3zzzw001zU1zzzU0zzzw0Ds0M7zzzw007z03zzz000Dzs0Dk0k7zrzs00Dy07zzy000Tzs0T03U7yDzk00Tw07z7w000zzk0y0707kTzk00zs03kDs001zzU0s0S000zzU03zs000zk003zz00U0w001zz007zk001zU007zz0003s003zz00Dzk003z000Tzy0007k007zy00TzU007w000zzy000TU00Tzw01zzU00Ds001zzw001z000zzw03zzU00Tk003zzw007zU01zzs07zzU00zU3zzzzw00TzU07zzs1zzzk03zzzzzzzy01zzk0zzzzzzzzs0zzzzzzzzz0TzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU",

    "MonkeyUnlock", "|<>*148$86.zzzzbzz01zk01zzzzzxzzk1zzU1zzw1sDw0Q1zzw0zzD0M1z070z0TUzU3k00Dk1kT01wD00s001w0QDU07bU0C000T073k00zk03U007k1ls007s00s0M0w0ww001y00C0C0D0DD000D003U3k3k3nU003k00s1w0w0xs1w0s0DC0T0D0DS0zUC0DnU7k3k3b0Ds3U7ws1w0w0tk3y0s1zC0T0D0Dw0zUC0T3U7k3k3z0Ds30D0s1w0w0zs3y0k3nS0T0D0Dy0T0C0TrU7k3k03U007U7xs1w0w00w001s0zy0S0D00D000S00DU7U3k01s00Dk03s1s0w00T007w00y0S0D007s03zU0DU7U3k03zU3zw03k1s0w1zzzjzTU0y1zzzzzzzzzXw0Dzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy",

    "NewBloonOK", "|<>*154$120.0000000003y1y00000000000000007zzzy0000000000000A0Dzzzz0000000000003zsDzzzz000000000000DzyC0T0D000000000000zzzC0S0D000000000001y0Ti0S0T000000000003s07y0Q0T000000000003k01y0M0y000000000007U00y0M1w00000000000D000y0E3s00000000000D000S003s00000000000C000C007k00000000000S0A0C00DU00000000000Q0z0C00DU00000000000Q0z0C00T000000000000Q1zUC00S000000000000Q1zUC00S000000000000Q1zUC00D000000000000Q0zUC00D000000000000Q0z0C007U00000000000S0S0C003U00000000000S000S003k00000000000S000S0U1s000000zzzzzz000y0k1zzzzzzzzzzzzzU01y0s0zzzzzzzzzzzzzk03y0s0zzzzzzzzzzzzzs07y0w0Tzzzzzzzzzzzzy0Ty0y0Tzzzzzzzzzzzzzzzy0y3zzzzzzzzzzzzzzzzy0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU",

    "LoginNotNow", "|<>*173$169.DzkTy000000003zwDzU0000000w0DzwzzUTw3zzzw3zzDzsDz01z00zz7zzTztzzVzzzy3zzjzwTzsTzzzzzrU3y0xzzxs007Vk1z0CTzzTzzzwTzU1y0Dw0Ts001ks0TU7y07zkTzy0Tk0T07s03w000sQ0Dk3y01z0DUD0Ds0DU7s00y000QC03s1y00DU3k7U7Q03k3s00D000C701w0y003k1k3k3i01s1s003U0073U0S0S001s0s1s1r00Q0w001k003Vk0D0C000S0Q0w0vU0C0Q000s003ks03U7000D0C0C0Rk030C0A0Ts0zsQ01k70303U7060Ss01U60TUDy0TsC00M3U7k1k3U30CQ00E70Dk3z0Dw700A1k7w0s1U1U7C0003U7w1zU7w3U000s3y0Q0E0k3b0801k7y0zk3U1k200Q1zUD08081nU400s1z0Ss1k0s100C0vU7U4040tk300Q0zUDQ0s0Q0k070Tk3k2020ws1U0C0TU7C0Q0C0M03U7s1s0000SQ0s07U7U3b0C070A01k1s1w01U0CC0Q01k003nU703U700w000z00k0770D00s001tk3U3k3U0S000TU0M03XU7U0S001ss1k1s1s0DU00Tk0A01lk3k0DU00wQ0s0w0w07s00Ts0701ss1w0Ds00wC0Q0S0S03w00TQ03U0sQ0y07y01y70C0C0TU1zU0TC03k0QC0T03zk3y3U7070Dk0zw0zbU1s0C70Dkzzzzy1k7U3k7wDxzzzXk0w073zzzztzzy0zzk1zzzzyTzzUzzz03VzzzzwDzy0Tzk0zzzzz7zz0Tzzzzkzzzzw1zw0Dzs0Dzvzz0zy0DzzzzkDznzU07U03zs07zwzs01s07zzzzs00000000000000000000001zyTzw4",
    "CloseDLC", "|<>*135$186.zk001s0007zw00TzU0U0Tk0007U0Tw0zk001s0003zs007zU000Dk0007U0Tk0zk001s0001zk003zU0007k0007U0Tk0zk001s0001zU001zU0007k0007U0zU0zk001s0000z0000zU0007k0007U0z00zk001s0D00y0000zU0803k0007U0z00zk0Dzs0TU0y0000TU0Q03k0007U0y00zk0Tzs0Tk0w0000TU0y03k0007U0y01zk0Tzs0Tk0w0000D00y03k00DzU0w07zk0Dzs0Tk0s07k0D00y03zs0DzU0w0Dzk003s0Tk1s0Ds0D01y03zs0DzU0w0Dzk003s0Tk1s0Tw0D01y03zs0DzU0w0Dzk003s0TU1s0Tw0D01y03zs0DzU0s0Dzk003s0T01s0zw0D01y01zs0DzU1s00zk003s0A01s0zw0D01y01zs0DzU1s00zk003s0001s0zw0D01y01zs0DzU1s00zk003s0003s0Tw0D01y01zs0DzU1s00zk0Dzs0007s0Tw0D01y01zs0DzU1s00zk0Tzs000Ds0Ds0D01y01zs0DzU1s03zk0Tzs000Ts0Dk0D01y01zs0DzU1s0DU",
    "BossRush", "|<>FFFFFF-0.90$45.000060600001y1z0000DkTs3zU1y3y1zz0DkzUTzw1y7w7zzkDlz1zzy1yTkDzzsDny3z3z1zzUTkDsDzs3w0zVzy0TU7wDzk7w0zXzy0zU7wTzs3w0zXzzUTU7sTzw3y1z3zzkTsTsTry1zzy3wTsDzzkTXz0zzw3wDw3zz0TUzkDzk3w7y0Ds0TUTk0003w1k0000D004",

    "MonkeyMoney", "|<>*138$299.0C3k1y000z07k0s1U0z000zy0Dzzw0M707s003w0T03k00DzU00S7U3y003y0DU1k3U0y003zw0Tzzs0sS0Ds00Ds0y07k00Tz000wD07y00Dw0S03U7U1y007zs0zzzk1kw0Ts00zk1w0DU00zy001wy0Dz01zk0w070D01y00Dzk1zzzU3ls0zw03zU3k0TU01zw003zw0TzUDzU1s0C0T03y00TzU3zzz07zk1zy0zz07U0zU03zs00Dzs0zzzzz03s0Q0z07y00zzUDzzy0zzU3zzzzy0DU1zU0Dzs1zzzszzzzzzzzzzs1z3zz07zzzzzzzzzzXzzzzzzzzzzzk1zzzz",
    "MKBook", "|<>*221$42.zzzzzzzzzzzzzzzzzzzzzzzzzk3zzzzzU1zzzzzU0zzzzz00zzzzy00Tzzzw00TDzzs00D3zzk00D1zzU00D0zzU00D0TzU00D0DzU00D0DzU00D0Dz000D0Dz000D0Dz000D0Dz000T0Dz000T0Dz000z0Dz000z0Dz001z0Tz003z0TzU07z0TzU0Tz0zzw3zz0zzzzzz0zzzzzz3zzzzzz7zzzzzzTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU",
)


global LastNewBloonPopupTick := 0


CheckGameState() {
    global GameStatePatterns


    ; Mid-game interruption screens can appear while
    ; waiting for rounds or while upgrading.
    if HandleLevelUpPopup() {
        return "Playing"
    }


    if HandleNewBloonPopup() {
        return "Playing"
    }


    if HandleMonkeyMoneyPopup() {
        return "Playing"
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
        GameStatePatterns["VictoryNext"]
    ) {
        return "Victory"
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
        GameStatePatterns["Restart"]
    ) {
        return "Defeat"
    }


    return "Playing"
}


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


IsHomeScreenVisible() {
    global NavigationPatterns


    if !IsSet(
        NavigationPatterns
    ) {
        return false
    }


    if !NavigationPatterns.Has(
        "Play"
    ) {
        return false
    }


    playPattern :=
        NavigationPatterns["Play"]


    if playPattern = "" {
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
        playPattern
    )
}


HandleVictory() {
    global GameStatePatterns


    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        GameStatePatterns["VictoryNext"]
    ) {
        return false
    }


    ReleaseMacroModifierKeys()


    Click(
        X,
        Y
    )


    Sleep(
        700
    )


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
            GameStatePatterns["VictoryHome"]
        ) {

            ReleaseMacroModifierKeys()


            Click(
                X,
                Y
            )


            Sleep(
                700
            )


            ReleaseMacroModifierKeys()


            ; Logged-out players can receive a login
            ; prompt after returning Home.
            HandleLoginNotNowPrompt(
                3000
            )


            ReleaseMacroModifierKeys()


            return true
        }


        Sleep(
            200
        )
    }


    ToolTip(
        "Could not find Home button after victory."
    )


    return false
}


HandleDefeat() {
    global GameStatePatterns


    if !GameStatePatterns.Has(
        "Restart"
    ) {

        ToolTip(
            "Restart pattern is missing."
        )


        return false
    }


    firstRestart :=
        GameStatePatterns["Restart"]


    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        firstRestart
    ) {

        ToolTip(
            "Could not find first Restart button."
        )


        return false
    }


    Click(
        X,
        Y
    )


    Sleep(
        500
    )


    ; Some modes show a second restart confirmation.
    if GameStatePatterns.Has(
        "Restart Confirm"
    ) {

        confirmPattern :=
            GameStatePatterns[
                "Restart Confirm"
            ]


        Loop 15 {

            if FindText(
                &X,
                &Y,
                0,
                0,
                A_ScreenWidth,
                A_ScreenHeight,
                0,
                0,
                confirmPattern
            ) {

                Click(
                    X,
                    Y
                )


                Sleep(
                    700
                )


                return true
            }


            Sleep(
                200
            )
        }


        ToolTip(
            "Could not find second Restart button."
        )


        Sleep(
            1500
        )


        ToolTip()


        return false
    }


    return true
}


ResetTowerSetup() {
    global TowerSetup
    global EliteSniperActive


    EliteSniperActive :=
        false


    ClearSelectedUpgradeTower()


    for name, tower in TowerSetup {

        tower.placed :=
            false


        if HasProp(
            tower,
            "upgrades"
        ) {

            tower.upgrades :=
                [0, 0, 0]
        }


        if tower.type = "Ace" {

            tower.targeting :=
                "Circle"
        }
        else {

            tower.targeting :=
                "First"
        }


        if tower.type = "Sub" {

            tower.targeting :=
                "First"


            tower.targetingBeforeSubmerge :=
                "First"


            tower.submerged :=
                false
        }
    }


    return true
}


ReleaseMacroModifierKeys() {
    SendEvent(
        "{LAlt Up}"
        . "{RAlt Up}"
        . "{LCtrl Up}"
        . "{RCtrl Up}"
        . "{LShift Up}"
        . "{RShift Up}"
        . "{LWin Up}"
        . "{RWin Up}"
    )


    Sleep(
        50
    )
}
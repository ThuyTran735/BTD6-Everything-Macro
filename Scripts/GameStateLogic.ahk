global GameStatePatterns := Map(
    "VictoryNext", "|<>*168$107.zU0TU7k00DU3U7U003z00T0D000DU60T0007y00y0S000T040y000Dw00w0w0Q0z003w000zs01s1k1w1y007zs0zzk01k3U7s1y00Tzk1zzU030D0Dk3w01zzU3zz0020S0TU7w03zz07zy0000w000Dw0Dzy0Dzw0E01k000Ts0Tzw0Tzs0U03U001zU0zzs0zzk3U07003zz00zzk1zzU700D07zzw00zzU3zz0C00S0Tzzk01zz07zy0S00w0TzzU01zy0Dzw0w01s0TXy003zw0Tzk1w03s087s0k3zs0zzU3s07k00Dk1U3zk1zz07k0DU00z07U7zk3z",
    "VictoryHome", "|<>*198$71.zzzzU0Tzzzzzzzzy00Tzzzzzzzzs00TzzzzzzzzU00Tzzzzzzzy000Tzzzzzzzw000Tzzzzzzzk000zzzzzzzz0000zzzzzzzw0000zzzzzzzk0000zzzzzzzU0001zzzzzzy00001zzzzzzs00001zzzzzzU00001zzzzzy000001zzzzzw000003zzzzzk000003zzzzz0000003zzzzw0000003zzzzs0000007zzzzU0000007zzzy00000007zzzs00000007zzzk0000000Dzzz00000000Dzzw00000000Dzzk00000000DzzU00000000Dzy000000000Tzs000000000Tzk000000000Tz0000000000Tw0000000000zs0000000000zk0000000000zU0000000000z00001zs0001y0001zzk0003w0003zzU000Dzz007zz001zzzy00Dzy007zzzw00Tzw00Dzzzs00zzs00zzzzk01zzk01zzzzU03zzU03zzzz003zz007zzzy007zy00Dzzzw00Dzw00Tzzzs00Tzs00zzzzs00zzk01zzzzk01zzU03zzzzU03zy007zzzz007zw00Tzzzy00Dzs00zzzzw0000001zzzzs0000003zzzzk0000007zzzzU000000DzzzzU000000Tzzzz0000001zzzzy0000003zzzzz0000zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
    "Defeat", "|<>*69$440.zk00003z0000Dy00000TzzzU7zw00000DzzzzU00007zzzs1zzs000000000007y0Ds00003zzw00000zU0001zU00003zzzU1zz000003zzzzs00000zzzs0Tzw000000000001zU3y00000zzz00000DU0000Ts00000TzzU0Tzk00000zzzzz000007zzs07zz000000000000Ts0zU0000Dzzk00003U00007z000001zz007zw00000Dzzzzk00000Tzs01zzk000000000007z0Ds00003zzw00000000001zk000007z001zz000003zzzzw000001zk00Tzs000000000000zk3y00000zzz00000000000Tw0000000000Tzk00000zzzzz00000000007zy000000000000Dw0zU0000Dzzk00000000007zU0000000007zw00000Dzzzzs0000000001zzU000000000003z0Dw00003zzw00000000001zs0000000001zz000003zzzzy0000000000Tzk000000000000Ts3z00000zzz00000000000Ty0000000000zzk00000zzk3zU0000000007zw0000000000007y0zk0000Dyzk00000000007zk000000000Dzw00000Dz00zw0000000001zz0000000000001zUDw00003zjw00000000003zw0000000003zz000003zk07z0000000000zzU000000000000Tw3z00000zvz00000000001zz0000000000zzk00000zw01zs000000000Dzs0000000000003z0zk0000Dyzk0000000000zzs000000000Dzw00000Dz00Ty0000000003zy0000000000000zkDw00003zjw0000000000Dzy0000000003zz000003zk03zk000000000zzU000000000000Dw3z00000zvz00000000007zzk000000000zzk00000zw00zw000000000Dzk0000000000001zUzk0000Dyzk0000000003zzw000000000Dzw00000Dz00Dz0000000003zw0000000000000TsDw00003zjw0000000001zzzU000000003zz000003zk01zs000000000zz00000000000007y3z00000zvz0000000001zzzw000000000zzk00000zw00Tz000000000DzU00000Tz000000zkzk0000Dyzk000000000zzzz000000000Dzw00000Dz007zk000000003zs00000Dzs00000DwDw00003zjs000000000Tzzzs000000007zz000003zk00zy000000000zy000003zy000003z3z00000zvy000000000Dzzzz000000001zzk00000zw00Dzk00000000Dz000000zzU00000zkzk0000DyzU00000000Dzzzzk00000000Tzw00000Dz001zy000000007zk00000Tzw000007y7w00003zjs000000007zzxzy000000007zz000003zk00Tzk00000001zw000007zz000001zVz00000zvy000000007zzyTzk00000001zzk00000zw003zw00000000Ty000001zzk00000TsTk0000DyU",
    "Restart", "|<>*220$72.zzzs00003zzzzzzk00000Tzzzzz000000Dzzzzy0000003zzzzw0000001zzzzs0000000zzzzk0000000Tz7zU0000000Dz0T000000007z07000000003z00000Dy0001z00000zzU000z00003zzs000T0000Dzzy000TU000Tzzz000DU000zzzzU007U000zzzzk007k000Dzzzs003k0001zzzw003k0000zzzy001k0000Dzzy001s00007zzz001s00003zzzU00s00001zzzU00w00001zzzk00w00003zzzk00w0000Dzzzs00y0000Tzzzs00y0001zzzzs00y0007zzzzs00y000Tzzzzw00z000zzzzzw00z003zzzzzw00z00Dzzzzzw00zU0zzzzzzw00zU3zzzzzzw00zUDzzzzzzw00zkzzzzzzzw00zzzzzzzzzw00zzzzzzzzzw00zzzzzzzzzs00zzzzzzzzzs00zzzzzzzzzs00zzzzzzzzzk00zzzzzzzzzk00zzzzzzzzzU00zzzzzzzzzU01zzzzzzzzz001zzzzzzzzz003zzzzzzzzy003zzzzzzzzw007zzzzzzzzs007zzzzzzzzs00DzzzzzzzzU00Dzzw7zzzz000Tzzs1zzzy000Tzzs0Dzzs000zzzk00Dy0001zzzk00000003zzzk00000007zzzk00000007zzzk0000000Dzzzk0000000zzzzk0000001zzzzs0000003zzU"
)


CheckGameState() {
    global GameStatePatterns


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


    Click(X, Y)
    Sleep(700)


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
            Click(X, Y)

            Sleep(1000)

            return true
        }

        Sleep(200)
    }


    ToolTip("Could not find Home button after victory.")

    return false
}


HandleDefeat() {
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
        GameStatePatterns["Restart"]
    ) {
        ToolTip("Could not find Restart button.")

        return false
    }


    Click(X, Y)

    Sleep(1500)

    return true
}


ResetTowerSetup() {
    global TowerSetup
    global EliteSniperActive


    EliteSniperActive := false


    for name, tower in TowerSetup {
        tower.placed := false


        if HasProp(tower, "upgrades")
            tower.upgrades := [0, 0, 0]


        if tower.type = "Ace"
            tower.targeting := "Circle"
        else
            tower.targeting := "First"


        if tower.type = "Sub"
            tower.targeting := "First"
            tower.targetingBeforeSubmerge := "First"
            tower.submerged := false
    }


    return true
}
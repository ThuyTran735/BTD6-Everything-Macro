#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

HeroPatterns := Map(
    "Quincy", [
        ; Archer Skin
        "|<>*198$71.7zzzzy00TzzyDzzzzU007zzwTzzzw0003zzszzzzk0003zzlzzzy00003zzXzzzs00003zz7zzz000003zyDzzw000007zwTzzs3w0007zszzzUDw000Dznzzz0zw000Tzbzzw3zs000TzDzzs7zk000zyzzzUTzU001zxzzz0zU0003zzzzy3zU0003zzzzs7zk0007zzzzkDzk000DzzzzUzzU000Tzzzz1zz0000zzzzy3zw0001zzzzw7zs0003zzzzsDzU0007zzzzsTz0000Dzzzzkzw0000zz",
        ; Cyber Quincy Skin
        "|<>*192$71.zzzzz0007zzzzzzzs0007zzzzzzz00007zzzzzzw00007zzzzzzk00007zzzzzz00000Dzzzzzw0s000Dzzzzzk7s000TzzzzzUTs000Tzzzzy1zs000zzzzzw7zk001zzzzzsDzU003zzzzzUTk0003zzzzz0zU0007zzzzy3zk000Dzzzzs7zk000TzzzzkDzU000zzzzzUzz0001zzzzz1zy0003zzzzy3zs0007zzzzw7zk000DzzzzwDz0000TzzzzsDy0001zzzzzsTs0003zzzzzkTU0007zz",
        ; Wolfpack Quincy Skin
        "|<>*197$71.Tzzzzw0007zyTzzzzU0003zwTzzzw00003zsTzzzk00003zkTzzz000007zUTzzw000007z0zzzs7k0007y1zzzUTk000Dw3zzz1zk000Ds7zzw7zk000TsDzzsDzU000zsTzzUTz0001zszzz1zy0003zXzzy3z00003x7zzs7y00007sDzzkDy0000DkTzzUzz0000TUzzz1zy0000z3zzw3zw0003y7zzs7zs0007wDzzkDzU000DszzzUTz0000Tlzzz0zw0000znzzz1zs0001zzzzy1zU0003z"
    ],

    "Gwendolin", [
        ; Pyromaniac Skin
        "|<>*136$71.zzzzzzzzzU01zzzzzzzzy003zzzzzzzzg007zzzzzzzwk00DzzzzzDzVU00Tzzzzlzw23k0zzzzwDzk4TU1zzzy1zz08z03zzzsTzy0Fw07zzzzzzw0Xs0Dzzzzzzk07zUTzzzzzzU0Dz0zzzzwzz00Tz1zzzzkzy00Ty3zzzzUTs00zw7zzzz0Tk01zsDzzzy0TU01zkTzzzy0T001zUzzzzw0C003z1zzzzs08001w3zzzzk00000k0Tzzzk00000000Dzws0000000007sA000000000TU4000001",
        ; Harlegwen Skin
        "|<>*168$71.0001s000/00000000000w00000000001M00000000003ks00000000073w000000000S7s000000000wTU0U0000001kz0300000003Vw06000000073zkC000000067zkQ0000000A7zUw0000000MDz1zzy00000sDz3zzzU0000kTy7zzzk0001UTwDzzzs00010zsM01zw00030zk0007q00020z00001y00060Q00000y0006000007UT000A00000DUD000A00000y0C000A00001w0C000A01",
        ; Scientist Gwendolin Skin
        "|<>*149$71.zzzzzzzzw001zzzzzzzzk003zzzzzzzzU007zzzzzzzy000Dzzzzzzzw000TzzzzzzzkS00zzzzzzzzXy01zzzzzzzv7s03zzzzzzzqDU07zzzzzzzcz00DzzzzzzzEy40TzzzzzzyVzs0zzzyzzzx3zs1zzzwzzjy7zk3zzzzzzTwDzk7zzzzzyzsDzUDzzzzjszkTz0TzzzzDlzUTy0zzzzzDVzUTw1zzzzzD3z0Ts3zzzzy67y0TU7zzzry07y0S0Dzzzzy0Dw000Dzzzzw0zw00000DsTw7zs001",
        ; Firecracker Gwen Skin
        "|<>*142$71.zzzzzzzzz001zzzzzzzzw003zzzzzzzzk007zzzzzzzz000Dzzzzzzzw000Tzzzzzzzs000zzzzzzzzU001zzzzzzzn0003zzzzwzy40007zzzz7zkM000Dzzzkzz0ks00Tzzw7zw13s00zzzVzzs2DU01zzzzzzU4T003zzzzzz08yM07zzzzzy01zk0DzzzkTw03zk0Tzzz0Ts03zU0zzzy0DU07zU1zzzy0700Dz03zzzw0600Dy07zzzs0400Dw0Dzzzk0000Ts0TzzzU0000TU0zzzz00000T01"
    ],

    "Striker Jones", [
        ; Artillery Commander Skin
        "|<>*142$71.zzzzzzzzzzzzzzzzzzzzzzzzkTzzzzzzzzzs0zzzzzzzzzzk0TzzzzzzzzzU07zzzzzzzzz101zzzzrzzzy600zzzzXzzzw800Tzzy3ztzss007zzw3zVzn7001zzk1z3zY1k00zz01w3yM0S00Dy01s3sU07U07s01k31000s01k01044000C000000MM0007k00000Xk0001w0E001D00000T0E003y00000TkU006w00001zxU009s00003zb000Hk00007zW000bU0000Tz2001D00000zz4002T",
        ; Biker Bones Skin
        "|<>*131$71.001sMs033zz0001sss063zy0001sss0M7zy0001sss0kDzw0001ssk1UTzs0001ss03Mzzk0001ss04nzzU0001ss0Nbzz3U001ss0nDzy7s001s01aTzwDw001k03AzzsTy000006Nzzszz00000AnzzVTzU0000Nbzz0Dzk0000nDzy0Dzs0001UTzw0Dzw00030zzs0Dzy00071zzk0Tzy000D7zzVkzzy000Tzzz3Uzzy000zzzw71zzy001zzzsC3zzy003zzzkQ7zzw013zzzUsDzzs037zzy1",
        ; Octojones Skin
        "|<>*129$71.zzzzzzzU7w01zzzzzzz0Dk03zzzzzzy0S007zzzzzzw0000Dzzzzzzs0000TzzzzzzU0000zzzzzzz00001zzzzzzy00003zzzzzzs00007zzzzzzk0000Dzzzzzz00000Tzzzzzy00000zzzzzzs00001zzzzzzU00003zzzzzz000007zzzzzw00000Dzzzzzk00000Tzzzzz000000zzzzzy000001zzzzzs000003zzzzzk800007zzzzz000000DzzzzyS00000Tzzzzs180000zzzzzU080001"
    ],

    "Obyn Greenfoot", [
        ; Forest Guardian Skin
        "|<>*179$71.0T1zzzzy3w000y3zzzzw7k000wDzzzzs7U001kTzzzzs600001zzzzzk000003zzzzzk00000DzzzzzU00000zzzzzzU00003zzzzzzU0000DzzzzzzU0000zzzzzzzU0007zzzzzzzU000Tzzzzzzzk003zzzzzzzzk00Tzzzzzzzzs07zzzzzzzzzy0DzzzzzzzzzzkTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
        ; Mountain Guardian Skin
        "|<>*134$71.VyQ00007XsDz1ws0000D7kTy3lk0000CDUzw7XU0000QT1zsD600000sy7zs4Q00000ksDzs0k00001lUTzs3U00001U0zzsS000003U3zzzs000003UDzzzU000007nzzzy0000007zzzzs0000007zzzzU0000007zzzw00000007zzzk00000003zzw000000003zzU000000001zz0200000000Tzzw000000w003zs000001zz07zk000003zzzzzU000003zzzzy0000007zzzzw000000Dzzz",
        ; Ocean Guardian Skin
        "|<>*157$71.0zz000007zs01jy00000Dyk02Dw00000TsU04TU00000Dl000y000000DW000s000000C0000U00000000000000000000000000700000000000zk0000000007zk000000000Q1k000000001U0k00000000600k00000000M00k00000000U00U00000000000000000000M3U000000007k7k00000000zkDs00020003zUPs000D000Db0ns001zU00yC3Xs007jU03sQ73s00yDUyDgsCPsy3t",
        ; Skeletor Skin
        ""
    ],

    "Dan D'Monke", [
        ; Courtly Monkey Skin
        "|<>*137$71.00003s00000000003U0000000000700000000000C000000000008000000M0000E000000y00000000001z0000000001zzk00000000zzzw0000000zzrzz000001zzzVzzk0001zzzz3zzs000zzzzs7zzs007zzzs0Dzzk00Dzzw003zzU00Tzzs007zC000zzzs00DyA000szzk00zwM001VlzU03zsk00333y007zlU00647w007zV000A0Ts007y200081zk007w4000EDz0007k0000Uzy01",
        ; He-Man Skin
        ""
    ],

    "Benjamin", [
        ; Code Monkey Skin
        "|<>*196$71.zzzTzzzU0zzzzzwzzzw00TzzzzvzzzU00Tzzzzrzzw000TzzzzjzzU000Tzzzzzzy0000Tzzzzzzk0000Tzzzzzz00000Tzzzzzw00000zzzzzzk00000zzzzzz000001zzzzzw000001zzzzzs000003zzzzzU000007zzzzy0000007zzzzw000000Dzzzzk000000TzzzzU000000zzzzy0000001zzzzw0000003zzzzs0000007zzzzU000000Dzzzz0000000Tzzzy0000000zzzzs0000001z",
        ; Benjammin DJ Skin
        "|<>*193$71.zzzk000001k1zzzU000003U3zzz000000701zw0000000C00000000000Q1U000000000uz0000000001yS000000000Dzw000000000zzs00000000y3zk0000000w03zU0000000003zT000DDU0003zzzzzzw00001zzzzzzU00003zzzzzy000003zzzzzs000007zzzzx000000Dzzzzk000000DzzzzU000000Tzzzy0000000zzzzs0000001zzzzk0000003zzzz00000003zzzy00000007",
        ; Sushi Bento Skin
        "|<>*120$71.Dzzzzzzzw0y0zzzzzzzzs1znzzzzzzzzk7zzzzzzzzzzkTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy01zzzzzzzzzw00Tzzzzzzzzs00Dzzzzzzy00007zzzzy0w0000Dzzy000s00000Dz0000M1zzjzzw000003zyTzzU000003zsTzw0000007zUzw00000007z1zk0000000Dw3y00000000Dk7k00000000DUC000000000S00000000000Q00000000000k00000000000U0000000001"
    ],

    "Template", [
        ;
        "",
        ;
        "",
        ;
        "",
        ;
        "",
        ;
        ""
    ],

)

SelectHero(heroName) {
    global HeroPatterns

    ; Make sure the hero exists
    if !HeroPatterns.Has(heroName) {
        ToolTip("Unknown hero: " heroName)
        return false
    }

    ; Get all skins belonging to this hero
    patterns := HeroPatterns[heroName]

    ; Try each skin
    for pattern in patterns {
        if FindText(&X, &Y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, pattern) {
            ToolTip("Found " heroName)
            Click(X, Y)
            return true
        }
    }

    ToolTip("Could not find " heroName)
    return false
}

Sleep(2000)
SelectHero("Obyn Greenfoot")
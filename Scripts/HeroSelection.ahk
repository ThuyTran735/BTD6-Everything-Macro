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

    "Pat Fusty", [
        ; Giant Monkey Skin
        "|<>*133$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz7zzzzzzzzzzk1zzzzzzzzzw00TzzzzzzzzU00zzzzzzzzzU03zzzzzzzzz007z3s00Dzjy00Dz0000DsTw00Ty000000zs00lw000001zk003s000003DU1",
        ; Fusty The Snowman Skin
        "|<>*152$71.000000000000000000000000000000000000000000000000000000000000000000000000z00000000001zs000003z007zkTs03Uzy00DzUzzzzVzy00TzXzzzz3zw00zz7zzzy7zs01zyDzzzwDzk03zsTzzzsTzU07y1zzzzszk00Dy3zzzzlzk00Dy7zzzzVzk00TwTzzzz3zU00zkzzzzz7y000zXzzzzy7w00007zzzzy000000Tzzzzw000001zzzzzw000007zzzzzw00000Tzzzzzw001",
        ; Kaiju Pat Skin
        "|<>*41$71.00000000000000000000000000000000000000000000000000000000000U0000000000700000000001y0000000000Dw0000000001zs000000000Dzk000000006TzU00000001wTz00000001XszyC000000z3lzwS800001z7XztwS00003y67zlly00007y0DzXXw00007w0zz0Dk00007w1zy0TU0000Ds7zw1w00000Dyzzw7k00000Dzzzzz000000Dzzzzw000000Dzzzzk000000Dzzz"
    ],

    "Captain Churchill", [
        ; Tank Skin
        "|<>*121$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzrzzzzzzzzzzU3zzzzzzzzzk0Bzzzzzzzzk001zzzzzzzzc003zzzzzzzz000Dzzzzzzzz000STzzzzzzy000sTkDTzvzw001kzUA1z7zs003Ur003sD1k0071b0070Q3U00C3600A0s3000Q6A00M1kC000M4800k3U0000k0E01070001",
        ; Sentai Churchill Skin
        "|<>*145$71.zzzzzzk0Tzk1zzzzzz01zz03zzzTzs07zy07zzwTzU0Dzs0TzzkTy00zzk0zzz0zs01zz03zzw0zU07zw0Dzzs0y00Tzs0TzzU0s01zzU1zzy00003zz03zzw0000Dzw0Dzzk0000Tzs0Tzz00001zzU1zzy00003zz03zzs0000Dzw0DzzU0000zzk0Tzz00001zzU1zzw00007zy07zzk0000Dzw0DzzU0000zzk0zzy00001zzU1zzw00007zy07zzk0000Dzw0Dzz00000zzk0zzy00003zzU3zz",
        ; Sleigh Churchill Skin
        "|<>*188$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzsTzXzzzzzzzzkzz0Tzy0TzzzVzy0zzw0zzUz3zw1zzk3zz007zs3zzU7zy00Dzk7zz0Dzw00TzU7zy0Tzs00zz0Dzw0zzk01zy0Tzs1zz003zw0zzk3zy007yM3zzU7zw007s07zz0Dls00Ds0Dzy0DVU00Ts0Tzw0TV000Ts0zzk0TU000TU1zy00TU000403zbU0T000000Dwz000000000Tby000000000wzw000000001zzw000000007zzs00001"
    ],

    "Ezili", [
        ; Voodoo Monkey Skin
        "|<>*143$71.0000003zkTy00000003zUzw00000003z1zw00000003y7zs00000003wDzk00000003sTz000000007kzy000000y07Vzw000003zU73zs00000DzkC3zU00000zzkC7z000001zzkQ7w000003zzkMDk000007zzkk0000000DzzUU0000000DzzV00000000Tzz000000000Tzy000000000Tzw000000000Tzk000000000TzU000800000Dy0000E000001U0001U0000000000700000000000D",
        ; Galaxili Skin
        "|<>*163$71.zzzw0Tzzzs01zzzk0zzzzk03zzzU0zzzzU07zzy01zzzy00DzzwDzzzzs00TzzlzzzzzU08zzzbzzzzz00NzzyDzzzzy00vzzwTzzzzy03rzzkzzzzzw07zzz1zzzzzy3zzzy3zzzzzzzzzzs7zzzzzzzzzzk7zzzzzzzzzz07zzzzzzwDzw07zzzzzzsTzk07zzzzzxUTzU03zzzzzX0zzw01z7zzw61zw00003zz0A3zk00000z00M7z000k00000sDw000E00000Nzo000M00000yzx000800000N",
        ; Smudge Catt Skin
        "|<>*141$71.00001zy3zs0Q00000zy7zk0s00000TwDzU1k00000TsTz03U00000Tkzy07000000TVzw0A000000TVzs0M000000T3zk0U000000S7z010000000S7y000000000Q7s000000Dy0M7U000000zyUkD0000003zzUkS000000DzzUUw000000TzzV0s000000zzz01k000001zzy03U000001zzw070000001zzs0C0000001zzk0Q0000001zz00s0000000zw01k0000000DU03U00000000007001"
    ],

    "Silas", [
        ; Ice Shaper Skin
        "|<>*174$71.00000000000y00000000000Q00000000000M00000000000E000000000000000000000000000000000000001000000000001000000000003U00000000007U0000000000DU0000000000TU0000000000zU0000000001zk0000zs0003zU0000zk0007zU0000zU000Dl00000z0000+000001y00004000001w00008000001s0000E000003k0000U000003U0001000000700000000000D"
    ],

    "Etienne", [
        ; Drone Operator Skin
        "|<>*148$71.000zzzzzzzzy001zzzzzzzzw001zzzzzzzzs003zzzzzzzzk007zzzzzzzzU007zzzzzzzz000Dzzzzzzzy000Dzzzzzzzw0007zzzzzzzs0003zzzzzzzk0001zzzzzzzU0001zzzzzzz00Dz0zzDzzzy07zzsTyDzzzw0zzzwDwTzzzk3zzzy7kTzjzkTzzzy1Uzy7zVzs0zy00zw3z7w007z01zk3yzU003y03z0Dzw0001y03y1zzU0001y07s7zy00000y07UTzs00000w0D1zzU00000w0Q7zz",
        ; ETn Skin
        "|<>*95$71.zzw000000001zzy000000003zzz000000007UTzU0000000A0DzU0000000k07zU0000003U07zU000000T007zUE00001y00DzU000007y00TzU00000TzU1zzU00001zzzzzzU00007zzzzzz00000Dzzzzzz00000zzzzzzz00003zzzzzzz0000Dzzzzzzy0000Tzzzzzzy0001zzzzzzzy0007zzzzzzzw000Dzzzzzzzw000zzzzzzzzs001zzzzzzzzk887zzzzzzzzk00DzzzzzzzzU10zzz",
        ; Book Wyrm Skin
        "|<>*142$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU0zzzzzzzzzz00yzzzzzzzzw01s3zzzzzzzs03U0zzzzzzzU0700Tzzzzz100400Dzzzy0200000Dzzzk0000000Dzzz00000000Tzzy00000000zzzs00000001zzzk01"
    ],

    "Sauda", [
        ; Swordmaster Skin
        "|<>*100$71.000000zzzk00000003zzzU0000000Dzzy00000000zzzs00000007zzzk0000000Tzzx00000003zzzk0000000Tzzz00000003zzzw0000000Tzzzk0000007zzzz0000000zzzzx0000007zzzzo000001zzzzyk00000Dzzzzv000001zzzzzg00000DzzzzzU00001zzzzzy000017zzzzrs00006zzzzyy00000Tzzzzzk00003zzzzzw00000DzzzzzU00001zTzzzw000007wzzzzU00000zl",
        ; Viking Sauda Skin
        "|<>*117$71.zzzzy1zzzzzzzzzzkDzzzzzzzzzy1zzzzzzzzzzkDzzzzTzzzzw3zzzzwzzzzzUTzzzzlzzzzy3zzzzz3zzzzUTzzzzw7zzzw7zzzzzkDzzzUzzzzzz0Tzzy7zzzzzw0zzzkzzzzzzU1zzy3zzzzzy03zzsTzzzzzk07zzXzzzzzy00DzyDzzzzzk00Tztzzzzzy000zzbzzzzz0001zzTzzzzy0003zzzzzzzw0007zzzzzzzs000Dzzzzzzzk000Tzzy3zzzU000zyTk0zzy0000zUz007zw0001s1",
        ; Jiangshi Sauda Skin
        "|<>*108$71.000007zzzzs000001zzzzzU00000zzzzzu00000DzzzzzU00003zzzzzw00000zzzzzzk0000Dzzzzzy00003zzzzzzk0030Tzzzzzy00073zzzzzzk0008Tzzzzzy00003zzzzzzU0000TzzzzzU00001zzzzzs000003zzzzzk000007zzzzzU00000Dzzzzz000000Tzzzzw000000znzzz0000001y1zzU0000003k0zy0000000600Tz0000000s007zU000007U001zk00000z0000Tk00007z"
    ],

    "Rosalia", [
        ; Tinkerer Skin
        "|<>*208$71.zzzzzzzzvzzzzzzzzzw0TzzzzzzzzxU07Tzzzzzzzw003TzzzzzzzU003zzzzzzzy0001zzzzzzzs0001zzzzzzzU0002zzzzzzy00002zzzzzzs00003zzzzzzk00007zzzzzz000007zTzzzy00000DyTzzzs00000Dwzzzzk00000TszzzzU03000Tkzzzz00TU00zVzzzw01zU01z1zzzs07z001y3zzzk0Dz003w3zzzU0Tz007z7zzz01zy00DyDzzy03zw00TyTzzw07zw00zyTzzs0Dzs01z",
        ; Tinkerfairy Skin
        "|<>*207$71.Tzzzy00000Tyzzzzs00000zwzzzzk00000zszzzzU00001zlzzzy00S001zVzzzw01y003z3zzzs07y007y3zzzk0Ty00Dw3zzzU0zy00Dy7zzz01zw00TyDzzy03zs00zyTzzw0Dzs01zyTzzs0Tzk03zwzzzk0zzU07zxzzzU1zz00Tzvzzz03zy00zzrzzy03zw01zzzzzy07zs07zzzzzw0ATU0Dzzzzzs01z00zzzzzzs07w01zzzzzzk0Ts07zzzzzzk0TU0Tzbzzzzk0A00zzTzzzzk0003zz"
    ],

    "Adora", [
        ; High Priestess Skin
        "|<>*212$71.0000000808000000000800000000000010000000000000000000000E800000000000U0001zs0000V0000Tzy000000003zzz00010000Tzzz0000000FzzzzU002001bzzzzU002007TzzzzU00400TzzzzzU00001zzzzzzU00003zzzzzz00000Dzzzzzz00000zzzzzzz00001zzzzzzy00007zzzzzzy0000Dzzzzzzw0000zzzzzzzw0001zzzzzzzs0007zzzzzzzs000Dz0Tzzzzk000Tz",
        ; Joan of Arc Adora Skin
        "|<>*152$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzXzzzzzzzzzyUU3zzzzzzzy00001zzzzzk00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000C00000000000w00000000003w00C0000000Ds00z0000000Tk03zU000001zU07z0000007z00Dy000000Dy1",
        ; Voidora Skin
        "|<>*110$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzlzzzzzzzzzzy3zzzzzzzzzzs01zzzzzzzzzk00Tzzzzzzzzk00DzzzzzzzzU00Dzzzzzzzz001zzzzzzzzy003zzzzzzzzw00Dxzzzzzzzs00Tszzzzzzzk00zkzzzzzzzU01zUzzzzzvz1",
        ; She-Ra Skin
        ""
    ],

    "Admiral Brickell", [
        ; Naval Commander Skin
        "|<>*168$71.zzzzw007zzzzzzzzs00Dzzzzzzzzk00TzzzszzzzU00TzzzkDzzz000zzzzU1zzz001zzzz003zy003zzzy0007w003zzzw0000w007zzy00001s007zz000001k00Dzk000003k00Ds0000003U00000000007U0000000000D00000000000S00000000000y00000000000y00000000001w00000000003w00000000007s0000000000Ds00000001U0Tk0000000Tk0zk0000001zk1zU003U1",
        ; Dread Pirate Brickell Skin
        "|<>*119$71.zzzzzyQTzzzzzzzzzyETzzzzzzzzzw0Tzzzzzzzzzs0Tzzzzzzzzzs0zzzzzzzzzzk1zzzzzzzzzzk3zzzzzzzzzzU7zzzzzzzzzzUDzzzzzzzzzzUTzzzzzzzzzzUzzzzzzzzzzz1zzzzzzzzzzz3zzzzzzzzzzz7zzzzzzzzzzyDzzz7zzzzzzyTzzkDzzzzzzwzzz0Tzzzzzzxzzz0zzzzzzztzzz1zzzzzzznzzy3zzzzzzzbyzy7zzzzzzzDlzwDzzzzzzzD3zUTzzzzzzySDz0zzzzzzzsQTy1",
        ; Lifeguard Brickell Skin
        "|<>*200$71.k000DzzzzU1z0000Tzzzy01y0000Tzzzw03w0000zzzzk07k0001zzzzU07U0001zzzz00D00003zzzw00S00003zzzs00Q00007zzzU00s00007zzz001k0000Dzzy003U0000Dzzw00300000Tzzs00600000zzzk00400TU1zzzU00801zU3zzz020007zU7zzy0z000DzUDzzw3z000zz0TzzsDz001zy0zzzkTz003zw3zzzUzy007zk7zzz3zw00Dz0Dzzy7zw00Ty0zzzyDzs00zz1zzzwTy1"
    ],

    "Psi", [
        ; Psionic Monkey Skin
        "|<>*161$71.zy000DzzzzU1zzU00Dzzzy03zzk00Dzzzs07zzs00DzzzU0Tzzw00Dzzy01zzzw00Dzzs07zzzy00TzzU0Tzzzy00Tzy01zzzzy00Tzs07zzzzy00zzU0Tzzzzy00zz00zzzzzw00zw03zzzzzw01zk0Dzzzzzw01z00Tzzzzzw03y01zzzzzzs03s07zzzzzzs03U0Dzzzzzzk0600zzzzzzzk0A01zzzzzzzU0007zzzzzzzU000Dzzzzzzz0000zzzzzzzz0001zzzzzzzy0007zzzzzzzw000Dzz",
        ; Psimbals Skin
        "|<>*204$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs1zzzzzzzzzzU07zzzzzzzzz001zzzzzzzzw000zzzzzzzzk000zzzzzzzz0000Tzzzzzzw0000Tzzzzzzk0000Tzzzzzz00000Tzzzzzy00000Tzzzzzs00000TzzzzzU00000Tzzzzz000000Tzzzzw000000Tzzzzs000000zzzzzU000000zzzzz0000001zzzzw0000001zzzzs0000003zzzzU0000003zzzz0y000003zzzw7z",
        ; Dreamstate Psi Skin
        "|<>*155$71.zzzz00zz03zzzzzz01zw0Dzzzzzy01zk0Tzzzzzy03z01zzzzzzy03y07zzzzzzw03s0Dzzzzzzw07U0zzzzzzzw0601zzzzzzzs0A07zzzzzzzs000Tzzzzzzzk000zzzzzzzzk003zzzzzzzzU007zzzzzzzz000Dzzzzzzzz000zzzzzzzzy001zzzzzzzzw003zzzzzzzzs00Dzzzzzzzzk00TzzzzzzzzU00zzzzzzzzzU03zzzzzzzzz007zzzjzzzzy00DzzsTzzzzw00Tzw01zzzzs01zy01"
    ],

    "Geraldo", [
        ; Mystic Shopkeeper Skin
        "|<>*189$71.zzzzzzy003zxzzzzzzw00DzuDzzzzzs00Tzs1zzzzzk00zzk1zzzzz001zzU1zzzzy003zz1Vzzzzw003zyDnzzzzs007zwTnzzzzk00DztznzzzzU00STnzrzzzz0000zbzbzzzy0001zDzjzzzw0007yTzDzzzs000TszyTzzzk000zVzwTzzzk000y3zwzzzzU00003ztzzzz000007zlzzzy00000DTXzzzw000000z7zzzw000001yDzzzs000007sDzzzs00000DkTzzzk00000S0zzzzk0001",
        ; Gentlemonkey Gadgeteer Skin
        "|<>*193$71.0Tzzzzk00Tzk0zzzzzU00zzU0zzzzz001zz0wzzzzy003zy3wzzzzw007zwDwzzzzs007zsTxzzzzk00ATlztzzzzU000zXzvzzzz0001z7znzzzy0007wDzbzzzw000TsDzbzzzs000zUTzDzzzk00080zyDzzzU00001zwTzzz000001zszzzz0000037lzzzy000000TVzzzy000000z3zzzw000001w7zzzw000007kDzzzw0000000Tzzzw0000000zzzzw0000001zzzzy0001007zzzzzk00T"
    ],

    "Corvus", [
        ; Spirit Walker Skin
        "|<>*79$71.0003y00000A60007y00000MA0007y00001k8000Dw000030E000Tw0000C00000Tw0000M00000zw0000k61001zw0003040z01zw000C000zzzzw000M000zzzzw001k100zzzzw0030901zzzzw00C0XU1zzzzy00sD7Uzzzzzy01UQD3zzzzzy06ssw7zzzzzz0NllsDzzzkTz1nU30zzzz0Tz770C1zzzy0TzQS0w7zzzw0Tzsy3sTzzzs0TzUyDnzzzzU0Ty3zzzzzzz00Ts7zzzzzzy00Tk7zz",
        ; Decryptor Corvus Skin
        "|<>*155$71.zzzzzzy00001zzzzzzy00003zzzzzzw00007zzzzzzs0000Dzzzzzzk0000TzzzzzzU0000zzzzzzz0000Vzzzzzzy00033zzzzzzy00077zzzzzzw000DDzzzzzzs000yTzzzzzzk001yzzzzzzzU007zzzzzzzz000Dzzzzzzzy000zzzzzzzzw001zzzzzzzzs007xzzzzzzzk00DnnzzzzzzU00DbVzzzzzz000TT7zzzzzz000zyDzzzzzw009zzzzzzs0000zzzzzzzk0003zzzzzzzU0007zz"
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


    ; If the requested hero isn't even configured,
    ; immediately fall back to Quincy.
    if !HeroPatterns.Has(
        heroName
    ) {
        return SelectFallbackHero(
            heroName
        )
    }


    patterns :=
        HeroPatterns[
            heroName
        ]


    ; Search current position.
    if FindAndClickHero(
        patterns
    ) {

        Sleep(
            500
        )


        return ClickSelectButton()
    }


    ; Search while scrolling down.
    Loop 2 {

        MouseMove(
            200,
            500
        )


        Send(
            "{WheelDown 6}"
        )


        Sleep(
            300
        )


        if FindAndClickHero(
            patterns
        ) {

            Sleep(
                500
            )


            return ClickSelectButton()
        }
    }


    ; Search while scrolling up.
    Loop 2 {

        MouseMove(
            200,
            500
        )


        Send(
            "{WheelUp 6}"
        )


        Sleep(
            300
        )


        if FindAndClickHero(
            patterns
        ) {

            Sleep(
                500
            )


            return ClickSelectButton()
        }
    }


    ; Requested hero could not be found.
    ; This can happen if the player hasn't
    ; unlocked that hero yet.
    return SelectFallbackHero(
        heroName
    )
}


SelectFallbackHero(
    requestedHero
) {
    global HeroPatterns


    ; Quincy is the default hero available
    ; to every player.
    if !HeroPatterns.Has(
        "Quincy"
    ) {

        ToolTip(
            "Could not find "
            . requestedHero
            . " and Quincy patterns are missing."
        )


        Sleep(
            1500
        )


        ToolTip()


        return false
    }


    ToolTip(
        requestedHero
        . " not available."
        . "`nUsing Quincy instead."
    )


    Sleep(
        600
    )


    ToolTip()


    quincyPatterns :=
        HeroPatterns[
            "Quincy"
        ]


    ; Search wherever the hero list currently is.
    if FindAndClickHero(
        quincyPatterns
    ) {

        Sleep(
            500
        )


        return ClickSelectButton()
    }


    ; Quincy should be near the top of the hero list,
    ; so scroll upward until we find him.
    Loop 5 {

        MouseMove(
            200,
            500
        )


        Send(
            "{WheelUp 8}"
        )


        Sleep(
            300
        )


        if FindAndClickHero(
            quincyPatterns
        ) {

            Sleep(
                500
            )


            return ClickSelectButton()
        }
    }


    ToolTip(
        "Could not find "
        . requestedHero
        . " or fallback hero Quincy."
    )


    Sleep(
        1500
    )


    ToolTip()


    return false
}

FindAndClickHero(patterns) {
    for pattern in patterns {
        if FindText(&X, &Y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, pattern) {
            Click(X, Y)
            return true
        }
    }

    return false
}

ClickSelectButton() {
    Click(1100, 600)
    Sleep(500)

    return true
}
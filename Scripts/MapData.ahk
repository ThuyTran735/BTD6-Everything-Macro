#Requires AutoHotkey v2.0

; Map-card FindText samples and page numbers used by navigation. Pages follow the in-game browser, not the order of strategy folders.

global CategoryStartPages := Map(
    "Beginner", 1,
    "Intermediate", 6,
    "Advanced", 11,
    "Expert", 15
)

global MapData := Map(
    "Monkey Meadow", {
        category: "Beginner",
        page: 1,
        pattern: "|<>*159$22.zzU3zw0Dzw0zzs3zk0Dk00zU03y00Dw00zkk3zzzzzzzzzzzzzzkTzs1kDU3000Q000k003000Q001k007000Q011k0Tz3zzzzzzzzwM008"
    },

    "In The Loop", {
        category: "Beginner",
        page: 1,
        pattern: "|<>*151$37.y00E3zy00A3zzU7W0zzk0k0Tzk700Dzs3w03zw3z01zw7zU0Ty3zk0Tz0zw07y0Dy03y83z00zA0zk0DXUzw07zkTw01zwDz01zk7zk0zk1zs1zk1tw0Dk6wT03s3yDUE03zzwA03znz000ztTk00TsDzk0DwDzy01yzzw00SSzz007wDzU02Dzzs007zzw002zzyk00Pzw00sTzw2"
    },

    "Skull Tweak", {
        category: "Beginner",
        page: 1,
        pattern: "|<>*137$28.00000000080000U00030000A0000k00030000D0000y0003y0E7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw7zzs00zz003z000Dk000w0003k000D0000w0003U000C0000U"
    },

    "Three Mines 'Round", {
        category: "Beginner",
        page: 1,
        pattern: "|<>*106$20.01y0000000000000300000000000000000000000s00Dk03zU0zz0Dzy3zzwzzynz40T007U00s00C003U00s00C001U00M007U01m00C003U00k00A007001k00Q006001U00Q007001s00T007U00s00C003U0U"
    },

    "Spa Pits", {
        category: "Beginner",
        page: 1,
        pattern: "|<>*177$19.zzzzzzzzzrztny0tC0A606T03D01tU3wsDyATz7zzXz07y07w03s0DU0zU3zUDzkTzsTzwTzyTzzDzzzzzzzzzzzzzzzzzzzzzzzzs"
    },

    "Tinkerton", {
        category: "Beginner",
        page: 1,
        pattern: "|<>*158$27.3zzztzzzzyTzzzlzzzy7zzzszzzzjzzzzzzzzzzzzznnzzw7zzz0zzTszzvzzUT7w03sS00T3U03zk00Ts003y000T0003s000T0003s000T0003s000T0000s0000U00060000w0027z000zU007w000zU007w000z0007s000y0007k000U"
    },

    "Tree Stump", {
        category: "Beginner",
        page: 2,
        pattern: "|<>*166$30.0001s0000s0000s0000s0000s0000w0000w0000w0000w0000Q0000Q0000Q0000C0000C0000C0000C0000D0000D0000D0003z0003z000Dv000DX000Tx000zx003tz007kT00D0D00D0D01y0D03w0D03s0D03s0D03U0DU"
    },

    "Town Center", {
        category: "Beginner",
        page: 2,
        pattern: "|<>*157$26.zU000y000Dzzs3zzzkS7jw70073U01ks00AS0U17kA0HA305V0k1kkA0QA307V0M0zs60Tzzzxzzzz00000000000000000000000000000000002"
    },

    "Middle Of The Road", {
        category: "Beginner",
        page: 2,
        pattern: "|<>*126$26.00zz00Dzk03zw00zz00Dzk03zw00zzA0Dzn0TzysDzziTzznzzzwzXzzDsTzn63zwv0zzjUDznk3zww0zzDzzznzzzwnDzzAvzzkS3zww0zz70Dzls3zwS0zz3UDzks3zwC1zz3UTzm"
    },

    "One Two Tree", {
        category: "Beginner",
        page: 2,
        pattern: "|<>*150$25.Xs00Fw00Dy007z003zU017k00zs00Tw00Dy000S000700000000000U000E000M000w000S000D0007U007k003s001w003y007z003zU01zk00zs00Tw00Tz"
    },

    "Scrapyard", {
        category: "Beginner",
        page: 2,
        pattern: "|<>*147$26.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzvzzzz000Dns03zy00zy00Dy003w000z0007k07tw03zT01zzk0Tzw00AT0007yA0Vy"
    },

    "The Cabin", {
        category: "Beginner",
        page: 2,
        pattern: "|<>*45$41.zsTDk01zkzT003zVyy007zzxs00Dzzvk0UTzzbU10zzzz021zzzz07nzzzz00bzzzzs0Dzzzxk0Tzzzz00zzzzw01zzzzs03zzzzs07zzzzs0DzzzzkATzzzzzkzzzzzw1zzzzzs3zzzzy07zzzzw0Dzzzzs0TzzzzU0zzzzw01zzzzs03zzzzU07zzzzU0Dzzzz00Tzzzw00zzzzs01zzzz003zzzz007zzzs00Dzzk000Tzw0000zzk0001wC00003x000004"
    },

    "Resort", {
        category: "Beginner",
        page: 3,
        pattern: "|<>*189$36.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk07zs0000Ds00007s00000k00000k00000w00000zs0000zs0000zk0000zU0000y00000yU0000zU0000v00003s00003s00007s00003w00003U"
    },

    "Skates", {
        category: "Beginner",
        page: 3,
        pattern: "|<>*149$28.zx03zzU0Dzw01zzk47zy00Tzk03zy08Dzk01zz007zk00zy143zk00Tz241jwlkBzw81rzX0DzzU3zzk0STz0XvzwATzzz7zzzlzzzkDzzz7zzzwzzzzrzvzzzzzzzwzzzzXzzzs"
    },

    "Lotus Island", {
        category: "Beginner",
        page: 3,
        pattern: "|<>*174$23.zs3zzU7zy0Dzk0Dy00Tw00zU01y003w007s007k00TU01z003y007y00Tw01zw03zw0Dzy0zzy1zzy3zzwDzs"
    },

    "Candy Falls", {
        category: "Beginner",
        page: 3,
        pattern: "|<>*147$27.01zzs07zz00zzs03zz007zs00zz003zs00Tz003zs00Dz001zs007z000zw003zk00Ty003zs00Tz003zs00DzU01zw00Dz001zs00Dz003zk00Ty003zU00Ts007z000zs00Dz001zs00Dy003z600T0006000000U"
    },

    "Winter Park", {
        category: "Beginner",
        page: 3,
        pattern: "|<>*235$28.003zk007z000Tw001zk00Dz000zw003zkDzzzDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxwzzzzzDyk00Tz001zs007zU00Ty001zs007zU00Ti001ys007zU00Ty001zs007zU00Ty001zs007zU00Ty001zu"
    },

    "Carved", {
        category: "Beginner",
        page: 3,
        pattern: "|<>*94$42.zbsTzzzY3szzzzU3zzzzzk3zzzzz03zzzzz03zzzTz07zzwzz07zztzz0Dzzjzz0DzytTz0Dztk/z0Tza0Tz0zyA0Dz1zzy0Bz3zzM0zzDzzM0DsTzzg4y0zzziTw0zzzbDU0zzzsTU0zzzlzk0zzzzzk0zzzzzk0zzzzyk0zzzzyE0zzzzy00zzzzw00zzzzw00zzzzw00zzzzs00zzzzs00zzzzs00zzzzs00zzzzk00zzzzk00zzzzU00zzzzU00zzzz000zzzz000zzzzU00zzzzk00zzzzk00zzzzk00U"
    },

    "", {
        category: "Beginner",
        page: 4,
        pattern: ""
    },

    "", {
        category: "Beginner",
        page: 4,
        pattern: ""
    },

    "", {
        category: "Beginner",
        page: 4,
        pattern: ""
    },

    "", {
        category: "Beginner",
        page: 4,
        pattern: ""
    },

    "", {
        category: "Beginner",
        page: 4,
        pattern: ""
    },

    "", {
        category: "Beginner",
        page: 4,
        pattern: ""
    },

    "", {
        category: "Beginner",
        page: 5,
        pattern: ""
    },

    "", {
        category: "Beginner",
        page: 5,
        pattern: ""
    },





    "Intermediate Map", {
        category: "Intermediate",
        page: 6,
        pattern: "|<>YOUR_INTERMEDIATE_MAP_PATTERN"
    },





    "Advanced Map", {
        category: "Advanced",
        page: 0,
        pattern: "|<>YOUR_ADVANCED_MAP_PATTERN"
    },





    "Tricky Tracks", {
        category: "Expert",
        page: 15,
        pattern: "|<>*132$35.03zzzy07zzzw0zzzzs3zzzzkTzzzzVzzzzzTzzzzzzzzzzzzzzzzzzzzzzzzzznrzzzw7jzzzwDzzzzwTzzzzwzzzzzzzzzzzzzzzzzzyzzzzztzzzzz3zzzzw7zzzzUDzzzw0TzzzU0zzzy01zTzs03zzzU07zzw00Dzzk00Tzy000zzs001zz0003zw0007zU000Dy0000TU0000U"
    },

    "Glacial Trail", {
        category: "Expert",
        page: 15,
        pattern: "|<>*142$22.zzzzzzzzzzzzzzxzzzrzzzDzzwzzzlzzy7zzsTyTVzUw3y3kDs60T081w007U0000000000000000000000000000000000000000000000000000000000000002"
    },

    "Dark Dungeons", {
        category: "Expert",
        page: 15,
        pattern: "|<>*90$25.DhzzbkzznsTzswTzwSDzzz7zzzUDzzzzzk03zs01zw00Ty00Dz1V7zU03zk03zs00zw00Tzzzzzzzzzz0zzk00zs00zw00Ty007z003zk"
    },

    "Sanctuary", {
        category: "Expert",
        page: 15,
        pattern: "|<>*36$21.0Dzs0zz03zs1zz007s001000000000000000001s1kTq07z00zw07zk0zzE7zy0zzy7zzkzzy7zzkzzz7zzwzzzzzzzzzzszzz1zzs1Tz01zs07z00Ts03z003w"
    },

    "Ravine", {
        category: "Expert",
        page: 15,
        pattern: "|<>*84$37.zU000zzs000Tzy000Dzz000DzzU007zzk007zxk003zz0003zyk001zy0E01zzU800zzk000Tzs000Tzs0008zs0300Tw00A87y00043z00061n00030Q00010Dk00003s00000w00000C000003000000U0000000000000000000000000000000000000030001U1000Uy1bU0QTtzk0CDzzsAD7zzwTbXzzzTvlzzzzzw"
    },

    "Flooded Valley", {
        category: "Expert",
        page: 15,
        pattern: "|<>*82$18.0zy1zz3zz7zzTzzTzzzzzzzzzzzzzzzzzzzzzzzzzzy03y03m03003003001001000000000000000000000000000000U"
    },

    "Inferno", {
        category: "Expert",
        page: 16,
        pattern: "|<>*78$29.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzzzzXzzzz7zzzyDzzzwTzzzsTzzzkzzzzVzzzzDUzzyT0bzzy07zzs03zy007zi007z6007yzU07zzU0Dzz00Tzy00zzy03zzw0Dzzs0TzzU3zzz07zzy0DwTy0zUzzzz1zzzy3zzzw7zzzzzzzzzzzzzzzzzzzzzzUzzzz1zzzy3zzzU3k"
    },

    "Dark Castle", {
        category: "Expert",
        page: 16,
        pattern: "|<>*114$24.D0003U003k000s000Q000C00kC00sC00y7U0y7w0z3w0z0y0zkS0zkD0zs3Uzw3kzw4Mzy0Mzy0Mzz0szz0szzUwzzUQzzkyzzkzzzsTzzw7zzy7zzy3TzzUU"
    },

    "#Ouch", {
        category: "Expert",
        page: 17,
        pattern: "|<>*78$17.zzzzzzzzzzzzzzzzzzzzzzzzzzzzrzza20S01Yk0700600A00M00800800A00A00A00DU"
    },

    "Expert Map", {
        category: "Expert",
        page: 0,
        pattern: "|<>YOUR_EXPERT_MAP_PATTERN"
    },
)
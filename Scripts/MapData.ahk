#Requires AutoHotkey v2.0

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
        pattern: "|<>*153$36.TsTzzzDzTzzz7zzzzz3zzzzz7zzzzzLzzzzzrzzzyT7ztzyT3zUzk74Dkzs7s3tzwD01zzxT00zzzzs03zzzy01zzyw0kDzkw0E3z0w001w0y00080zU0000yk0000w00000k3U000k3s001s3y007lTzy6DzzzzzzTzzwzzzXzzjzT3zwlkzUTsjkw0TtzUy0zzzkDVXTzU3bVDzs3zUDzs3zmTz0DzqTz0DyDbzozzzrzyzzzzzzzzzzzzjzjvzzzzzzznU"
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
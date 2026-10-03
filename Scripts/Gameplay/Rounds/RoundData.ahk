#Requires AutoHotkey v2.0

; v3 file note: Stores the round limits, OCR boxes, digit patterns, and tracker state.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

global DifficultyRounds := Map(
    "Easy", 40,
    "Medium", 60,
    "Hard", 80,
    "Impoppable", 100,
    "CHIMPS", 100
)


; Production 1920x1080 round OCR rectangles.
global RoundAreas := Map(
    "Easy", {
        regular: {
            x1: 1421,
            y1: 33,
            x2: 1489,
            y2: 73
        },

        rightPanel: {
            x1: 1027,
            y1: 31,
            x2: 1095,
            y2: 74
        }
    },


    "Medium", {
        regular: {
            x1: 1420,
            y1: 30,
            x2: 1490,
            y2: 73
        },

        rightPanel: {
            x1: 1030,
            y1: 31,
            x2: 1095,
            y2: 76
        }
    },


    "Hard", {
        regular: {
            x1: 1418,
            y1: 32,
            x2: 1489,
            y2: 73
        },

        rightPanel: {
            x1: 1015,
            y1: 32,
            x2: 1093,
            y2: 73
        }
    },


    "Impoppable", {
        regular: {
            x1: 1364,
            y1: 30,
            x2: 1468,
            y2: 74
        },

        rightPanel: {
            x1: 969,
            y1: 30,
            x2: 1075,
            y2: 74
        }
    },


    "CHIMPS", {
        regular: {
            x1: 1364,
            y1: 30,
            x2: 1468,
            y2: 74
        },

        rightPanel: {
            x1: 969,
            y1: 30,
            x2: 1075,
            y2: 74
        }
    }
)


global RoundDigits :=
(
    "|<0>FFFFFF-0.90$5.1vzzzzwME000000000Tzzzw"
    "|<0>*138$18.00S00D0070070030037U1Dk1Ts1Ts1Ts1Qw0Qw0Qw1Qs1Ts1Ds1Dk33U300700700D00T00z03ysDwU"
    "|<0>*139$16.0s0zyDzyzzzU3s0300400000000000001s0Dk0zU7z0Sw1vk7D0Qw1vk7i0Ds0T00s00000000000803k0TsDs"
    "|<0>*131$10.zvzzz0A000000000007Uz3yDsvnjAwnnjCszVw3U0000000001Uzzzzzzz8"
    "|<1>FFFFFF-4C4C4C$8.QDzzzzzzzzzzTrxzTrxzTrxzTrxzU"
    "|<1>FFFFFF-0.90$15.TzXzwDzV7w0zU7w0zU7w0zU7w0zU7w0zU7w0zU7w0zU7w0zU7w0z07s00000U"
    "|<1>*129$10.000000000002kD0w3kD0w1k70Q1k70Q1k70Q1k70Q2"
    "|<1>*129$14.0007w3z3zlw0y0y0D03U0s0C03U0w0D01v0Tk3w0z07k0w0701k0Q0701k0Q0701k0Q0701k0Q07z1zkTy"
    "|<1>*135$11.Tzzzzy0E0000000000E0U103U70C0Q0s1k3U70C0Q0s1k3U70C0Q0s1k3zzzzzzzbzU"
    "|<2>FFFFFF-1.00$15.7y3zkzzzzzzzzzzzzw"
    "|<2>FFFFFF-0.90$13.zyTzjzrzvzw3z0zUTkDs7w3y3z1z1zVzVzVzVz0zkTzzzzzzzz"
    "|<2>FFFFFF-0.90$15.zz7zwzzrzzzzzzz0Ts1z07s0z07s1z0Ds1z0Tk7w1z0TkDw7zUzzzzzzzzzzzzw"
    "|<2>FFFFFF-0.90$14.zzjzzzzzzzzw1z0Dk3w0z0Dk3w0z0TkDw3y3z1zVzkzwDzzzzzzzzy"
    "|<2>*135$16.zy3zyC3y01w03k0700A00E01000s0Ds0zU3y0Ds0XU0S03k1T0Ds1y0Dk1w0Dk000000000000000000z06"
    "|<2>*134$18.0Dk3zyDzzTkTy03w00s00w00w00w00Q00SS0Tz0TzUDzUDzU7bU0700D00y01w0Ds0zU1y03s00s00s00s00s00s00s00zy0zzzzzzzzzDzzU"
    "|<2>*134$19.0Dk0zzVzztz1xw06s01Q00C007U03k01s00QS0DzU7zs3zw0zy0SC00D00D00DU0TU0zU1z02y03w00S00D007U03k01s00w00TzUDzzvzzxzzyDzzU"
    "|<2>*132$12.zUzs3y0T0D0703010100U0s0s0s0s0s0s0k1k3U70D0T0z00000000000000U1zzzzU"
    "|<3>FFFFFF-1.00$14.Dz3zszz1zk7w0z0Dk3y"
    "|<3>FFFFFF-0.90$10.zzzzzzy3k30A0k30Q3nzDwzlz0Q0k10A0yDzzzzzzy"
    "|<3>*130$13.zsTzDzs1w060100000000001y0zUTkDk7k20100U0E0807k3y1z0zUTU0000000000000E0w1zzzzzzzTy8"
    "|<4>FFFFFF-0.91$8.kwD3zzzz1kA30kA30s"
    "|<4>FFFFFF-1.00$12.sDsDsDsTzzzzzz0T0T0TU"
    "|<4>FFFFFF-0.90$15.DltyDDltwDTVvwDTVvwDTVvwDzzzzzzzu0T01w"
    "|<4>*130$16.1zw7zkzzzk3y0Ds01U0600M01U0600M13U4C0Es13U4C0Es00000000000000Dk1z07w0Tk1z04Q0Fk1704Q0lzz7zwTzlzz1s2"
    "|<5>FFFFFF-0.83$12.0000zzzzzzzzzzzzw0w0w0w0w0zzzzzzDzU"
    "|<5>*133$13.zzzzzzs000000000000000C07z7zXzk0s04000000T0Dk7w3y1z0w00000000000000U1zzzzzzzzyzsE"
    "|<6>FFFFFF-0.90$5.zzzzzU0007zzw00004Dzzzzk0U"
    "|<6>*132$15.3zvzzzzzU1k040000000000000T0Dz3zsTz3ksE000000000001w0Tk3y0Tk1w0200000000000U0C07zDzzzzzzzy7y4"
    "|<7>FFFFFF-0.90$14.zzzzzzzzzzXw0z0Dk3w1z0TkDw3y1zUTkDw3z1zUTsDy8"
    "|<7>FFFFFF-0.90$13.zzzzzzzzzsS0D07U7k3s3w1y1z0zUzkTsTsDwDw7yE"
    "|<7>*137$11.0000000DsTkz1y3s3k70C0w1"
    "|<7>*133$12.zzzzzz0000000000000000zkzkzkzUzU70D0C0S0Q0w0s0s0k0k1U1U1030303zzzzzzU"
    "|<8>FFFFFF-0.9$4.0Dzzy00008zk0000zzzz08"
    "|<8>*131$14.DyDzzzzs3s04000000000000y0Tk7w1z0Tk3s0000000080DU7w1z0Tk3w0Q000000000000A0Dzzzzzzzzz7y8"
    "|<9>FFFFFF-0.90$5.03zzzzY00013zs"
    "|<9>*131$13.DsTzjzz0w0601000000000S0TUDk7s1w0M000000000Ay7y3z1z0C00000000020307UDzzw"
)


global LastRound := 0
global LastWeirdRead := 0
global WeirdReadCount := 0
global WeirdReadActive := false

; Raw OCR value that represented the most recently validated game round.
; When OCR consistently misreads a digit (for example round 10 as 14),
; latching that raw value prevents the same screen from advancing strategy
; time more than once.
global LastAcceptedRoundRead := 0

; De-duplicates diagnostic messages when a known OCR confusion is repaired.
global LastRoundOcrRepairLogKey := ""
global LastGlacialRejectedOcrLogKey := ""

; Glacial Trail has bright snow/particle effects behind the round counter.
; Keep its OCR recovery isolated so other maps continue using the normal path.
global LastGlacialFallbackLogRound := 0
global GlacialLastInferredRound := 0

; If generic popup recovery had to click the bottom-right of the game on
; Glacial Trail, the round counter may become readable several rounds ahead.
; Temporarily resync one round at a time so scheduled actions are not lost.
global GlacialPostRecoveryResyncActive := false
global GlacialPostRecoveryResyncTick := 0

global RoundStartTick := 0
global LastTrackedRound := 0

global RoundReadMissingSince := 0
global RoundReadTimeoutMs := 1500

global RoundRecoveryX := 1598
global RoundRecoveryY := 1043


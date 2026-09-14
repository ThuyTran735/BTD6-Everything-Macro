#Requires AutoHotkey v2.0


global DifficultyRounds := Map(
    "Easy", 40,
    "Medium", 60,
    "Hard", 80,
    "Impoppable", 100,
    "CHIMPS", 100
)


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
    "|<0>FFFFFF-0.95$5.1vzzzzwME000000000Tzzzw"
    "|<1>FFFFFF-4C4C4C$8.QDzzzzzzzzzzTrxzTrxzTrxzTrxzU"
    "|<1>FFFFFF-0.90$15.TzXzwDzV7w0zU7w0zU7w0zU7w0zU7w0zU7w0zU7w0zU7w0zU7w0z07s00000U"
    "|<2>FFFFFF-1.00$15.7y3zkzzzzzzzzzzzzw"
    "|<2>FFFFFF-0.90$13.zyTzjzrzvzw3z0zUTkDs7w3y3z1z1zVzVzVzVz0zkTzzzzzzzz"
    "|<2>FFFFFF-0.90$15.zz7zwzzrzzzzzzz0Ts1z07s0z07s1z0Ds1z0Tk7w1z0TkDw7zUzzzzzzzzzzzzw"
    "|<2>FFFFFF-0.90$14.zzjzzzzzzzzw1z0Dk3w0z0Dk3w0z0TkDw3y3z1zVzkzwDzzzzzzzzy"
    "|<3>FFFFFF-1.00$14.Dz3zszz1zk7w0z0Dk3y"
    "|<3>FFFFFF-0.90$10.zzzzzzy3k30A0k30Q3nzDwzlz0Q0k10A0yDzzzzzzy"
    "|<4>FFFFFF-0.91$8.kwD3zzzz1kA30kA30s"
    "|<4>FFFFFF-1.00$12.sDsDsDsTzzzzzz0T0T0TU"
    "|<4>FFFFFF-0.90$15.DltyDDltwDTVvwDTVvwDTVvwDzzzzzzzu0T01w"
    "|<5>FFFFFF-0.83$12.0000zzzzzzzzzzzzw0w0w0w0w0zzzzzzDzU"
    "|<6>FFFFFF-0.90$5.zzzzzU0007zzw00004Dzzzzk0U"
    "|<7>FFFFFF-0.90$14.zzzzzzzzzzXw0z0Dk3w1z0TkDw3y1zUTkDw3z1zUTsDy8"
    "|<7>FFFFFF-0.90$13.zzzzzzzzzsS0D07U7k3s3w1y1z0zUzkTsTsDwDw7yE"
    "|<8>FFFFFF-0.9$4.0Dzzy00008zk0000zzzz08"
    "|<9>FFFFFF-0.90$5.03zzzzY00013zs"
)


global LastRound := 0
global LastWeirdRead := 0
global WeirdReadActive := false

global RoundStartTick := 0
global LastTrackedRound := 0

global RoundReadMissingSince := 0
global RoundReadTimeoutMs := 10000

global RoundRecoveryX := 1598
global RoundRecoveryY := 1043


GetRoundArea() {
    global RunConfig
    global RoundAreas


    difficulty :=
        RunConfig.difficulty


    if !RoundAreas.Has(
        difficulty
    ) {

        throw Error(
            "No round area configured for: "
            . difficulty
        )
    }


    return RoundAreas[
        difficulty
    ]
}


GetStartingRound() {
    global RunConfig


    if HasProp(
        RunConfig,
        "startRound"
    ) {

        return RunConfig.startRound
    }


    return 1
}


GetFinalRound() {
    global RunConfig
    global DifficultyRounds


    if HasProp(
        RunConfig,
        "endRound"
    ) {

        return RunConfig.endRound
    }


    difficulty :=
        RunConfig.difficulty


    if !DifficultyRounds.Has(
        difficulty
    ) {

        throw Error(
            "Unknown difficulty: "
            . difficulty
        )
    }


    return DifficultyRounds[
        difficulty
    ]
}


GetCurrentRound() {
    global RoundDigits


    areas :=
        GetRoundArea()


    for areaName in [
        "regular",
        "rightPanel"
    ] {

        area :=
            areas.%areaName%


        ok :=
            FindText(
                &X,
                &Y,
                area.x1,
                area.y1,
                area.x2,
                area.y2,
                0,
                0,
                RoundDigits,
                1,
                1
            )


        if !ok {
            continue
        }


        ok :=
            FindText().Sort(
                ok
            )


        result :=
            FindText().Ocr(
                ok,
                20,
                20,
                3
            )


        roundText :=
            RegExReplace(
                result.text,
                "\D"
            )


        if roundText != "" {

            return Integer(
                roundText
            )
        }
    }


    return false
}


TrackRoundStart() {
    global LastRound
    global LastTrackedRound
    global RoundStartTick


    if LastTrackedRound != LastRound {

        LastTrackedRound :=
            LastRound


        RoundStartTick :=
            A_TickCount
    }
}


ValidateRound(
    detectedRound
) {
    global LastRound
    global LastWeirdRead
    global WeirdReadActive


    finalRound :=
        GetFinalRound()


    startingRound :=
        GetStartingRound()


    if LastRound < startingRound {

        if (
            detectedRound >= startingRound
            && detectedRound <= finalRound
        ) {

            LastRound :=
                detectedRound


            TrackRoundStart()


            return LastRound
        }
    }


    difference :=
        detectedRound
        - LastRound


    if !WeirdReadActive {

        if difference = 0 {
            return LastRound
        }


        if (
            difference > 0
            && difference <= 5
        ) {

            LastRound :=
                Min(
                    detectedRound,
                    finalRound
                )


            TrackRoundStart()


            return LastRound
        }


        WeirdReadActive :=
            true


        LastWeirdRead :=
            detectedRound


        if LastRound < finalRound {

            LastRound++


            TrackRoundStart()
        }


        return LastRound
    }


    if detectedRound = LastRound {

        ResetWeirdReads()


        return LastRound
    }


    difference :=
        detectedRound
        - LastRound


    if (
        difference > 0
        && difference <= 5
    ) {

        LastRound :=
            Min(
                detectedRound,
                finalRound
            )


        TrackRoundStart()


        ResetWeirdReads()


        return LastRound
    }


    if detectedRound = LastWeirdRead {
        return LastRound
    }


    LastWeirdRead :=
        detectedRound


    if LastRound < finalRound {

        LastRound++


        TrackRoundStart()
    }


    return LastRound
}


ResetWeirdReads() {
    global LastWeirdRead
    global WeirdReadActive


    LastWeirdRead :=
        0


    WeirdReadActive :=
        false
}


GetValidatedRound() {
    global LastRound


    detectedRound :=
        GetCurrentRound()


    if !detectedRound {

        HandleMissingRoundRead()


        return LastRound
    }


    ResetRoundReadFailureTracking()


    return ValidateRound(
        detectedRound
    )
}


CheckRoundReadRecovery() {
    detectedRound :=
        GetCurrentRound()


    if detectedRound {

        ResetRoundReadFailureTracking()


        ValidateRound(
            detectedRound
        )


        return "Readable"
    }


    if HandleMissingRoundRead() {

        return "Recovered"
    }


    return "Waiting"
}


HandleMissingRoundRead() {
    global RoundReadMissingSince
    global RoundReadTimeoutMs


    if RoundReadMissingSince = 0 {

        RoundReadMissingSince :=
            A_TickCount


        return false
    }


    if (
        A_TickCount
        - RoundReadMissingSince
        < RoundReadTimeoutMs
    ) {

        return false
    }


    DismissUnknownRoundBlockingPopup()


    ; Prevent click spam if the first recovery attempt
    ; did not clear whatever blocked the round display.
    RoundReadMissingSince :=
        A_TickCount


    return true
}


DismissUnknownRoundBlockingPopup() {
    global RoundRecoveryX
    global RoundRecoveryY


    oldMouseMode :=
        A_CoordModeMouse


    CoordMode(
        "Mouse",
        "Screen"
    )


    Loop 3 {

        Click(
            RoundRecoveryX,
            RoundRecoveryY
        )


        Sleep(
            300
        )
    }


    CoordMode(
        "Mouse",
        oldMouseMode
    )


    Sleep(
        400
    )


    return true
}


ResetRoundReadFailureTracking() {
    global RoundReadMissingSince


    RoundReadMissingSince :=
        0
}


WaitForRound(
    targetRound
) {
    startingRound :=
        GetStartingRound()


    finalRound :=
        GetFinalRound()


    if targetRound < startingRound {

        throw Error(
            "Round "
            . targetRound
            . " is before this mode's starting round "
            . startingRound
            . "."
        )
    }


    if targetRound > finalRound {

        throw Error(
            "Round "
            . targetRound
            . " is after this mode's final round "
            . finalRound
            . "."
        )
    }


    lastStateCheck :=
        A_TickCount


    Loop {

        currentRound :=
            GetValidatedRound()


        if currentRound >= targetRound {
            return true
        }


        if (
            A_TickCount
            - lastStateCheck
            >= 200
        ) {

            lastStateCheck :=
                A_TickCount


            state :=
                CheckGameState()


            if state = "Victory" {
                return "Victory"
            }


            if state = "Defeat" {
                return "Defeat"
            }
        }


        Sleep(
            50
        )
    }
}


WaitForFinalRound() {
    return WaitForRound(
        GetFinalRound()
    )
}


GetRoundElapsedTime() {
    global RoundStartTick


    if RoundStartTick = 0 {
        return 0
    }


    return A_TickCount
        - RoundStartTick
}


ResetRoundTracking() {
    global LastRound
    global LastWeirdRead
    global WeirdReadActive
    global RoundStartTick
    global LastTrackedRound
    global RoundReadMissingSince


    LastRound :=
        GetStartingRound()
        - 1


    LastWeirdRead :=
        0


    WeirdReadActive :=
        false


    RoundStartTick :=
        0


    LastTrackedRound :=
        LastRound


    RoundReadMissingSince :=
        0
}
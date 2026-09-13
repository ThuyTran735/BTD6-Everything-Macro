#Requires AutoHotkey v2.0

#Include IncludeAll.ahk

global DifficultyRounds := Map(
    "Easy", 40,
    "Medium", 60,
    "Hard", 80,
    "Impoppable", 100,
    "CHIMPS", 100
)

global RoundAreas := Map(
    "Easy", {
        x1: 0,
        y1: 0,
        x2: 0,
        y2: 0
    },

    "Medium", {
        x1: 0,
        y1: 0,
        x2: 0,
        y2: 0
    },

    "Hard", {
        x1: 0,
        y1: 0,
        x2: 0,
        y2: 0
    },

    "Impoppable", {
        x1: 0,
        y1: 0,
        x2: 0,
        y2: 0
    },

    "CHIMPS", {
        x1: 0,
        y1: 0,
        x2: 0,
        y2: 0
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


GetRoundArea() {
    global RunConfig
    global RoundAreas

    difficulty := RunConfig.difficulty

    if !RoundAreas.Has(difficulty)
        throw Error("No round area configured for: " difficulty)

    return RoundAreas[difficulty]
}


GetFinalRound() {
    global RunConfig
    global DifficultyRounds

    difficulty := RunConfig.difficulty

    if !DifficultyRounds.Has(difficulty)
        throw Error("Unknown difficulty: " difficulty)

    return DifficultyRounds[difficulty]
}


GetCurrentRound() {
    global RoundDigits

    area := GetRoundArea()

    ok := FindText(
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

    if !ok
        return false

    ok := FindText().Sort(ok)

    result := FindText().Ocr(ok, 20, 20, 3)

    roundText := RegExReplace(result.text, "\D")

    if roundText = ""
        return false

    return Integer(roundText)
}


ValidateRound(detectedRound) {
    global LastRound
    global LastWeirdRead
    global WeirdReadActive

    finalRound := GetFinalRound()

    ; First OCR reading
    if LastRound = 0 {
        LastRound := Min(detectedRound, finalRound)
        return LastRound
    }

    difference := detectedRound - LastRound


    ; Normal mode
    if !WeirdReadActive {

        ; Same round
        if difference = 0
            return LastRound

        ; Normal forward movement
        if difference > 0 && difference <= 5 {
            LastRound := Min(detectedRound, finalRound)
            return LastRound
        }

        ; Weird OCR reading detected
        WeirdReadActive := true
        LastWeirdRead := detectedRound

        ; Assume actual round advanced by one
        if LastRound < finalRound
            LastRound++

        return LastRound
    }


    ; Weird mode

    ; OCR recovered and now matches our tracked round
    if detectedRound = LastRound {
        ResetWeirdReads()
        return LastRound
    }

    difference := detectedRound - LastRound

    ; OCR recovered to a believable next round
    if difference > 0 && difference <= 5 {
        LastRound := Min(detectedRound, finalRound)
        ResetWeirdReads()
        return LastRound
    }

    ; Same weird OCR value as previous scan
    ; Do not increment again
    if detectedRound = LastWeirdRead
        return LastRound

    ; Weird OCR value changed
    ; Assume actual round advanced again
    LastWeirdRead := detectedRound

    if LastRound < finalRound
        LastRound++

    return LastRound
}


ResetWeirdReads() {
    global LastWeirdRead
    global WeirdReadActive

    LastWeirdRead := 0
    WeirdReadActive := false
}


GetValidatedRound() {
    global LastRound

    detectedRound := GetCurrentRound()

    if !detectedRound
        return LastRound

    return ValidateRound(detectedRound)
}


WaitForRound(targetRound) {
    finalRound := GetFinalRound()

    if targetRound < 1
        throw Error("Round must be at least 1.")

    if targetRound > finalRound
        throw Error(
            "Round " targetRound
            " does not exist on this difficulty."
        )

    Loop {
        currentRound := GetValidatedRound()

        if currentRound >= targetRound
            return true

        Sleep(200)
    }
}


WaitForFinalRound() {
    return WaitForRound(GetFinalRound())
}


ResetRoundTracking() {
    global LastRound
    global LastWeirdRead
    global WeirdReadActive

    LastRound := 0
    LastWeirdRead := 0
    WeirdReadActive := false
}
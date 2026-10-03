#Requires AutoHotkey v2.0

; v3 file note: Gets the active round area and mode limits, including Glacial Trail checks.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

GetRoundArea() {
    global RunConfig
    global RoundAreas


    difficulty :=
        RunConfig.difficulty


    areaKey :=
        difficulty


    ; Impoppable and CHIMPS are Hard game modes, but their /100 round
    ; display uses the wider OCR region that was previously keyed by
    ; those mode names. Keep the difficulty canonical while selecting
    ; the correct OCR area from the game mode.
    if HasProp(
        RunConfig,
        "gameMode"
    ) {

        gameMode :=
            RunConfig.gameMode


        if (
            gameMode = "Impoppable"
            || gameMode = "CHIMPS"
        ) {

            areaKey :=
                gameMode
        }
    }


    if !RoundAreas.Has(
        areaKey
    ) {

        throw Error(
            "No round area configured for: "
            . areaKey
        )
    }


    return RoundAreas[
        areaKey
    ]
}


IsGlacialTrailRun() {
    global RunConfig

    return (
        HasProp(RunConfig, "map")
        && RunConfig.map = "Glacial Trail"
    )
}


IsGlacialTrailEarlyOcrTrouble() {
    global LastRound

    return (
        IsGlacialTrailRun()
        && LastRound >= 9
        && LastRound <= 12
    )
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


    if HasProp(
        RunConfig,
        "gameMode"
    ) {

        gameMode :=
            RunConfig.gameMode


        if (
            gameMode = "Impoppable"
            || gameMode = "CHIMPS"
        ) {

            return 100
        }
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



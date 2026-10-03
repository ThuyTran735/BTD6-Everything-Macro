#Requires AutoHotkey v2.0

; v3 file note: Gets from the home screen to the requested map and handles map clicking.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

NavigateToMap(
    category,
    mapName,
    difficulty,
    gameMode,
    hero := false
) {
    if !OpenPlayMenu() {
        ToolTip(
            "Could not reach map selection screen."
        )

        return SetRunFailureReason("FAILED TO OPEN PLAY MENU")
    }

    if hero {
        if !OpenHeroSelection() {
            ToolTip(
                "Could not open hero selection."
            )

            return SetRunFailureReason("FAILED TO OPEN HERO SELECTION")
        }

        if !SelectHero(hero) {
            ToolTip(
                "Could not select hero: "
                hero
            )

            return SetRunFailureReason("FAILED TO SELECT HERO", hero)
        }

        Send("{Esc}")

        Sleep(1000)
    }

    if !FindAndClickMap(
        category,
        mapName,
        15
    ) {
        return EnsureRunFailureReason("MAP NOT FOUND")
    }

    Sleep(500)

    if !SelectDifficulty(difficulty) {
        ToolTip(
            "Could not select difficulty: "
            difficulty
        )

        return SetRunFailureReason("FAILED TO SELECT DIFFICULTY", difficulty)
    }

    HandleSavePrompt(700)

    Sleep(150)

    modeResult := SelectGameMode(
        gameMode
    )

    if modeResult = "Locked" {
        ToolTip(
            "Game mode is locked:"
            "`n" gameMode
        )

        Sleep(1200)

        ToolTip()

        return "Locked"
    }

    if modeResult = false {
        ToolTip(
            "Could not select game mode: "
            gameMode
        )

        return SetRunFailureReason("FAILED TO ENTER MODE", gameMode)
    }

    HandleSavePrompt(500)

    if !HandleModePrompt(
        gameMode
    ) {
        return SetRunFailureReason("MODE CONFIRMATION FAILED", gameMode)
    }

    return true
}

OpenPlayMenu() {
    global NavigationPatterns

    ; Clear Home-menu interruptions before trying Play.
    ; This returns immediately when no configured popup
    ; pattern is visible.
    HandleHomeMenuInterruptions()

    if NavigationPatterns.Has(
        "MapScreen"
    ) {
        if PatternExists(
            NavigationPatterns[
                "MapScreen"
            ]
        ) {
            return true
        }
    }

    if !NavigationPatterns.Has(
        "Play"
    ) {
        ToolTip(
            "Play pattern is missing."
        )

        return false
    }

    playPattern :=
        NavigationPatterns[
            "Play"
        ]

    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        playPattern
    ) {
        ToolTip(
            "Could not find Play button."
        )

        return false
    }

    Click(X, Y)

    Sleep(700)

    if NavigationPatterns.Has(
        "MapScreen"
    ) {
        Loop 10 {
            if PatternExists(
                NavigationPatterns[
                    "MapScreen"
                ]
            ) {
                return true
            }

            Sleep(200)
        }

        ToolTip(
            "Play was clicked, but map screen "
            "was not detected."
        )

        return false
    }

    return true
}

OpenHeroSelection() {
    Click(
        97,
        991
    )

    Sleep(500)

    return true
}

TryClickCurrentMap(mapName) {
    global MapData

    if !MapData.Has(
        mapName
    ) {
        ToolTip(
            "Unknown map: "
            mapName
        )

        return false
    }

    mapPattern :=
        MapData[
            mapName
        ].pattern

    Loop 4 {
        if FindText(
            &X,
            &Y,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            mapPattern
        ) {
            Click(X, Y)

            Sleep(600)

            return true
        }

        Sleep(200)
    }

    return false
}

FindAndClickMap(
    category,
    mapName,
    maxPageChanges := 15
) {
    global MapData
    global NavigationPatterns

    if !MapData.Has(
        mapName
    ) {
        ToolTip(
            "Unknown map: "
            . mapName
        )

        RequestLauncherCycleStop()

        Sleep(1800)
        ToolTip()

        return SetRunFailureReason("MAP NOT FOUND", mapName)
    }

    if !NavigationPatterns.Has(
        category
    ) {
        ToolTip(
            "Could not find map category control."
            . "`nCategory: "
            . category
        )

        RequestLauncherCycleStop()

        Sleep(1800)
        ToolTip()

        return SetRunFailureReason("MAP CATEGORY NOT FOUND", category)
    }

    ; Search the page the user is currently on first.
    if TryClickCurrentMap(
        mapName
    ) {
        return true
    }

    categoryPattern :=
        NavigationPatterns[
            category
        ]

    ; Never use the left/right map arrows.
    ; Clicking the category icon cycles through
    ; that category's map pages and wraps around.
    Loop maxPageChanges {
        if !FindText(
            &X,
            &Y,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            categoryPattern
        ) {
            ToolTip(
                "Could not find category button: "
                . category
            )

            RequestLauncherCycleStop()

            Sleep(1800)
            ToolTip()

            return SetRunFailureReason("MAP CATEGORY CONTROL NOT FOUND", category)
        }

        Click(X, Y)

        Sleep(550)

        if TryClickCurrentMap(
            mapName
        ) {
            return true
        }
    }

    ToolTip(
        "Could not find map: "
        . mapName
        . "`nStopped after "
        . maxPageChanges
        . " page changes."
    )

    RequestLauncherCycleStop()

    Sleep(2200)
    ToolTip()

    return SetRunFailureReason("MAP NOT FOUND", mapName)
}


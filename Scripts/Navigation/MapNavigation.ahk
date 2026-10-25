#Requires AutoHotkey v2.0

; Navigates from Home through hero, map, difficulty, and mode selection.
; Map scans hide the launcher HUD and focus BTD6 so overlays cannot obscure the capture.

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

        SendEscapeAndWait(1000)
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

        if IsCollectionEventRun()
            return SetRunFailureReason("EVENT CANDIDATE UNAVAILABLE", mapName . " - Impoppable pattern was not found")

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
    homeResult := HandleHomeMenuInterruptions()
    if homeResult = "blocked"
        return false
    if homeResult = "pending"
        return SetRunFailureReason("COLLECTION REWARDS BUSY", "Another handler still owns the reward screen")

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

PrepareMapPatternScan() {
    ; A normal launcher run has the Cycle HUD visible, while the standalone
    ; map-pattern tester does not. Hide it briefly so the runtime scan sees
    ; the same clean BTD6 screen as the tester.
    RequestCycleStatusHide(2500)

    gameWindow := WinExist(
        "ahk_exe BloonsTD6.exe"
    )

    if !gameWindow {
        return false
    }

    ; SwitchToFullscreen can return immediately when the game is already
    ; fullscreen. Make sure BTD6 is also the active window before scanning.
    WinActivate(
        "ahk_id "
        . gameWindow
    )

    if !WinWaitActive(
        "ahk_id "
        . gameWindow,
        ,
        1
    ) {
        return false
    }

    Sleep(100)
    return true
}

ClickMapPatternMatch(x, y) {
    previousMouseCoordMode := A_CoordModeMouse

    try {
        ; FindText gives us screen coordinates. Use the same coordinate system
        ; for the click instead of depending on whichever window had focus.
        CoordMode("Mouse", "Screen")
        Click(x, y)
    }
    finally {
        CoordMode("Mouse", previousMouseCoordMode)
    }
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

    ; Keep BTD6 focused and the launcher HUD out of the captured cards.
    if !PrepareMapPatternScan() {
        return false
    }

    Loop 4 {
        match := FindMapCardPattern(mapPattern)
        if match {
            if !WinActive("ahk_exe BloonsTD6.exe")
                return false
            X := match.x
            Y := match.y
            LogMessage(
                "INFO",
                "Map pattern found: "
                . mapName
                . " at X="
                . X
                . " Y="
                . Y
            )

            ClickMapPatternMatch(X, Y)

            Sleep(600)

            return true
        }

        Sleep(200)
    }

    return false
}

FindMapCardPattern(mapPattern) {
    ; Map patterns describe the artwork, not the surrounding UI. Search each
    ; card separately so controls, gaps, and medals cannot count as a map.
    ; Normal and collection runs must use the same bounds here.
    if !WinActive("ahk_exe BloonsTD6.exe")
        return false
    FindText().ScreenShot(320, 105, 1610, 750)
    Loop 6 {
        if !WinActive("ahk_exe BloonsTD6.exe")
            return false
        area := GetCollectionEventMapArtRegion(A_Index)
        matches := FindText(&x, &y, area.left, area.top, area.right, area.bottom,
            0, 0, mapPattern, 0, 1)
        if matches {
            for match in matches {
                if IsCollectionEventMapArtMatch(match)
                    return match
            }
        }
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

        if !IsCollectionEventRun()
            RequestLauncherCycleStop()

        Sleep(1800)
        ToolTip()

        ; Failure logging keeps the first cause, so classify the skip here.
        return SetRunFailureReason(
            IsCollectionEventRun() ? "EVENT CANDIDATE UNAVAILABLE" : "MAP NOT FOUND", mapName)
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
        if IsCollectionEventRun() && !WinActive("ahk_exe BloonsTD6.exe")
            return SetRunFailureReason("BTD6 LOST FOCUS DURING MAP SEARCH")

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

        if IsCollectionEventRun() && !WinActive("ahk_exe BloonsTD6.exe")
            return SetRunFailureReason("BTD6 LOST FOCUS DURING MAP SEARCH")
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

    ; Event runs can try another installed strategy when this map is absent.
    ; Category/focus failures still stop because changing maps cannot fix them.
    if !IsCollectionEventRun()
        RequestLauncherCycleStop()

    Sleep(2200)
    ToolTip()

    return SetRunFailureReason(
        IsCollectionEventRun() ? "EVENT CANDIDATE UNAVAILABLE" : "MAP NOT FOUND", mapName)
}

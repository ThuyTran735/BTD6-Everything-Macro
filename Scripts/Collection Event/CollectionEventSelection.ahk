#Requires AutoHotkey v2.0
#Include CollectionEventPatterns.ahk
#Include CollectionEventGeometry.ahk
#Include ..\CycleStatusClickGuard.ahk

; Find a supported Expert Impoppable strategy before starting a collection run.
; Detection only chooses a script; the normal runner still owns playing the map.

DiscoverCollectionEventStrategies(projectRoot := "") {
    global MapData

    if projectRoot = ""
        projectRoot := A_ScriptDir

    candidatesByMap := Map()
    mapsRoot := projectRoot . "\Maps\Expert"
    if !DirExist(mapsRoot)
        return []

    Loop Files mapsRoot . "\*", "D" {
        folderMapName := A_LoopFileName
        hardDirectory := A_LoopFileFullPath . "\Hard"
        if !DirExist(hardDirectory)
            continue

        Loop Files hardDirectory . "\*.ahk", "FR" {
            scriptPath := A_LoopFileFullPath
            try scriptText := FileRead(scriptPath, "UTF-8")
            catch
                continue

            config := ReadCollectionEventRunConfig(scriptText)
            if !config
                continue
            if (
                config.category != "Expert"
                || config.difficulty != "Hard"
                || config.gameMode != "Impoppable"
                || StrLower(config.mapName) != StrLower(folderMapName)
                || !IsCollectionEventMapSupported(config.mapName)
            ) {
                continue
            }

            ; Multiple files for one map must not give that map extra random weight.
            key := StrLower(config.mapName)
            candidate := {mapName: config.mapName, scriptPath: scriptPath}
            if (
                !candidatesByMap.Has(key)
                || StrCompare(scriptPath, candidatesByMap[key].scriptPath, false) < 0
            ) {
                candidatesByMap[key] := candidate
            }
        }
    }

    candidates := []
    for key, candidate in candidatesByMap
        candidates.Push(candidate)
    SortCollectionEventCandidates(candidates)
    return candidates
}

ReadCollectionEventRunConfig(scriptText) {
    ; Read configuration as text. Importing a candidate must never execute it.
    cleanText := RegExReplace(scriptText, "ms)^\h*/\*.*?^\h*\*/[^\r\n]*", "")
    cleanText := RegExReplace(cleanText, "m)^\h*;[^\r\n]*", "")
    if !RegExMatch(
        cleanText,
        "ims)^\h*(?:global\h+)?RunConfig\h*:=\h*\{(.*?)^\h*\}",
        &configMatch
    ) {
        return false
    }

    result := {}
    for field in ["category", "map", "difficulty", "gameMode"] {
        if !RegExMatch(
            configMatch[1],
            "im)^\h*" . field . "\h*:\h*\x22((?:\x22\x22|[^\x22\r\n])*)\x22\h*(?:,|;|$)",
            &valueMatch
        ) {
            return false
        }
        property := field = "map" ? "mapName" : field
        result.%property% := StrReplace(valueMatch[1], Chr(34) . Chr(34), Chr(34))
    }
    return result
}

SortCollectionEventCandidates(candidates) {
    index := 2
    while index <= candidates.Length {
        candidate := candidates[index]
        previous := index - 1
        while previous >= 1 && StrCompare(candidates[previous].mapName, candidate.mapName, false) > 0 {
            candidates[previous + 1] := candidates[previous]
            previous -= 1
        }
        candidates[previous + 1] := candidate
        index += 1
    }
}

IsCollectionEventPatternUsable(pattern) {
    return Type(pattern) = "String"
        && Trim(pattern) != ""
        && InStr(pattern, "$")
        && !InStr(StrUpper(pattern), "YOUR_")
}

IsCollectionEventMapSupported(mapName) {
    global MapData

    if !MapData.Has(mapName)
        return false
    mapInfo := MapData[mapName]
    return mapInfo.category = "Expert"
        && mapInfo.page > 0
        && IsCollectionEventPatternUsable(mapInfo.pattern)
}

NormalizeCollectionEventPath(path) {
    return StrLower(StrReplace(path, "/", "\"))
}

IsCollectionEventPathExcluded(path, excludedPaths) {
    if !IsObject(excludedPaths)
        return false
    normalizedPath := NormalizeCollectionEventPath(path)
    for excludedPath, value in excludedPaths {
        if excludedPaths is Array
            excludedPath := value
        if NormalizeCollectionEventPath(excludedPath) = normalizedPath
            return true
    }
    return false
}

GetRemainingCollectionEventCandidates(candidates, excludedPaths) {
    remaining := []
    seenPaths := Map()
    for candidate in candidates {
        if (
            !IsObject(candidate)
            || !HasProp(candidate, "mapName")
            || !HasProp(candidate, "scriptPath")
            || !IsCollectionEventMapSupported(candidate.mapName)
            || IsCollectionEventPathExcluded(candidate.scriptPath, excludedPaths)
        ) {
            continue
        }
        attributes := FileExist(candidate.scriptPath)
        if attributes = "" || InStr(attributes, "D")
            continue
        key := NormalizeCollectionEventPath(candidate.scriptPath)
        if seenPaths.Has(key)
            continue
        seenPaths[key] := true
        remaining.Push(candidate)
    }
    return remaining
}

GetCollectionEventExpertPageCount(mapDataOverride := false, startPagesOverride := false) {
    global MapData, CategoryStartPages

    mapData := IsObject(mapDataOverride) ? mapDataOverride : MapData
    startPages := IsObject(startPagesOverride) ? startPagesOverride : CategoryStartPages
    if !startPages.Has("Expert")
        return 0
    firstPage := startPages["Expert"]
    lastPage := firstPage - 1
    for mapName, mapInfo in mapData {
        if (
            mapName != ""
            && mapInfo.category = "Expert"
            && mapInfo.page >= firstPage
            && IsCollectionEventPatternUsable(mapInfo.pattern)
        ) {
            lastPage := Max(lastPage, mapInfo.page)
        }
    }
    return Max(0, lastPage - firstPage + 1)
}

GetCollectionEventMarkedCandidates(candidates, badges, mapMatches, excludedPaths := false) {
    candidateByName := Map()
    for candidate in candidates {
        if !IsCollectionEventPathExcluded(candidate.scriptPath, excludedPaths)
            candidateByName[StrLower(candidate.mapName)] := candidate
    }

    markedCards := Map()
    for badge in badges {
        cardIndex := GetCollectionEventBadgeCardIndex(badge.x, badge.y)
        if cardIndex
            markedCards[cardIndex] := true
    }

    namesByCard := Map()
    for match in mapMatches {
        cardIndex := GetCollectionEventCardIndex(match.x, match.y)
        if !cardIndex
            continue
        if !namesByCard.Has(cardIndex)
            namesByCard[cardIndex] := Map()
        namesByCard[cardIndex][StrLower(match.mapName)] := true
    }

    selected := []
    seenNames := Map()
    Loop 6 {
        cardIndex := A_Index
        if !markedCards.Has(cardIndex) || !namesByCard.Has(cardIndex)
            continue
        names := namesByCard[cardIndex]
        ; Two different map names in one card are ambiguous, not a choice to guess.
        if names.Count != 1
            continue
        for name, unused in names {
            if candidateByName.Has(name) && !seenNames.Has(name) {
                selected.Push(candidateByName[name])
                seenNames[name] := true
            }
        }
    }
    return selected
}

ScanCollectionEventCachedFrame(candidates, isCurrent, offsetX := 0, offsetY := 0, imageWidth := 1920, imageHeight := 1080, requireGameActive := false) {
    global MapData, CollectionEventBonusPattern

    interruption := GetCollectionEventScanInterruption(isCurrent, requireGameActive)
    if interruption
        return interruption
    if !IsCollectionEventPatternUsable(CollectionEventBonusPattern)
        return CollectionEventSelectionResult("failed", "Collection Event bonus pattern is missing")

    badges := []
    mapMatches := []
    visiblePages := Map()

    ; Read one card at a time from the same captured frame. A map sample must
    ; fit its artwork box; the event badge must belong to that card's right edge.
    Loop 6 {
        cardIndex := A_Index
        art := GetCollectionEventMapArtRegion(cardIndex)
        artBounds := ClipCollectionEventFixtureRegion(art, offsetX, offsetY, imageWidth, imageHeight)
        if artBounds {
            for mapName, mapInfo in MapData {
                if !IsCollectionEventMapSupported(mapName)
                    continue
                interruption := GetCollectionEventScanInterruption(isCurrent, requireGameActive)
                if interruption
                    return interruption
                matches := FindText(&foundX, &foundY, artBounds.left, artBounds.top, artBounds.right, artBounds.bottom, 0, 0, mapInfo.pattern, 0, 1)
                interruption := GetCollectionEventScanInterruption(isCurrent, requireGameActive)
                if interruption
                    return interruption
                if !matches
                    continue
                for match in matches {
                    if GetCollectionEventMapMatchCard(match, offsetX, offsetY) != cardIndex
                        continue
                    mapMatches.Push({mapName: mapName, x: match.x + offsetX, y: match.y + offsetY})
                    visiblePages[mapInfo.page] := true
                }
            }
        }

        badgeRegion := GetCollectionEventBadgeSearchRegion(cardIndex)
        badgeBounds := ClipCollectionEventFixtureRegion(badgeRegion, offsetX, offsetY, imageWidth, imageHeight)
        if !badgeBounds
            continue
        interruption := GetCollectionEventScanInterruption(isCurrent, requireGameActive)
        if interruption
            return interruption
        matches := FindText(&foundX, &foundY, badgeBounds.left, badgeBounds.top, badgeBounds.right, badgeBounds.bottom, 0, 0, CollectionEventBonusPattern, 0, 1)
        interruption := GetCollectionEventScanInterruption(isCurrent, requireGameActive)
        if interruption
            return interruption
        if matches {
            for match in matches {
                x := match.x + offsetX
                y := match.y + offsetY
                if GetCollectionEventBadgeCardIndex(x, y) = cardIndex
                    badges.Push({x: x, y: y, cardIndex: cardIndex})
            }
        }
    }

    pageNumber := 0
    if visiblePages.Count = 1 {
        for page, unused in visiblePages
            pageNumber := page
    }
    return {
        status: "scanned",
        reason: "",
        badges: badges,
        mapMatches: mapMatches,
        pageNumber: pageNumber,
        markedCandidates: GetCollectionEventMarkedCandidates(candidates, badges, mapMatches)
    }
}

ClipCollectionEventFixtureRegion(region, offsetX, offsetY, imageWidth, imageHeight) {
    ; Live frames use zero offsets. Cropped offline fixtures retain their screen
    ; coordinates by translating only the search rectangles and returned hits.
    clipped := {
        left: Max(0, region.left - offsetX),
        top: Max(0, region.top - offsetY),
        right: Min(imageWidth - 1, region.right - offsetX),
        bottom: Min(imageHeight - 1, region.bottom - offsetY)
    }
    return clipped.left <= clipped.right && clipped.top <= clipped.bottom ? clipped : false
}

SelectCollectionEventStrategy(candidates, excludedPaths, isCurrent) {
    if !IsCurrentCollectionEventSelection(isCurrent)
        return CollectionEventSelectionResult("cancelled", "Selection cancelled")

    remaining := GetRemainingCollectionEventCandidates(candidates, excludedPaths)
    if remaining.Length = 0
        return CollectionEventSelectionResult("exhausted", "No untried Expert Impoppable strategies remain")

    pageCount := GetCollectionEventExpertPageCount()
    if pageCount < 1
        return CollectionEventSelectionResult("failed", "Expert map pages are not configured")

    try {
        recovery := RecoverCollectionEventMapScreen(isCurrent)
        if recovery.status != "ready"
            return recovery

        ; The Expert icon cycles pages when that category is already open.
        ; Inspect the visible page first so its bonus map is not skipped.
        if !WaitCollectionEventSelection(1250, isCurrent, true)
            return CollectionEventSelectionStopped(isCurrent, "BTD6 lost focus while waiting for the current map page")
        page := ScanCollectionEventPage(remaining, excludedPaths, isCurrent)
        if page.status != "scanned"
            return page

        ; A stable Expert page already received its full scan. An unknown or
        ; changing page must not shorten the pass through the Expert category.
        pagesToAdvance := pageCount - (page.pageNumber > 0 ? 1 : 0)
        Loop pagesToAdvance {
            if !AdvanceCollectionEventExpertPage(isCurrent)
                return CollectionEventSelectionStopped(isCurrent, "Could not advance the Expert map page")
            page := ScanCollectionEventPage(remaining, excludedPaths, isCurrent)
            if page.status != "scanned"
                return page
        }

        ; Only a complete page pass can fall back to a random supported map.
        remaining := GetRemainingCollectionEventCandidates(candidates, excludedPaths)
        randomCandidates := []
        for candidate in remaining {
            ; Dark Dungeons remains valid when marked, but is not a random fallback.
            if candidate.mapName != "Dark Dungeons"
                randomCandidates.Push(candidate)
        }
        interruption := GetCollectionEventScanInterruption(isCurrent, true)
        if interruption
            return interruption
        if remaining.Length = 0
            return CollectionEventSelectionResult("exhausted", "No untried Expert Impoppable strategies remain")
        if randomCandidates.Length = 0
            return CollectionEventSelectionResult("exhausted", "No random Expert Impoppable fallback is available; Dark Dungeons requires a collection bonus")
        chosen := randomCandidates[Random(1, randomCandidates.Length)]
        return CollectionEventSelectionResult("selected", "No supported bonus map found; using a random Expert Impoppable strategy", chosen, false)
    }
    catch as err {
        return CollectionEventSelectionStopped(isCurrent, "Collection Event scan failed: " . err.Message)
    }
}

ScanCollectionEventPage(candidates, excludedPaths, isCurrent) {
    firstPageNumber := 0
    Loop 2 {
        interruption := GetCollectionEventScanInterruption(isCurrent, true)
        if interruption
            return interruption
        RequestCycleStatusHide(5000)
        interruption := GetCollectionEventScanInterruption(isCurrent, true)
        if interruption
            return interruption
        ; Each retry needs a new screenshot. Every card in that scan
        ; still shares one frame for badge-to-map association.
        FindText().ScreenShot(320, 105, 1640, 750)
        interruption := GetCollectionEventScanInterruption(isCurrent, true)
        if interruption
            return interruption
        page := ScanCollectionEventCachedFrame(candidates, isCurrent, 0, 0, 1920, 1080, true)
        if page.status != "scanned"
            return page

        ; Recheck disk and exclusions after scanning; a missing file is never selected.
        eligible := GetRemainingCollectionEventCandidates(page.markedCandidates, excludedPaths)
        interruption := GetCollectionEventScanInterruption(isCurrent, true)
        if interruption
            return interruption
        if eligible.Length
            return CollectionEventSelectionResult("selected", "Bonus map found", eligible[1], true)

        if A_Index = 1 {
            firstPageNumber := page.pageNumber
            ; Retrying the same page must not restart its badge animation.
            if !WaitCollectionEventSelection(250, isCurrent, true)
                return CollectionEventSelectionStopped(isCurrent, "BTD6 lost focus while waiting for Collection Event badges")
        }
        else {
            ; Two agreeing frames establish which Expert page was inspected.
            ; A partial transition or unknown frame never spends a page slot.
            stablePage := firstPageNumber > 0 && page.pageNumber = firstPageNumber
                ? firstPageNumber : 0
            return {status: "scanned", reason: "", pageNumber: stablePage}
        }
    }
}

RecoverCollectionEventMapScreen(isCurrent) {
    if !FocusCollectionEventGame(isCurrent)
        return CollectionEventSelectionStopped(isCurrent, "BTD6 could not be focused")
    interruption := GetCollectionEventScanInterruption(isCurrent, true)
    if interruption
        return interruption
    RequestCycleStatusHide(5000)
    interruption := GetCollectionEventScanInterruption(isCurrent, true)
    if interruption
        return interruption

    ; Fixed map-card coordinates are only valid in the normal fullscreen layout.
    WinGetClientPos(&gameX, &gameY, &gameWidth, &gameHeight, "ahk_exe BloonsTD6.exe")
    interruption := GetCollectionEventScanInterruption(isCurrent, true)
    if interruption
        return interruption
    if gameX != 0 || gameY != 0 || gameWidth != 1920 || gameHeight != 1080
        return CollectionEventSelectionResult("failed", "Collection Event needs BTD6 fullscreen at 1920x1080")

    homeCheck := CheckCollectionEventRecoveryInterruptions(isCurrent)
    if homeCheck.status != "clear" && homeCheck.status != "handled"
        return homeCheck

    Loop 5 {
        mapScreen := IsCollectionEventMapBrowserVisible(isCurrent)
        if !IsCurrentCollectionEventSelection(isCurrent)
            return CollectionEventSelectionResult("cancelled", "Selection cancelled")
        if mapScreen
            return CollectionEventSelectionResult("ready", "Map screen found")

        homePlay := FindCollectionEventNavigationControl("Play", isCurrent)
        if !IsCurrentCollectionEventSelection(isCurrent)
            return CollectionEventSelectionResult("cancelled", "Selection cancelled")
        if homePlay {
            if !ClickCollectionEventControl(homePlay.x, homePlay.y, isCurrent)
                return CollectionEventSelectionStopped(isCurrent, "Could not open the Play menu")
            if !WaitCollectionEventSelection(700, isCurrent, true)
                return CollectionEventSelectionStopped(isCurrent, "BTD6 lost focus while opening the Play menu")
            retryHome := false
            Loop 10 {
                mapScreen := IsCollectionEventMapBrowserVisible(isCurrent)
                if !IsCurrentCollectionEventSelection(isCurrent)
                    return CollectionEventSelectionResult("cancelled", "Selection cancelled")
                if mapScreen
                    return CollectionEventSelectionResult("ready", "Map screen found")
                ; A delayed reward can cover Home after Play was detected.
                ; Once claimed, start again from its verified Home screen.
                homeCheck := CheckCollectionEventRecoveryInterruptions(isCurrent)
                if homeCheck.status != "clear" && homeCheck.status != "handled"
                    return homeCheck
                if homeCheck.status = "handled" {
                    retryHome := true
                    break
                }
                if !WaitCollectionEventSelection(150, isCurrent, true)
                    return CollectionEventSelectionStopped(isCurrent, "BTD6 lost focus while waiting for the map browser")
            }
            if retryHome
                continue
            return CollectionEventSelectionResult("failed", "Play was clicked, but the map screen did not appear")
        }

        ; Check the final pass too: a reward can appear during the fourth Back
        ; wait. Finish it before reporting an unknown screen, without another Back.
        homeCheck := CheckCollectionEventRecoveryInterruptions(isCurrent)
        if homeCheck.status != "clear" && homeCheck.status != "handled"
            return homeCheck
        if homeCheck.status = "handled" {
            if A_Index = 5
                return CollectionEventSelectionResult("pending", "Home interruption handled; resume map selection")
            continue
        }
        if A_Index < 5 {
            if !SendCollectionEventEscape(isCurrent)
                return CollectionEventSelectionStopped(isCurrent, "Could not return to the map browser")
            if !WaitCollectionEventSelection(350, isCurrent, true)
                return CollectionEventSelectionStopped(isCurrent, "BTD6 lost focus while returning to the map browser")
        }
    }
    return CollectionEventSelectionResult("failed", "Could not verify Home or the map browser after four Back attempts")
}

CheckCollectionEventRecoveryInterruptions(isCurrent) {
    interruption := GetCollectionEventScanInterruption(isCurrent, true)
    if interruption
        return interruption
    homeResult := HandleHomeMenuInterruptions(isCurrent)
    interruption := GetCollectionEventScanInterruption(isCurrent, true)
    if interruption
        return interruption
    if homeResult = "blocked"
        return CollectionEventSelectionResult("failed", GetHomeMenuInterruptionReason())
    if homeResult = "pending"
        return CollectionEventSelectionResult("pending", "Collection rewards are still being handled")
    return CollectionEventSelectionResult(homeResult ? "handled" : "clear", "")
}

AdvanceCollectionEventExpertPage(isCurrent) {
    category := FindCollectionEventNavigationControl("Expert", isCurrent)
    if !category || !IsCurrentCollectionEventSelection(isCurrent)
        return false
    if !ClickCollectionEventControl(category.x, category.y, isCurrent)
        return false
    ; The event badge animates for about a second after every category click.
    ; Leave a small render margin before capturing the six map cards.
    if !WaitCollectionEventSelection(1250, isCurrent, true)
        return false
    mapScreen := IsCollectionEventMapBrowserVisible(isCurrent)
    return IsCurrentCollectionEventSelection(isCurrent) && !!mapScreen
}

IsCollectionEventMapBrowserVisible(isCurrent) {
    ; MapScreen is the shared Back-button capture. Difficulty and mode menus
    ; have that button too; the Expert category proves this is the map browser.
    if !FindCollectionEventNavigationControl("MapScreen", isCurrent)
        return false
    return !!FindCollectionEventNavigationControl("Expert", isCurrent)
}

FindCollectionEventNavigationControl(name, isCurrent) {
    global NavigationPatterns

    if !IsCurrentCollectionEventSelection(isCurrent) || !WinActive("ahk_exe BloonsTD6.exe")
        return false
    if !NavigationPatterns.Has(name) || !IsCollectionEventPatternUsable(NavigationPatterns[name])
        return false
    found := FindText(&x, &y, 0, 0, 1919, 1079, 0, 0, NavigationPatterns[name], 1, 0)
    if !IsCurrentCollectionEventSelection(isCurrent) || !WinActive("ahk_exe BloonsTD6.exe")
        return false
    return found ? {x: x, y: y} : false
}

FocusCollectionEventGame(isCurrent) {
    if !IsCurrentCollectionEventSelection(isCurrent)
        return false
    if !WinExist("ahk_exe BloonsTD6.exe")
        return false
    if !IsCurrentCollectionEventSelection(isCurrent)
        return false
    WinActivate("ahk_exe BloonsTD6.exe")
    if !IsCurrentCollectionEventSelection(isCurrent)
        return false
    if !WinWaitActive("ahk_exe BloonsTD6.exe",, 1)
        return false
    if !IsCurrentCollectionEventSelection(isCurrent)
        return false
    return WaitCollectionEventSelection(100, isCurrent)
}

ClickCollectionEventControl(x, y, isCurrent) {
    if !IsCurrentCollectionEventSelection(isCurrent) || !WinActive("ahk_exe BloonsTD6.exe")
        return false
    previousMode := A_CoordModeMouse
    try {
        CoordMode("Mouse", "Screen")
        if !IsCurrentCollectionEventSelection(isCurrent)
            return false
        Click(x, y)
        return IsCurrentCollectionEventSelection(isCurrent)
    }
    finally {
        CoordMode("Mouse", previousMode)
    }
}

SendCollectionEventEscape(isCurrent) {
    if !IsCurrentCollectionEventSelection(isCurrent) || !WinActive("ahk_exe BloonsTD6.exe")
        return false
    SendEvent("{Esc}")
    return IsCurrentCollectionEventSelection(isCurrent)
}

WaitCollectionEventSelection(durationMs, isCurrent, requireGameActive := false) {
    remaining := durationMs
    while remaining > 0 {
        if !IsCurrentCollectionEventSelection(isCurrent)
            || (requireGameActive && !WinActive("ahk_exe BloonsTD6.exe"))
            return false
        slice := Min(50, remaining)
        Sleep(slice)
        if !IsCurrentCollectionEventSelection(isCurrent)
            || (requireGameActive && !WinActive("ahk_exe BloonsTD6.exe"))
            return false
        remaining -= slice
    }
    return IsCurrentCollectionEventSelection(isCurrent)
        && (!requireGameActive || !!WinActive("ahk_exe BloonsTD6.exe"))
}

IsCurrentCollectionEventSelection(isCurrent) {
    try return !!isCurrent.Call()
    catch
        return false
}

GetCollectionEventScanInterruption(isCurrent, requireGameActive := false) {
    if !IsCurrentCollectionEventSelection(isCurrent)
        return CollectionEventSelectionResult("cancelled", "Selection cancelled")
    if requireGameActive && !WinActive("ahk_exe BloonsTD6.exe")
        return CollectionEventSelectionResult("failed", "BTD6 lost focus during Collection Event selection")
    return false
}

CollectionEventSelectionStopped(isCurrent, reason) {
    return IsCurrentCollectionEventSelection(isCurrent)
        ? CollectionEventSelectionResult("failed", reason)
        : CollectionEventSelectionResult("cancelled", "Selection cancelled")
}

CollectionEventSelectionResult(status, reason, candidate := false, marked := false) {
    result := {status: status, reason: reason, marked: marked}
    if IsObject(candidate)
        result.candidate := candidate
    return result
}

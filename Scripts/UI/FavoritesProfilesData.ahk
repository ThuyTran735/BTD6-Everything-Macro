#Requires AutoHotkey v2.0


global FavoriteMaps := Map()
global FavoriteExpScripts := Map()


GetUserDataDirectory() {
    return A_ScriptDir . "\UserData"
}


GetFavoritesFilePath() {
    return GetUserDataDirectory() . "\Favorites.ini"
}


GetQueueProfilesDirectory() {
    return GetUserDataDirectory() . "\QueueProfiles"
}


GetLegacyQueueProfilesDirectory() {
    return GetUserDataDirectory() . "\Queue Profiles"
}


EnsureUserDataDirectory() {
    directory := GetUserDataDirectory()

    if !DirExist(directory) {
        DirCreate(directory)
    }

    return directory
}


EnsureQueueProfilesDirectory() {
    EnsureUserDataDirectory()

    directory := GetQueueProfilesDirectory()

    if !DirExist(directory) {
        DirCreate(directory)
    }

    MigrateLegacyQueueProfiles()

    return directory
}


MigrateLegacyQueueProfiles() {
    legacyDirectory := GetLegacyQueueProfilesDirectory()
    newDirectory := GetQueueProfilesDirectory()

    if !DirExist(legacyDirectory) {
        return
    }

    if !DirExist(newDirectory) {
        DirCreate(newDirectory)
    }

    Loop Files legacyDirectory . "\*.ini", "F" {
        destination := newDirectory . "\" . A_LoopFileName

        if FileExist(destination) {
            continue
        }

        try FileMove(A_LoopFileFullPath, destination, false)
        catch {
            ; If moving is blocked, keep the original and copy it instead.
            try FileCopy(A_LoopFileFullPath, destination, false)
        }
    }
}


LoadFavoriteData() {
    global FavoriteMaps
    global FavoriteExpScripts

    FavoriteMaps := Map()
    FavoriteExpScripts := Map()

    filePath := GetFavoritesFilePath()

    if !FileExist(filePath) {
        return
    }

    index := 1

    Loop {
        value := IniRead(
            filePath,
            "FavoriteMaps",
            "Item" . index,
            ""
        )

        if value = "" {
            break
        }

        FavoriteMaps[value] := true
        index += 1
    }

    index := 1

    Loop {
        value := IniRead(
            filePath,
            "FavoriteExpScripts",
            "Item" . index,
            ""
        )

        if value = "" {
            break
        }

        FavoriteExpScripts[value] := true
        index += 1
    }
}


SaveFavoriteData() {
    global FavoriteMaps
    global FavoriteExpScripts

    EnsureUserDataDirectory()

    filePath := GetFavoritesFilePath()

    try IniDelete(filePath, "FavoriteMaps")
    try IniDelete(filePath, "FavoriteExpScripts")

    index := 1

    for favoriteId, _ in FavoriteMaps {
        IniWrite(
            favoriteId,
            filePath,
            "FavoriteMaps",
            "Item" . index
        )

        index += 1
    }

    index := 1

    for favoriteId, _ in FavoriteExpScripts {
        IniWrite(
            favoriteId,
            filePath,
            "FavoriteExpScripts",
            "Item" . index
        )

        index += 1
    }
}


GetMapFavoriteId(categoryName, mapName) {
    return categoryName . "|" . mapName
}


IsFavoriteMap(categoryName, mapName) {
    global FavoriteMaps

    return FavoriteMaps.Has(
        GetMapFavoriteId(categoryName, mapName)
    )
}


ToggleFavoriteMap(categoryName, mapName) {
    global FavoriteMaps

    if (
        categoryName = ""
        || mapName = ""
        || InStr(mapName, "No configured") = 1
    ) {
        return false
    }

    favoriteId := GetMapFavoriteId(categoryName, mapName)

    if FavoriteMaps.Has(favoriteId) {
        FavoriteMaps.Delete(favoriteId)
        isFavorite := false
    }
    else {
        FavoriteMaps[favoriteId] := true
        isFavorite := true
    }

    SaveFavoriteData()

    return isFavorite
}


GetExpFavoriteId(towerType, scriptName) {
    return towerType . "|" . scriptName
}


IsFavoriteExpScript(towerType, scriptName) {
    global FavoriteExpScripts

    return FavoriteExpScripts.Has(
        GetExpFavoriteId(towerType, scriptName)
    )
}


ToggleFavoriteExpScript(towerType, scriptName) {
    global FavoriteExpScripts

    if (
        towerType = ""
        || scriptName = ""
        || InStr(scriptName, "No ") = 1
    ) {
        return false
    }

    favoriteId := GetExpFavoriteId(towerType, scriptName)

    if FavoriteExpScripts.Has(favoriteId) {
        FavoriteExpScripts.Delete(favoriteId)
        isFavorite := false
    }
    else {
        FavoriteExpScripts[favoriteId] := true
        isFavorite := true
    }

    SaveFavoriteData()

    return isFavorite
}


SortMapNamesByFavorites(categoryName, mapNames) {
    sorted := []

    for mapName in mapNames {
        if IsFavoriteMap(categoryName, mapName) {
            sorted.Push(mapName)
        }
    }

    for mapName in mapNames {
        if !IsFavoriteMap(categoryName, mapName) {
            sorted.Push(mapName)
        }
    }

    return sorted
}


SortExpScriptsByFavorites(towerType, scripts) {
    sorted := []

    for script in scripts {
        if IsFavoriteExpScript(towerType, script.name) {
            sorted.Push(script)
        }
    }

    for script in scripts {
        if !IsFavoriteExpScript(towerType, script.name) {
            sorted.Push(script)
        }
    }

    return sorted
}


MakeProjectRelativePath(fullPath) {
    prefix := A_ScriptDir . "\"

    if SubStr(fullPath, 1, StrLen(prefix)) = prefix {
        return SubStr(fullPath, StrLen(prefix) + 1)
    }

    return fullPath
}


ResolveStoredProjectPath(storedPath) {
    if RegExMatch(storedPath, "i)^[A-Z]:\\") {
        return storedPath
    }

    return A_ScriptDir . "\" . storedPath
}


IsValidQueueProfileName(profileName) {
    profileName := Trim(profileName)

    if profileName = "" {
        return false
    }

    if InStr(profileName, Chr(34)) {
        return false
    }

    if RegExMatch(
        profileName,
        "[\\/:*?<>|\[\]=]"
    ) {
        return false
    }

    if (
        SubStr(profileName, -1) = "."
        || SubStr(profileName, -1) = " "
    ) {
        return false
    }

    firstPart := StrUpper(
        StrSplit(profileName, ".")[1]
    )

    for reservedName in [
        "CON",
        "PRN",
        "AUX",
        "NUL",
        "COM1",
        "COM2",
        "COM3",
        "COM4",
        "COM5",
        "COM6",
        "COM7",
        "COM8",
        "COM9",
        "LPT1",
        "LPT2",
        "LPT3",
        "LPT4",
        "LPT5",
        "LPT6",
        "LPT7",
        "LPT8",
        "LPT9"
    ] {
        if firstPart = reservedName {
            return false
        }
    }

    return true
}


GetQueueProfileRecords() {
    records := []

    try directory := EnsureQueueProfilesDirectory()
    catch {
        return records
    }

    favorites := []
    normal := []

    Loop Files directory . "\*.ini", "F" {
        profilePath := A_LoopFileFullPath
        profileName := IniRead(
            profilePath,
            "Profile",
            "Name",
            RegExReplace(A_LoopFileName, "i)\.ini$")
        )

        favorite := IniRead(profilePath, "Profile", "Favorite", "0") = "1"
        repeatCount := Max(1, Integer(IniRead(profilePath, "Profile", "RepeatCount", "1")))
        description := IniRead(profilePath, "Profile", "Description", "")
        jobCount := Max(0, Integer(IniRead(profilePath, "Profile", "JobCount", "0")))

        enabledJobs := 0
        totalRuns := 0
        Loop jobCount {
            section := "Job" . A_Index
            enabled := IniRead(profilePath, section, "Enabled", "1") != "0"
            if enabled {
                enabledJobs++
                totalRuns += Max(1, Integer(IniRead(profilePath, section, "Runs", "1")))
            }
        }

        record := {
            name: profileName,
            path: profilePath,
            favorite: favorite,
            repeatCount: repeatCount,
            description: description,
            jobCount: jobCount,
            enabledJobs: enabledJobs,
            totalRuns: totalRuns
        }

        if favorite {
            favorites.Push(record)
        }
        else {
            normal.Push(record)
        }
    }

    for record in favorites {
        records.Push(record)
    }

    for record in normal {
        records.Push(record)
    }

    return records
}


FindQueueProfileRecord(profileName) {
    for record in GetQueueProfileRecords() {
        if record.name = profileName {
            return record
        }
    }

    return false
}


WriteQueueProfile(profileName, jobs, existingPath := "") {
    profileName := Trim(profileName)

    if !IsValidQueueProfileName(profileName) {
        return false
    }

    EnsureQueueProfilesDirectory()

    profilePath := existingPath
    if profilePath = "" {
        profilePath := GetQueueProfilesDirectory() . "\" . profileName . ".ini"
    }

    favorite := "0"
    description := ""
    repeatCount := "1"

    try {
        if FileExist(profilePath) {
            favorite := IniRead(profilePath, "Profile", "Favorite", "0")
            description := IniRead(profilePath, "Profile", "Description", "")
            repeatCount := IniRead(profilePath, "Profile", "RepeatCount", "1")
            FileDelete(profilePath)
        }

        IniWrite(profileName, profilePath, "Profile", "Name")
        IniWrite(favorite, profilePath, "Profile", "Favorite")
        IniWrite(description, profilePath, "Profile", "Description")
        IniWrite(Max(1, Integer(repeatCount)), profilePath, "Profile", "RepeatCount")
        IniWrite(jobs.Length, profilePath, "Profile", "JobCount")

        for index, job in jobs {
            section := "Job" . index

            if !job.HasOwnProp("path") || job.path = "" {
                throw Error("Queue job is missing a script path.")
            }

            jobLabel := job.HasOwnProp("label") ? job.label : job.path
            jobMode := job.HasOwnProp("mode") ? job.mode : ""
            jobRuns := job.HasOwnProp("runs") ? Max(1, job.runs) : 1
            jobEnabled := (!job.HasOwnProp("enabled") || job.enabled) ? "1" : "0"

            IniWrite(MakeProjectRelativePath(job.path), profilePath, section, "Path")
            IniWrite(jobLabel, profilePath, section, "Label")
            IniWrite(jobMode, profilePath, section, "Mode")
            IniWrite(jobRuns, profilePath, section, "Runs")
            IniWrite(jobEnabled, profilePath, section, "Enabled")
        }
    }
    catch {
        return false
    }

    if !FileExist(profilePath) {
        return false
    }

    try {
        savedName := IniRead(profilePath, "Profile", "Name", "")
        savedCount := IniRead(profilePath, "Profile", "JobCount", "")
    }
    catch {
        return false
    }

    if savedName != profileName || savedCount = "" {
        return false
    }

    return profilePath
}


ReadQueueProfileJobs(profilePath) {
    jobs := []

    if !FileExist(profilePath) {
        return jobs
    }

    jobCount := Integer(IniRead(profilePath, "Profile", "JobCount", "0"))

    Loop jobCount {
        section := "Job" . A_Index
        storedPath := IniRead(profilePath, section, "Path", "")

        if storedPath = "" {
            continue
        }

        jobs.Push(
            {
                path: ResolveStoredProjectPath(storedPath),
                label: IniRead(profilePath, section, "Label", storedPath),
                mode: IniRead(profilePath, section, "Mode", "Default"),
                runs: Max(1, Integer(IniRead(profilePath, section, "Runs", "1"))),
                enabled: IniRead(profilePath, section, "Enabled", "1") != "0"
            }
        )
    }

    return jobs
}


GetQueueProfileDescription(profilePath) {
    if !FileExist(profilePath) {
        return ""
    }

    return IniRead(profilePath, "Profile", "Description", "")
}


GetQueueProfileRepeatCount(profilePath) {
    if !FileExist(profilePath) {
        return 1
    }

    return Max(1, Integer(IniRead(profilePath, "Profile", "RepeatCount", "1")))
}


SetQueueProfileDetails(profilePath, description, repeatCount) {
    if !FileExist(profilePath) {
        return false
    }

    repeatCount := Max(1, Min(99, Integer(repeatCount)))
    description := Trim(StrReplace(StrReplace(description, "`r", " "), "`n", " "))

    try {
        IniWrite(description, profilePath, "Profile", "Description")
        IniWrite(repeatCount, profilePath, "Profile", "RepeatCount")
    }
    catch {
        return false
    }

    return true
}


GetQueueProfileSummary(profilePath, repeatOverride := "") {
    jobs := ReadQueueProfileJobs(profilePath)
    repeatCount := repeatOverride = ""
        ? GetQueueProfileRepeatCount(profilePath)
        : Max(1, Min(99, Integer(repeatOverride)))

    jobsPerPass := 0
    runsPerPass := 0

    for job in jobs {
        if !job.HasOwnProp("enabled") || job.enabled {
            jobsPerPass++
            runsPerPass += job.runs
        }
    }

    return {
        jobsPerPass: jobsPerPass,
        repeatCount: repeatCount,
        queueJobs: jobsPerPass * repeatCount,
        runsPerPass: runsPerPass,
        totalRuns: runsPerPass * repeatCount
    }
}


SetQueueProfileFavorite(profilePath, isFavorite) {
    if !FileExist(profilePath) {
        return false
    }

    try {
        IniWrite(
            isFavorite ? "1" : "0",
            profilePath,
            "Profile",
            "Favorite"
        )
    }
    catch {
        return false
    }

    return true
}
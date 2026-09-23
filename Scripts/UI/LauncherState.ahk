#Requires AutoHotkey v2.0


GetLauncherStateFilePath() {
    return A_ScriptDir . "\UserData\LauncherState.ini"
}


GetLauncherStateSettingsFilePath() {
    return A_ScriptDir . "\UserData\Settings.ini"
}


IsRememberLauncherStateEnabled() {
    try {
        value := IniRead(
            GetLauncherStateSettingsFilePath(),
            "Launcher",
            "RememberLastState",
            "1"
        )

        return value != "0"
    }

    return true
}


SetRememberLauncherStateEnabled(enabled) {
    EnsureUserDataDirectory()

    IniWrite(
        enabled ? "1" : "0",
        GetLauncherStateSettingsFilePath(),
        "Launcher",
        "RememberLastState"
    )
}


ClearLauncherSavedState() {
    path := GetLauncherStateFilePath()

    try {
        if FileExist(path) {
            FileDelete(path)
        }
    }
}


IsValidRememberedLauncherMode(modeName) {
    return (
        modeName = "Default"
        || modeName = "Monkey EXP Grind"
        || modeName = "Monkey Money Grind"
    )
}


GetRememberedScriptIdentity(scriptPath) {
    if scriptPath = "" {
        return ""
    }

    normalizedPath := StrReplace(Trim(scriptPath), "/", "\")
    scriptRoot := StrReplace(A_ScriptDir, "/", "\")
    rootPrefix := scriptRoot . "\"

    if (
        StrLen(normalizedPath) > StrLen(rootPrefix)
        && StrLower(SubStr(normalizedPath, 1, StrLen(rootPrefix)))
            = StrLower(rootPrefix)
    ) {
        return SubStr(normalizedPath, StrLen(rootPrefix) + 1)
    }

    return normalizedPath
}


RememberLastRunStrategy(scriptPath) {
    if !IsRememberLauncherStateEnabled() {
        return false
    }

    scriptIdentity := GetRememberedScriptIdentity(scriptPath)

    if scriptIdentity = "" {
        return false
    }

    EnsureUserDataDirectory()

    IniWrite(
        scriptIdentity,
        GetLauncherStateFilePath(),
        "LauncherState",
        "LastRunStrategy"
    )

    return true
}


GetRememberedLastRunStrategy() {
    if !IsRememberLauncherStateEnabled() {
        return ""
    }

    path := GetLauncherStateFilePath()

    if !FileExist(path) {
        return ""
    }

    try {
        return IniRead(
            path,
            "LauncherState",
            "LastRunStrategy",
            ""
        )
    }

    return ""
}


IsRememberedRunStrategy(scriptPath) {
    savedIdentity := GetRememberedLastRunStrategy()

    if savedIdentity = "" {
        return false
    }

    return (
        StrLower(GetRememberedScriptIdentity(scriptPath))
        = StrLower(StrReplace(savedIdentity, "/", "\"))
    )
}


SaveLauncherState() {
    global CurrentMode
    global CategoryDropdown
    global MapDropdown
    global MonkeyExpTypeDropdown
    global MonkeyExpScriptDropdown

    if !IsRememberLauncherStateEnabled() {
        return false
    }

    EnsureUserDataDirectory()

    path := GetLauncherStateFilePath()
    modeName := IsValidRememberedLauncherMode(CurrentMode) ? CurrentMode : "Default"

    IniWrite(modeName, path, "LauncherState", "Mode")

    if IsObject(CategoryDropdown) {
        IniWrite(CategoryDropdown.Text, path, "LauncherState", "Category")
    }

    if IsObject(MapDropdown) {
        IniWrite(MapDropdown.Text, path, "LauncherState", "Map")
    }

    if IsObject(MonkeyExpTypeDropdown) {
        IniWrite(MonkeyExpTypeDropdown.Text, path, "LauncherState", "MonkeyExpType")
    }

    if IsObject(MonkeyExpScriptDropdown) {
        IniWrite(MonkeyExpScriptDropdown.Text, path, "LauncherState", "MonkeyExpScript")
    }

    return true
}


RestoreLauncherState() {
    global CurrentMode
    global CategoryDropdown
    global MapDropdown
    global MonkeyExpTypeDropdown
    global MonkeyExpScriptDropdown

    if !IsRememberLauncherStateEnabled() {
        return false
    }

    path := GetLauncherStateFilePath()

    if !FileExist(path) {
        return false
    }

    savedMode := "Default"
    savedCategory := ""
    savedMap := ""
    savedExpType := ""
    savedExpScript := ""

    try savedMode := IniRead(path, "LauncherState", "Mode", "Default")
    try savedCategory := IniRead(path, "LauncherState", "Category", "")
    try savedMap := IniRead(path, "LauncherState", "Map", "")
    try savedExpType := IniRead(path, "LauncherState", "MonkeyExpType", "")
    try savedExpScript := IniRead(path, "LauncherState", "MonkeyExpScript", "")

    if IsValidRememberedLauncherMode(savedMode) {
        CurrentMode := savedMode
    }
    else {
        CurrentMode := "Default"
    }

    if IsObject(CategoryDropdown) && IsObject(MapDropdown) {
        categoryIndex := FindTextIndex(CategoryDropdown.Items, savedCategory)

        if categoryIndex > 0 {
            CategoryDropdown.Choose(categoryIndex, false)
        }

        categoryName := CategoryDropdown.Text
        maps := GetMapNamesForCategory(categoryName)

        MapDropdown.Delete()

        if maps.Length = 0 {
            MapDropdown.Add(["No configured maps"])
            MapDropdown.Choose(1, false)
        }
        else {
            MapDropdown.Add(maps)

            mapIndex := FindTextIndex(maps, savedMap)
            MapDropdown.Choose(mapIndex > 0 ? mapIndex : 1, false)
        }
    }

    if IsObject(MonkeyExpTypeDropdown) && IsObject(MonkeyExpScriptDropdown) {
        typeIndex := FindTextIndex(MonkeyExpTypeDropdown.Items, savedExpType)

        if typeIndex > 0 {
            MonkeyExpTypeDropdown.Choose(typeIndex, false)
        }

        towerType := MonkeyExpTypeDropdown.Text
        RefreshMonkeyExpScripts(towerType, false)

        scriptIndex := FindTextIndex(MonkeyExpScriptDropdown.Items, savedExpScript)

        if scriptIndex > 0 {
            MonkeyExpScriptDropdown.Choose(scriptIndex, false)
        }
    }

    SaveLauncherState()
    return true
}


OnLauncherMapChanged(*) {
    UpdateLauncherMapFavoriteButton()
    SaveLauncherState()
}


OnLauncherExpScriptChanged(*) {
    UpdateLauncherExpFavoriteButton()
    SaveLauncherState()
}
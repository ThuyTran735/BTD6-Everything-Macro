#Requires AutoHotkey v2.0


CreateFavoriteButton(
    guiObject,
    x,
    y,
    size := 22
) {
    button := CreateDarkButton(
        guiObject,
        x,
        y,
        size,
        size,
        "☆",
        9
    )

    try button.TextControl.SetFont(
        "s10 Norm",
        "Segoe UI Symbol"
    )

    return button
}


CreateFavoriteButtonForField(
    guiObject,
    fieldObject,
    size := 15,
    favoriteHelpSize := 15,
    gap := 4
) {
    ; Keep Favorites as a compact right-aligned pair on the label row:
    ; [favorite star] [favorite ?]
    ; The field's own ? now lives directly after the label text.
    x :=
        fieldObject.X
        + fieldObject.Width
        - favoriteHelpSize
        - gap
        - size

    y :=
        fieldObject.Y
        - size
        - 6

    return CreateFavoriteButton(
        guiObject,
        x,
        y,
        size
    )
}


CreateFavoriteHelpBadgeForField(
    guiObject,
    fieldObject,
    title,
    body,
    size := 15,
    gap := 4
) {
    ; Favorite help owns the far-right spot next to the star.
    x :=
        fieldObject.X
        + fieldObject.Width
        - size

    y :=
        fieldObject.Y
        - size
        - 6

    return CreateHelpBadge(
        guiObject,
        x,
        y,
        title,
        body,
        size
    )
}


SetFavoriteButtonState(buttonObject, isFavorite) {
    if !buttonObject {
        return
    }

    buttonObject.Text := isFavorite ? "★" : "☆"
}


FindTextIndex(items, textValue) {
    for index, item in items {
        if item = textValue {
            return index
        }
    }

    return 0
}


RefreshLauncherMapFavorites(
    keepSelectedMap := true
) {
    global CategoryDropdown
    global MapDropdown
    global MapFavoriteButton

    if !CategoryDropdown || !MapDropdown {
        return
    }

    categoryName := CategoryDropdown.Text
    selectedMap := keepSelectedMap ? MapDropdown.Text : ""

    maps := GetMapNamesForCategory(categoryName)

    MapDropdown.Delete()

    if maps.Length = 0 {
        MapDropdown.Add(["No configured maps"])
        MapDropdown.Choose(1)
    }
    else {
        MapDropdown.Add(maps)

        selectedIndex := FindTextIndex(
            maps,
            selectedMap
        )

        MapDropdown.Choose(
            selectedIndex > 0 ? selectedIndex : 1
        )
    }

    UpdateLauncherMapFavoriteButton()
}


UpdateLauncherMapFavoriteButton(*) {
    global CategoryDropdown
    global MapDropdown
    global MapFavoriteButton

    if !MapFavoriteButton {
        return
    }

    categoryName := CategoryDropdown ? CategoryDropdown.Text : ""
    mapName := MapDropdown ? MapDropdown.Text : ""

    valid := (
        categoryName != ""
        && mapName != ""
        && InStr(mapName, "No configured") != 1
    )

    MapFavoriteButton.Enabled := valid

    SetFavoriteButtonState(
        MapFavoriteButton,
        valid && IsFavoriteMap(categoryName, mapName)
    )
}


ToggleLauncherMapFavorite(*) {
    global CategoryDropdown
    global MapDropdown

    if !CategoryDropdown || !MapDropdown {
        return
    }

    categoryName := CategoryDropdown.Text
    mapName := MapDropdown.Text

    if (
        categoryName = ""
        || mapName = ""
        || InStr(mapName, "No configured") = 1
    ) {
        return
    }

    ToggleFavoriteMap(categoryName, mapName)
    RefreshLauncherMapFavorites(true)
}


RefreshLauncherExpFavorites(
    keepSelectedScript := true
) {
    global MonkeyExpTypeDropdown
    global MonkeyExpScriptDropdown
    global MonkeyExpScripts

    if !MonkeyExpTypeDropdown || !MonkeyExpScriptDropdown {
        return 0
    }

    towerType := MonkeyExpTypeDropdown.Text
    selectedName := keepSelectedScript ? MonkeyExpScriptDropdown.Text : ""

    MonkeyExpScripts := GetMonkeyExpScripts(towerType)
    names := []

    for script in MonkeyExpScripts {
        names.Push(script.name)
    }

    MonkeyExpScriptDropdown.Delete()

    if names.Length = 0 {
        MonkeyExpScriptDropdown.Add(
            ["No " . towerType . " scripts found"]
        )
        MonkeyExpScriptDropdown.Choose(1)
    }
    else {
        MonkeyExpScriptDropdown.Add(names)

        selectedIndex := FindTextIndex(
            names,
            selectedName
        )

        MonkeyExpScriptDropdown.Choose(
            selectedIndex > 0 ? selectedIndex : 1
        )
    }

    UpdateLauncherExpFavoriteButton()

    return names.Length
}


UpdateLauncherExpFavoriteButton(*) {
    global MonkeyExpTypeDropdown
    global MonkeyExpScriptDropdown
    global MonkeyExpFavoriteButton

    if !MonkeyExpFavoriteButton {
        return
    }

    towerType := MonkeyExpTypeDropdown ? MonkeyExpTypeDropdown.Text : ""
    scriptName := MonkeyExpScriptDropdown ? MonkeyExpScriptDropdown.Text : ""

    valid := (
        towerType != ""
        && scriptName != ""
        && InStr(scriptName, "No ") != 1
    )

    MonkeyExpFavoriteButton.Enabled := valid

    SetFavoriteButtonState(
        MonkeyExpFavoriteButton,
        valid && IsFavoriteExpScript(towerType, scriptName)
    )
}


ToggleLauncherExpFavorite(*) {
    global MonkeyExpTypeDropdown
    global MonkeyExpScriptDropdown

    if !MonkeyExpTypeDropdown || !MonkeyExpScriptDropdown {
        return
    }

    towerType := MonkeyExpTypeDropdown.Text
    scriptName := MonkeyExpScriptDropdown.Text

    if (
        towerType = ""
        || scriptName = ""
        || InStr(scriptName, "No ") = 1
    ) {
        return
    }

    ToggleFavoriteExpScript(towerType, scriptName)
    RefreshLauncherExpFavorites(true)
}


RefreshQueueBuilderMapFavorites(
    keepSelectedMap := true
) {
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown

    if !QueueBuilderCategoryDropdown || !QueueBuilderMapDropdown {
        return
    }

    categoryName := QueueBuilderCategoryDropdown.Text
    selectedMap := keepSelectedMap ? QueueBuilderMapDropdown.Text : ""
    maps := GetMapNamesForCategory(categoryName)

    QueueBuilderMapDropdown.Delete()

    if maps.Length = 0 {
        QueueBuilderMapDropdown.Add(["No configured maps"])
        QueueBuilderMapDropdown.Choose(1)
    }
    else {
        QueueBuilderMapDropdown.Add(maps)

        selectedIndex := FindTextIndex(maps, selectedMap)
        QueueBuilderMapDropdown.Choose(
            selectedIndex > 0 ? selectedIndex : 1
        )
    }

    UpdateQueueBuilderMapFavoriteButton()
    RefreshQueueBuilderMapStrategies()
}


UpdateQueueBuilderMapFavoriteButton(*) {
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown
    global QueueBuilderMapFavoriteButton

    if !QueueBuilderMapFavoriteButton {
        return
    }

    categoryName := QueueBuilderCategoryDropdown.Text
    mapName := QueueBuilderMapDropdown.Text

    valid := (
        categoryName != ""
        && mapName != ""
        && InStr(mapName, "No configured") != 1
    )

    QueueBuilderMapFavoriteButton.Enabled := valid

    SetFavoriteButtonState(
        QueueBuilderMapFavoriteButton,
        valid && IsFavoriteMap(categoryName, mapName)
    )
}


ToggleQueueBuilderMapFavorite(*) {
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown

    categoryName := QueueBuilderCategoryDropdown.Text
    mapName := QueueBuilderMapDropdown.Text

    if (
        categoryName = ""
        || mapName = ""
        || InStr(mapName, "No configured") = 1
    ) {
        return
    }

    ToggleFavoriteMap(categoryName, mapName)
    RefreshQueueBuilderMapFavorites(true)
}


RefreshQueueBuilderExpFavorites(
    keepSelectedScript := true
) {
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global QueueBuilderExpScripts

    towerType := QueueBuilderExpTypeDropdown.Text
    selectedName := keepSelectedScript ? QueueBuilderExpScriptDropdown.Text : ""

    QueueBuilderExpScripts := GetMonkeyExpScripts(towerType)
    names := []

    for script in QueueBuilderExpScripts {
        names.Push(script.name)
    }

    QueueBuilderExpScriptDropdown.Delete()

    if names.Length = 0 {
        QueueBuilderExpScriptDropdown.Add(
            ["No " . towerType . " scripts found"]
        )
        QueueBuilderExpScriptDropdown.Choose(1)
    }
    else {
        QueueBuilderExpScriptDropdown.Add(names)
        selectedIndex := FindTextIndex(names, selectedName)
        QueueBuilderExpScriptDropdown.Choose(
            selectedIndex > 0 ? selectedIndex : 1
        )
    }

    UpdateQueueBuilderExpFavoriteButton()

    return names.Length
}


UpdateQueueBuilderExpFavoriteButton(*) {
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global QueueBuilderExpFavoriteButton

    if !QueueBuilderExpFavoriteButton {
        return
    }

    towerType := QueueBuilderExpTypeDropdown.Text
    scriptName := QueueBuilderExpScriptDropdown.Text

    valid := (
        towerType != ""
        && scriptName != ""
        && InStr(scriptName, "No ") != 1
    )

    QueueBuilderExpFavoriteButton.Enabled := valid

    SetFavoriteButtonState(
        QueueBuilderExpFavoriteButton,
        valid && IsFavoriteExpScript(towerType, scriptName)
    )
}


ToggleQueueBuilderExpFavorite(*) {
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown

    towerType := QueueBuilderExpTypeDropdown.Text
    scriptName := QueueBuilderExpScriptDropdown.Text

    if (
        towerType = ""
        || scriptName = ""
        || InStr(scriptName, "No ") = 1
    ) {
        return
    }

    ToggleFavoriteExpScript(towerType, scriptName)
    RefreshQueueBuilderExpFavorites(true)
}
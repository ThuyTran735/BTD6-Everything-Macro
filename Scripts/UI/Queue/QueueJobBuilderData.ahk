#Requires AutoHotkey v2.0

; v3 file note: Refreshes map strategies and Monkey EXP scripts used by the builder dropdowns.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

RefreshQueueBuilderMapStrategies() {
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyDropdown
    global QueueBuilderMapStrategies
    global CategoryData


    QueueBuilderMapStrategies := []


    categoryName :=
        QueueBuilderCategoryDropdown.Text


    mapName :=
        QueueBuilderMapDropdown.Text


    GetConfiguredCategories()


    if !CategoryData.Has(
        categoryName
    ) {
        return SetQueueBuilderStrategyPlaceholder()
    }


    category :=
        CategoryData[
            categoryName
        ]


    if !category.directories.Has(
        mapName
    ) {
        return SetQueueBuilderStrategyPlaceholder()
    }


    mapDirectory :=
        category.directories[
            mapName
        ]


    scripts :=
        GetMapScripts(
            mapDirectory
        )


    names := []


    for difficulty in [
        "Easy",
        "Medium",
        "Hard"
    ] {
        for script in scripts[
            difficulty
        ] {
            displayName :=
                difficulty
                . " - "
                . script.name


            QueueBuilderMapStrategies.Push(
                {
                    name: displayName,
                    path: script.path,
                    label: mapName
                        . " - "
                        . script.name
                }
            )


            names.Push(
                displayName
            )
        }
    }


    QueueBuilderStrategyDropdown.Delete()


    if names.Length = 0 {
        QueueBuilderStrategyDropdown.Add(
            [
                "No strategies found"
            ]
        )
    }
    else {
        QueueBuilderStrategyDropdown.Add(
            names
        )
    }


    QueueBuilderStrategyDropdown.Choose(
        1
    )


    return names.Length
}


SetQueueBuilderStrategyPlaceholder() {
    global QueueBuilderStrategyDropdown


    QueueBuilderStrategyDropdown.Delete()


    QueueBuilderStrategyDropdown.Add(
        [
            "No strategies found"
        ]
    )


    QueueBuilderStrategyDropdown.Choose(
        1
    )


    return 0
}


QueueBuilderExpTypeChanged(*) {
    RefreshQueueBuilderExpFavorites(false)
}


RefreshQueueBuilderExpScripts() {
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global QueueBuilderExpScripts


    towerType :=
        QueueBuilderExpTypeDropdown.Text


    QueueBuilderExpScripts :=
        GetMonkeyExpScripts(
            towerType
        )


    names := []


    for script in QueueBuilderExpScripts {
        names.Push(
            script.name
        )
    }


    QueueBuilderExpScriptDropdown.Delete()


    if names.Length = 0 {
        QueueBuilderExpScriptDropdown.Add(
            [
                "No "
                . towerType
                . " scripts found"
            ]
        )
    }
    else {
        QueueBuilderExpScriptDropdown.Add(
            names
        )
    }


    QueueBuilderExpScriptDropdown.Choose(
        1
    )


    UpdateQueueBuilderExpFavoriteButton()


    return names.Length
}


QueueBuilderPathsMatch(pathA, pathB) {
    return StrLower(StrReplace(pathA, "/", "\"))
        = StrLower(StrReplace(pathB, "/", "\"))
}



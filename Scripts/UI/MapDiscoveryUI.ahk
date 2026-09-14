#Requires AutoHotkey v2.0


GetConfiguredCategories() {
    global CategoryData


    CategoryData := Map()

    categories := []


    mapsRoot :=
        A_ScriptDir
        . "\Maps"


    if !DirExist(
        mapsRoot
    ) {

        categories.Push(
            "No configured categories"
        )


        return categories
    }


    preferredCategories := [
        "Beginner",
        "Intermediate",
        "Advanced",
        "Expert"
    ]


    ; Normal BTD6 categories first.
    for categoryName in preferredCategories {

        categoryDirectory :=
            mapsRoot
            . "\"
            . categoryName


        if !DirExist(
            categoryDirectory
        ) {
            continue
        }


        data :=
            BuildCategoryData(
                categoryDirectory
            )


        if data.names.Length = 0 {
            continue
        }


        CategoryData[
            categoryName
        ] := data


        categories.Push(
            categoryName
        )
    }


    ; Also support additional category
    ; folders if we add any later.
    Loop Files mapsRoot "\*", "D" {

        categoryName :=
            A_LoopFileName


        categoryDirectory :=
            A_LoopFileFullPath


        if CategoryData.Has(
            categoryName
        ) {
            continue
        }


        data :=
            BuildCategoryData(
                categoryDirectory
            )


        if data.names.Length = 0 {
            continue
        }


        CategoryData[
            categoryName
        ] := data


        categories.Push(
            categoryName
        )
    }


    if categories.Length = 0 {

        categories.Push(
            "No configured categories"
        )
    }


    return categories
}


BuildCategoryData(
    categoryDirectory
) {
    mapNames := []

    mapDirectories := Map()


    Loop Files categoryDirectory "\*", "D" {

        mapName :=
            A_LoopFileName


        mapDirectory :=
            A_LoopFileFullPath


        ; A map only appears if it has
        ; at least one runnable strategy.
        if !MapHasRunnableScripts(
            mapDirectory
        ) {
            continue
        }


        mapNames.Push(
            mapName
        )


        mapDirectories[
            mapName
        ] := mapDirectory
    }


    return {
        names: mapNames,
        directories: mapDirectories
    }
}


GetMapNamesForCategory(
    categoryName
) {
    global CategoryData


    maps := []


    if !CategoryData.Has(
        categoryName
    ) {
        return maps
    }


    data :=
        CategoryData[
            categoryName
        ]


    for mapName in data.names {

        maps.Push(
            mapName
        )
    }


    return maps
}


MapHasRunnableScripts(
    mapDirectory
) {
    difficulties := [
        "Easy",
        "Medium",
        "Hard"
    ]


    for difficulty in difficulties {

        difficultyDirectory :=
            mapDirectory
            . "\"
            . difficulty


        if !DirExist(
            difficultyDirectory
        ) {
            continue
        }


        Loop Files difficultyDirectory "\*.ahk", "R" {

            return true
        }
    }


    return false
}


GetMapScripts(
    mapDirectory
) {
    scripts := Map(
        "Easy", [],
        "Medium", [],
        "Hard", []
    )


    difficulties := [
        "Easy",
        "Medium",
        "Hard"
    ]


    for difficulty in difficulties {

        difficultyDirectory :=
            mapDirectory
            . "\"
            . difficulty


        if !DirExist(
            difficultyDirectory
        ) {
            continue
        }


        Loop Files difficultyDirectory "\*.ahk", "R" {

            scripts[
                difficulty
            ].Push(
                {
                    name: A_LoopFileName,
                    path: A_LoopFileFullPath
                }
            )
        }
    }


    return scripts
}


CountMapScripts(
    scripts
) {
    total := 0


    total +=
        scripts[
            "Easy"
        ].Length


    total +=
        scripts[
            "Medium"
        ].Length


    total +=
        scripts[
            "Hard"
        ].Length


    return total
}


GetOnlyMapScript(
    scripts
) {
    difficulties := [
        "Easy",
        "Medium",
        "Hard"
    ]


    for difficulty in difficulties {

        if scripts[
            difficulty
        ].Length = 1 {

            return scripts[
                difficulty
            ][1]
        }
    }


    return false
}


OnCategoryChanged(*) {
    global CategoryDropdown
    global MapDropdown


    categoryName :=
        CategoryDropdown.Text


    maps :=
        GetMapNamesForCategory(
            categoryName
        )


    MapDropdown.Delete()


    if maps.Length = 0 {

        MapDropdown.Add(
            [
                "No configured maps"
            ]
        )
    }
    else {

        MapDropdown.Add(
            maps
        )
    }


    MapDropdown.Choose(
        1
    )


    UpdateStatus(
        "READY",
        "22C55E"
    )
}


RefreshLauncherLists() {
    global CategoryDropdown
    global MapDropdown


    categories :=
        GetConfiguredCategories()


    CategoryDropdown.Delete()


    CategoryDropdown.Add(
        categories
    )


    CategoryDropdown.Choose(
        1
    )


    maps := []


    if (
        categories.Length > 0
        && categories[1]
            != "No configured categories"
    ) {

        maps :=
            GetMapNamesForCategory(
                categories[1]
            )
    }


    MapDropdown.Delete()


    if maps.Length = 0 {

        MapDropdown.Add(
            [
                "No configured maps"
            ]
        )
    }
    else {

        MapDropdown.Add(
            maps
        )
    }


    MapDropdown.Choose(
        1
    )
}
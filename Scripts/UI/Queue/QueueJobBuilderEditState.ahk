#Requires AutoHotkey v2.0

; v3 file note: Restores an existing queue job when the builder is opened for editing.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

InitializeQueueBuilderEditSelection() {
    global QueueBuilderEditIndex
    global MacroJobQueue
    global QueueBuilderJobTypeDropdown
    global QueueBuilderCategoryDropdown
    global QueueBuilderMapDropdown
    global QueueBuilderStrategyDropdown
    global QueueBuilderMapStrategies
    global QueueBuilderExpTypeDropdown
    global QueueBuilderExpScriptDropdown
    global CategoryData

    if (
        QueueBuilderEditIndex < 1
        || QueueBuilderEditIndex > MacroJobQueue.Length
    ) {
        return false
    }

    job := MacroJobQueue[QueueBuilderEditIndex]

    if job.mode = "Monkey EXP Grind" {
        QueueBuilderJobTypeDropdown.Choose(2)
        QueueBuilderJobTypeChanged()

        towerTypes := GetMonkeyExpTowerTypes()

        for typeIndex, towerType in towerTypes {
            scripts := GetMonkeyExpScripts(towerType)

            for scriptIndex, script in scripts {
                if QueueBuilderPathsMatch(script.path, job.path) {
                    QueueBuilderExpTypeDropdown.Choose(typeIndex)
                    RefreshQueueBuilderExpScripts()
                    QueueBuilderExpScriptDropdown.Choose(scriptIndex)
                    UpdateQueueBuilderExpFavoriteButton()
                    return true
                }
            }
        }

        return false
    }

    QueueBuilderJobTypeDropdown.Choose(1)
    QueueBuilderJobTypeChanged()
    categories := GetConfiguredCategories()

    for categoryIndex, categoryName in categories {
        maps := GetMapNamesForCategory(categoryName)

        for mapIndex, mapName in maps {
            if !CategoryData.Has(categoryName) {
                continue
            }

            category := CategoryData[categoryName]

            if !category.directories.Has(mapName) {
                continue
            }

            scripts := GetMapScripts(category.directories[mapName])

            for difficulty in ["Easy", "Medium", "Hard"] {
                for candidate in scripts[difficulty] {
                    if QueueBuilderPathsMatch(candidate.path, job.path) {
                        QueueBuilderCategoryDropdown.Choose(categoryIndex)
                        RefreshQueueBuilderMapFavorites(false)

                        currentMaps := GetMapNamesForCategory(categoryName)
                        chosenMapIndex := FindTextIndex(currentMaps, mapName)

                        if chosenMapIndex > 0 {
                            QueueBuilderMapDropdown.Choose(chosenMapIndex)
                        }

                        RefreshQueueBuilderMapStrategies()

                        for strategyIndex, strategy in QueueBuilderMapStrategies {
                            if QueueBuilderPathsMatch(strategy.path, job.path) {
                                QueueBuilderStrategyDropdown.Choose(strategyIndex)
                                break
                            }
                        }

                        UpdateQueueBuilderMapFavoriteButton()
                        return true
                    }
                }
            }
        }
    }

    return false
}



#Requires AutoHotkey v2.0

; v3 file note: Reads an existing strategy back into the builder without mixing parser code into the UI.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

ImportStrategyScript(*) {
    global MainGui, Entities, UpgradeActions, OutputEdit, StatusText
    global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL
    global EntityTypeDDL, EntityNameEdit, HeroDDL, XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit
    global ImportedStartRound, ImportedEndRound, IsImportingStrategy
    global WingmonkeyMKCheckbox

    projectRoot := RegExReplace(A_ScriptDir, "i)\\Tools$")
    MainGui.Opt("-AlwaysOnTop")
    path := FileSelect("1", projectRoot "\Maps", "Import strategy script", "AutoHotkey Script (*.ahk)")
    if path = ""
        return

    try text := FileRead(path, "UTF-8")
    catch as err {
        MsgBox("Could not read the strategy file.`n`n" err.Message, "Strategy Builder", "Iconx")
        return
    }

    parsed := ParseStrategyScript(text)
    if !parsed || parsed.entities.Length = 0 {
        MsgBox("No TowerSetup entries could be imported from this script.", "Strategy Builder", "Icon!")
        return
    }

    HideMonkeyOverlay()
    Entities := parsed.entities
    UpgradeActions := parsed.actions
    ImportedStartRound := parsed.startRound
    ImportedEndRound := parsed.endRound
    WingmonkeyMKCheckbox.Value := parsed.wingmonkeyMK ? 1 : 0

    IsImportingStrategy := true
    MapNameEdit.Value := parsed.map
    FunctionNameEdit.Value := parsed.functionName
    ChooseDropdownText(CategoryDDL, parsed.category)

    difficulty := parsed.difficulty
    mode := parsed.gameMode
    if difficulty = "Impoppable" {
        difficulty := "Hard"
        mode := "Impoppable"
    } else if difficulty = "CHIMPS" {
        difficulty := "Hard"
        mode := "CHIMPS"
    }

    if !ChooseDropdownText(DifficultyDDL, difficulty)
        DifficultyDDL.Choose(1)

    RefreshModeChoicesForDifficulty(DifficultyDDL.Text, mode)
    OnModeChanged()
    IsImportingStrategy := false

    RefreshEntityList()
    RefreshActionEntityDropdown()
    RefreshActionList()
    OutputEdit.Value := ""

    EntityTypeDDL.Choose(1)
    HeroDDL.Enabled := false
    EntityNameEdit.Value := GetNextEntityName(EntityTypeDDL.Text)
    XEdit.Value := "0"
    YEdit.Value := "0"
    PlaceRoundEdit.Value := "0"
    PlaceDelayEdit.Value := "0"
    ApplyDefaultTargetingForType(EntityTypeDDL.Text)

    unsupported := parsed.totalStrategyEntries - parsed.parsedStrategyEntries
    if unsupported > 0 {
        StatusText.Text := "Imported with " unsupported " unsupported action(s) skipped"
        MsgBox(
            "Imported " parsed.entities.Length " monkey/hero entries and " parsed.parsedStrategyEntries " recognized strategy actions.`n`n"
            . unsupported " action(s) used helpers Strategy Builder does not edit yet, so those actions were skipped.",
            "Strategy Builder - Import",
            "Icon!"
        )
    } else {
        StatusText.Text := "Imported: " path
    }
}

ParseStrategyScript(text) {
    cleanText := RegExReplace(text, "m)^\s*;.*$", "")

    result := {
        functionName: "GeneratedMapStrategy",
        map: ExtractConfigString(cleanText, "map", "MAP NAME"),
        category: ExtractConfigString(cleanText, "category", "Beginner"),
        difficulty: ExtractConfigString(cleanText, "difficulty", "Easy"),
        gameMode: ExtractConfigString(cleanText, "gameMode", "Standard"),
        hero: ExtractConfigString(cleanText, "hero", ""),
        wingmonkeyMK: ExtractConfigBoolean(cleanText, "wingmonkeyMK", false),
        startRound: ExtractConfigInteger(cleanText, "startRound", ""),
        endRound: ExtractConfigInteger(cleanText, "endRound", ""),
        entities: [],
        actions: [],
        totalStrategyEntries: CountStrategyEntries(cleanText),
        parsedStrategyEntries: 0
    }

    if RegExMatch(cleanText, "im)^\s*([A-Za-z_][A-Za-z0-9_]*)\(\)\s*\{", &functionMatch)
        result.functionName := functionMatch[1]

    if !RegExMatch(cleanText, "is)global\s+TowerSetup\s*:=\s*Map\((.*?)\)\s*strategy\s*:=", &setupMatch)
        return result

    setupText := setupMatch[1]
    entityPattern := "is)\x22([^\x22]+)\x22\s*,\s*\{(.*?)\}"
    pos := 1

    while matchPos := RegExMatch(setupText, entityPattern, &entityMatch, pos) {
        name := entityMatch[1]
        body := entityMatch[2]
        type := ExtractObjectString(body, "type", "Dart")
        targeting := ExtractObjectString(body, "targeting", GetBuilderDefaultTargeting(type))

        result.entities.Push({
            name: name,
            type: type,
            heroName: type = "Hero" ? result.hero : "",
            x: ExtractObjectInteger(body, "x", 0),
            y: ExtractObjectInteger(body, "y", 0),
            placeRound: 0,
            placeDelay: 0,
            targeting: targeting
        })

        pos := matchPos + entityMatch.Len(0)
    }

    importedActions := ParseImportedStrategyActions(cleanText)
    result.parsedStrategyEntries := importedActions.Length
    placedEntities := Map()

    for action in importedActions {
        if action.kind = "place" {
            entity := FindEntityByNameInArray(result.entities, action.entity)

            ; The builder stores one placement schedule per configured monkey.
            ; If an imported script sells and later re-places the same object,
            ; warn instead of silently replacing the first placement action.
            if !entity || placedEntities.Has(action.entity) {
                result.parsedStrategyEntries -= 1
                continue
            }

            placedEntities[action.entity] := true
            entity.placeRound := action.round
            entity.placeDelay := action.delay
            continue
        }

        if (
            HasProp(action, "entity")
            && !FindEntityByNameInArray(result.entities, action.entity)
        ) {
            result.parsedStrategyEntries -= 1
            continue
        }

        result.actions.Push(action)
    }

    return result
}

ParseImportedStrategyActions(text) {
    actions := []

    CollectImportedActions(
        text,
        "is)\[\s*(\d+)\s*,\s*(\d+)\s*,\s*\(\)\s*=>\s*PlaceTower\(\s*TowerSetup\[\x22([^\x22]+)\x22\]\s*\)\s*\]",
        "place",
        actions
    )

    CollectImportedActions(
        text,
        "is)\[\s*(\d+)\s*,\s*(\d+)\s*,\s*\(\)\s*=>\s*UpgradeTower\(\s*TowerSetup\[\x22([^\x22]+)\x22\]\s*,\s*\x22(\d{3})\x22\s*(?:,\s*(-?\d+)\s*,\s*(-?\d+)\s*)?\)\s*\]",
        "upgrade",
        actions
    )

    CollectImportedActions(
        text,
        "is)\[\s*(\d+)\s*,\s*(\d+)\s*,\s*\(\)\s*=>\s*SetTargeting\(\s*TowerSetup\[\x22([^\x22]+)\x22\]\s*,\s*\x22([^\x22]+)\x22\s*\)\s*\]",
        "target",
        actions
    )

    CollectImportedActions(
        text,
        "is)\[\s*(\d+)\s*,\s*(\d+)\s*,\s*\(\)\s*=>\s*SetSpikeFactoryTargeting\(\s*TowerSetup\[\x22([^\x22]+)\x22\]\s*,\s*\x22([^\x22]+)\x22\s*(?:,\s*(-?\d+)\s*,\s*(-?\d+)\s*)?\)\s*\]",
        "spikeTarget",
        actions
    )

    CollectImportedActions(
        text,
        "is)\[\s*(\d+)\s*,\s*(\d+)\s*,\s*\(\)\s*=>\s*SetSpikeFactoryTarget\(\s*TowerSetup\[\x22([^\x22]+)\x22\]\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)\s*\]",
        "spikeSetTarget",
        actions
    )

    CollectImportedActions(
        text,
        "is)\[\s*(\d+)\s*,\s*(\d+)\s*,\s*\(\)\s*=>\s*SellTower\(\s*TowerSetup\[\x22([^\x22]+)\x22\]\s*(?:,\s*(-?\d+)\s*,\s*(-?\d+)\s*)?\)\s*\]",
        "sell",
        actions
    )

    CollectImportedActions(
        text,
        "is)\[\s*(\d+)\s*,\s*(\d+)\s*,\s*\(\)\s*=>\s*UseAbility\(\s*\x22([^\x22]+)\x22\s*\)\s*\]",
        "ability",
        actions
    )

    SortImportedActionsByPosition(actions)
    return actions
}

CollectImportedActions(text, pattern, kind, actions) {
    pos := 1

    while matchPos := RegExMatch(text, pattern, &m, pos) {
        action := {
            kind: kind,
            round: Integer(m[1]),
            delay: Integer(m[2]),
            sourcePos: matchPos
        }

        if kind = "place" {
            action.entity := m[3]
        } else if kind = "upgrade" {
            action.entity := m[3]
            action.upgrade := m[4]
            if m[5] != "" && m[6] != "" {
                action.overrideX := Integer(m[5])
                action.overrideY := Integer(m[6])
            }
        } else if kind = "target" {
            action.entity := m[3]
            action.target := m[4]
        } else if kind = "spikeTarget" {
            action.kind := "target"
            action.entity := m[3]
            action.target := m[4]
            if m[5] != "" && m[6] != "" {
                action.targetX := Integer(m[5])
                action.targetY := Integer(m[6])
            }
        } else if kind = "spikeSetTarget" {
            action.kind := "target"
            action.entity := m[3]
            action.target := "Set Target"
            action.targetX := Integer(m[4])
            action.targetY := Integer(m[5])
        } else if kind = "sell" {
            action.entity := m[3]
            if m[4] != "" && m[5] != "" {
                action.overrideX := Integer(m[4])
                action.overrideY := Integer(m[5])
            }
        } else if kind = "ability" {
            action.hotkey := m[3]
        }

        actions.Push(action)
        pos := matchPos + m.Len(0)
    }
}

SortImportedActionsByPosition(actions) {
    i := 2
    while i <= actions.Length {
        current := actions[i]
        j := i - 1

        while j >= 1 && actions[j].sourcePos > current.sourcePos {
            actions[j + 1] := actions[j]
            j -= 1
        }

        actions[j + 1] := current
        i += 1
    }
}

CountStrategyEntries(text) {
    pattern := "is)\[\s*\d+\s*,\s*\d+\s*,\s*\(\)\s*=>"
    pos := 1
    count := 0

    while matchPos := RegExMatch(text, pattern, &m, pos) {
        count += 1
        pos := matchPos + m.Len(0)
    }

    return count
}

ExtractConfigString(text, field, defaultValue := "") {
    pattern := "im)^\s*" field "\s*:\s*\x22([^\x22]*)\x22"
    if RegExMatch(text, pattern, &m)
        return m[1]
    return defaultValue
}

ExtractConfigBoolean(text, field, defaultValue := false) {
    pattern := "im)^\s*" field "\s*:\s*(true|false)"
    if RegExMatch(text, pattern, &m)
        return StrLower(m[1]) = "true"
    return defaultValue
}

ExtractConfigInteger(text, field, defaultValue := "") {
    pattern := "im)^\s*" field "\s*:\s*(-?\d+)"
    if RegExMatch(text, pattern, &m)
        return Integer(m[1])
    return defaultValue
}

ExtractObjectString(text, field, defaultValue := "") {
    pattern := "im)^\s*" field "\s*:\s*\x22([^\x22]*)\x22"
    if RegExMatch(text, pattern, &m)
        return m[1]
    return defaultValue
}

ExtractObjectInteger(text, field, defaultValue := 0) {
    pattern := "im)^\s*" field "\s*:\s*(-?\d+)"
    if RegExMatch(text, pattern, &m)
        return Integer(m[1])
    return defaultValue
}

GetBuilderDefaultTargeting(type) {
    if type = "Ace"
        return "Circle"
    if type = "Dartling"
        return "Normal"
    if type = "Heli"
        return "Follow Mouse"
    if type = "Mortar"
        return "Target"
    if type = "SpikeFactory"
        return "Normal"
    return "First"
}

FindEntityByNameInArray(entities, name) {
    for entity in entities {
        if entity.name = name
            return entity
    }
    return false
}


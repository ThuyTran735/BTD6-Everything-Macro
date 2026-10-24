#Requires AutoHotkey v2.0

; Check the saved editor model before it becomes an executable strategy.
; Keep the error finder free of UI work so the same rules can be tested offline.

ValidateBuilderModel() {
    global Entities, UpgradeActions, MapNameEdit, FunctionNameEdit

    errorText := GetBuilderValidationError(Entities, UpgradeActions)
    if errorText = "" && Trim(MapNameEdit.Value) = ""
        errorText := "Enter the map name before generating the strategy."
    if errorText = "" && Trim(FunctionNameEdit.Value) = ""
        errorText := "Enter the strategy function name before generating the strategy."
    if errorText = ""
        return true

    MsgBox(errorText, "Strategy Builder - Check strategy", "Icon!")
    return false
}

GetBuilderValidationError(entities, actions) {
    if entities.Length = 0
        return "Add at least one monkey or hero before generating the template."

    knownEntities := Map()
    knownEntities.CaseSense := false
    schedule := []
    heroCount := 0

    for index, entity in entities {
        label := "Placement " index
        if !HasProp(entity, "name") || Type(entity.name) != "String" || Trim(entity.name) = ""
            return label ": enter a monkey or hero name."
        label := entity.name
        if knownEntities.Has(entity.name)
            return label ": another placement already uses this name."
        if !HasProp(entity, "type") || Trim(entity.type) = ""
            return label ": choose a monkey or hero type."
        if !HasProp(entity, "targeting") || Trim(entity.targeting) = ""
            return label ": choose an initial targeting mode."

        if entity.type = "Hero" {
            heroCount += 1
            if heroCount > 1
                return "A strategy can only have one hero placement."
            if !HasProp(entity, "heroName") || Trim(entity.heroName) = ""
                return label ": choose which hero to use."
        }

        coordinateError := GetBuilderCoordinatePairError(entity, "x", "y", label " placement", true)
        if coordinateError != ""
            return coordinateError
        if !HasProp(entity, "placeRound") || !IsBuilderNonnegativeInteger(entity.placeRound)
            return label ": placement round must be a whole number of 0 or higher."
        placeDelay := HasProp(entity, "placeDelay") ? entity.placeDelay : 0
        if !IsBuilderNonnegativeInteger(placeDelay)
            return label ": placement delay must be a whole number of 0 or higher."

        knownEntities[entity.name] := entity
        schedule.Push({kind: "place", entity: entity.name, round: entity.placeRound, delay: placeDelay})
    }

    for index, action in actions {
        label := "Action " index
        kind := HasProp(action, "kind") ? action.kind : "upgrade"
        if !HasProp(action, "round") || !IsBuilderNonnegativeInteger(action.round)
            return label ": round must be a whole number of 0 or higher."
        if !HasProp(action, "delay") || !IsBuilderNonnegativeInteger(action.delay)
            return label ": delay must be a whole number of 0 or higher."

        if kind = "upgrade" || kind = "target" || kind = "sell" {
            if !HasProp(action, "entity") || !knownEntities.Has(action.entity)
                return label ": the selected monkey or hero no longer exists."
            ; TowerSetup uses case-sensitive Map keys in the generated script.
            ; Older imports can match a placement despite different capitalization.
            if !(action.entity == knownEntities[action.entity].name)
                return label ": the monkey name has different capitalization from its placement. Edit this action and choose the monkey again."
            label .= " (" action.entity ")"
            if kind = "upgrade" {
                if knownEntities[action.entity].type = "Hero"
                    return label ": heroes cannot use tower upgrade actions."
                if !HasProp(action, "upgrade") || !IsBuilderLegalUpgrade(action.upgrade)
                    return label ": use three upgrade digits from 0 to 5, with at most two paths and only one path above tier 2."
            } else if kind = "target" {
                if !HasProp(action, "target") || Trim(action.target) = ""
                    return label ": choose a targeting mode."
            }
        } else if kind = "ability" {
            if !HasProp(action, "hotkey") || Trim(action.hotkey) = ""
                return label ": enter an ability hotkey."
        } else if kind = "speed" {
            if !HasProp(action, "speed") || (action.speed != "Normal" && action.speed != "Fast")
                return label ": choose Normal or Fast game speed."
        } else if kind = "bananaCollection" {
            if !HasProp(action, "enabled") || (action.enabled != 0 && action.enabled != 1)
                return label ": choose whether banana collection is enabled or disabled."
        } else {
            return label ": this action type is not supported by the builder."
        }

        for names in [["overrideX", "overrideY"], ["targetX", "targetY"]] {
            coordinateError := GetBuilderCoordinatePairError(action, names[1], names[2], label)
            if coordinateError != ""
                return coordinateError
        }

        scheduled := {kind: kind, round: action.round, delay: action.delay, label: label}
        if HasProp(action, "entity")
            scheduled.entity := action.entity
        if kind = "upgrade"
            scheduled.upgrade := action.upgrade
        schedule.Push(scheduled)
    }

    ; Use the exporter's exact order. A tied placement runs first, while a tied
    ; sell and upgrade keep their order in the action list.
    SortActions(schedule)
    placed := Map()
    placed.CaseSense := false
    sold := Map()
    sold.CaseSense := false
    upgrades := Map()
    upgrades.CaseSense := false
    for action in schedule {
        if action.kind = "place" {
            placed[action.entity] := true
            upgrades[action.entity] := [0, 0, 0]
            continue
        }
        if action.kind != "upgrade" && action.kind != "target" && action.kind != "sell"
            continue
        if !placed.Has(action.entity)
            return action.label ": this action runs before the monkey or hero is placed."
        if sold.Has(action.entity)
            return action.label ": this action runs after the monkey or hero has been sold."
        if action.kind = "sell" {
            sold[action.entity] := true
        } else if action.kind = "upgrade" {
            ; UpgradeTower buys missing tiers; a lower target never removes a
            ; previous purchase. Check the combined paths, not just this row.
            combined := ""
            Loop 3 {
                upgrades[action.entity][A_Index] := Max(upgrades[action.entity][A_Index], Integer(SubStr(action.upgrade, A_Index, 1)))
                combined .= upgrades[action.entity][A_Index]
            }
            if !IsBuilderLegalUpgrade(combined)
                return action.label ": these upgrades conflict with a path purchased earlier in the strategy."
        }
    }
    return ""
}

IsBuilderNonnegativeInteger(value) {
    return (Type(value) = "Integer" || Type(value) = "String") && RegExMatch(value, "^\d+$")
}

GetBuilderCoordinatePairError(item, xName, yName, label, required := false) {
    hasX := HasProp(item, xName)
    hasY := HasProp(item, yName)
    if !required && !hasX && !hasY
        return ""
    if !hasX || !hasY
        return label ": enter both X and Y coordinates."
    if !IsBuilderNonnegativeInteger(item.%xName%) || item.%xName% > 1919
        return label ": X must be a whole number from 0 to 1919."
    if !IsBuilderNonnegativeInteger(item.%yName%) || item.%yName% > 1079
        return label ": Y must be a whole number from 0 to 1079."
    return ""
}

IsBuilderLegalUpgrade(value) {
    if (Type(value) != "String" && Type(value) != "Integer") || !RegExMatch(value, "^[0-5]{3}$")
        return false
    usedPaths := 0
    highPaths := 0
    Loop 3 {
        tier := Integer(SubStr(value, A_Index, 1))
        usedPaths += tier > 0 ? 1 : 0
        highPaths += tier > 2 ? 1 : 0
    }
    return usedPaths <= 2 && highPaths <= 1
}

GetBuilderRoundBounds(difficulty, gameMode, importedStart := "", importedEnd := "") {
    ; These match the existing map strategies and the runtime's final-round data.
    ; Explicit import values belong to that script until the user changes mode.
    if gameMode = "Deflation" {
        firstRound := 31
        lastRound := 60
    } else if gameMode = "Impoppable" || gameMode = "CHIMPS" {
        firstRound := 6
        lastRound := 100
    } else if difficulty = "Hard" {
        firstRound := 3
        lastRound := 80
    } else if difficulty = "Medium" {
        firstRound := 1
        lastRound := 60
    } else {
        firstRound := 1
        lastRound := 40
    }
    return {
        startRound: importedStart != "" ? importedStart : firstRound,
        endRound: importedEnd != "" ? importedEnd : lastRound
    }
}

GetBuilderRoundValidationError(entities, actions, roundBounds) {
    firstRound := roundBounds.startRound
    lastRound := roundBounds.endRound
    if !IsBuilderNonnegativeInteger(firstRound) || firstRound < 1
        return "The starting round must be a whole number of 1 or higher. Use action round 0 for pregame setup."
    if !IsBuilderNonnegativeInteger(lastRound) || lastRound < firstRound
        return "The ending round must be a whole number at or above the starting round (" firstRound ")."

    allowed := "Use round 0 for pregame setup or rounds " firstRound "-" lastRound " for this strategy."
    for entity in entities {
        if entity.placeRound != 0 && (entity.placeRound < firstRound || entity.placeRound > lastRound)
            return entity.name " uses placement round " entity.placeRound ". " allowed
    }
    for index, action in actions {
        if action.round != 0 && (action.round < firstRound || action.round > lastRound)
            return "Action " index " uses round " action.round ". " allowed
    }
    return ""
}

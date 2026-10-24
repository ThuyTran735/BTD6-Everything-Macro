#Requires AutoHotkey v2.0

; Snapshots contain data only. A draft never needs to execute imported code to
; restore the editor, and restoring a row also reconnects its editing reference.
InitializeBuilderHistory() {
    global BuilderHistoryReady, BuilderHistoryDepth, BuilderHistoryStates
    global BuilderHistoryPosition, BuilderHistoryObserved, BuilderHistoryChangedAt
    global BuilderFormBaseline
    BuilderHistoryReady := false
    BuilderHistoryDepth := 0
    BuilderFormBaseline := CaptureBuilderForms()
    BuilderHistoryStates := [CaptureBuilderState()]
    BuilderHistoryPosition := 1
    BuilderHistoryObserved := CloneBuilderState(BuilderHistoryStates[1])
    BuilderHistoryChangedAt := A_TickCount
    BuilderHistoryReady := true
    SetTimer(ObserveBuilderHistory, 200)
}

StopBuilderHistory() {
    global BuilderHistoryReady
    BuilderHistoryReady := false
    SetTimer(ObserveBuilderHistory, 0)
}

ResetBuilderHistory() {
    global BuilderHistoryReady, BuilderHistoryStates, BuilderHistoryPosition
    global BuilderHistoryObserved, BuilderHistoryChangedAt
    if !IsSet(BuilderHistoryReady) || !BuilderHistoryReady
        return
    BuilderHistoryStates := [CaptureBuilderState()]
    BuilderHistoryPosition := 1
    BuilderHistoryObserved := CloneBuilderState(BuilderHistoryStates[1])
    BuilderHistoryChangedAt := A_TickCount
}

BeginBuilderHistoryChange(flushPending := true) {
    global BuilderHistoryReady, BuilderHistoryDepth
    if !IsSet(BuilderHistoryReady) || !BuilderHistoryReady
        return
    ; Dropdown Change callbacks already contain the newly selected text. Those
    ; callers skip the pre-flush so dependent fields stay in the same undo step.
    if !BuilderHistoryDepth && flushPending
        BuilderHistoryFlush()
    BuilderHistoryDepth += 1
}

EndBuilderHistoryChange() {
    global BuilderHistoryReady, BuilderHistoryDepth
    if !IsSet(BuilderHistoryReady) || !BuilderHistoryReady
        return
    BuilderHistoryDepth := Max(0, BuilderHistoryDepth - 1)
    if !BuilderHistoryDepth
        BuilderHistoryFlush()
}

ObserveBuilderHistory() {
    global BuilderHistoryReady, BuilderHistoryDepth, BuilderHistoryObserved
    global BuilderHistoryChangedAt, MainGui
    if !IsSet(BuilderHistoryReady) || !BuilderHistoryReady || BuilderHistoryDepth
        return
    ; Modal dialogs and coordinate capture must not expose an intermediate edit.
    if !DllCall("IsWindowEnabled", "Ptr", MainGui.Hwnd) || !DllCall("IsWindowVisible", "Ptr", MainGui.Hwnd)
        return
    current := CaptureBuilderState()
    if !BuilderStatesEqual(current, BuilderHistoryObserved) {
        BuilderHistoryObserved := current
        BuilderHistoryChangedAt := A_TickCount
    } else if A_TickCount - BuilderHistoryChangedAt >= 600 {
        CommitBuilderHistoryState(current)
    }
}

BuilderFlushHistory() => BuilderHistoryFlush()

BuilderHistoryFlush() {
    global BuilderHistoryReady, BuilderHistoryDepth
    if !IsSet(BuilderHistoryReady) || !BuilderHistoryReady || BuilderHistoryDepth
        return
    CommitBuilderHistoryState(CaptureBuilderState())
}

CommitBuilderHistoryState(state) {
    global BuilderHistoryStates, BuilderHistoryPosition, BuilderHistoryObserved, BuilderHistoryChangedAt
    previous := BuilderHistoryStates[BuilderHistoryPosition]
    if BuilderStatesEqual(previous, state)
        return false
    ; Selection, preview generation and opening an untouched row are not edits.
    if BuilderStatesEqual(BuilderStateContent(previous), BuilderStateContent(state)) {
        BuilderHistoryStates[BuilderHistoryPosition] := CloneBuilderState(state)
    } else {
        while BuilderHistoryStates.Length > BuilderHistoryPosition
            BuilderHistoryStates.Pop()
        BuilderHistoryStates.Push(CloneBuilderState(state))
        if BuilderHistoryStates.Length > 100
            BuilderHistoryStates.RemoveAt(1)
        BuilderHistoryPosition := BuilderHistoryStates.Length
        BuilderDraftChanged()
    }
    BuilderHistoryObserved := CloneBuilderState(state)
    BuilderHistoryChangedAt := A_TickCount
    return true
}

BuilderUndo(*) {
    global BuilderHistoryReady, BuilderHistoryStates, BuilderHistoryPosition, StatusText
    if !IsSet(BuilderHistoryReady) || !BuilderHistoryReady
        return
    BuilderHistoryFlush()
    if BuilderHistoryPosition <= 1 {
        StatusText.Text := "Nothing to undo"
        return
    }
    BuilderHistoryPosition -= 1
    RestoreBuilderHistoryPosition()
    StatusText.Text := "Undid the last change"
}

BuilderRedo(*) {
    global BuilderHistoryReady, BuilderHistoryStates, BuilderHistoryPosition, StatusText
    if !IsSet(BuilderHistoryReady) || !BuilderHistoryReady
        return
    BuilderHistoryFlush()
    if BuilderHistoryPosition >= BuilderHistoryStates.Length {
        StatusText.Text := "Nothing to redo"
        return
    }
    BuilderHistoryPosition += 1
    RestoreBuilderHistoryPosition()
    StatusText.Text := "Redid the last change"
}

RestoreBuilderHistoryPosition() {
    global BuilderHistoryStates, BuilderHistoryPosition, BuilderHistoryObserved, BuilderHistoryChangedAt
    RestoreBuilderState(BuilderHistoryStates[BuilderHistoryPosition])
    BuilderHistoryObserved := CaptureBuilderState()
    BuilderHistoryChangedAt := A_TickCount
    BuilderDraftChanged()
}

BuilderFormControls() {
    global
    return Map("EntityNameEdit", EntityNameEdit, "EntityTypeDDL", EntityTypeDDL, "HeroDDL", HeroDDL,
        "XEdit", XEdit, "YEdit", YEdit, "PlaceRoundEdit", PlaceRoundEdit, "PlaceDelayEdit", PlaceDelayEdit,
        "TargetingDDL", TargetingDDL, "BuilderActionTypeDDL", BuilderActionTypeDDL, "ActionEntityDDL", ActionEntityDDL,
        "UpgradeEdit", UpgradeEdit, "UpgradeXEdit", UpgradeXEdit, "UpgradeYEdit", UpgradeYEdit,
        "UpgradeRoundEdit", UpgradeRoundEdit, "UpgradeDelayEdit", UpgradeDelayEdit, "ActionTargetDDL", ActionTargetDDL,
        "ActionTargetXEdit", ActionTargetXEdit, "ActionTargetYEdit", ActionTargetYEdit,
        "AbilityEdit", AbilityEdit, "GameSpeedDDL", GameSpeedDDL, "ClickXEdit", ClickXEdit, "ClickYEdit", ClickYEdit,
        "ClickCountEdit", ClickCountEdit, "ClickIntervalEdit", ClickIntervalEdit)
}

CaptureBuilderForms() {
    result := Map()
    for name, control in BuilderFormControls()
        result[name] := InStr(name, "DDL") ? control.Text : control.Value
    return result
}

MarkBuilderFormBaseline(group := "all") {
    global BuilderFormBaseline
    if !IsSet(BuilderFormBaseline)
        BuilderFormBaseline := Map()
    entityNames := "|EntityNameEdit|EntityTypeDDL|HeroDDL|XEdit|YEdit|PlaceRoundEdit|PlaceDelayEdit|TargetingDDL|"
    for name, value in CaptureBuilderForms() {
        isEntity := InStr(entityNames, "|" name "|")
        if group = "all" || (group = "entity" && isEntity) || (group = "action" && !isEntity)
            BuilderFormBaseline[name] := value
    }
}

CaptureBuilderState() {
    global Entities, UpgradeActions, MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL
    global WingmonkeyMKCheckbox, ImportedStartRound, ImportedEndRound, BuilderView, EntityLV, ActionLV
    global BuilderEditingEntity, BuilderEditingAction, OutputEdit, BuilderFormBaseline
    forms := CaptureBuilderForms()
    entityEdit := 0, actionEdit := 0
    for index, entity in Entities
        if IsObject(BuilderEditingEntity) && entity = BuilderEditingEntity
            entityEdit := index
    for index, action in UpgradeActions
        if IsObject(BuilderEditingAction) && action = BuilderEditingAction
            actionEdit := index
    return Map("schema", 1, "entities", CloneBuilderState(Entities), "actions", CloneBuilderState(UpgradeActions),
        "metadata", Map("mapName", MapNameEdit.Value, "functionName", FunctionNameEdit.Value,
            "category", CategoryDDL.Text, "difficulty", DifficultyDDL.Text, "mode", ModeDDL.Text,
            "wingmonkey", WingmonkeyMKCheckbox.Value, "importedStartRound", ImportedStartRound, "importedEndRound", ImportedEndRound),
        "forms", forms, "formBaseline", IsSet(BuilderFormBaseline) ? CloneBuilderState(BuilderFormBaseline) : CloneBuilderState(forms),
        "editor", Map("view", BuilderView, "entitySelection", EntityLV.GetNext(), "actionSelection", ActionLV.GetNext(),
            "entityEditIndex", entityEdit, "actionEditIndex", actionEdit), "preview", OutputEdit.Value)
}

; Only pending form values contribute to dirty state. Loading an existing row
; or preparing the next default name should not ask the user to save again.
BuilderStateContent(state) {
    pending := Map()
    context := Map()
    entityNames := "|EntityNameEdit|EntityTypeDDL|HeroDDL|XEdit|YEdit|PlaceRoundEdit|PlaceDelayEdit|TargetingDDL|"
    for name, value in state["forms"]
        if !state["formBaseline"].Has(name) || !BuilderStatesEqual(value, state["formBaseline"][name]) {
            pending[name] := value
            if InStr(entityNames, "|" name "|") {
                context["entityEditIndex"] := state["editor"]["entityEditIndex"]
                context["entityName"] := state["forms"]["EntityNameEdit"]
                context["entityType"] := state["forms"]["EntityTypeDDL"]
            } else {
                context["actionEditIndex"] := state["editor"]["actionEditIndex"]
                context["actionEntity"] := state["forms"]["ActionEntityDDL"]
                context["actionType"] := state["forms"]["BuilderActionTypeDDL"]
            }
        }
    return Map("entities", state["entities"], "actions", state["actions"], "metadata", state["metadata"],
        "pendingForms", pending, "pendingContext", context)
}

RestoreBuilderState(state) {
    global
    if !ValidateBuilderState(state)
        throw ValueError("The saved Strategy Builder draft is incomplete or unsupported.")
    previousDepth := IsSet(BuilderHistoryDepth) ? BuilderHistoryDepth : 0
    BuilderHistoryDepth := previousDepth + 1
    BeginBuilderLayout()
    try {
        CloseBuilderDropdowns()
        Entities := BuilderRecordsFromState(state["entities"])
        UpgradeActions := BuilderRecordsFromState(state["actions"])
        metadata := state["metadata"], editor := state["editor"], forms := state["forms"]
        MapNameEdit.Value := metadata["mapName"]
        FunctionNameEdit.Value := metadata["functionName"]
        ChooseDropdownText(CategoryDDL, metadata["category"])
        ChooseDropdownText(DifficultyDDL, metadata["difficulty"])
        RefreshModeChoicesForDifficulty(metadata["difficulty"], metadata["mode"])
        WingmonkeyMKCheckbox.Value := metadata["wingmonkey"]
        ImportedStartRound := metadata["importedStartRound"]
        ImportedEndRound := metadata["importedEndRound"]
        DifficultyDDL.Enabled := metadata["mode"] != "Deflation"
        BuilderEditingEntity := editor["entityEditIndex"] ? Entities[editor["entityEditIndex"]] : false
        BuilderEditingActionIndex := editor["actionEditIndex"]
        BuilderEditingAction := BuilderEditingActionIndex ? UpgradeActions[BuilderEditingActionIndex] : false
        RefreshEntityList()
        RefreshActionList()
        RefreshActionEntityDropdown(forms["ActionEntityDDL"])
        ; Dependent dropdown choices must exist before their saved text is chosen.
        ChooseDropdownText(EntityTypeDDL, forms["EntityTypeDDL"])
        ChooseDropdownText(ActionEntityDDL, forms["ActionEntityDDL"])
        RefreshActionTargetDropdown()
        for name, control in BuilderFormControls() {
            if InStr(name, "DDL")
                ChooseDropdownText(control, forms[name])
            else
                control.Value := forms[name]
        }
        HeroDDL.Enabled := EntityTypeDDL.Text = "Hero"
        BuilderEntitySaveButton.Text := IsObject(BuilderEditingEntity) ? "SAVE CHANGES" : "ADD MONKEY"
        BuilderActionSaveButton.Text := BuilderEditingActionIndex ? "Save changes" : "Add action"
        EntityLV.Modify(0, "-Select")
        ActionLV.Modify(0, "-Select")
        if editor["entitySelection"]
            EntityLV.Modify(editor["entitySelection"], "Select Focus Vis")
        if editor["actionSelection"]
            ActionLV.Modify(editor["actionSelection"], "Select Focus Vis")
        BuilderFormBaseline := CloneBuilderState(state["formBaseline"])
        OutputEdit.Value := state["preview"]
        RefreshBuilderRoundHint()
        ShowBuilderView(editor["view"])
        RefreshBuilderActionForm()
        RefreshMonkeyOverlayIfVisible()
    } finally {
        EndBuilderLayout()
        BuilderHistoryDepth := previousDepth
    }
}

CloneBuilderState(value) {
    if value is Array {
        copy := []
        for item in value
            copy.Push(CloneBuilderState(item))
        return copy
    }
    if IsObject(value) {
        copy := Map()
        if value is Map {
            for key, item in value
                copy[key] := CloneBuilderState(item)
        } else {
            for key, item in value.OwnProps()
                copy[key] := CloneBuilderState(item)
        }
        return copy
    }
    return value
}

BuilderRecordsFromState(records) {
    result := []
    for record in records {
        item := {}
        for key, value in record
            item.%key% := value
        result.Push(item)
    }
    return result
}

BuilderStatesEqual(left, right) {
    if left is Array {
        if !(right is Array) || left.Length != right.Length
            return false
        for index, value in left
            if !BuilderStatesEqual(value, right[index])
                return false
        return true
    }
    if left is Map {
        if !(right is Map) || left.Count != right.Count
            return false
        for key, value in left
            if !right.Has(key) || !BuilderStatesEqual(value, right[key])
                return false
        return true
    }
    return !IsObject(right) && left == right
}

ValidateBuilderState(state) {
    global CategoryChoices, DifficultyChoices, ModeChoicesByDifficulty, TowerTypes, HeroNames
    if !(state is Map)
        return false
    for key in ["schema", "entities", "actions", "metadata", "forms", "formBaseline", "editor", "preview"]
        if !state.Has(key)
            return false
    if state["schema"] != 1 || !(state["entities"] is Array) || !(state["actions"] is Array)
        return false
    for key in ["metadata", "forms", "formBaseline", "editor"]
        if !(state[key] is Map)
            return false
    if IsObject(state["preview"]) || StrLen(state["preview"]) > 4000000
        return false
    for key in ["mapName", "functionName", "category", "difficulty", "mode", "wingmonkey", "importedStartRound", "importedEndRound"]
        if !state["metadata"].Has(key) || IsObject(state["metadata"][key])
            return false
    metadata := state["metadata"]
    if !BuilderChoiceContains(CategoryChoices, metadata["category"])
        || !BuilderChoiceContains(DifficultyChoices, metadata["difficulty"])
        || !BuilderChoiceContains(ModeChoicesByDifficulty[metadata["difficulty"]], metadata["mode"])
        || !BuilderIntegerInRange(metadata["wingmonkey"], 0, 1)
        return false
    for key in ["importedStartRound", "importedEndRound"]
        if metadata[key] != "" && !BuilderIntegerInRange(metadata[key], 0, 2147483647)
            return false
    for key, control in BuilderFormControls()
        if !state["forms"].Has(key) || !state["formBaseline"].Has(key) || IsObject(state["forms"][key]) || IsObject(state["formBaseline"][key])
            return false
    ; Extra nested values are not part of the draft format. Reject them before
    ; any controls change, rather than allowing a half-restored window.
    for section in ["metadata", "forms", "formBaseline", "editor"]
        for key, value in state[section]
            if IsObject(value) || StrLen(value) > 131072
                return false
    forms := state["forms"]
    if !BuilderChoiceContains(TowerTypes, forms["EntityTypeDDL"])
        || !BuilderChoiceContains(HeroNames, forms["HeroDDL"])
        || !BuilderChoiceContains(["Upgrade", "Targeting", "Sell", "Ability", "Game speed", "Repeat clicks", "Enable banana collection", "Disable banana collection"], forms["BuilderActionTypeDDL"])
        || !BuilderChoiceContains(["Normal", "Fast"], forms["GameSpeedDDL"])
        return false
    for key in ["view", "entitySelection", "actionSelection", "entityEditIndex", "actionEditIndex"]
        if !state["editor"].Has(key) || IsObject(state["editor"][key])
            return false
    if !InStr("|Monkeys|Actions|Export|", "|" state["editor"]["view"] "|")
        return false
    for pair in [["entitySelection", "entities"], ["entityEditIndex", "entities"], ["actionSelection", "actions"], ["actionEditIndex", "actions"]] {
        index := state["editor"][pair[1]]
        if !IsInteger(index) || index < 0 || index > state[pair[2]].Length
            return false
    }
    names := Map()
    names.CaseSense := "Off"
    heroCount := 0
    for entity in state["entities"] {
        if !(entity is Map)
            return false
        for key in ["name", "type", "heroName", "x", "y", "placeRound", "targeting"]
            if !entity.Has(key)
                return false
        for key, value in entity
            if !InStr("|name|type|heroName|x|y|placeRound|placeDelay|targeting|", "|" key "|") || IsObject(value)
                return false
        if Trim(entity["name"]) = "" || names.Has(entity["name"])
            || !BuilderChoiceContains(TowerTypes, entity["type"])
            || !BuilderIntegerInRange(entity["x"], 0, 1919) || !BuilderIntegerInRange(entity["y"], 0, 1079)
            || !BuilderIntegerInRange(entity["placeRound"], 0, 2147483647)
            || (entity.Has("placeDelay") && !BuilderIntegerInRange(entity["placeDelay"], 0, 2147483647))
            return false
        if entity["type"] = "Hero" {
            heroCount += 1
            if heroCount > 1 || !BuilderChoiceContains(HeroNames, entity["heroName"])
                return false
        }
        names[entity["name"]] := true
    }
    required := Map("upgrade", ["entity", "upgrade"], "target", ["entity", "target"], "sell", ["entity"],
        "ability", ["hotkey"], "speed", ["speed"], "click", ["x", "y", "count", "interval"], "bananaCollection", ["enabled"])
    for action in state["actions"] {
        if !(action is Map) || !action.Has("round") || !action.Has("delay")
            return false
        kind := action.Has("kind") ? action["kind"] : "upgrade"
        if !required.Has(kind)
            return false
        for key in required[kind]
            if !action.Has(key)
                return false
        for key, value in action
            if !InStr("|kind|entity|round|delay|upgrade|target|hotkey|speed|x|y|count|interval|enabled|overrideX|overrideY|targetX|targetY|sourcePos|", "|" key "|") || IsObject(value)
                return false
        if !BuilderIntegerInRange(action["round"], 0, 2147483647)
            || !BuilderIntegerInRange(action["delay"], 0, 2147483647)
            || (action.Has("entity") && !names.Has(action["entity"]))
            return false
        if action.Has("sourcePos") && !BuilderIntegerInRange(action["sourcePos"], 0, 2147483647)
            return false
        for pair in [["overrideX", "overrideY"], ["targetX", "targetY"]] {
            if action.Has(pair[1]) != action.Has(pair[2])
                return false
            if action.Has(pair[1]) && (!BuilderIntegerInRange(action[pair[1]], 0, 1919) || !BuilderIntegerInRange(action[pair[2]], 0, 1079))
                return false
        }
        if kind = "upgrade" && !RegExMatch(action["upgrade"], "^[0-5]{3}$")
            return false
        if kind = "speed" && !BuilderChoiceContains(["Normal", "Fast"], action["speed"])
            return false
        if kind = "bananaCollection" && !BuilderIntegerInRange(action["enabled"], 0, 1)
            return false
        if kind = "click" && (!BuilderIntegerInRange(action["x"], 0, 1919) || !BuilderIntegerInRange(action["y"], 0, 1079)
            || !BuilderIntegerInRange(action["count"], 1, 2147483647) || !BuilderIntegerInRange(action["interval"], 0, 2147483647))
            return false
    }
    return true
}

BuilderIntegerInRange(value, minimum, maximum) {
    return !IsObject(value) && IsInteger(value) && value >= minimum && value <= maximum
}

BuilderChoiceContains(choices, wanted) {
    for choice in choices
        if choice == wanted
            return true
    return false
}

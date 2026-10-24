#Requires AutoHotkey v2.0

; Builds scheduled actions from the current form and keeps their list in insertion order.
; Coordinate overrides select a moved tower; Spike Factory target points have a separate meaning.

SaveBuilderAction(*) {
    global BuilderActionTypeDDL, BuilderEditingActionIndex, BuilderEditingAction
    global UpgradeActions, ActionLV, StatusText

    problem := ValidateBuilderActionInput()
    if problem != "" {
        MsgBox(problem, "Strategy Builder", "Icon!")
        return false
    }

    ; The original row stays in place until the existing add helper succeeds.
    ; A rejected edit therefore cannot delete an action or change its position.
    editIndex := FindBuilderEditingActionIndex()
    beforeCount := UpgradeActions.Length
    switch BuilderActionTypeDDL.Text {
        case "Upgrade": AddUpgradeAction()
        case "Targeting": AddTargetingAction()
        case "Sell": AddSellAction()
        case "Ability": AddAbilityAction()
        case "Game speed": AddGameSpeedAction()
        case "Enable banana collection": AddBananaCollectionEnableAction()
        case "Disable banana collection": AddBananaCollectionDisableAction()
        default:
            MsgBox("Choose an action type first.", "Strategy Builder", "Icon!")
            return false
    }

    if UpgradeActions.Length != beforeCount + 1
        return false

    if editIndex {
        replacement := UpgradeActions.Pop()
        UpgradeActions[editIndex] := replacement
        savedRow := editIndex
    } else {
        savedRow := UpgradeActions.Length
    }

    BuilderEditingActionIndex := 0
    BuilderEditingAction := false
    RefreshActionList()
    NewBuilderAction()
    ActionLV.Modify(savedRow, "Select Focus Vis")
    StatusText.Text := editIndex ? "Saved changes to action " savedRow : "Added action " savedRow
    return true
}

LoadSelectedActionForEdit(*) {
    global UpgradeActions, ActionLV, BuilderActionTypeDDL, BuilderActionSaveButton
    global BuilderEditingActionIndex, BuilderEditingAction, ActionEntityDDL
    global UpgradeEdit, UpgradeXEdit, UpgradeYEdit, UpgradeRoundEdit, UpgradeDelayEdit
    global ActionTargetDDL, ActionTargetXEdit, ActionTargetYEdit, AbilityEdit, GameSpeedDDL, StatusText

    row := ActionLV.GetNext(0)
    if row < 1 || row > UpgradeActions.Length
        return false

    action := UpgradeActions[row]
    kind := HasProp(action, "kind") ? action.kind : "upgrade"
    typeNames := Map("upgrade", "Upgrade", "target", "Targeting", "sell", "Sell",
        "ability", "Ability", "speed", "Game speed", "bananaCollection", "Enable banana collection")
    if !typeNames.Has(kind)
        return false

    if HasProp(action, "entity") {
        if !ChooseDropdownText(ActionEntityDDL, action.entity) {
            MsgBox("This action refers to a monkey that is no longer in the strategy.", "Strategy Builder", "Icon!")
            return false
        }
    }

    ; Choosing a monkey clears old overrides, so restore the row's values afterwards.
    OnActionEntityChanged()
    typeName := kind = "bananaCollection" && !action.enabled ? "Disable banana collection" : typeNames[kind]
    ChooseDropdownText(BuilderActionTypeDDL, typeName)
    UpgradeRoundEdit.Value := action.round
    UpgradeDelayEdit.Value := action.delay

    switch kind {
        case "upgrade":
            UpgradeEdit.Value := action.upgrade
            if HasProp(action, "overrideX") {
                UpgradeXEdit.Value := action.overrideX
                UpgradeYEdit.Value := action.overrideY
            }
        case "sell":
            if HasProp(action, "overrideX") {
                UpgradeXEdit.Value := action.overrideX
                UpgradeYEdit.Value := action.overrideY
            }
        case "target":
            if !ChooseDropdownText(ActionTargetDDL, action.target) {
                NewBuilderAction()
                MsgBox("This targeting mode is not supported by the action editor.", "Strategy Builder", "Icon!")
                return false
            }
            if HasProp(action, "targetX") {
                ActionTargetXEdit.Value := action.targetX
                ActionTargetYEdit.Value := action.targetY
            } else if HasProp(action, "overrideX") {
                ActionTargetXEdit.Value := action.overrideX
                ActionTargetYEdit.Value := action.overrideY
            }
        case "ability": AbilityEdit.Value := action.hotkey
        case "speed": ChooseDropdownText(GameSpeedDDL, action.speed)
    }

    BuilderEditingActionIndex := row
    BuilderEditingAction := action
    BuilderActionSaveButton.Text := "Save changes"
    RefreshBuilderActionForm()
    StatusText.Text := "Editing action " row " — choose New action to leave this row unchanged"
    return true
}

NewBuilderAction(*) {
    global BuilderEditingActionIndex, BuilderEditingAction, BuilderActionSaveButton
    global UpgradeDelayEdit, AbilityEdit, GameSpeedDDL, ActionLV, StatusText

    BuilderEditingActionIndex := 0
    BuilderEditingAction := false
    BuilderActionSaveButton.Text := "Add action"
    ActionLV.Modify(0, "-Select")
    UpgradeDelayEdit.Value := "0"
    AbilityEdit.Value := "1"
    GameSpeedDDL.Choose(1)
    OnActionEntityChanged()
    RefreshBuilderActionForm()
    StatusText.Text := "New action — the last round is kept for the next entry"
}

FindBuilderEditingActionIndex() {
    global BuilderEditingActionIndex, BuilderEditingAction, UpgradeActions

    ; An object reference survives a rename or an earlier row being removed.
    ; Imports and Clear replace the objects, so an old edit cannot affect a new row.
    if IsObject(BuilderEditingAction) {
        for index, action in UpgradeActions {
            if action == BuilderEditingAction {
                BuilderEditingActionIndex := index
                return index
            }
        }
    }
    BuilderEditingActionIndex := 0
    BuilderEditingAction := false
    return 0
}

ValidateBuilderActionInput() {
    global BuilderActionTypeDDL, UpgradeRoundEdit, UpgradeDelayEdit, UpgradeEdit
    global UpgradeXEdit, UpgradeYEdit, ActionTargetXEdit, ActionTargetYEdit
    global ActionEntityDDL, ActionTargetDDL

    if !IsBuilderInputInteger(UpgradeRoundEdit.Value)
        return "Round must be a whole number from 0 to 2147483647. Round 0 means pregame."
    if !IsBuilderInputInteger(UpgradeDelayEdit.Value)
        return "Delay must be a whole number from 0 to 2147483647 milliseconds."

    actionType := BuilderActionTypeDDL.Text
    if actionType = "Upgrade" {
        upgrade := Trim(UpgradeEdit.Value)
        if !RegExMatch(upgrade, "^[0-5]{3}$")
            return "Use three upgrade tiers from 0 to 5, such as 002, 024, or 520."
        activePaths := 0
        highPaths := 0
        Loop Parse upgrade {
            tier := Integer(A_LoopField)
            activePaths += tier > 0 ? 1 : 0
            highPaths += tier > 2 ? 1 : 0
        }
        if activePaths > 2 || highPaths > 1
            return "Use at most two upgrade paths. Only one path can go above tier 2."
    }

    if actionType = "Upgrade" || actionType = "Sell"
        return ValidateBuilderCoordinatePair(UpgradeXEdit.Value, UpgradeYEdit.Value, "Tower selection")

    if actionType = "Targeting" {
        entity := FindEntityByName(ActionEntityDDL.Text)
        if entity && (entity.type != "SpikeFactory" || ActionTargetDDL.Text = "Set Target")
            return ValidateBuilderCoordinatePair(ActionTargetXEdit.Value, ActionTargetYEdit.Value, "Targeting")
    }
    return ""
}

IsBuilderInputInteger(value) {
    value := Trim(value)
    if !RegExMatch(value, "^\d+$")
        return false
    ; Bound the text before conversion so a pasted huge number cannot overflow.
    value := LTrim(value, "0")
    return value = "" || (StrLen(value) <= 10 && value + 0 <= 2147483647)
}

ValidateBuilderCoordinatePair(xText, yText, label) {
    xText := Trim(xText)
    yText := Trim(yText)
    if xText = "" && yText = ""
        return ""
    if xText = "" || yText = ""
        return label " coordinates need both X and Y. Leave both blank to use the placement point."
    if !IsBuilderInputInteger(xText) || !IsBuilderInputInteger(yText)
        return label " coordinates must be whole numbers."
    if xText + 0 > 1919 || yText + 0 > 1079
        return label " coordinates must be inside the 1920 × 1080 game screen (X 0–1919, Y 0–1079)."
    return ""
}

AddUpgradeAction(*) {
    global Entities, UpgradeActions, ActionEntityDDL, UpgradeEdit, UpgradeXEdit, UpgradeYEdit, UpgradeRoundEdit, UpgradeDelayEdit, StatusText

    if Entities.Length = 0 {
        MsgBox("Add at least one monkey first.", "Strategy Builder", "Icon!")
        return
    }

    entityName := ActionEntityDDL.Text
    if entityName = "" || entityName = "Add a monkey first" {
        MsgBox("Select a monkey.", "Strategy Builder", "Icon!")
        return
    }

    selectedEntity := FindEntityByName(entityName)
    if !selectedEntity {
        MsgBox("The selected monkey could not be found.", "Strategy Builder", "Icon!")
        return
    }

    if selectedEntity.type = "Hero" {
        MsgBox("Heroes level automatically in BTD6, so UpgradeTower actions are not generated for heroes. Set the hero's placement round when adding it.", "Strategy Builder", "Icon!")
        return
    }

    upgrade := Trim(UpgradeEdit.Value)
    if !RegExMatch(upgrade, "^\d{3}$") {
        MsgBox("Upgrade must be exactly three digits, such as 002, 024, 050, or 520.", "Strategy Builder", "Icon!")
        return
    }

    round := IntegerOrDefault(UpgradeRoundEdit.Value, 0)
    delay := IntegerOrDefault(UpgradeDelayEdit.Value, 0)

    action := {
        kind: "upgrade",
        entity: entityName,
        upgrade: upgrade,
        round: round,
        delay: delay
    }

    ; Blank overrides use the placement point; one coordinate alone cannot select a tower.
    overrideXText := Trim(UpgradeXEdit.Value)
    overrideYText := Trim(UpgradeYEdit.Value)

    if overrideXText != "" || overrideYText != "" {
        if overrideXText = "" || overrideYText = "" {
            MsgBox("Upgrade coordinate override requires both X and Y.", "Strategy Builder", "Icon!")
            return
        }

        action.overrideX := IntegerOrDefault(overrideXText, 0)
        action.overrideY := IntegerOrDefault(overrideYText, 0)
    }

    UpgradeActions.Push(action)
    RefreshActionList()

    if HasProp(action, "overrideX")
        StatusText.Text := "Added " entityName " -> " upgrade " @ " action.overrideX "," action.overrideY " on round " round
    else
        StatusText.Text := "Added " entityName " -> " upgrade " on round " round
}

AddTargetingAction(*) {
    global Entities, UpgradeActions, ActionEntityDDL, ActionTargetDDL, ActionTargetXEdit, ActionTargetYEdit
    global UpgradeRoundEdit, UpgradeDelayEdit, StatusText

    if Entities.Length = 0 {
        MsgBox("Add at least one monkey first.", "Strategy Builder", "Icon!")
        return
    }

    entityName := ActionEntityDDL.Text
    if entityName = "" || entityName = "Add a monkey first" {
        MsgBox("Select a monkey.", "Strategy Builder", "Icon!")
        return
    }

    selectedEntity := FindEntityByName(entityName)
    if !selectedEntity {
        MsgBox("The selected monkey could not be found.", "Strategy Builder", "Icon!")
        return
    }

    ; These tower types need their dedicated aiming helpers, not a normal targeting cycle.
    if selectedEntity.type = "Dartling" {
        MsgBox("Dartling Gunners use SetDartlingTargeting() / AimDartling() instead of SetTargeting().", "Strategy Builder", "Icon!")
        return
    }

    if selectedEntity.type = "Heli" {
        MsgBox("Heli Pilots use LockHeliInPlace() / RetargetHeli() instead of SetTargeting().", "Strategy Builder", "Icon!")
        return
    }

    if selectedEntity.type = "Mortar" {
        MsgBox("Mortar Monkeys use SetMortarTarget() / RetargetMortar() instead of SetTargeting().", "Strategy Builder", "Icon!")
        return
    }

    targetMode := ActionTargetDDL.Text
    if targetMode = "" {
        MsgBox("Select a targeting mode.", "Strategy Builder", "Icon!")
        return
    }

    round := IntegerOrDefault(UpgradeRoundEdit.Value, 0)
    delay := IntegerOrDefault(UpgradeDelayEdit.Value, 0)

    action := {
        kind: "target",
        entity: entityName,
        target: targetMode,
        round: round,
        delay: delay
    }

    targetXText := Trim(ActionTargetXEdit.Value)
    targetYText := Trim(ActionTargetYEdit.Value)

    if selectedEntity.type = "SpikeFactory" && targetMode = "Set Target" {
        if targetXText = "" || targetYText = "" {
            MsgBox("Enter both Spike Factory Set Target X and Y coordinates.", "Strategy Builder", "Icon!")
            return
        }

        action.targetX := IntegerOrDefault(targetXText, 0)
        action.targetY := IntegerOrDefault(targetYText, 0)
    } else if selectedEntity.type != "SpikeFactory" {
        if targetXText != "" || targetYText != "" {
            if targetXText = "" || targetYText = "" {
                MsgBox("Targeting coordinate override requires both X and Y.", "Strategy Builder", "Icon!")
                return
            }

            action.overrideX := IntegerOrDefault(targetXText, 0)
            action.overrideY := IntegerOrDefault(targetYText, 0)
        }
    }

    UpgradeActions.Push(action)
    RefreshActionList()

    if selectedEntity.type = "SpikeFactory" && targetMode = "Set Target"
        StatusText.Text := "Added " entityName " Set Target -> " action.targetX "," action.targetY " on round " round
    else if HasProp(action, "overrideX")
        StatusText.Text := "Added " entityName " targeting -> " targetMode " @ " action.overrideX "," action.overrideY " on round " round
    else
        StatusText.Text := "Added " entityName " targeting -> " targetMode " on round " round
}

AddSellAction(*) {
    global Entities, UpgradeActions, ActionEntityDDL, UpgradeRoundEdit, UpgradeDelayEdit, StatusText
    global UpgradeXEdit, UpgradeYEdit

    if Entities.Length = 0 {
        MsgBox("Add at least one monkey or hero first.", "Strategy Builder", "Icon!")
        return
    }

    entityName := ActionEntityDDL.Text
    if entityName = "" || entityName = "Add a monkey first" {
        MsgBox("Select a monkey or hero to sell.", "Strategy Builder", "Icon!")
        return
    }

    if !FindEntityByName(entityName) {
        MsgBox("The selected monkey could not be found.", "Strategy Builder", "Icon!")
        return
    }

    round := IntegerOrDefault(UpgradeRoundEdit.Value, 0)
    delay := IntegerOrDefault(UpgradeDelayEdit.Value, 0)

    action := {kind: "sell", entity: entityName, round: round, delay: delay}
    overrideXText := Trim(UpgradeXEdit.Value)
    overrideYText := Trim(UpgradeYEdit.Value)
    if overrideXText != "" || overrideYText != "" {
        problem := ValidateBuilderCoordinatePair(overrideXText, overrideYText, "Tower selection")
        if problem != "" {
            MsgBox(problem, "Strategy Builder", "Icon!")
            return
        }
        action.overrideX := Integer(overrideXText)
        action.overrideY := Integer(overrideYText)
    }
    UpgradeActions.Push(action)
    RefreshActionList()
    StatusText.Text := "Added sell for " entityName " on round " round
}

AddAbilityAction(*) {
    global UpgradeActions, AbilityEdit, UpgradeRoundEdit, UpgradeDelayEdit, StatusText

    hotkey := Trim(AbilityEdit.Value)
    if hotkey = "" {
        MsgBox("Enter the BTD6 ability hotkey, such as 1, 2, or 3.", "Strategy Builder", "Icon!")
        return
    }

    round := IntegerOrDefault(UpgradeRoundEdit.Value, 0)
    delay := IntegerOrDefault(UpgradeDelayEdit.Value, 0)

    UpgradeActions.Push({kind: "ability", hotkey: hotkey, round: round, delay: delay})
    RefreshActionList()
    StatusText.Text := "Added ability " hotkey " on round " round
}


AddBananaCollectionEnableAction(*) {
    AddBananaCollectionAction(true)
}


AddBananaCollectionDisableAction(*) {
    AddBananaCollectionAction(false)
}


; Collection toggles affect the whole run, so they do not need a selected monkey.
AddBananaCollectionAction(enabled) {
    global UpgradeActions, UpgradeRoundEdit, UpgradeDelayEdit, StatusText

    round := IntegerOrDefault(UpgradeRoundEdit.Value, 0)
    delay := IntegerOrDefault(UpgradeDelayEdit.Value, 0)

    UpgradeActions.Push({
        kind: "bananaCollection",
        enabled: enabled,
        round: round,
        delay: delay
    })

    RefreshActionList()

    StatusText.Text :=
        (enabled ? "Enable" : "Disable")
        . " banana collection on round "
        . round
}


AddGameSpeedAction(*) {
    global UpgradeActions, GameSpeedDDL, UpgradeRoundEdit, UpgradeDelayEdit, StatusText

    speedMode := GameSpeedDDL.Text
    if speedMode != "Normal" && speedMode != "Fast" {
        MsgBox("Select Normal or Fast game speed.", "Strategy Builder", "Icon!")
        return
    }

    round := IntegerOrDefault(UpgradeRoundEdit.Value, 0)
    delay := IntegerOrDefault(UpgradeDelayEdit.Value, 0)

    ; Round 0 happens before StartGame(), where Space starts the match instead
    ; of changing speed, so speed actions must be scheduled on real rounds.
    if round <= 0 {
        MsgBox("Game speed actions must use round 1 or later.", "Strategy Builder", "Icon!")
        return
    }

    UpgradeActions.Push({kind: "speed", speed: speedMode, round: round, delay: delay})
    RefreshActionList()
    StatusText.Text := "Added game speed -> " speedMode " on round " round
}

DeleteSelectedUpgrade(*) {
    global ActionLV, UpgradeActions, StatusText

    row := ActionLV.GetNext(0)
    if row = 0 {
        MsgBox("Select a scheduled action to delete.", "Strategy Builder", "Icon!")
        return
    }

    UpgradeActions.RemoveAt(row)
    RefreshActionList()
    ; Deleting a different row must not replace the upgrade text being edited.
    if !FindBuilderEditingActionIndex()
        RefreshUpgradeEditForSelectedEntity()
    StatusText.Text := "Scheduled action deleted"
}

RefreshEntityList() {
    global EntityLV, Entities

    EntityLV.Delete()
    for entity in Entities {
        heroDisplay := entity.type = "Hero" ? entity.heroName : "-"
        placeDelay := HasProp(entity, "placeDelay") ? entity.placeDelay : 0
        EntityLV.Add("", entity.name, entity.type, heroDisplay, entity.x, entity.y, entity.placeRound, placeDelay, entity.targeting)
    }
}

RefreshActionList() {
    global ActionLV, UpgradeActions
    global BuilderActionSaveButton

    ActionLV.Delete()
    for action in UpgradeActions {
        kind := HasProp(action, "kind") ? action.kind : "upgrade"

        if kind = "target" {
            value := action.target
            if action.target = "Set Target" && HasProp(action, "targetX")
                value .= " -> " action.targetX "," action.targetY
            else if HasProp(action, "overrideX")
                value .= " @ " action.overrideX "," action.overrideY
            ActionLV.Add("", "Target", action.entity, value, action.round, action.delay)
        } else if kind = "sell" {
            value := HasProp(action, "overrideX") ? "@ " action.overrideX "," action.overrideY : "Sell"
            ActionLV.Add("", "Sell", action.entity, value, action.round, action.delay)
        } else if kind = "ability" {
            ActionLV.Add("", "Ability", "-", action.hotkey, action.round, action.delay)
        } else if kind = "speed" {
            ActionLV.Add("", "Speed", "-", action.speed, action.round, action.delay)
        } else if kind = "bananaCollection" {
            ActionLV.Add("", "Farm", "-", action.enabled ? "Enable" : "Disable", action.round, action.delay)
        } else {
            value := action.upgrade
            if HasProp(action, "overrideX")
                value .= " @ " action.overrideX "," action.overrideY
            ActionLV.Add("", "Upgrade", action.entity, value, action.round, action.delay)
        }
    }
    editIndex := FindBuilderEditingActionIndex()
    BuilderActionSaveButton.Text := editIndex ? "Save changes" : "Add action"
    if editIndex
        ActionLV.Modify(editIndex, "Select Focus")
}

RefreshActionEntityDropdown(preferredName := "") {
    global ActionEntityDDL, Entities

    names := []
    for entity in Entities
        names.Push(entity.name)

    ActionEntityDDL.Delete()

    if names.Length = 0 {
        ActionEntityDDL.Add(["Add a monkey first"])
        ActionEntityDDL.Choose(1)
        RefreshActionTargetDropdown()
        RefreshUpgradeEditForSelectedEntity()
        ClearUpgradeCoordinateInputs()
        ClearTargetCoordinateInputs()
        return
    }

    ActionEntityDDL.Add(names)

    if preferredName != "" && ChooseDropdownText(ActionEntityDDL, preferredName) {
        RefreshActionTargetDropdown()
        RefreshUpgradeEditForSelectedEntity()
        ClearUpgradeCoordinateInputs()
        ClearTargetCoordinateInputs()
        return
    }

    ActionEntityDDL.Choose(1)
    RefreshActionTargetDropdown()
    RefreshUpgradeEditForSelectedEntity()
    ClearUpgradeCoordinateInputs()
    ClearTargetCoordinateInputs()
}

; A coordinate override belongs to one tower and must not carry into a different selection.
OnActionEntityChanged(*) {
    RefreshActionTargetDropdown()
    RefreshUpgradeEditForSelectedEntity()
    ClearUpgradeCoordinateInputs()
    ClearTargetCoordinateInputs()
}

GetRememberedUpgradeForEntity(entityName) {
    global UpgradeActions

    ; Reuse the most recently entered upgrade for this monkey as the next edit starting point.
    remembered := "000"

    for action in UpgradeActions {
        kind := HasProp(action, "kind") ? action.kind : "upgrade"

        if (
            kind = "upgrade"
            && HasProp(action, "entity")
            && action.entity = entityName
        ) {
            remembered := action.upgrade
        }
    }

    return remembered
}

RefreshUpgradeEditForSelectedEntity() {
    global ActionEntityDDL, UpgradeEdit

    if !UpgradeEdit
        return

    selectedEntity := FindEntityByName(ActionEntityDDL.Text)

    if !selectedEntity || selectedEntity.type = "Hero" {
        UpgradeEdit.Value := "000"
        return
    }

    UpgradeEdit.Value := GetRememberedUpgradeForEntity(selectedEntity.name)
}

ClearUpgradeCoordinateInputs() {
    global UpgradeXEdit, UpgradeYEdit

    if UpgradeXEdit
        UpgradeXEdit.Value := ""

    if UpgradeYEdit
        UpgradeYEdit.Value := ""
}

CaptureUpgradeCoordinatesInstant(*) {
    global UpgradeXEdit, UpgradeYEdit, StatusText

    MouseGetPos(&mx, &my)
    UpgradeXEdit.Value := mx
    UpgradeYEdit.Value := my
    StatusText.Text := "Captured upgrade coordinates: " mx ", " my
    ToolTip("Captured upgrade coordinates: " mx ", " my)
    SetTimer(() => ToolTip(), -800)
}

CaptureUpgradeCoordinates(*) {
    global MainGui, UpgradeXEdit, UpgradeYEdit, StatusText

    StatusText.Text := "Move cursor and press F3..."
    MainGui.Hide()
    Sleep(150)
    ToolTip("Move the mouse over the tower's current BTD6 position.`nPress F3 to capture upgrade coordinates.`nPress Esc to cancel.")

    Loop {
        if GetKeyState("Escape", "P") {
            KeyWait("Escape")
            ToolTip()
            MainGui.Show()
            StatusText.Text := "Upgrade coordinate capture cancelled"
            return
        }

        if GetKeyState("F3", "P") {
            MouseGetPos(&mx, &my)
            KeyWait("F3")
            ToolTip()
            UpgradeXEdit.Value := mx
            UpgradeYEdit.Value := my
            MainGui.Show()
            MainGui.Opt("+AlwaysOnTop")
            WinActivate("ahk_id " MainGui.Hwnd)
            SetTimer(() => MainGui.Opt("-AlwaysOnTop"), -250)
            StatusText.Text := "Captured upgrade coordinates: " mx ", " my
            return
        }

        Sleep(20)
    }
}


ClearTargetCoordinateInputs() {
    global ActionTargetXEdit, ActionTargetYEdit

    if ActionTargetXEdit
        ActionTargetXEdit.Value := ""

    if ActionTargetYEdit
        ActionTargetYEdit.Value := ""
}

CaptureTargetCoordinatesInstant(*) {
    global ActionTargetXEdit, ActionTargetYEdit, StatusText

    if !ActionTargetXEdit.Enabled || !ActionTargetYEdit.Enabled
        return

    MouseGetPos(&mx, &my)
    ActionTargetXEdit.Value := mx
    ActionTargetYEdit.Value := my
    StatusText.Text := "Captured targeting coordinates: " mx ", " my
    ToolTip("Captured targeting coordinates: " mx ", " my)
    SetTimer(() => ToolTip(), -800)
}

CaptureTargetCoordinates(*) {
    global MainGui, ActionTargetXEdit, ActionTargetYEdit, StatusText

    if !ActionTargetXEdit.Enabled || !ActionTargetYEdit.Enabled {
        MsgBox("Select a targeting action that supports coordinates first.", "Strategy Builder", "Icon!")
        return
    }

    StatusText.Text := "Move cursor and press F5..."
    MainGui.Hide()
    Sleep(150)
    ToolTip("Move the mouse to the targeting coordinate.`nPress F5 to capture SCREEN coordinates.`nPress Esc to cancel.")

    Loop {
        if GetKeyState("Escape", "P") {
            KeyWait("Escape")
            ToolTip()
            MainGui.Show()
            StatusText.Text := "Targeting coordinate capture cancelled"
            return
        }

        if GetKeyState("F5", "P") {
            MouseGetPos(&mx, &my)
            KeyWait("F5")
            ToolTip()
            ActionTargetXEdit.Value := mx
            ActionTargetYEdit.Value := my
            MainGui.Show()
            MainGui.Opt("+AlwaysOnTop")
            WinActivate("ahk_id " MainGui.Hwnd)
            SetTimer(() => MainGui.Opt("-AlwaysOnTop"), -250)
            StatusText.Text := "Captured targeting coordinates: " mx ", " my
            return
        }

        Sleep(20)
    }
}

OnActionTargetChanged(*) {
    RefreshActionTargetCoordinateState()
}

RefreshActionTargetCoordinateState() {
    global ActionEntityDDL, ActionTargetDDL, ActionTargetXEdit, ActionTargetYEdit

    enabled := false
    selectedEntity := FindEntityByName(ActionEntityDDL.Text)

    if selectedEntity {
        if selectedEntity.type = "SpikeFactory" {
            ; Spike Factory Set Target uses these as the actual spike target point.
            enabled := ActionTargetDDL.Text = "Set Target"
        } else if (
            selectedEntity.type != "Dartling"
            && selectedEntity.type != "Heli"
            && selectedEntity.type != "Mortar"
        ) {
            ; Normal targeting can optionally use a moving-map click override.
            enabled := true
        }
    }

    ActionTargetXEdit.Enabled := enabled
    ActionTargetYEdit.Enabled := enabled
}

RefreshActionTargetDropdown() {
    global ActionEntityDDL, ActionTargetDDL

    if !ActionTargetDDL
        return

    ActionTargetDDL.Delete()

    entityName := ActionEntityDDL.Text
    selectedEntity := FindEntityByName(entityName)

    if !selectedEntity {
        ActionTargetDDL.Add(["First"])
        ActionTargetDDL.Choose(1)
        ActionTargetDDL.Enabled := false
        RefreshActionTargetCoordinateState()
        return
    }

    type := selectedEntity.type

    if type = "Dartling" {
        choices := ["Use Dartling helper"]
        ActionTargetDDL.Enabled := false
    } else if type = "Heli" {
        choices := ["Use Heli helper"]
        ActionTargetDDL.Enabled := false
    } else if type = "Mortar" {
        choices := ["Use Mortar helper"]
        ActionTargetDDL.Enabled := false
    } else if type = "SpikeFactory" {
        choices := ["Normal", "Close", "Smart", "Set Target", "Automatic"]
        ActionTargetDDL.Enabled := true
    } else if type = "Ace" {
        choices := ["Circle", "Figure Infinite", "Figure Eight", "Centered Path"]
        ActionTargetDDL.Enabled := true
    } else if type = "Sniper" {
        choices := ["First", "Last", "Close", "Strong", "Elite"]
        ActionTargetDDL.Enabled := true
    } else {
        choices := ["First", "Last", "Close", "Strong"]
        ActionTargetDDL.Enabled := true
    }

    ActionTargetDDL.Add(choices)
    ActionTargetDDL.Choose(1)
    RefreshActionTargetCoordinateState()
}

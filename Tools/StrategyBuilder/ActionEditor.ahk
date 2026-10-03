#Requires AutoHotkey v2.0

; v3 file note: Handles scheduled upgrades, targeting, sells, abilities, and the action list.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

AddUpgradeAction(*) {
    global Entities, UpgradeActions, ActionEntityDDL, UpgradeEdit, UpgradeRoundEdit, UpgradeDelayEdit, StatusText

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

    UpgradeActions.Push({kind: "upgrade", entity: entityName, upgrade: upgrade, round: round, delay: delay})
    RefreshActionList()
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

    if selectedEntity.type = "SpikeFactory" && targetMode = "Set Target" {
        targetX := IntegerOrDefault(ActionTargetXEdit.Value, 0)
        targetY := IntegerOrDefault(ActionTargetYEdit.Value, 0)

        if targetX = 0 && targetY = 0 {
            MsgBox("Enter the Spike Factory Set Target X and Y coordinates.", "Strategy Builder", "Icon!")
            return
        }

        action.targetX := targetX
        action.targetY := targetY
    }

    UpgradeActions.Push(action)
    RefreshActionList()

    if selectedEntity.type = "SpikeFactory" && targetMode = "Set Target"
        StatusText.Text := "Added " entityName " Set Target -> " action.targetX "," action.targetY " on round " round
    else
        StatusText.Text := "Added " entityName " targeting -> " targetMode " on round " round
}

AddSellAction(*) {
    global Entities, UpgradeActions, ActionEntityDDL, UpgradeRoundEdit, UpgradeDelayEdit, StatusText

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

    UpgradeActions.Push({kind: "sell", entity: entityName, round: round, delay: delay})
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

DeleteSelectedUpgrade(*) {
    global ActionLV, UpgradeActions, StatusText

    row := ActionLV.GetNext(0)
    if row = 0 {
        MsgBox("Select a scheduled action to delete.", "Strategy Builder", "Icon!")
        return
    }

    UpgradeActions.RemoveAt(row)
    RefreshActionList()
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

    ActionLV.Delete()
    for action in UpgradeActions {
        kind := HasProp(action, "kind") ? action.kind : "upgrade"

        if kind = "target" {
            value := action.target
            if action.target = "Set Target" && HasProp(action, "targetX")
                value .= " @ " action.targetX "," action.targetY
            ActionLV.Add("", "Target", action.entity, value, action.round, action.delay)
        } else if kind = "sell" {
            value := HasProp(action, "overrideX") ? "@ " action.overrideX "," action.overrideY : "Sell"
            ActionLV.Add("", "Sell", action.entity, value, action.round, action.delay)
        } else if kind = "ability" {
            ActionLV.Add("", "Ability", "-", action.hotkey, action.round, action.delay)
        } else {
            value := action.upgrade
            if HasProp(action, "overrideX")
                value .= " @ " action.overrideX "," action.overrideY
            ActionLV.Add("", "Upgrade", action.entity, value, action.round, action.delay)
        }
    }
}

RefreshActionEntityDropdown(preferredName := "") {
    global ActionEntityDDL, Entities

    names := []
    for entity in Entities
        names.Push(entity.name)

    ; CB_RESETCONTENT clears all items from a DropDownList/ComboBox.
    DllCall("SendMessage", "Ptr", ActionEntityDDL.Hwnd, "UInt", 0x014B, "Ptr", 0, "Ptr", 0)

    if names.Length = 0 {
        ActionEntityDDL.Add(["Add a monkey first"])
        ActionEntityDDL.Choose(1)
        RefreshActionTargetDropdown()
        return
    }

    ActionEntityDDL.Add(names)

    if preferredName != "" && ChooseDropdownText(ActionEntityDDL, preferredName) {
        RefreshActionTargetDropdown()
        return
    }

    ActionEntityDDL.Choose(1)
    RefreshActionTargetDropdown()
}

OnActionEntityChanged(*) {
    RefreshActionTargetDropdown()
}

OnActionTargetChanged(*) {
    RefreshActionTargetCoordinateState()
}

RefreshActionTargetCoordinateState() {
    global ActionEntityDDL, ActionTargetDDL, ActionTargetXEdit, ActionTargetYEdit

    enabled := false
    selectedEntity := FindEntityByName(ActionEntityDDL.Text)

    if (
        selectedEntity
        && selectedEntity.type = "SpikeFactory"
        && ActionTargetDDL.Text = "Set Target"
    )
        enabled := true

    ActionTargetXEdit.Enabled := enabled
    ActionTargetYEdit.Enabled := enabled
}

RefreshActionTargetDropdown() {
    global ActionEntityDDL, ActionTargetDDL

    if !ActionTargetDDL
        return

    DllCall("SendMessage", "Ptr", ActionTargetDDL.Hwnd, "UInt", 0x014B, "Ptr", 0, "Ptr", 0)

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
        choices := ["Normal", "Close", "Smart", "Automatic", "Set Target"]
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


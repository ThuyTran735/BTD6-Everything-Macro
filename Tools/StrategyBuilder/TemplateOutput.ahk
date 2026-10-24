#Requires AutoHotkey v2.0

; Turns editor state into a strategy script, with placements sorted before other tied actions.
; Generation, copy, and save share the same output so the preview matches the saved file.

GenerateTemplate(*) {
    global OutputEdit, StatusText

    template := BuildTemplateText()
    if template = ""
        return

    OutputEdit.Value := template
    StatusText.Text := "Template generated"
}

CopyTemplate(*) {
    global OutputEdit, StatusText

    ; The preview may predate the latest tower or action edit.
    template := BuildTemplateText()
    if template = ""
        return
    OutputEdit.Value := template

    A_Clipboard := template
    StatusText.Text := "Copied to clipboard"
}

SaveTemplate(*) {
    global OutputEdit, FunctionNameEdit, StatusText, MainGui

    template := BuildTemplateText()
    if template = ""
        return false
    OutputEdit.Value := template

    defaultName := SanitizeFileName(FunctionNameEdit.Value) ".ahk"
    try EnsureBuilderDataFolders()
    catch as err {
        MsgBox("Could not create the local export folder.`n`n" err.Message, "Strategy Builder", "Iconx")
        return false
    }
    defaultPath := GetBuilderDataFolder("Exports") "\" defaultName

    MainGui.Opt("-AlwaysOnTop")
    path := FileSelect("S", defaultPath, "Save generated strategy in UserData", "AutoHotkey Script (*.ahk)")
    if path = ""
        return false

    if !RegExMatch(path, "i)\.ahk$")
        path .= ".ahk"
    if !IsBuilderLocalSavePath(path, "Exports") {
        MsgBox("Save generated scripts inside this local folder so they stay out of GitHub:`n`n"
            GetBuilderDataFolder("Exports"), "Strategy Builder - Local exports", "Icon!")
        return false
    }
    if !ConfirmBuilderFileOverwrite(path)
        return false

    try {
        ; UserData/StrategyBuilder/Exports is one level shallower than a map's
        ; normal strategy folder. Keep the local export runnable from here.
        exported := StrReplace(template, "#Include ..\..\..\..\Scripts\IncludeAll.ahk",
            "#Include ..\..\..\Scripts\IncludeAll.ahk")
        WriteBuilderFileAtomic(path, exported)
        StatusText.Text := "Script exported locally. Save draft also keeps unfinished fields: " path
        return true
    } catch as err {
        MsgBox("Could not save the file.`n`n" err.Message, "Strategy Builder", "Iconx")
        return false
    }
}

ClearAll(*) {
    global Entities, UpgradeActions, OutputEdit, StatusText, EntityNameEdit, EntityTypeDDL, HeroDDL, TargetingDDL
    global PlaceRoundEdit, PlaceDelayEdit, XEdit, YEdit
    global UpgradeEdit, UpgradeXEdit, UpgradeYEdit
    global ImportedStartRound, ImportedEndRound
    global WingmonkeyMKCheckbox, GameSpeedDDL

    if !ConfirmBuilderReplace("clearing this strategy")
        return false

    BeginBuilderHistoryChange()
    try {
        HideMonkeyOverlay()
        Entities := []
        UpgradeActions := []
        ImportedStartRound := ""
        ImportedEndRound := ""
        WingmonkeyMKCheckbox.Value := 0
        if GameSpeedDDL
            GameSpeedDDL.Choose(1)
        OutputEdit.Value := ""
        EntityTypeDDL.Choose(1)
        HeroDDL.Enabled := false
        EntityNameEdit.Value := GetNextEntityName(EntityTypeDDL.Text)
        XEdit.Value := "0"
        YEdit.Value := "0"
        PlaceRoundEdit.Value := "0"
        PlaceDelayEdit.Value := "0"
        UpgradeEdit.Value := "000"
        UpgradeXEdit.Value := ""
        UpgradeYEdit.Value := ""
        ApplyDefaultTargetingForType(EntityTypeDDL.Text)
        RefreshEntityList()
        RefreshActionEntityDropdown()
        RefreshActionList()
        ResetBuilderEditors()
        MarkBuilderSaved()
        StatusText.Text := "Cleared"
        return true
    } finally {
        EndBuilderHistoryChange()
    }
}

BuildTemplateText() {
    global Entities, UpgradeActions
    global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL
    global ImportedStartRound, ImportedEndRound
    global WingmonkeyMKCheckbox

    if !ValidateBuilderModel()
        return ""

    q := Chr(34)
    functionName := SanitizeFunctionName(FunctionNameEdit.Value)
    mapName := EscapeAhkString(Trim(MapNameEdit.Value))
    category := EscapeAhkString(CategoryDDL.Text)
    difficulty := EscapeAhkString(DifficultyDDL.Text)
    gameMode := EscapeAhkString(ModeDDL.Text)
    isDeflation := gameMode = "Deflation"
    roundBounds := GetBuilderRoundBounds(DifficultyDDL.Text, ModeDDL.Text, ImportedStartRound, ImportedEndRound)
    roundError := GetBuilderRoundValidationError(Entities, UpgradeActions, roundBounds)
    if roundError != "" {
        MsgBox(roundError, "Strategy Builder - Check rounds", "Icon!")
        return ""
    }

    if isDeflation
        difficulty := "Easy"

    heroValue := "false"
    for entity in Entities {
        if entity.type = "Hero" {
            heroValue := q EscapeAhkString(entity.heroName) q
            break
        }
    }

    out := "#Requires AutoHotkey v2.0`r`n`r`n"
    out .= "#Include ..\..\..\..\Scripts\IncludeAll.ahk`r`n`r`n"
    out .= functionName "() {`r`n"
    out .= "    global RunConfig := {`r`n"
    out .= "        category: " q category q ",`r`n"
    out .= "        map: " q mapName q ",`r`n"
    out .= "        difficulty: " q difficulty q ",`r`n"
    out .= "        gameMode: " q gameMode q ",`r`n"
    out .= "        hero: " heroValue ",`r`n"
    out .= "        wingmonkeyMK: " (WingmonkeyMKCheckbox.Value ? "true" : "false") ",`r`n"
    ; Round 0 belongs to pregame actions; the tracker starts at the mode's first live round.
    out .= "        startRound: " roundBounds.startRound ",`r`n"
    out .= "        endRound: " roundBounds.endRound "`r`n"

    out .= "    }`r`n`r`n"

    out .= "    global TowerSetup := Map(`r`n"
    for index, entity in Entities {
        out .= BuildEntityBlock(entity)
        if index < Entities.Length
            out .= ","
        out .= "`r`n"
    }
    out .= "    )`r`n`r`n"

    ; Merge placement rows and scheduled actions into fresh records; sorting must not reorder the editor.
    allActions := []
    for entity in Entities {
        placeDelay := HasProp(entity, "placeDelay") ? entity.placeDelay : 0
        allActions.Push({kind: "place", entity: entity.name, round: entity.placeRound, delay: placeDelay})
    }

    for action in UpgradeActions {
        kind := HasProp(action, "kind") ? action.kind : "upgrade"

        if kind = "target" {
            item := {
                kind: "target",
                entity: action.entity,
                round: action.round,
                delay: action.delay,
                target: action.target
            }
            if HasProp(action, "targetX") {
                item.targetX := action.targetX
                item.targetY := action.targetY
            }
            if HasProp(action, "overrideX") {
                item.overrideX := action.overrideX
                item.overrideY := action.overrideY
            }
            allActions.Push(item)
        } else if kind = "sell" {
            item := {
                kind: "sell",
                entity: action.entity,
                round: action.round,
                delay: action.delay
            }
            if HasProp(action, "overrideX") {
                item.overrideX := action.overrideX
                item.overrideY := action.overrideY
            }
            allActions.Push(item)
        } else if kind = "ability" {
            allActions.Push({
                kind: "ability",
                round: action.round,
                delay: action.delay,
                hotkey: action.hotkey
            })
        } else if kind = "speed" {
            allActions.Push({
                kind: "speed",
                round: action.round,
                delay: action.delay,
                speed: action.speed
            })
        } else if kind = "bananaCollection" {
            allActions.Push({
                kind: "bananaCollection",
                round: action.round,
                delay: action.delay,
                enabled: action.enabled
            })
        } else if kind = "click" {
            allActions.Push({
                kind: "click", round: action.round, delay: action.delay,
                x: action.x, y: action.y, count: action.count, interval: action.interval
            })
        } else {
            item := {
                kind: "upgrade",
                entity: action.entity,
                round: action.round,
                delay: action.delay,
                upgrade: action.upgrade
            }
            if HasProp(action, "overrideX") {
                item.overrideX := action.overrideX
                item.overrideY := action.overrideY
            }
            allActions.Push(item)
        }
    }

    SortActions(allActions)

    out .= "    strategy := [`r`n"
    for index, action in allActions {
        if action.kind = "ability" {
            hotkey := EscapeAhkString(action.hotkey)
            out .= "        [" action.round ", " action.delay ", () => UseAbility(" q hotkey q ")]"
        } else if action.kind = "speed" {
            speedMode := EscapeAhkString(action.speed)
            out .= "        [" action.round ", " action.delay ", () => SetGameSpeed(" q speedMode q ")]"
        } else if action.kind = "bananaCollection" {
            helper := action.enabled ? "EnableBananaCollection" : "DisableBananaCollection"
            out .= "        [" action.round ", " action.delay ", () => " helper "()]"
        } else if action.kind = "click" {
            out .= "        [" action.round ", " action.delay ", () => RepeatMapClicks(" action.x ", " action.y ", " action.count ", " action.interval ")]"
        } else {
            entityName := EscapeAhkString(action.entity)

            if action.kind = "place" {
                out .= "        [" action.round ", " action.delay ", () => PlaceTower(TowerSetup[" q entityName q "])]"
            } else if action.kind = "target" {
                targetMode := EscapeAhkString(action.target)
                targetEntity := FindEntityByName(action.entity)

                ; Spike Factory targeting has its own helpers and its own destination coordinates.
                if targetEntity && targetEntity.type = "SpikeFactory" {
                    if action.target = "Set Target" && HasProp(action, "targetX") {
                        out .= "        [" action.round ", " action.delay ", () => SetSpikeFactoryTarget(TowerSetup[" q entityName q "], " action.targetX ", " action.targetY ")]"
                    } else {
                        out .= "        [" action.round ", " action.delay ", () => SetSpikeFactoryTargeting(TowerSetup[" q entityName q "], " q targetMode q ")]"
                    }
                } else {
                    out .= "        [" action.round ", " action.delay ", () => SetTargeting(TowerSetup[" q entityName q "], " q targetMode q
                    if HasProp(action, "overrideX")
                        out .= ", " action.overrideX ", " action.overrideY
                    out .= ")]"
                }
            } else if action.kind = "sell" {
                out .= "        [" action.round ", " action.delay ", () => SellTower(TowerSetup[" q entityName q "]"
                if HasProp(action, "overrideX")
                    out .= ", " action.overrideX ", " action.overrideY
                out .= ")]"
            } else {
                out .= "        [" action.round ", " action.delay ", () => UpgradeTower(TowerSetup[" q entityName q "], " q action.upgrade q
                if HasProp(action, "overrideX")
                    out .= ", " action.overrideX ", " action.overrideY
                out .= ")]"
            }
        }

        if index < allActions.Length
            out .= ","
        out .= "`r`n"
    }
    out .= "    ]`r`n`r`n"
    out .= "    return RunMapStrategy(strategy)`r`n"
    out .= "}`r`n`r`n"
    out .= functionName "()`r`n"

    return out
}

BuildEntityBlock(entity) {
    q := Chr(34)
    name := EscapeAhkString(entity.name)
    targeting := EscapeAhkString(entity.targeting)
    type := EscapeAhkString(entity.type)

    out := "        " q name q ", {`r`n"
    out .= "            type: " q type q ",`r`n"
    out .= "            x: " entity.x ",`r`n"
    out .= "            y: " entity.y ",`r`n"
    out .= "            placed: false,`r`n"
    out .= "            upgrades: [0, 0, 0],`r`n"
    out .= "            targeting: " q targeting q

    ; Submerge needs to remember the normal targeting mode for the next surface transition.
    if entity.type = "Sub" {
        out .= ",`r`n"
        out .= "            targetingBeforeSubmerge: " q targeting q ",`r`n"
        out .= "            submerged: false`r`n"
    } else {
        out .= "`r`n"
    }

    out .= "        }"
    return out
}

SortActions(actions) {
    ; Sort by round and delay, then put placements first at the same time.
    ; Equal non-placement actions keep their entry order, which can change what the strategy does.
    i := 2
    while i <= actions.Length {
        current := actions[i]
        j := i - 1

        while j >= 1 && ActionComesAfter(actions[j], current) {
            actions[j + 1] := actions[j]
            j -= 1
        }
        actions[j + 1] := current
        i += 1
    }
}

ActionComesAfter(a, b) {
    if a.round != b.round
        return a.round > b.round

    if a.delay != b.delay
        return a.delay > b.delay

    priorityA := a.kind = "place" ? 0 : 1
    priorityB := b.kind = "place" ? 0 : 1
    return priorityA > priorityB
}

FindEntityByName(name) {
    global Entities
    for entity in Entities {
        if entity.name = name
            return entity
    }
    return false
}

GetNextEntityName(type) {
    global Entities

    if type = "Hero"
        return "Hero"

    index := 1
    Loop {
        candidate := type " " NumberToLetters(index)
        exists := false

        for entity in Entities {
            if StrLower(entity.name) = StrLower(candidate) {
                exists := true
                break
            }
        }

        if !exists
            return candidate

        index += 1
    }
}

NumberToLetters(number) {
    result := ""
    while number > 0 {
        number -= 1
        result := Chr(65 + Mod(number, 26)) result
        number := Floor(number / 26)
    }
    return result
}

ChooseDropdownText(control, wanted) {
    ; Match a whole item, preserving the current selection if it is absent.
    ; Shared dark dropdowns expose their items instead of a native combo HWND.
    for index, item in control.Items {
        if item = wanted {
            control.Choose(index)
            return true
        }
    }
    return false
}


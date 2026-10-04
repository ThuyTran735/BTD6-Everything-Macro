#Requires AutoHotkey v2.0

; v3 file note: Turns the builder state into map-script text and handles copy/save/clear.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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

    if Trim(OutputEdit.Value) = "" {
        template := BuildTemplateText()
        if template = ""
            return
        OutputEdit.Value := template
    }

    A_Clipboard := OutputEdit.Value
    StatusText.Text := "Copied to clipboard"
}

SaveTemplate(*) {
    global OutputEdit, FunctionNameEdit, StatusText, MainGui

    if Trim(OutputEdit.Value) = "" {
        template := BuildTemplateText()
        if template = ""
            return
        OutputEdit.Value := template
    }

    defaultName := SanitizeFileName(FunctionNameEdit.Value) ".ahk"
    projectRoot := RegExReplace(A_ScriptDir, "i)\\Tools$")
    defaultPath := projectRoot "\Maps\" defaultName

    MainGui.Opt("-AlwaysOnTop")
    path := FileSelect("S16", defaultPath, "Save generated strategy", "AutoHotkey Script (*.ahk)")
    if path = ""
        return

    if !RegExMatch(path, "i)\.ahk$")
        path .= ".ahk"

    try {
        if FileExist(path)
            FileDelete(path)
        FileAppend(OutputEdit.Value, path, "UTF-8")
        StatusText.Text := "Saved: " path
        MsgBox("Strategy template saved to:`n" path, "Strategy Builder", "Iconi")
    } catch as err {
        MsgBox("Could not save the file.`n`n" err.Message, "Strategy Builder", "Iconx")
    }
}

ClearAll(*) {
    global Entities, UpgradeActions, OutputEdit, StatusText, EntityNameEdit, EntityTypeDDL, HeroDDL, TargetingDDL
    global PlaceRoundEdit, PlaceDelayEdit, XEdit, YEdit
    global ImportedStartRound, ImportedEndRound
    global WingmonkeyMKCheckbox, GameSpeedDDL

    result := MsgBox("Clear all monkeys, hero, scheduled actions, and generated output?", "Strategy Builder", "YesNo Icon?")
    if result != "Yes"
        return

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
    ApplyDefaultTargetingForType(EntityTypeDDL.Text)
    RefreshEntityList()
    RefreshActionEntityDropdown()
    RefreshActionList()
    StatusText.Text := "Cleared"
}

BuildTemplateText() {
    global Entities, UpgradeActions
    global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL
    global ImportedStartRound, ImportedEndRound
    global WingmonkeyMKCheckbox

    if Entities.Length = 0 {
        MsgBox("Add at least one monkey or hero before generating the template.", "Strategy Builder", "Icon!")
        return ""
    }

    q := Chr(34)
    functionName := SanitizeFunctionName(FunctionNameEdit.Value)
    mapName := EscapeAhkString(Trim(MapNameEdit.Value))
    category := EscapeAhkString(CategoryDDL.Text)
    difficulty := EscapeAhkString(DifficultyDDL.Text)
    gameMode := EscapeAhkString(ModeDDL.Text)
    isDeflation := gameMode = "Deflation"

    if isDeflation {
        difficulty := "Easy"
        if !ValidateDeflationRounds()
            return ""
    }

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
    out .= "        wingmonkeyMK: " (WingmonkeyMKCheckbox.Value ? "true" : "false")

    if isDeflation {
        out .= ",`r`n"
        out .= "        startRound: 31,`r`n"
        out .= "        endRound: 60`r`n"
    } else if ImportedStartRound != "" || ImportedEndRound != "" {
        out .= ",`r`n"
        if ImportedStartRound != ""
            out .= "        startRound: " ImportedStartRound ",`r`n"
        if ImportedEndRound != ""
            out .= "        endRound: " ImportedEndRound "`r`n"
    } else {
        out .= "`r`n"
    }

    out .= "    }`r`n`r`n"

    out .= "    global TowerSetup := Map(`r`n"
    for index, entity in Entities {
        out .= BuildEntityBlock(entity)
        if index < Entities.Length
            out .= ","
        out .= "`r`n"
    }
    out .= "    )`r`n`r`n"

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
        } else {
            entityName := EscapeAhkString(action.entity)

            if action.kind = "place" {
                out .= "        [" action.round ", " action.delay ", () => PlaceTower(TowerSetup[" q entityName q "])]"
            } else if action.kind = "target" {
                targetMode := EscapeAhkString(action.target)
                targetEntity := FindEntityByName(action.entity)

                if targetEntity && targetEntity.type = "SpikeFactory" {
                    if action.target = "Set Target" && HasProp(action, "targetX") {
                        out .= "        [" action.round ", " action.delay ", () => SetSpikeFactoryTarget(TowerSetup[" q entityName q "], " action.targetX ", " action.targetY ")]"
                    } else {
                        out .= "        [" action.round ", " action.delay ", () => SetSpikeFactoryTargeting(TowerSetup[" q entityName q "], " q targetMode q ")]"
                    }
                } else {
                    out .= "        [" action.round ", " action.delay ", () => SetTargeting(TowerSetup[" q entityName q "], " q targetMode q ")]"
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

ValidateDeflationRounds() {
    global Entities, UpgradeActions

    for entity in Entities {
        if !IsValidDeflationActionRound(entity.placeRound) {
            MsgBox(
                entity.name " has placement round " entity.placeRound ".`n`n"
                . "Deflation actions must use round 0 for pregame setup or rounds 31-60.",
                "Strategy Builder - Deflation",
                "Icon!"
            )
            return false
        }
    }

    for action in UpgradeActions {
        if !IsValidDeflationActionRound(action.round) {
            kind := HasProp(action, "kind") ? action.kind : "upgrade"

            if kind = "target" {
                value := action.target
                actionLabel := "targeting"
            } else if kind = "sell" {
                value := "sell"
                actionLabel := "sell"
            } else if kind = "ability" {
                value := action.hotkey
                actionLabel := "ability"
            } else if kind = "speed" {
                value := action.speed
                actionLabel := "game speed"
            } else {
                value := action.upgrade
                actionLabel := "upgrade"
            }

            entityLabel := HasProp(action, "entity") ? action.entity " " : ""
            MsgBox(
                entityLabel actionLabel " -> " value " uses round " action.round ".`n`n"
                . "Deflation actions must use round 0 for pregame setup or rounds 31-60.",
                "Strategy Builder - Deflation",
                "Icon!"
            )
            return false
        }
    }

    return true
}

IsValidDeflationActionRound(round) {
    return round = 0 || (round >= 31 && round <= 60)
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
    ; Stable insertion sort: round, delay, placement before upgrade.
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
    ; CB_FINDSTRINGEXACT returns a zero-based combo-box item index.
    ; Avoid unsupported Gui.DDL.GetCount() calls in AutoHotkey v2.
    itemIndex := DllCall("SendMessage", "Ptr", control.Hwnd, "UInt", 0x0158, "Ptr", -1, "Str", wanted, "Ptr")
    if itemIndex = -1
        return false

    control.Choose(itemIndex + 1)
    return true
}
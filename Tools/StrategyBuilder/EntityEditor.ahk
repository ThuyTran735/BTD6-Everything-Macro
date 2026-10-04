#Requires AutoHotkey v2.0

; v3 file note: Handles coordinate capture plus adding, editing, and deleting monkeys/heroes.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

CaptureCoordinatesInstant(*) {
    global XEdit, YEdit, StatusText

    MouseGetPos(&mx, &my)
    XEdit.Value := mx
    YEdit.Value := my
    StatusText.Text := "Captured: " mx ", " my
    ToolTip("Captured coordinates: " mx ", " my)
    SetTimer(() => ToolTip(), -800)
}

CaptureCoordinates(*) {
    global MainGui, XEdit, YEdit, StatusText

    StatusText.Text := "Move cursor and press F2..."
    MainGui.Hide()
    Sleep(150)
    ToolTip("Move the mouse to the desired BTD6 placement position.`nPress F2 to capture SCREEN coordinates.`nPress Esc to cancel.")

    Loop {
        if GetKeyState("Escape", "P") {
            KeyWait("Escape")
            ToolTip()
            MainGui.Show()
            StatusText.Text := "Coordinate capture cancelled"
            return
        }

        if GetKeyState("F2", "P") {
            MouseGetPos(&mx, &my)
            KeyWait("F2")
            ToolTip()
            XEdit.Value := mx
            YEdit.Value := my
            MainGui.Show()
            MainGui.Opt("+AlwaysOnTop")
            WinActivate("ahk_id " MainGui.Hwnd)
            SetTimer(() => MainGui.Opt("-AlwaysOnTop"), -250)
            StatusText.Text := "Captured: " mx ", " my
            return
        }

        Sleep(20)
    }
}


RemapAllPlacementCoordinates(*) {
    global MainGui, Entities, MonkeyOverlayVisible, StatusText

    if Entities.Length = 0 {
        MsgBox(
            "Import or add a strategy first. Remap mode only changes each monkey/hero X/Y coordinate.",
            "Strategy Builder",
            "Icon!"
        )
        return
    }

    result := MsgBox(
        "Remap every placement coordinate for this strategy?`n`n"
        . "This keeps the same monkeys, placement rounds, placement delays, upgrades, targeting, sells, abilities, speed actions, and action delays.`n`n"
        . "For each monkey/hero, move the mouse to its new map position and press F4. Press Esc at any time to cancel and restore all original coordinates.",
        "Strategy Builder - Remap X/Y",
        "YesNo Icon?"
    )

    if result != "Yes"
        return

    originalCoords := []
    for entity in Entities {
        originalCoords.Push({x: entity.x, y: entity.y})
    }

    overlayWasVisible := MonkeyOverlayVisible
    if overlayWasVisible
        HideMonkeyOverlay()

    MainGui.Hide()
    Sleep(150)

    for index, entity in Entities {
        ToolTip(
            "REMAP " index "/" Entities.Length "`n"
            . entity.name " (" entity.type ")`n`n"
            . "Move the mouse to the NEW placement spot and press F4.`n"
            . "Press Esc to cancel all remapped coordinates."
        )

        Loop {
            if GetKeyState("Escape", "P") {
                KeyWait("Escape")

                for restoreIndex, coords in originalCoords {
                    Entities[restoreIndex].x := coords.x
                    Entities[restoreIndex].y := coords.y
                }

                ToolTip()
                MainGui.Show()
                MainGui.Opt("+AlwaysOnTop")
                WinActivate("ahk_id " MainGui.Hwnd)
                SetTimer(() => MainGui.Opt("-AlwaysOnTop"), -250)
                RefreshEntityList()

                if overlayWasVisible
                    ShowMonkeyOverlay()

                StatusText.Text := "Coordinate remap cancelled; original X/Y restored"
                return
            }

            if GetKeyState("F4", "P") {
                MouseGetPos(&mx, &my)
                KeyWait("F4")

                Entities[index].x := mx
                Entities[index].y := my

                ToolTip("Saved " entity.name ": " mx ", " my)
                Sleep(180)
                break
            }

            Sleep(20)
        }
    }

    ToolTip()
    MainGui.Show()
    MainGui.Opt("+AlwaysOnTop")
    WinActivate("ahk_id " MainGui.Hwnd)
    SetTimer(() => MainGui.Opt("-AlwaysOnTop"), -250)

    RefreshEntityList()

    if overlayWasVisible
        ShowMonkeyOverlay()

    StatusText.Text := "Remapped " Entities.Length " placement X/Y values; rounds and scheduled actions preserved"
}

AddEntity(*) {
    global Entities, EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit, TargetingDDL
    global StatusText

    name := Trim(EntityNameEdit.Value)
    type := EntityTypeDDL.Text
    x := IntegerOrDefault(XEdit.Value, 0)
    y := IntegerOrDefault(YEdit.Value, 0)
    placeRound := IntegerOrDefault(PlaceRoundEdit.Value, 0)
    placeDelay := IntegerOrDefault(PlaceDelayEdit.Value, 0)
    targeting := TargetingDDL.Text
    heroName := type = "Hero" ? HeroDDL.Text : ""

    if name = "" {
        MsgBox("Enter a name for this monkey or hero.", "Strategy Builder", "Icon!")
        return
    }

    if x = 0 && y = 0 {
        result := MsgBox("Coordinates are still 0, 0. Add this entry anyway?", "Strategy Builder", "YesNo Icon?")
        if result != "Yes"
            return
    }

    for entity in Entities {
        if StrLower(entity.name) = StrLower(name) {
            MsgBox("An entry named '" name "' already exists.", "Strategy Builder", "Icon!")
            return
        }

        if type = "Hero" && entity.type = "Hero" {
            MsgBox("A strategy can only have one hero entry. Delete the existing hero first.", "Strategy Builder", "Icon!")
            return
        }
    }

    entity := {
        name: name,
        type: type,
        heroName: heroName,
        x: x,
        y: y,
        placeRound: placeRound,
        placeDelay: placeDelay,
        targeting: targeting
    }

    Entities.Push(entity)

    RefreshEntityList()
    RefreshActionEntityDropdown()
    RefreshMonkeyOverlayIfVisible()

    EntityNameEdit.Value := GetNextEntityName(type)
    HeroDDL.Enabled := (type = "Hero")
    XEdit.Value := "0"
    YEdit.Value := "0"
    ; Keep the last placement round so consecutive entries on the same
    ; round do not require re-entering it every time.
    PlaceRoundEdit.Value := placeRound
    PlaceDelayEdit.Value := "0"
    ApplyDefaultTargetingForType(type)
    StatusText.Text := "Added " name
}

LoadSelectedEntityForEdit(*) {
    global EntityLV, Entities
    global EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit, TargetingDDL
    global StatusText

    row := EntityLV.GetNext(0)
    if row = 0
        return

    entity := Entities[row]
    EntityNameEdit.Value := entity.name
    ChooseDropdownText(EntityTypeDDL, entity.type)
    HeroDDL.Enabled := entity.type = "Hero"

    if entity.type = "Hero" && entity.heroName != ""
        ChooseDropdownText(HeroDDL, entity.heroName)

    XEdit.Value := entity.x
    YEdit.Value := entity.y
    PlaceRoundEdit.Value := entity.placeRound
    PlaceDelayEdit.Value := HasProp(entity, "placeDelay") ? entity.placeDelay : 0
    ChooseDropdownText(TargetingDDL, entity.targeting)
    StatusText.Text := "Editing " entity.name
}

UpdateSelectedEntity(*) {
    global EntityLV, Entities, UpgradeActions
    global EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit, TargetingDDL
    global StatusText

    row := EntityLV.GetNext(0)
    if row = 0 {
        MsgBox("Select a monkey/hero first. Double-clicking its row will also load it into the editor.", "Strategy Builder", "Icon!")
        return
    }

    oldEntity := Entities[row]
    oldName := oldEntity.name
    name := Trim(EntityNameEdit.Value)
    type := EntityTypeDDL.Text
    x := IntegerOrDefault(XEdit.Value, 0)
    y := IntegerOrDefault(YEdit.Value, 0)
    placeRound := IntegerOrDefault(PlaceRoundEdit.Value, 0)
    placeDelay := IntegerOrDefault(PlaceDelayEdit.Value, 0)
    targeting := TargetingDDL.Text
    heroName := type = "Hero" ? HeroDDL.Text : ""

    if name = "" {
        MsgBox("Enter a name for this monkey or hero.", "Strategy Builder", "Icon!")
        return
    }

    for index, entity in Entities {
        if index = row
            continue

        if StrLower(entity.name) = StrLower(name) {
            MsgBox("An entry named '" name "' already exists.", "Strategy Builder", "Icon!")
            return
        }

        if type = "Hero" && entity.type = "Hero" {
            MsgBox("A strategy can only have one hero entry.", "Strategy Builder", "Icon!")
            return
        }
    }

    Entities[row] := {
        name: name,
        type: type,
        heroName: heroName,
        x: x,
        y: y,
        placeRound: placeRound,
        placeDelay: placeDelay,
        targeting: targeting
    }

    if name != oldName {
        for action in UpgradeActions {
            if HasProp(action, "entity") && action.entity = oldName
                action.entity := name
        }
    }

    RefreshEntityList()
    EntityLV.Modify(row, "Select Focus")
    RefreshActionEntityDropdown(name)
    RefreshActionList()
    RefreshMonkeyOverlayIfVisible()
    StatusText.Text := "Updated " name
}

DeleteSelectedEntity(*) {
    global EntityLV, Entities, UpgradeActions, StatusText
    global EntityTypeDDL, EntityNameEdit

    row := EntityLV.GetNext(0)
    if row = 0 {
        MsgBox("Select an entry to delete.", "Strategy Builder", "Icon!")
        return
    }

    removedName := Entities[row].name
    Entities.RemoveAt(row)

    ; Remove scheduled actions that belonged to the deleted monkey.
    i := UpgradeActions.Length
    while i >= 1 {
        if HasProp(UpgradeActions[i], "entity") && UpgradeActions[i].entity = removedName
            UpgradeActions.RemoveAt(i)
        i -= 1
    }

    RefreshEntityList()
    RefreshActionEntityDropdown()
    RefreshActionList()
    RefreshMonkeyOverlayIfVisible()
    EntityNameEdit.Value := GetNextEntityName(EntityTypeDDL.Text)
    StatusText.Text := "Deleted " removedName
}
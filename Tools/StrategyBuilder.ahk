#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\Scripts\Version.ahk

CoordMode("Mouse", "Screen")

; BTD6 Everything Macro - Strategy Builder / Coordinate Tool
; ---------------------------------------------------------
; Build TowerSetup + strategy actions without hand-writing coordinates.
; Press F2 at any time while this tool is open to instantly capture the current
; mouse position as the placement coordinates. The button is an alternate capture mode.

global Entities := []
global UpgradeActions := []
global NextMonkeyIndex := 1
global MainGui := false

global TowerTypes := [
    "Dart", "Boomerang", "Bomb", "Tack", "Ice", "Glue", "Desperado",
    "Sniper", "Sub", "Buccaneer", "Ace", "Heli", "Mortar", "Dartling",
    "Wizard", "Super", "Ninja", "Alchemist", "Druid", "Mermonkey", "Skywarden",
    "Farm", "SpikeFactory", "Village", "Engineer", "Hero"
]

global HeroNames := [
    "Quincy", "Gwendolin", "Striker Jones", "Obyn Greenfoot", "Dan D'Monke",
    "Benjamin", "Pat Fusty", "Captain Churchill", "Ezili", "Silas", "Etienne",
    "Sauda", "Rosalia", "Adora", "Admiral Brickell", "Psi", "Geraldo", "Corvus"
]

global CategoryChoices := ["Beginner", "Intermediate", "Advanced", "Expert"]
global DifficultyChoices := ["Easy", "Medium", "Hard", "Impoppable", "CHIMPS"]
global ModeChoices := ["Standard", "Primary Only", "Deflation", "Military Only", "Apopalypse", "Reverse", "Magic Monkeys Only", "Double HP MOABs", "Half Cash", "Alternate Bloons Rounds"]

global EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, TargetingDDL
global EntityLV, ActionEntityDDL, UpgradeEdit, UpgradeRoundEdit, UpgradeDelayEdit, ActionLV
global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL, OutputEdit, StatusText

BuildGui()

BuildGui() {
    global MainGui
    global EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, TargetingDDL
    global EntityLV, ActionEntityDDL, UpgradeEdit, UpgradeRoundEdit, UpgradeDelayEdit, ActionLV
    global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL, OutputEdit, StatusText
    global TowerTypes, HeroNames, CategoryChoices, DifficultyChoices, ModeChoices

    MainGui := Gui("+Resize +MinSize1040x720", "BTD6 Strategy Builder " . GetAppVersionLabel())
    MainGui.BackColor := "1E1E1E"
    MainGui.SetFont("s10 cF2F2F2", "Segoe UI")
    MainGui.OnEvent("Close", (*) => ExitApp())

    MainGui.SetFont("s16 w700 cFFFFFF")
    MainGui.AddText("x20 y14 w1000 h28", "BTD6 STRATEGY BUILDER + COORDINATE TOOL")
    MainGui.SetFont("s9 w400 cB7B7B7")
    MainGui.AddText("x20 y45 w1000 h20", "Add multiple monkeys or one hero, capture placement coordinates, schedule upgrades, then generate a ready-to-use map strategy template.")

    ; Map / strategy metadata
    MainGui.SetFont("s10 w700 cFFFFFF")
    MainGui.AddGroupBox("x20 y76 w1000 h100", " STRATEGY INFO ")
    MainGui.SetFont("s9 w400 cE8E8E8")

    MainGui.AddText("x40 y105 w80 h20", "Map Name")
    MapNameEdit := MainGui.AddEdit("x120 y101 w210 h26", "MAP NAME")
    SetEditTextBlack(MapNameEdit)

    MainGui.AddText("x350 y105 w85 h20", "Function")
    FunctionNameEdit := MainGui.AddEdit("x425 y101 w190 h26", "GeneratedMapStrategy")
    SetEditTextBlack(FunctionNameEdit)

    MainGui.AddText("x635 y105 w70 h20", "Category")
    CategoryDDL := MainGui.AddDropDownList("x700 y101 w140 Choose1", CategoryChoices)

    MainGui.AddText("x40 y141 w80 h20", "Difficulty")
    DifficultyDDL := MainGui.AddDropDownList("x120 y137 w150 Choose1", DifficultyChoices)

    MainGui.AddText("x290 y141 w55 h20", "Mode")
    ModeDDL := MainGui.AddDropDownList("x345 y137 w220 Choose1", ModeChoices)

    ; Entity builder
    MainGui.SetFont("s10 w700 cFFFFFF")
    MainGui.AddGroupBox("x20 y190 w500 h310", " MONKEY / HERO ")
    MainGui.SetFont("s9 w400 cE8E8E8")

    MainGui.AddText("x40 y220 w65 h20", "Name")
    EntityNameEdit := MainGui.AddEdit("x105 y216 w155 h26", "Monkey A")
    SetEditTextBlack(EntityNameEdit)

    MainGui.AddText("x275 y220 w45 h20", "Type")
    EntityTypeDDL := MainGui.AddDropDownList("x320 y216 w175 Choose1", TowerTypes)
    EntityTypeDDL.OnEvent("Change", OnEntityTypeChanged)

    MainGui.AddText("x40 y256 w65 h20", "Hero")
    HeroDDL := MainGui.AddDropDownList("x105 y252 w155 Choose1", HeroNames)
    HeroDDL.Enabled := false

    MainGui.AddText("x275 y256 w45 h20", "Target")
    TargetingDDL := MainGui.AddDropDownList("x320 y252 w175", ["First", "Last", "Close", "Strong", "Circle", "Figure Infinite", "Figure Eight", "Elite", "Normal", "Locked", "Target Independent", "Follow Mouse", "Lock in Place", "Patrol Points", "Pursuit", "Target"])
    TargetingDDL.Choose(1)

    MainGui.AddText("x40 y292 w65 h20", "X")
    XEdit := MainGui.AddEdit("x105 y288 w75 h26 ReadOnly", "0")
    SetEditTextBlack(XEdit)
    MainGui.AddText("x190 y292 w25 h20", "Y")
    YEdit := MainGui.AddEdit("x215 y288 w75 h26 ReadOnly", "0")
    SetEditTextBlack(YEdit)

    CaptureBtn := MainGui.AddButton("x305 y286 w190 h30", "CAPTURE COORDS (F2)")
    CaptureBtn.OnEvent("Click", CaptureCoordinates)

    MainGui.AddText("x40 y330 w90 h20", "Place Round")
    PlaceRoundEdit := MainGui.AddEdit("x130 y326 w70 h26 Number", "0")
    SetEditTextBlack(PlaceRoundEdit)
    MainGui.AddText("x215 y330 w275 h20 cAFAFAF", "Round 0 = pregame")

    AddEntityBtn := MainGui.AddButton("x40 y363 w220 h32", "ADD MONKEY / HERO")
    AddEntityBtn.OnEvent("Click", AddEntity)
    DeleteEntityBtn := MainGui.AddButton("x275 y363 w220 h32", "DELETE SELECTED")
    DeleteEntityBtn.OnEvent("Click", DeleteSelectedEntity)

    EntityLV := MainGui.AddListView("x40 y407 w455 h76 -Multi", ["Name", "Type", "Hero", "X", "Y", "Round"])
    EntityLV.ModifyCol(1, 105)
    EntityLV.ModifyCol(2, 75)
    EntityLV.ModifyCol(3, 95)
    EntityLV.ModifyCol(4, 45)
    EntityLV.ModifyCol(5, 45)
    EntityLV.ModifyCol(6, 50)

    ; Upgrade builder
    MainGui.SetFont("s10 w700 cFFFFFF")
    MainGui.AddGroupBox("x540 y190 w480 h310", " UPGRADE SCHEDULE ")
    MainGui.SetFont("s9 w400 cE8E8E8")

    MainGui.AddText("x560 y220 w60 h20", "Monkey")
    ActionEntityDDL := MainGui.AddDropDownList("x620 y216 w180", ["Add a monkey first"])

    MainGui.AddText("x815 y220 w70 h20", "Upgrade")
    UpgradeEdit := MainGui.AddEdit("x880 y216 w90 h26", "000")
    SetEditTextBlack(UpgradeEdit)

    MainGui.AddText("x560 y258 w45 h20", "Round")
    UpgradeRoundEdit := MainGui.AddEdit("x605 y254 w70 h26 Number", "0")
    SetEditTextBlack(UpgradeRoundEdit)

    MainGui.AddText("x695 y258 w65 h20", "Delay ms")
    UpgradeDelayEdit := MainGui.AddEdit("x760 y254 w80 h26 Number", "0")
    SetEditTextBlack(UpgradeDelayEdit)
    MainGui.AddText("x850 y258 w130 h20 cAFAFAF", "e.g. 002 / 024 / 520")

    AddUpgradeBtn := MainGui.AddButton("x560 y291 w200 h32", "ADD UPGRADE")
    AddUpgradeBtn.OnEvent("Click", AddUpgradeAction)
    DeleteUpgradeBtn := MainGui.AddButton("x775 y291 w200 h32", "DELETE SELECTED")
    DeleteUpgradeBtn.OnEvent("Click", DeleteSelectedUpgrade)

    ActionLV := MainGui.AddListView("x560 y336 w415 h147 -Multi", ["Monkey", "Upgrade", "Round", "Delay"])
    ActionLV.ModifyCol(1, 145)
    ActionLV.ModifyCol(2, 80)
    ActionLV.ModifyCol(3, 70)
    ActionLV.ModifyCol(4, 75)

    ; Output
    MainGui.SetFont("s10 w700 cFFFFFF")
    MainGui.AddGroupBox("x20 y515 w1000 h160", " GENERATED TEMPLATE ")
    MainGui.SetFont("s9 w400 cE8E8E8")

    GenerateBtn := MainGui.AddButton("x40 y544 w180 h32", "GENERATE TEMPLATE")
    GenerateBtn.OnEvent("Click", GenerateTemplate)
    CopyBtn := MainGui.AddButton("x235 y544 w160 h32", "COPY TO CLIPBOARD")
    CopyBtn.OnEvent("Click", CopyTemplate)
    SaveBtn := MainGui.AddButton("x410 y544 w160 h32", "SAVE .AHK")
    SaveBtn.OnEvent("Click", SaveTemplate)
    ClearBtn := MainGui.AddButton("x585 y544 w140 h32", "CLEAR ALL")
    ClearBtn.OnEvent("Click", ClearAll)

    StatusText := MainGui.AddText("x745 y550 w250 h22 cB7B7B7", "Ready")
    OutputEdit := MainGui.AddEdit("x40 y586 w955 h70 ReadOnly -Wrap VScroll", "")
    SetEditTextBlack(OutputEdit)

    MainGui.SetFont("s8 c9E9E9E")
    MainGui.AddText("x20 y687 w1000 h18", "Coordinate capture uses SCREEN coordinates. Press F2 anytime for an instant capture, or use CAPTURE COORDS for guided capture mode.")

    MainGui.Show("w1040 h720")
    Hotkey("F2", CaptureCoordinatesInstant, "On")
}

SetEditTextBlack(control) {
    control.SetFont("c000000", "Segoe UI")
}

OnEntityTypeChanged(*) {
    global EntityTypeDDL, HeroDDL, TargetingDDL, EntityNameEdit

    isHero := EntityTypeDDL.Text = "Hero"
    HeroDDL.Enabled := isHero

    if isHero {
        EntityNameEdit.Value := "Hero"
        TargetingDDL.Choose(1)
    } else {
        if EntityNameEdit.Value = "Hero"
            EntityNameEdit.Value := GetNextMonkeyName()

        if EntityTypeDDL.Text = "Ace"
            ChooseDropdownText(TargetingDDL, "Circle")
        else if EntityTypeDDL.Text = "Dartling"
            ChooseDropdownText(TargetingDDL, "Normal")
        else if EntityTypeDDL.Text = "Heli"
            ChooseDropdownText(TargetingDDL, "Follow Mouse")
        else if EntityTypeDDL.Text = "Mortar"
            ChooseDropdownText(TargetingDDL, "Target")
        else
            ChooseDropdownText(TargetingDDL, "First")
    }
}

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

AddEntity(*) {
    global Entities, EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, TargetingDDL
    global NextMonkeyIndex, StatusText

    name := Trim(EntityNameEdit.Value)
    type := EntityTypeDDL.Text
    x := IntegerOrDefault(XEdit.Value, 0)
    y := IntegerOrDefault(YEdit.Value, 0)
    placeRound := IntegerOrDefault(PlaceRoundEdit.Value, 0)
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
        targeting: targeting
    }

    Entities.Push(entity)

    if type != "Hero"
        NextMonkeyIndex += 1

    RefreshEntityList()
    RefreshActionEntityDropdown()

    EntityNameEdit.Value := GetNextMonkeyName()
    EntityTypeDDL.Choose(1)
    HeroDDL.Enabled := false
    XEdit.Value := "0"
    YEdit.Value := "0"
    PlaceRoundEdit.Value := "0"
    ChooseDropdownText(TargetingDDL, "First")
    StatusText.Text := "Added " name
}

DeleteSelectedEntity(*) {
    global EntityLV, Entities, UpgradeActions, StatusText

    row := EntityLV.GetNext(0)
    if row = 0 {
        MsgBox("Select an entry to delete.", "Strategy Builder", "Icon!")
        return
    }

    removedName := Entities[row].name
    Entities.RemoveAt(row)

    ; Remove upgrade actions that belonged to the deleted monkey.
    i := UpgradeActions.Length
    while i >= 1 {
        if UpgradeActions[i].entity = removedName
            UpgradeActions.RemoveAt(i)
        i -= 1
    }

    RefreshEntityList()
    RefreshActionEntityDropdown()
    RefreshActionList()
    StatusText.Text := "Deleted " removedName
}

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

    UpgradeActions.Push({entity: entityName, upgrade: upgrade, round: round, delay: delay})
    RefreshActionList()
    StatusText.Text := "Added " entityName " -> " upgrade " on round " round
}

DeleteSelectedUpgrade(*) {
    global ActionLV, UpgradeActions, StatusText

    row := ActionLV.GetNext(0)
    if row = 0 {
        MsgBox("Select an upgrade action to delete.", "Strategy Builder", "Icon!")
        return
    }

    UpgradeActions.RemoveAt(row)
    RefreshActionList()
    StatusText.Text := "Upgrade action deleted"
}

RefreshEntityList() {
    global EntityLV, Entities

    EntityLV.Delete()
    for entity in Entities {
        heroDisplay := entity.type = "Hero" ? entity.heroName : "-"
        EntityLV.Add("", entity.name, entity.type, heroDisplay, entity.x, entity.y, entity.placeRound)
    }
}

RefreshActionList() {
    global ActionLV, UpgradeActions

    ActionLV.Delete()
    for action in UpgradeActions
        ActionLV.Add("", action.entity, action.upgrade, action.round, action.delay)
}

RefreshActionEntityDropdown() {
    global ActionEntityDDL, Entities

    names := []
    for entity in Entities {
        if entity.type != "Hero"
            names.Push(entity.name)
    }

    ; CB_RESETCONTENT clears all items from a DropDownList/ComboBox.
    ; Gui.DropDownList does not expose GetCount() in AutoHotkey v2.
    DllCall("SendMessage", "Ptr", ActionEntityDDL.Hwnd, "UInt", 0x014B, "Ptr", 0, "Ptr", 0)

    if names.Length = 0 {
        ActionEntityDDL.Add(["Add a monkey first"])
        ActionEntityDDL.Choose(1)
        return
    }

    ActionEntityDDL.Add(names)
    ActionEntityDDL.Choose(1)
}

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
    global Entities, UpgradeActions, NextMonkeyIndex, OutputEdit, StatusText, EntityNameEdit

    result := MsgBox("Clear all monkeys, hero, upgrades, and generated output?", "Strategy Builder", "YesNo Icon?")
    if result != "Yes"
        return

    Entities := []
    UpgradeActions := []
    NextMonkeyIndex := 1
    OutputEdit.Value := ""
    EntityNameEdit.Value := "Monkey A"
    RefreshEntityList()
    RefreshActionEntityDropdown()
    RefreshActionList()
    StatusText.Text := "Cleared"
}

BuildTemplateText() {
    global Entities, UpgradeActions
    global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL

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

    heroValue := "false"
    for entity in Entities {
        if entity.type = "Hero" {
            heroValue := q EscapeAhkString(entity.heroName) q
            break
        }
    }

    out := "#Requires AutoHotkey v2.0`r`n`r`n"
    out .= "#Include ..\Scripts\IncludeAll.ahk`r`n`r`n"
    out .= functionName "() {`r`n"
    out .= "    global RunConfig := {`r`n"
    out .= "        category: " q category q ",`r`n"
    out .= "        map: " q mapName q ",`r`n"
    out .= "        difficulty: " q difficulty q ",`r`n"
    out .= "        gameMode: " q gameMode q ",`r`n"
    out .= "        hero: " heroValue ",`r`n"
    out .= "        wingmonkeyMK: false`r`n"
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
    for entity in Entities
        allActions.Push({kind: "place", entity: entity.name, round: entity.placeRound, delay: 0, upgrade: ""})

    for action in UpgradeActions
        allActions.Push({kind: "upgrade", entity: action.entity, round: action.round, delay: action.delay, upgrade: action.upgrade})

    SortActions(allActions)

    out .= "    strategy := [`r`n"
    for index, action in allActions {
        entityName := EscapeAhkString(action.entity)

        if action.kind = "place" {
            out .= "        [" action.round ", " action.delay ", () => PlaceTower(TowerSetup[" q entityName q "])]"
        } else {
            out .= "        [" action.round ", " action.delay ", () => UpgradeTower(TowerSetup[" q entityName q "], " q action.upgrade q ")]"
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

GetNextMonkeyName() {
    global NextMonkeyIndex
    return "Monkey " NumberToLetters(NextMonkeyIndex)
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

IntegerOrDefault(value, defaultValue := 0) {
    value := Trim(value)
    if value = ""
        return defaultValue
    try return Integer(value)
    catch
        return defaultValue
}

EscapeAhkString(text) {
    q := Chr(34)
    return StrReplace(text, q, q q)
}

SanitizeFunctionName(text) {
    text := Trim(text)
    if text = ""
        return "GeneratedMapStrategy"

    text := RegExReplace(text, "[^A-Za-z0-9_]", "")
    if text = ""
        return "GeneratedMapStrategy"

    if RegExMatch(SubStr(text, 1, 1), "\d")
        text := "Map" text

    return text
}

SanitizeFileName(text) {
    text := Trim(text)
    if text = ""
        return "GeneratedMapStrategy"
    text := RegExReplace(text, "[\\/:*?\x22<>|]", "_")
    return text
}
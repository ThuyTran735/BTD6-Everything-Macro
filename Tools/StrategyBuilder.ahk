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
global MainGui := false
global BuilderMinimizeControl := false
global BuilderCloseControl := false
global BuilderChromeMessageReady := false
global BuilderWindowBorder := false
global MonkeyOverlayWindows := []
global MonkeyOverlayVisible := false
global ImportedStartRound := ""
global ImportedEndRound := ""
global IsImportingStrategy := false

global TowerTypes := [
    "Dart", "Boomerang", "Bomb", "Tack", "Ice", "Glue", "Desperado",
    "Sniper", "Sub", "Buccaneer", "Ace", "Heli", "Mortar", "Dartling",
    "Wizard", "Super", "Ninja", "Alchemist", "Druid", "Mermonkey", "Skywarden",
    "Farm", "SpikeFactory", "Village", "Engineer", "Beast Handler", "Hero"
]

global HeroNames := [
    "Quincy", "Gwendolin", "Striker Jones", "Obyn Greenfoot", "Dan D'Monke",
    "Benjamin", "Pat Fusty", "Captain Churchill", "Ezili", "Silas", "Etienne",
    "Sauda", "Rosalia", "Adora", "Admiral Brickell", "Psi", "Geraldo", "Corvus"
]

global CategoryChoices := ["Beginner", "Intermediate", "Advanced", "Expert"]
global DifficultyChoices := ["Easy", "Medium", "Hard"]
global ModeChoicesByDifficulty := Map(
    "Easy", ["Standard", "Primary Only", "Deflation"],
    "Medium", ["Standard", "Military Only", "Apopalypse", "Reverse"],
    "Hard", ["Standard", "Magic Monkeys Only", "Double HP MOABs", "Half Cash", "Alternate Bloons Rounds", "Impoppable", "CHIMPS"]
)

global EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit, TargetingDDL
global EntityLV, ActionEntityDDL, UpgradeEdit, UpgradeRoundEdit, UpgradeDelayEdit, ActionTargetDDL, AbilityEdit, ActionLV
global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL, WingmonkeyMKCheckbox, OutputEdit, StatusText

BuildGui()

BuildGui() {
    global MainGui
    global BuilderMinimizeControl, BuilderCloseControl, BuilderChromeMessageReady, BuilderWindowBorder
    global EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit, TargetingDDL
    global EntityLV, ActionEntityDDL, UpgradeEdit, UpgradeRoundEdit, UpgradeDelayEdit, ActionTargetDDL, AbilityEdit, ActionLV
    global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL, WingmonkeyMKCheckbox, OutputEdit, StatusText
    global TowerTypes, HeroNames, CategoryChoices, DifficultyChoices, ModeChoicesByDifficulty

    MainGui := Gui("+Resize +MinSize1040x805 -Caption +Border", "BTD6 Strategy Builder " . GetAppVersionLabel())
    MainGui.BackColor := "0B0F14"
    MainGui.SetFont("s10 cF5F7FA", "Segoe UI")
    MainGui.OnEvent("Close", (*) => ExitApp())

    if !BuilderChromeMessageReady {
        OnMessage(0x84, StrategyBuilderChromeHitTest)
        BuilderChromeMessageReady := true
    }

    BuilderWindowBorder := CreateStrategyBuilderBorder(MainGui, 1040, 805)

    MainGui.SetFont("s16 w400 cFFD45C")
    MainGui.AddText("x20 y14 w920 h28", "BTD6 STRATEGY BUILDER + COORDINATE TOOL")

    MainGui.SetFont("s12 w400 c7F91A6")
    BuilderMinimizeControl := MainGui.AddText("x954 y12 w30 h28 Center +0x200", "-")
    BuilderMinimizeControl.OnEvent("Click", MinimizeStrategyBuilder)

    MainGui.SetFont("s11 w400 cFF6B7A")
    BuilderCloseControl := MainGui.AddText("x994 y12 w30 h28 Center +0x200", "X")
    BuilderCloseControl.OnEvent("Click", (*) => ExitApp())

    MainGui.OnEvent("Size", ResizeStrategyBuilderChrome)
    MainGui.SetFont("s9 w400 cB8C6D6")
    MainGui.AddText("x20 y45 w1000 h20", "Build, import, edit, label, and export map strategies with placements, upgrades, targeting, sells, and abilities.")

    ; Map / strategy metadata
    MainGui.SetFont("s10 w400 cD9E3EE")
    MainGui.AddGroupBox("x20 y76 w1000 h100", " STRATEGY INFO ")
    MainGui.SetFont("s9 w400 cD9E3EE")

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
    ModeDDL := MainGui.AddDropDownList("x345 y137 w220 Choose1", ModeChoicesByDifficulty["Easy"])
    DifficultyDDL.OnEvent("Change", OnDifficultyChanged)
    ModeDDL.OnEvent("Change", OnModeChanged)

    WingmonkeyMKCheckbox := MainGui.AddCheckBox("x590 y137 w150 h24", "Wingmonkey MK")

    ; Entity builder
    MainGui.SetFont("s10 w400 cD9E3EE")
    MainGui.AddGroupBox("x20 y190 w500 h350", " MONKEY / HERO ")
    MainGui.SetFont("s9 w400 cD9E3EE")

    MainGui.AddText("x40 y220 w65 h20", "Name")
    EntityNameEdit := MainGui.AddEdit("x105 y216 w155 h26", "Dart A")
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

    MainGui.AddText("x40 y330 w82 h20", "Place Round")
    PlaceRoundEdit := MainGui.AddEdit("x122 y326 w58 h26 Number", "0")
    SetEditTextBlack(PlaceRoundEdit)

    MainGui.AddText("x195 y330 w70 h20", "Delay ms")
    PlaceDelayEdit := MainGui.AddEdit("x260 y326 w70 h26 Number", "0")
    SetEditTextBlack(PlaceDelayEdit)
    MainGui.AddText("x345 y330 w145 h20 c7F91A6", "Round 0 = pregame")

    AddEntityBtn := MainGui.AddButton("x40 y363 w140 h32", "ADD")
    AddEntityBtn.OnEvent("Click", AddEntity)
    UpdateEntityBtn := MainGui.AddButton("x190 y363 w145 h32", "UPDATE SELECTED")
    UpdateEntityBtn.OnEvent("Click", UpdateSelectedEntity)
    DeleteEntityBtn := MainGui.AddButton("x345 y363 w150 h32", "DELETE SELECTED")
    DeleteEntityBtn.OnEvent("Click", DeleteSelectedEntity)

    EntityLV := MainGui.AddListView("x40 y407 w455 h88 -Multi", ["Name", "Type", "Hero", "X", "Y", "Round", "Delay", "Target"])
    EntityLV.ModifyCol(1, 88)
    EntityLV.ModifyCol(2, 64)
    EntityLV.ModifyCol(3, 70)
    EntityLV.ModifyCol(4, 40)
    EntityLV.ModifyCol(5, 40)
    EntityLV.ModifyCol(6, 45)
    EntityLV.ModifyCol(7, 48)
    EntityLV.ModifyCol(8, 58)
    EntityLV.OnEvent("DoubleClick", LoadSelectedEntityForEdit)

    OverlayBtn := MainGui.AddButton("x40 y502 w190 h28", "TOGGLE MONKEY LABELS")
    OverlayBtn.OnEvent("Click", ToggleMonkeyOverlay)
    MainGui.AddText("x245 y507 w245 h18 c7F91A6", "Double-click a row to load it for editing.")

    ; Scheduled action builder
    MainGui.SetFont("s10 w400 cD9E3EE")
    MainGui.AddGroupBox("x540 y190 w480 h350", " ACTION SCHEDULE ")
    MainGui.SetFont("s9 w400 cD9E3EE")

    MainGui.AddText("x560 y220 w60 h20", "Monkey")
    ActionEntityDDL := MainGui.AddDropDownList("x620 y216 w180", ["Add a monkey first"])
    ActionEntityDDL.OnEvent("Change", OnActionEntityChanged)

    MainGui.AddText("x815 y220 w45 h20", "Round")
    UpgradeRoundEdit := MainGui.AddEdit("x860 y216 w50 h26 Number", "0")
    SetEditTextBlack(UpgradeRoundEdit)

    MainGui.AddText("x920 y220 w38 h20", "Delay")
    UpgradeDelayEdit := MainGui.AddEdit("x960 y216 w45 h26 Number", "0")
    SetEditTextBlack(UpgradeDelayEdit)

    MainGui.AddText("x560 y258 w60 h20", "Upgrade")
    UpgradeEdit := MainGui.AddEdit("x620 y254 w90 h26", "000")
    SetEditTextBlack(UpgradeEdit)

    MainGui.AddText("x730 y258 w45 h20", "Target")
    ActionTargetDDL := MainGui.AddDropDownList("x775 y254 w200", ["First", "Last", "Close", "Strong"])
    ActionTargetDDL.Choose(1)

    MainGui.AddText("x560 y294 w60 h20", "Ability")
    AbilityEdit := MainGui.AddEdit("x620 y290 w90 h26", "1")
    SetEditTextBlack(AbilityEdit)
    MainGui.AddText("x730 y294 w245 h20 c7F91A6", "Ability hotkey, e.g. 1, 2, 3")

    AddUpgradeBtn := MainGui.AddButton("x560 y327 w98 h30", "ADD UPGRADE")
    AddUpgradeBtn.OnEvent("Click", AddUpgradeAction)
    AddTargetBtn := MainGui.AddButton("x664 y327 w90 h30", "ADD TARGET")
    AddTargetBtn.OnEvent("Click", AddTargetingAction)
    AddSellBtn := MainGui.AddButton("x760 y327 w90 h30", "ADD SELL")
    AddSellBtn.OnEvent("Click", AddSellAction)
    AddAbilityBtn := MainGui.AddButton("x856 y327 w119 h30", "ADD ABILITY")
    AddAbilityBtn.OnEvent("Click", AddAbilityAction)

    DeleteActionBtn := MainGui.AddButton("x560 y363 w415 h28", "DELETE SELECTED ACTION")
    DeleteActionBtn.OnEvent("Click", DeleteSelectedUpgrade)

    ActionLV := MainGui.AddListView("x560 y400 w415 h122 -Multi", ["Type", "Monkey", "Value", "Round", "Delay"])
    ActionLV.ModifyCol(1, 66)
    ActionLV.ModifyCol(2, 100)
    ActionLV.ModifyCol(3, 90)
    ActionLV.ModifyCol(4, 65)
    ActionLV.ModifyCol(5, 65)

    ; Output
    MainGui.SetFont("s10 w400 cD9E3EE")
    MainGui.AddGroupBox("x20 y555 w1000 h190", " GENERATED TEMPLATE ")
    MainGui.SetFont("s9 w400 cD9E3EE")

    GenerateBtn := MainGui.AddButton("x40 y584 w150 h32", "GENERATE TEMPLATE")
    GenerateBtn.OnEvent("Click", GenerateTemplate)
    ImportBtn := MainGui.AddButton("x200 y584 w130 h32", "IMPORT .AHK")
    ImportBtn.OnEvent("Click", ImportStrategyScript)
    CopyBtn := MainGui.AddButton("x340 y584 w145 h32", "COPY")
    CopyBtn.OnEvent("Click", CopyTemplate)
    SaveBtn := MainGui.AddButton("x495 y584 w130 h32", "SAVE .AHK")
    SaveBtn.OnEvent("Click", SaveTemplate)
    ClearBtn := MainGui.AddButton("x635 y584 w120 h32", "CLEAR ALL")
    ClearBtn.OnEvent("Click", ClearAll)

    StatusText := MainGui.AddText("x770 y590 w225 h22 cB8C6D6", "Ready")
    OutputEdit := MainGui.AddEdit("x40 y630 w955 h95 ReadOnly -Wrap VScroll", "")
    SetEditTextBlack(OutputEdit)

    MainGui.SetFont("s8 c7F91A6")
    MainGui.AddText("x20 y765 w1000 h18", "F2 captures SCREEN coordinates. Monkey labels are click-through overlays at each configured placement coordinate.")

    MainGui.Show("w1040 h805")
    Hotkey("F2", CaptureCoordinatesInstant, "On")
}
SetEditTextBlack(control) {
    control.SetFont("c000000", "Segoe UI")
}

OnDifficultyChanged(*) {
    global DifficultyDDL, ModeDDL

    difficulty := DifficultyDDL.Text
    previousMode := ModeDDL.Text

    RefreshModeChoicesForDifficulty(
        difficulty,
        previousMode
    )

    OnModeChanged()
}

RefreshModeChoicesForDifficulty(
    difficulty,
    preferredMode := "Standard"
) {
    global ModeDDL
    global ModeChoicesByDifficulty

    if !ModeChoicesByDifficulty.Has(difficulty)
        return false

    ModeDDL.Delete()
    ModeDDL.Add(
        ModeChoicesByDifficulty[difficulty]
    )

    if !ChooseDropdownText(
        ModeDDL,
        preferredMode
    ) {
        ModeDDL.Choose(1)
    }

    return true
}

OnModeChanged(*) {
    global ModeDDL, DifficultyDDL, StatusText
    global ImportedStartRound, ImportedEndRound, IsImportingStrategy

    if !IsImportingStrategy {
        ImportedStartRound := ""
        ImportedEndRound := ""
    }

    if ModeDDL.Text = "Deflation" {
        ChooseDropdownText(DifficultyDDL, "Easy")
        DifficultyDDL.Enabled := false
        StatusText.Text := "Deflation: Easy | Rounds 31-60 | Round 0 = pregame"
    } else {
        DifficultyDDL.Enabled := true
        StatusText.Text := "Ready"
    }
}

OnEntityTypeChanged(*) {
    global EntityTypeDDL, HeroDDL, TargetingDDL, EntityNameEdit

    type := EntityTypeDDL.Text
    isHero := type = "Hero"
    HeroDDL.Enabled := isHero
    EntityNameEdit.Value := GetNextEntityName(type)

    ApplyDefaultTargetingForType(type)
}

ApplyDefaultTargetingForType(type) {
    global TargetingDDL

    if type = "Ace"
        ChooseDropdownText(TargetingDDL, "Circle")
    else if type = "Dartling"
        ChooseDropdownText(TargetingDDL, "Normal")
    else if type = "Heli"
        ChooseDropdownText(TargetingDDL, "Follow Mouse")
    else if type = "Mortar"
        ChooseDropdownText(TargetingDDL, "Target")
    else
        ChooseDropdownText(TargetingDDL, "First")
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
    PlaceRoundEdit.Value := "0"
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
    global Entities, UpgradeActions, ActionEntityDDL, ActionTargetDDL, UpgradeRoundEdit, UpgradeDelayEdit, StatusText

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

    UpgradeActions.Push({kind: "target", entity: entityName, target: targetMode, round: round, delay: delay})
    RefreshActionList()
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
            ActionLV.Add("", "Target", action.entity, action.target, action.round, action.delay)
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
    global Entities, UpgradeActions, OutputEdit, StatusText, EntityNameEdit, EntityTypeDDL, HeroDDL, TargetingDDL
    global PlaceRoundEdit, PlaceDelayEdit, XEdit, YEdit
    global ImportedStartRound, ImportedEndRound
    global WingmonkeyMKCheckbox

    result := MsgBox("Clear all monkeys, hero, scheduled actions, and generated output?", "Strategy Builder", "YesNo Icon?")
    if result != "Yes"
        return

    HideMonkeyOverlay()
    Entities := []
    UpgradeActions := []
    ImportedStartRound := ""
    ImportedEndRound := ""
    WingmonkeyMKCheckbox.Value := 0
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
    out .= "#Include ..\Scripts\IncludeAll.ahk`r`n`r`n"
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
            allActions.Push({
                kind: "target",
                entity: action.entity,
                round: action.round,
                delay: action.delay,
                target: action.target
            })
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
        } else {
            entityName := EscapeAhkString(action.entity)

            if action.kind = "place" {
                out .= "        [" action.round ", " action.delay ", () => PlaceTower(TowerSetup[" q entityName q "])]"
            } else if action.kind = "target" {
                targetMode := EscapeAhkString(action.target)
                out .= "        [" action.round ", " action.delay ", () => SetTargeting(TowerSetup[" q entityName q "], " q targetMode q ")]"
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
    return "First"
}

FindEntityByNameInArray(entities, name) {
    for entity in entities {
        if entity.name = name
            return entity
    }
    return false
}

ToggleMonkeyOverlay(*) {
    global MonkeyOverlayVisible

    if MonkeyOverlayVisible {
        HideMonkeyOverlay()
        return
    }

    ShowMonkeyOverlay()
}

ShowMonkeyOverlay() {
    global Entities, MonkeyOverlayWindows, MonkeyOverlayVisible, StatusText

    HideMonkeyOverlay()

    if Entities.Length = 0 {
        MsgBox("Add or import at least one monkey first.", "Strategy Builder", "Icon!")
        return false
    }

    for entity in Entities {
        overlay := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        overlay.BackColor := "010203"
        overlay.SetFont("s10 w600 cFFD45C", "Segoe UI")
        overlay.AddText("x0 y0 w20 h26 Center +0x200", "+")
        overlay.AddText("x20 y0 w175 h26 +0x200", entity.name " (" entity.type ")")

        overlayX := entity.x - 10
        overlayY := entity.y - 13
        overlay.Show("NA x" overlayX " y" overlayY " w195 h26")
        WinSetTransColor("010203", "ahk_id " overlay.Hwnd)
        MonkeyOverlayWindows.Push(overlay)
    }

    MonkeyOverlayVisible := true
    StatusText.Text := "Showing " Entities.Length " monkey label(s)"
    return true
}

HideMonkeyOverlay(*) {
    global MonkeyOverlayWindows, MonkeyOverlayVisible

    for overlay in MonkeyOverlayWindows {
        try overlay.Destroy()
    }

    MonkeyOverlayWindows := []
    MonkeyOverlayVisible := false
    return true
}

RefreshMonkeyOverlayIfVisible() {
    global MonkeyOverlayVisible

    if MonkeyOverlayVisible
        ShowMonkeyOverlay()
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

StrategyBuilderChromeHitTest(wParam, lParam, msg, hwnd) {
    global MainGui

    if !MainGui {
        return
    }

    rootHwnd := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")

    if !rootHwnd {
        rootHwnd := hwnd
    }

    if rootHwnd != MainGui.Hwnd {
        return
    }

    rect := Buffer(16, 0)

    if !DllCall("GetWindowRect", "Ptr", rootHwnd, "Ptr", rect.Ptr, "Int") {
        return
    }

    left := NumGet(rect, 0, "Int")
    top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int")

    screenX := lParam & 0xFFFF
    screenY := (lParam >> 16) & 0xFFFF

    if screenX >= 0x8000 {
        screenX -= 0x10000
    }

    if screenY >= 0x8000 {
        screenY -= 0x10000
    }

    clientX := screenX - left
    clientY := screenY - top
    windowWidth := right - left

    if (
        clientY >= 0
        && clientY < 68
        && clientX >= 0
        && clientX < windowWidth - 96
    ) {
        return 2
    }
}


CreateStrategyBuilderBorder(guiObject, width, height) {
    borderColor := "263241"
    thickness := 4

    top := guiObject.Add(
        "Progress",
        "x0 y0 w" . width . " h" . thickness
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    bottom := guiObject.Add(
        "Progress",
        "x0 y" . (height - thickness) . " w" . width . " h" . thickness
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    left := guiObject.Add(
        "Progress",
        "x0 y0 w" . thickness . " h" . height
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )
    right := guiObject.Add(
        "Progress",
        "x" . (width - thickness) . " y0 w" . thickness . " h" . height
        . " c" . borderColor . " Background" . borderColor . " Disabled",
        100
    )

    return {
        Top: top,
        Bottom: bottom,
        Left: left,
        Right: right,
        Thickness: thickness
    }
}


ResizeStrategyBuilderBorder(border, width, height) {
    if !IsObject(border) {
        return
    }

    thickness := border.Thickness
    try border.Top.Move(0, 0, width, thickness)
    try border.Bottom.Move(0, height - thickness, width, thickness)
    try border.Left.Move(0, 0, thickness, height)
    try border.Right.Move(width - thickness, 0, thickness, height)
}


MinimizeStrategyBuilder(*) {
    global MainGui

    if MainGui {
        WinMinimize("ahk_id " . MainGui.Hwnd)
    }
}


ResizeStrategyBuilderChrome(guiObject, minMax, width, height) {
    global BuilderMinimizeControl
    global BuilderCloseControl
    global BuilderWindowBorder

    if minMax = -1 {
        return
    }

    try BuilderMinimizeControl.Move(width - 86, 12, 30, 28)
    try BuilderCloseControl.Move(width - 46, 12, 30, 28)
    ResizeStrategyBuilderBorder(BuilderWindowBorder, width, height)
}
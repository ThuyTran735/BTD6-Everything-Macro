#Requires AutoHotkey v2.0

; v3 file note: Builds the main Strategy Builder window and keeps the basic form state in one spot.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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
global EntityLV, ActionEntityDDL, UpgradeEdit, UpgradeRoundEdit, UpgradeDelayEdit, ActionTargetDDL, ActionTargetXEdit, ActionTargetYEdit, AbilityEdit, ActionLV
global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL, WingmonkeyMKCheckbox, OutputEdit, StatusText

BuildGui()

BuildGui() {
    global MainGui
    global BuilderMinimizeControl, BuilderCloseControl, BuilderChromeMessageReady, BuilderWindowBorder
    global EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit, TargetingDDL
    global EntityLV, ActionEntityDDL, UpgradeEdit, UpgradeRoundEdit, UpgradeDelayEdit, ActionTargetDDL, ActionTargetXEdit, ActionTargetYEdit, AbilityEdit, ActionLV
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
    TargetingDDL := MainGui.AddDropDownList("x320 y252 w175", ["First", "Last", "Close", "Strong", "Circle", "Figure Infinite", "Figure Eight", "Elite", "Normal", "Smart", "Set Target", "Automatic", "Locked", "Target Independent", "Follow Mouse", "Lock in Place", "Patrol Points", "Pursuit", "Target"])
    TargetingDDL.Choose(1)

    MainGui.AddText("x40 y292 w65 h20", "X")
    XEdit := MainGui.AddEdit("x105 y288 w75 h26 Number", "0")
    SetEditTextBlack(XEdit)
    MainGui.AddText("x190 y292 w25 h20", "Y")
    YEdit := MainGui.AddEdit("x215 y288 w75 h26 Number", "0")
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
    ActionTargetDDL := MainGui.AddDropDownList("x775 y254 w115", ["First", "Last", "Close", "Strong"])
    ActionTargetDDL.Choose(1)
    ActionTargetDDL.OnEvent("Change", OnActionTargetChanged)

    MainGui.AddText("x898 y258 w12 h20", "X")
    ActionTargetXEdit := MainGui.AddEdit("x910 y254 w42 h26 Number", "0")
    SetEditTextBlack(ActionTargetXEdit)
    ActionTargetXEdit.Enabled := false

    MainGui.AddText("x958 y258 w12 h20", "Y")
    ActionTargetYEdit := MainGui.AddEdit("x970 y254 w42 h26 Number", "0")
    SetEditTextBlack(ActionTargetYEdit)
    ActionTargetYEdit.Enabled := false

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
    else if type = "SpikeFactory"
        ChooseDropdownText(TargetingDDL, "Normal")
    else
        ChooseDropdownText(TargetingDDL, "First")
}
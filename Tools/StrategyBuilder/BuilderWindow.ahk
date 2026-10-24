#Requires AutoHotkey v2.0

; Keeps the builder form and shared editor state together.
; Both editor panels use the same row spacing so related fields line up.

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
global EntityLV, ActionEntityDDL, UpgradeEdit, UpgradeXEdit, UpgradeYEdit, UpgradeRoundEdit, UpgradeDelayEdit, ActionTargetDDL, ActionTargetXEdit, ActionTargetYEdit, AbilityEdit, GameSpeedDDL, ActionLV
global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL, WingmonkeyMKCheckbox, OutputEdit, StatusText

BuildGui()

BuildGui() {
    global MainGui
    global BuilderMinimizeControl, BuilderCloseControl, BuilderChromeMessageReady, BuilderWindowBorder
    global EntityNameEdit, EntityTypeDDL, HeroDDL, XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit, TargetingDDL
    global EntityLV, ActionEntityDDL, UpgradeEdit, UpgradeXEdit, UpgradeYEdit, UpgradeRoundEdit, UpgradeDelayEdit, ActionTargetDDL, ActionTargetXEdit, ActionTargetYEdit, AbilityEdit, GameSpeedDDL, ActionLV
    global MapNameEdit, FunctionNameEdit, CategoryDDL, DifficultyDDL, ModeDDL, WingmonkeyMKCheckbox, OutputEdit, StatusText
    global TowerTypes, HeroNames, CategoryChoices, DifficultyChoices, ModeChoicesByDifficulty

    MainGui := Gui("+Resize +MinSize1040x790 -Caption +Border", "BTD6 Strategy Builder " . GetAppVersionLabel())
    MainGui.BackColor := "0D1117"
    MainGui.SetFont("s10 Norm cF4F7FB", "Segoe UI")
    MainGui.OnEvent("Close", (*) => ExitApp())

    if !BuilderChromeMessageReady {
        OnMessage(0x84, StrategyBuilderChromeHitTest)
        BuilderChromeMessageReady := true
    }

    BuilderWindowBorder := CreateStrategyBuilderBorder(MainGui, 1040, 790)

    MainGui.SetFont("s16 Norm cF4F7FB")
    MainGui.AddText("x24 y16 w900 h28", "Strategy Builder")

    MainGui.SetFont("s12 Norm c7D8B9C")
    BuilderMinimizeControl := MainGui.AddText("x954 y12 w30 h28 Center +0x200", "-")
    BuilderMinimizeControl.OnEvent("Click", MinimizeStrategyBuilder)

    MainGui.SetFont("s11 Norm cFF6B7A")
    BuilderCloseControl := MainGui.AddText("x994 y12 w30 h28 Center +0x200", "X")
    BuilderCloseControl.OnEvent("Click", (*) => ExitApp())

    MainGui.OnEvent("Size", ResizeStrategyBuilderChrome)
    MainGui.SetFont("s9 Norm cB3BFCC")
    MainGui.AddText("x24 y48 w992 h20", "Create, import, and export strategies. Capture coordinates and schedule placements, upgrades, targeting, abilities, and banana collection.")

    ; Metadata applies to every exported placement and action.
    MainGui.SetFont("s10 Norm cD8E0E8")
    MainGui.AddGroupBox("x24 y80 w992 h96", " Strategy details ")
    MainGui.SetFont("s9 Norm cD8E0E8")

    MainGui.AddText("x44 y108 w68 h20", "Map Name")
    MapNameEdit := MainGui.AddEdit("x112 y104 w208 h26", "MAP NAME")
    StyleBuilderEdit(MapNameEdit)

    MainGui.AddText("x340 y108 w68 h20", "Function")
    FunctionNameEdit := MainGui.AddEdit("x408 y104 w208 h26", "GeneratedMapStrategy")
    StyleBuilderEdit(FunctionNameEdit)

    MainGui.AddText("x636 y108 w68 h20", "Category")
    CategoryDDL := MainGui.AddDropDownList("x704 y104 w160 Choose1", CategoryChoices)

    MainGui.AddText("x44 y144 w68 h20", "Difficulty")
    DifficultyDDL := MainGui.AddDropDownList("x112 y140 w208 Choose1", DifficultyChoices)

    MainGui.AddText("x340 y144 w68 h20", "Mode")
    ModeDDL := MainGui.AddDropDownList("x408 y140 w208 Choose1", ModeChoicesByDifficulty["Easy"])
    DifficultyDDL.OnEvent("Change", OnDifficultyChanged)
    ModeDDL.OnEvent("Change", OnModeChanged)

    WingmonkeyMKCheckbox := MainGui.AddCheckBox("x636 y140 w180 h26", "Wingmonkey MK")

    ; The placement list keeps selection for update/delete.
    MainGui.SetFont("s10 Norm cD8E0E8")
    MainGui.AddGroupBox("x24 y188 w488 h376", " Monkeys and heroes ")
    MainGui.SetFont("s9 Norm cD8E0E8")

    MainGui.AddText("x44 y214 w68 h20", "Name")
    EntityNameEdit := MainGui.AddEdit("x112 y210 w148 h26", "Dart A")
    StyleBuilderEdit(EntityNameEdit)

    MainGui.AddText("x280 y214 w40 h20", "Type")
    EntityTypeDDL := MainGui.AddDropDownList("x320 y210 w172 Choose1", TowerTypes)
    EntityTypeDDL.OnEvent("Change", OnEntityTypeChanged)

    MainGui.AddText("x44 y250 w68 h20", "Hero")
    HeroDDL := MainGui.AddDropDownList("x112 y246 w148 Choose1", HeroNames)
    HeroDDL.Enabled := false

    MainGui.AddText("x280 y250 w40 h20", "Target")
    TargetingDDL := MainGui.AddDropDownList("x320 y246 w172", ["First", "Last", "Close", "Strong", "Circle", "Figure Infinite", "Figure Eight", "Elite", "Normal", "Smart", "Set Target", "Automatic", "Locked", "Target Independent", "Follow Mouse", "Lock in Place", "Patrol Points", "Pursuit", "Target"])
    TargetingDDL.Choose(1)

    MainGui.AddText("x44 y286 w68 h20", "X")
    XEdit := MainGui.AddEdit("x112 y282 w68 h26 Number", "0")
    StyleBuilderEdit(XEdit)
    MainGui.AddText("x192 y286 w16 h20", "Y")
    YEdit := MainGui.AddEdit("x212 y282 w68 h26 Number", "0")
    StyleBuilderEdit(YEdit)

    CaptureBtn := MainGui.AddButton("x296 y280 w196 h30", "Capture coordinates (F2)")
    CaptureBtn.OnEvent("Click", CaptureCoordinates)

    MainGui.AddText("x44 y322 w78 h20", "Place Round")
    PlaceRoundEdit := MainGui.AddEdit("x122 y318 w58 h26 Number", "0")
    StyleBuilderEdit(PlaceRoundEdit)

    MainGui.AddText("x192 y322 w64 h20", "Delay ms")
    PlaceDelayEdit := MainGui.AddEdit("x256 y318 w72 h26 Number", "0")
    StyleBuilderEdit(PlaceDelayEdit)
    MainGui.AddText("x340 y322 w152 h20 c7D8B9C", "Round 0 = pregame")

    AddEntityBtn := MainGui.AddButton("x44 y354 w136 h32", "Add monkey")
    AddEntityBtn.OnEvent("Click", AddEntity)
    UpdateEntityBtn := MainGui.AddButton("x192 y354 w144 h32", "Update selected")
    UpdateEntityBtn.OnEvent("Click", UpdateSelectedEntity)
    DeleteEntityBtn := MainGui.AddButton("x348 y354 w144 h32", "Delete selected")
    DeleteEntityBtn.OnEvent("Click", DeleteSelectedEntity)

    EntityLV := MainGui.AddListView("x44 y398 w448 h116 -Multi", ["Name", "Type", "Hero", "X", "Y", "Round", "Delay", "Target"])
    EntityLV.ModifyCol(1, 88)
    EntityLV.ModifyCol(2, 64)
    EntityLV.ModifyCol(3, 70)
    EntityLV.ModifyCol(4, 40)
    EntityLV.ModifyCol(5, 40)
    EntityLV.ModifyCol(6, 45)
    EntityLV.ModifyCol(7, 48)
    EntityLV.ModifyCol(8, 58)
    EntityLV.OnEvent("DoubleClick", LoadSelectedEntityForEdit)

    OverlayBtn := MainGui.AddButton("x44 y526 w218 h28", "Toggle monkey labels")
    OverlayBtn.OnEvent("Click", ToggleMonkeyOverlay)

    RemapCoordsBtn := MainGui.AddButton("x274 y526 w218 h28", "Remap all coordinates")
    RemapCoordsBtn.OnEvent("Click", RemapAllPlacementCoordinates)

    ; All action types read the same round and delay fields.
    MainGui.SetFont("s10 Norm cD8E0E8")
    MainGui.AddGroupBox("x528 y188 w488 h376", " Action schedule ")
    MainGui.SetFont("s9 Norm cD8E0E8")

    MainGui.AddText("x548 y214 w64 h20", "Monkey")
    ActionEntityDDL := MainGui.AddDropDownList("x612 y210 w172", ["Add a monkey first"])
    ActionEntityDDL.OnEvent("Change", OnActionEntityChanged)

    MainGui.AddText("x800 y214 w44 h20", "Round")
    UpgradeRoundEdit := MainGui.AddEdit("x844 y210 w52 h26 Number", "0")
    StyleBuilderEdit(UpgradeRoundEdit)

    MainGui.AddText("x908 y214 w40 h20", "Delay")
    UpgradeDelayEdit := MainGui.AddEdit("x948 y210 w48 h26 Number", "0")
    StyleBuilderEdit(UpgradeDelayEdit)

    MainGui.AddText("x548 y250 w64 h20", "Upgrade")
    UpgradeEdit := MainGui.AddEdit("x612 y246 w68 h26", "000")
    StyleBuilderEdit(UpgradeEdit)

    MainGui.AddText("x692 y250 w40 h20", "Upg X")
    UpgradeXEdit := MainGui.AddEdit("x732 y246 w56 h26 Number", "")
    StyleBuilderEdit(UpgradeXEdit)

    MainGui.AddText("x800 y250 w16 h20", "Y")
    UpgradeYEdit := MainGui.AddEdit("x820 y246 w56 h26 Number", "")
    StyleBuilderEdit(UpgradeYEdit)

    CaptureUpgradeBtn := MainGui.AddButton("x888 y244 w108 h30", "Capture (F3)")
    CaptureUpgradeBtn.OnEvent("Click", CaptureUpgradeCoordinates)

    MainGui.AddText("x548 y286 w64 h20", "Target")
    ActionTargetDDL := MainGui.AddDropDownList("x612 y282 w156", ["First", "Last", "Close", "Strong"])
    ActionTargetDDL.Choose(1)
    ActionTargetDDL.OnEvent("Change", OnActionTargetChanged)

    MainGui.AddText("x780 y286 w16 h20", "X")
    ActionTargetXEdit := MainGui.AddEdit("x800 y282 w56 h26 Number", "")
    StyleBuilderEdit(ActionTargetXEdit)
    ActionTargetXEdit.Enabled := false

    MainGui.AddText("x868 y286 w16 h20", "Y")
    ActionTargetYEdit := MainGui.AddEdit("x888 y282 w56 h26 Number", "")
    StyleBuilderEdit(ActionTargetYEdit)
    ActionTargetYEdit.Enabled := false

    CaptureTargetBtn := MainGui.AddButton("x956 y280 w40 h30", "F5")
    CaptureTargetBtn.OnEvent("Click", CaptureTargetCoordinates)

    MainGui.AddText("x548 y322 w64 h20", "Ability")
    AbilityEdit := MainGui.AddEdit("x612 y318 w84 h26", "1")
    StyleBuilderEdit(AbilityEdit)

    MainGui.AddText("x712 y322 w48 h20", "Speed")
    GameSpeedDDL := MainGui.AddDropDownList("x760 y318 w116", ["Normal", "Fast"])
    GameSpeedDDL.Choose(1)
    AddSpeedBtn := MainGui.AddButton("x888 y316 w108 h30", "Add speed")
    AddSpeedBtn.OnEvent("Click", AddGameSpeedAction)

    AddUpgradeBtn := MainGui.AddButton("x548 y354 w106 h32", "Add upgrade")
    AddUpgradeBtn.OnEvent("Click", AddUpgradeAction)
    AddTargetBtn := MainGui.AddButton("x662 y354 w106 h32", "Add target")
    AddTargetBtn.OnEvent("Click", AddTargetingAction)
    AddSellBtn := MainGui.AddButton("x776 y354 w106 h32", "Add sell")
    AddSellBtn.OnEvent("Click", AddSellAction)
    AddAbilityBtn := MainGui.AddButton("x890 y354 w106 h32", "Add ability")
    AddAbilityBtn.OnEvent("Click", AddAbilityAction)

    FarmOnBtn := MainGui.AddButton("x548 y394 w218 h28", "Enable banana collection")
    FarmOnBtn.OnEvent("Click", AddBananaCollectionEnableAction)
    FarmOffBtn := MainGui.AddButton("x778 y394 w218 h28", "Disable banana collection")
    FarmOffBtn.OnEvent("Click", AddBananaCollectionDisableAction)

    DeleteActionBtn := MainGui.AddButton("x548 y430 w448 h28", "Delete selected action")
    DeleteActionBtn.OnEvent("Click", DeleteSelectedUpgrade)

    ActionLV := MainGui.AddListView("x548 y470 w448 h84 -Multi", ["Type", "Monkey", "Value", "Round", "Delay"])
    ActionLV.ModifyCol(1, 66)
    ActionLV.ModifyCol(2, 100)
    ActionLV.ModifyCol(3, 90)
    ActionLV.ModifyCol(4, 65)
    ActionLV.ModifyCol(5, 65)

    ; Leave status a full line so import and validation messages remain readable.
    MainGui.SetFont("s10 Norm cD8E0E8")
    MainGui.AddGroupBox("x24 y576 w992 h174", " Generated template ")
    MainGui.SetFont("s9 Norm cD8E0E8")

    GenerateBtn := MainGui.AddButton("x44 y602 w152 h32", "Generate template")
    GenerateBtn.OnEvent("Click", GenerateTemplate)
    ImportBtn := MainGui.AddButton("x208 y602 w136 h32", "Import .AHK")
    ImportBtn.OnEvent("Click", ImportStrategyScript)
    CopyBtn := MainGui.AddButton("x356 y602 w136 h32", "Copy")
    CopyBtn.OnEvent("Click", CopyTemplate)
    SaveBtn := MainGui.AddButton("x504 y602 w136 h32", "Save .AHK")
    SaveBtn.OnEvent("Click", SaveTemplate)
    ClearBtn := MainGui.AddButton("x652 y602 w136 h32", "Clear all")
    ClearBtn.OnEvent("Click", ClearAll)

    StatusText := MainGui.AddText("x44 y724 w952 h20 cB3BFCC", "Ready")
    OutputEdit := MainGui.AddEdit("x44 y646 w952 h68 ReadOnly -Wrap VScroll", "")
    StyleBuilderEdit(OutputEdit)
    OutputEdit.SetFont("s9 Norm", "Consolas")

    MainGui.SetFont("s8 c7D8B9C")
    MainGui.AddText("x24 y760 w992 h18", "F2 = placement. F3 = moving upgrade. F4 = remap. F5 = targeting coords / moving target click override.")

    StyleBuilderNativeControls(MainGui)
    MainGui.Show("w1040 h790")
    Hotkey("F2", CaptureCoordinatesInstant, "On")
    Hotkey("F3", CaptureUpgradeCoordinatesInstant, "On")
    Hotkey("F5", CaptureTargetCoordinatesInstant, "On")
}
; Keep typed values readable against the dark input surface, including the read-only preview.
StyleBuilderEdit(control) {
    control.SetFont("s9 Norm cF4F7FB", "Segoe UI")
    control.Opt("Background10161D")
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

    ; A manual mode change starts fresh; loading an import keeps its explicit round bounds.
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
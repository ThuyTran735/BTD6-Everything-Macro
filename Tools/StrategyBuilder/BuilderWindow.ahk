#Requires AutoHotkey v2.0

; The three workspaces share the same editor data. Hidden controls keep their
; values, so switching views never changes a strategy or its action order.
CoordMode("Mouse", "Screen")

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
global BuilderEditingActionIndex := 0
global BuilderEditingAction := false
global BuilderEditingEntity := false
global BuilderView := "Monkeys"
global BuilderGroups := Map("Monkeys", [], "Actions", [], "Export", [])
global BuilderActionFields := Map()
global BuilderLayoutItems := []
global BuilderButtons := Map()
global BuilderEditFrames := Map()
global BuilderHelpBadges := Map()
global BuilderHeaders := Map()
global BuilderTabs := Map()
global BuilderHeadingFont := LoadBuilderHeadingFont()
global BuilderBuildGroup := ""
global BuilderLayoutDepth := 0
global BuilderRedrawPaused := false
global BuilderActionTypeDDL, BuilderActionSaveButton, BuilderEntitySaveButton
global BuilderActionHint, BuilderRowMenuButton, BuilderHelpGui := false
global BuilderRoundHint

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

; Tray Exit and Reload need the same cleanup as the window's close button.
OnExit(CleanupStrategyBuilder)
BuildGui()

BuildGui() {
    global
    MainGui := Gui("+Resize +MinSize1040x744 -Caption -Border", "BTD6 Strategy Builder " . GetAppVersionLabel())
    MainGui.BackColor := "0D1117"
    MainGui.SetFont("s9 Norm cF4F7FB", "Segoe UI")
    MainGui.OnEvent("Close", CloseStrategyBuilder)
    if !BuilderChromeMessageReady {
        OnMessage(0x84, StrategyBuilderChromeHitTest)
        OnMessage(0x83, StrategyBuilderClientArea)
        OnMessage(0x85, StrategyBuilderFramePaint)
        OnMessage(0x86, StrategyBuilderFramePaint)
        OnMessage(0x138, StrategyBuilderCheckboxColor)
        OnMessage(0x135, StrategyBuilderCheckboxColor)
        OnMessage(0x231, CloseBuilderDropdowns)
        BuilderChromeMessageReady := true
    }
    ; Recalculate the native frame now that our client-area handler is active.
    DisableBuilderNativeFrame(MainGui)
    DllCall("SetWindowPos", "Ptr", MainGui.Hwnd, "Ptr", 0,
        "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x27)
    BuilderWindowBorder := CreateStrategyBuilderBorder(MainGui, 1040, 744)
    MainGui.OnEvent("Size", ResizeStrategyBuilderChrome)

    BuilderHeading("STRATEGY BUILDER", 24, 18, 570, 30, 18)
    BuilderLabel("Create a strategy, one step at a time.  |  " . GetAppVersionLabel(), 24, 51, 570, 20, "93A1B2")
    BuilderButton("TOOLS", 784, 22, 100, 34, ShowBuilderTools, false, 1)
    BuilderButton("?", 894, 22, 34, 34, ShowBuilderHelp, false, 1)
    BuilderMinimizeControl := BuilderButton("-", 940, 22, 34, 34, MinimizeStrategyBuilder, false, 1)
    BuilderCloseControl := BuilderButton("X", 984, 22, 32, 34, CloseStrategyBuilder, false, 1)

    BuilderPanel(24, 82, 992, 114, 1)
    BuilderLabel("MAP NAME", 40, 94, 240, 18)
    MapNameEdit := BuilderEdit(40, 114, 240, "MAP NAME")
    BuilderLabel("CATEGORY", 296, 94, 160, 18)
    CategoryDDL := BuilderDDL(296, 114, 160, CategoryChoices)
    BuilderLabel("DIFFICULTY", 472, 94, 144, 18)
    DifficultyDDL := BuilderDDL(472, 114, 144, DifficultyChoices)
    DifficultyDDL.OnEvent("Change", OnDifficultyChanged)
    BuilderLabel("GAME MODE", 632, 94, 368, 18)
    ModeDDL := BuilderDDL(632, 114, 368, ModeChoicesByDifficulty["Easy"])
    BuilderAnchor(ModeDDL, 632, 114, 368, 32, 0, 0, 1)
    ModeDDL.OnEvent("Change", OnModeChanged)
    BuilderLabel("Function", 40, 161, 96, 18, "93A1B2")
    FunctionNameEdit := BuilderEdit(140, 156, 316, "GeneratedMapStrategy")
    MainGui.SetFont("s9 Norm cD8E0E8", "Segoe UI")
    WingmonkeyMKCheckbox := BuilderControl(MainGui.AddCheckBox("x472 y156 w210 h26 cD8E0E8", "Wingmonkey knowledge"))
    AddBuilderHelpBadge(WingmonkeyMKCheckbox, "Wingmonkey knowledge", 682, 161)
    BuilderRoundHint := BuilderLabel("Round 0 = pregame setup", 728, 161, 272, 18, "93A1B2")
    BuilderRoundHint.Text := "Rounds 1-40 | 0 = setup"

    ; Share the full content width, keeping the same gaps when the window grows.
    for index, viewName in ["Monkeys", "Actions", "Import", "Export"] {
        tabX := 24 + (index - 1) * 252
        callback := viewName = "Import" ? ImportBuilderStrategy : ShowBuilderView.Bind(viewName)
        tab := BuilderButton(StrUpper(viewName), tabX, 212, 236, 36, callback, false, (index - 1) / 4, 0, 0.25)
        if viewName != "Import"
            BuilderTabs[viewName] := tab
    }

    BuilderBuildGroup := "Monkeys"
    BuilderPanel(24, 264, 328, 398, 0, 1)
    BuilderPanel(368, 264, 648, 398, 1, 1)
    BuilderHeading("MONKEY DETAILS", 40, 280, 296, 24)
    BuilderLabel("Name", 40, 312, 296, 18)
    EntityNameEdit := BuilderEdit(40, 332, 296, "Dart A")
    BuilderLabel("Type", 40, 372, 140, 18)
    EntityTypeDDL := BuilderDDL(40, 392, 140, TowerTypes)
    EntityTypeDDL.OnEvent("Change", OnEntityTypeChanged)
    BuilderLabel("Hero", 196, 372, 140, 18)
    HeroDDL := BuilderDDL(196, 392, 140, HeroNames)
    HeroDDL.Enabled := false
    BuilderLabel("Starting targeting", 40, 432, 296, 18)
    TargetingDDL := BuilderDDL(40, 452, 296, ["First", "Last", "Close", "Strong", "Circle", "Figure Infinite", "Figure Eight", "Elite", "Normal", "Smart", "Set Target", "Automatic", "Locked", "Target Independent", "Follow Mouse", "Lock in Place", "Patrol Points", "Pursuit", "Target"])
    BuilderLabel("Place X", 40, 492, 72, 18)
    XEdit := BuilderEdit(40, 512, 72, "0", "Number")
    BuilderLabel("Y", 128, 492, 68, 18)
    YEdit := BuilderEdit(128, 512, 68, "0", "Number")
    BuilderButton("F2 CAPTURE", 212, 510, 124, 30, CaptureCoordinates)
    BuilderLabel("Place round", 40, 552, 136, 18)
    PlaceRoundEdit := BuilderEdit(40, 572, 136, "0", "Number")
    BuilderLabel("Delay (ms)", 200, 552, 136, 18)
    PlaceDelayEdit := BuilderEdit(200, 572, 136, "0", "Number")
    BuilderEntitySaveButton := BuilderButton("ADD MONKEY", 40, 616, 184, 32, SaveBuilderEntity, true, 0, 1)
    BuilderButton("NEW", 236, 616, 100, 32, NewBuilderEntity, false, 0, 1)
    BuilderHeading("PLACEMENTS", 384, 280, 380, 24)
    BuilderButton("ROW OPTIONS", 864, 278, 136, 28, ShowBuilderEntityMenu, false, 1)
    EntityLV := BuilderControl(MainGui.AddListView("x384 y316 w616 h296 -Multi NoSortHdr", ["Name", "Type", "Hero", "X", "Y", "Round", "Delay", "Target"]))
    SendMessage(0x1036, 0x10000, 0x10000, EntityLV)
    BuilderAnchor(EntityLV, 384, 316, 616, 296, 0, 0, 1, 1)
    for index, width in [104, 86, 80, 46, 46, 54, 60, 110]
        EntityLV.ModifyCol(index, width)
    RegisterBuilderListHeader(EntityLV, ["Name", "Type", "Hero", "X", "Y", "Round", "Delay", "Target"])
    EntityLV.OnEvent("DoubleClick", EditBuilderEntity)
    EntityLV.OnEvent("ContextMenu", ShowBuilderEntityMenu)
    BuilderLabel("Double-click a row to edit. Row options contains edit and delete.", 384, 632, 616, 18, "93A1B2", 0, 1, 1)

    BuilderBuildGroup := "Actions"
    BuilderPanel(24, 264, 328, 398, 0, 1)
    BuilderPanel(368, 264, 648, 398, 1, 1)
    BuilderHeading("ACTION DETAILS", 40, 280, 296, 24)
    BuilderLabel("Action type", 40, 312, 296, 18)
    BuilderActionTypeDDL := BuilderDDL(40, 332, 296, ["Upgrade", "Targeting", "Sell", "Ability", "Game speed", "Enable banana collection", "Disable banana collection"])
    BuilderActionTypeDDL.OnEvent("Change", RefreshBuilderActionForm)
    entityLabel := BuilderLabel("Monkey", 40, 372, 296, 18)
    ActionEntityDDL := BuilderDDL(40, 392, 296, ["Add a monkey first"])
    ActionEntityDDL.OnEvent("Change", OnActionEntityChanged)
    BuilderActionFields["entity"] := [entityLabel, ActionEntityDDL]
    BuilderLabel("Round", 40, 432, 136, 18)
    UpgradeRoundEdit := BuilderEdit(40, 452, 136, "0", "Number")
    BuilderLabel("Delay (ms)", 200, 432, 136, 18)
    UpgradeDelayEdit := BuilderEdit(200, 452, 136, "0", "Number")
    upLabel := BuilderLabel("Upgrade path (for example, 024)", 40, 492, 296, 18)
    UpgradeEdit := BuilderEdit(40, 512, 296, "000")
    BuilderActionFields["upgrade"] := [upLabel, UpgradeEdit]
    uxLabel := BuilderLabel("Tower X", 40, 552, 72, 18)
    UpgradeXEdit := BuilderEdit(40, 572, 72, "", "Number")
    uyLabel := BuilderLabel("Y", 128, 552, 68, 18)
    UpgradeYEdit := BuilderEdit(128, 572, 68, "", "Number")
    upCapture := BuilderButton("F3 CAPTURE", 212, 570, 124, 30, CaptureUpgradeCoordinates)
    BuilderActionFields["override"] := [uxLabel, UpgradeXEdit, uyLabel, UpgradeYEdit, upCapture]
    tLabel := BuilderLabel("Targeting mode", 40, 492, 296, 18)
    ActionTargetDDL := BuilderDDL(40, 512, 296, ["First", "Last", "Close", "Strong"])
    ActionTargetDDL.OnEvent("Change", OnActionTargetChanged)
    txLabel := BuilderLabel("Target X", 40, 552, 72, 18)
    ActionTargetXEdit := BuilderEdit(40, 572, 72, "", "Number")
    tyLabel := BuilderLabel("Y", 128, 552, 68, 18)
    ActionTargetYEdit := BuilderEdit(128, 572, 68, "", "Number")
    targetCapture := BuilderButton("F5 CAPTURE", 212, 570, 124, 30, CaptureTargetCoordinates)
    BuilderActionFields["target"] := [tLabel, ActionTargetDDL, txLabel, ActionTargetXEdit, tyLabel, ActionTargetYEdit, targetCapture]
    abilityLabel := BuilderLabel("Ability hotkey", 40, 492, 296, 18)
    AbilityEdit := BuilderEdit(40, 512, 296, "1")
    BuilderActionFields["ability"] := [abilityLabel, AbilityEdit]
    speedLabel := BuilderLabel("Game speed", 40, 492, 296, 18)
    GameSpeedDDL := BuilderDDL(40, 512, 296, ["Normal", "Fast"])
    BuilderActionFields["speed"] := [speedLabel, GameSpeedDDL]
    BuilderActionHint := BuilderLabel("", 40, 552, 296, 46, "93A1B2")
    BuilderActionFields["hint"] := [BuilderActionHint]
    BuilderActionSaveButton := BuilderButton("ADD ACTION", 40, 616, 184, 32, SaveBuilderAction, true, 0, 1)
    BuilderButton("NEW", 236, 616, 100, 32, NewBuilderAction, false, 0, 1)
    BuilderHeading("SCHEDULED ACTIONS", 384, 280, 400, 24)
    BuilderButton("ROW OPTIONS", 864, 278, 136, 28, ShowBuilderActionMenu, false, 1)
    ActionLV := BuilderControl(MainGui.AddListView("x384 y316 w616 h296 -Multi NoSortHdr", ["Type", "Monkey", "Value", "Round", "Delay"]))
    SendMessage(0x1036, 0x10000, 0x10000, ActionLV)
    BuilderAnchor(ActionLV, 384, 316, 616, 296, 0, 0, 1, 1)
    for index, width in [90, 146, 206, 76, 76]
        ActionLV.ModifyCol(index, width)
    RegisterBuilderListHeader(ActionLV, ["Type", "Monkey", "Value", "Round", "Delay"])
    ActionLV.OnEvent("DoubleClick", LoadSelectedActionForEdit)
    ActionLV.OnEvent("ContextMenu", ShowBuilderActionMenu)
    BuilderLabel("Double-click to edit. Actions at the same round and delay keep their order.", 384, 632, 616, 18, "93A1B2", 0, 1, 1)

    BuilderBuildGroup := "Export"
    BuilderPanel(24, 264, 992, 398, 1, 1)
    BuilderHeading("STRATEGY PREVIEW", 40, 280, 600, 24)
    BuilderButton("GENERATE", 584, 278, 132, 32, GenerateTemplate, false, 1)
    BuilderButton("COPY", 728, 278, 108, 32, CopyTemplate, false, 1)
    BuilderButton("SAVE .AHK", 848, 278, 152, 32, SaveTemplate, true, 1)
    BuilderPanel(39, 325, 962, 286, 1, 1)
    OutputEdit := BuilderControl(MainGui.AddEdit("x40 y326 w960 h284 ReadOnly -Wrap HScroll VScroll -Border -E0x200", ""))
    StyleBuilderEdit(OutputEdit)
    OutputEdit.SetFont("s9 Norm", "Consolas")
    BuilderAnchor(OutputEdit, 40, 326, 960, 284, 0, 0, 1, 1)
    BuilderLabel("Copy and Save always regenerate from your current strategy. Nothing runs from this preview.", 40, 632, 960, 18, "93A1B2", 0, 1, 1)
    BuilderBuildGroup := ""
    StatusText := BuilderLabel("Ready - add a monkey or import an existing strategy.", 24, 682, 992, 20, "B3BFCC", 0, 1, 1)
    BuilderLabel("F2  Placement     F3  Moving tower     F5  Target point     Tools  Labels / remap / clear", 24, 716, 992, 18, "93A1B2", 0, 1, 1)

    StyleBuilderNativeControls(MainGui)
    ShowBuilderView("Monkeys")
    MainGui.Show("w1040 h744")
    Hotkey("F2", CaptureCoordinatesInstant, "On")
    Hotkey("F3", CaptureUpgradeCoordinatesInstant, "On")
    Hotkey("F5", CaptureTargetCoordinatesInstant, "On")
}

ShowBuilderView(view, *) {
    global BuilderView, BuilderGroups, BuilderTabs, MainGui, UIDarkActiveDropdown
    if IsObject(UIDarkActiveDropdown)
        UIDarkActiveDropdown.Close()
    BeginBuilderLayout()
    try {
    BuilderView := view
    for name, controls in BuilderGroups
        for control in controls
            control.Visible := name = view
    for name, tab in BuilderTabs {
        tab.Style := name = view ? "ToggleOn" : "Normal"
        tab.ShowRestState()
    }
    if view = "Actions"
        RefreshBuilderActionForm()
    } finally EndBuilderLayout()
}

RefreshBuilderActionForm(*) {
    global BuilderView, BuilderActionFields, BuilderActionTypeDDL, BuilderActionHint
    global ActionEntityDDL, Entities
    if !IsSet(BuilderActionTypeDDL)
        return
    BeginBuilderLayout()
    try {
    kind := BuilderActionTypeDDL.Text
    fields := ["entity"]
    if kind = "Upgrade"
        fields.Push("upgrade", "override")
    else if kind = "Targeting"
        fields.Push("target")
    else if kind = "Sell"
        fields.Push("override")
    else {
        fields := ["hint"]
        if kind = "Ability" {
            fields.Push("ability")
            BuilderActionHint.Text := "Uses the ability hotkey from BTD6. No monkey selection is needed."
        } else if kind = "Game speed" {
            fields.Push("speed")
            BuilderActionHint.Text := "Use a live round within this mode's range. Round 0 is pregame setup."
        } else
            BuilderActionHint.Text := "Applies to all eligible Banana Farms during idle strategy time."
    }
    for key, controls in BuilderActionFields {
        shown := false
        for wanted in fields
            if wanted = key
                shown := true
        for control in controls
            SetBuilderFieldVisible(control, BuilderView = "Actions" && shown)
    }
    ActionEntityDDL.Enabled := Entities.Length > 0
    RefreshActionTargetCoordinateState()
    } finally EndBuilderLayout()
}

SaveBuilderEntity(*) {
    global BuilderEditingEntity, Entities, EntityLV, BuilderEntitySaveButton
    if !ValidateBuilderEntityInputs()
        return
    if IsObject(BuilderEditingEntity) {
        for index, entity in Entities {
            if entity = BuilderEditingEntity {
                EntityLV.Modify(0, "-Select")
                EntityLV.Modify(index, "Select Focus")
                UpdateSelectedEntity()
                if Entities[index] != entity
                    NewBuilderAction()
                BuilderEditingEntity := Entities[index]
                return
            }
        }
    }
    previousCount := Entities.Length
    AddEntity()
    if Entities.Length > previousCount
        NewBuilderAction()
}

EditBuilderEntity(*) {
    global EntityLV, Entities, BuilderEditingEntity, BuilderEntitySaveButton
    row := EntityLV.GetNext()
    if !row
        return
    BuilderEditingEntity := Entities[row]
    LoadSelectedEntityForEdit()
    BuilderEntitySaveButton.Text := "SAVE CHANGES"
}

NewBuilderEntity(*) {
    global BuilderEditingEntity, BuilderEntitySaveButton, EntityLV
    global EntityTypeDDL, EntityNameEdit, XEdit, YEdit, PlaceDelayEdit
    BuilderEditingEntity := false
    BuilderEntitySaveButton.Text := "ADD MONKEY"
    EntityLV.Modify(0, "-Select")
    EntityNameEdit.Value := GetNextEntityName(EntityTypeDDL.Text)
    XEdit.Value := "0"
    YEdit.Value := "0"
    PlaceDelayEdit.Value := "0"
    ApplyDefaultTargetingForType(EntityTypeDDL.Text)
}

ValidateBuilderEntityInputs() {
    global XEdit, YEdit, PlaceRoundEdit, PlaceDelayEdit
    for pair in [[XEdit, "Placement X", 1919], [YEdit, "Placement Y", 1079], [PlaceRoundEdit, "Place round", 2147483647], [PlaceDelayEdit, "Placement delay", 2147483647]] {
        text := Trim(pair[1].Value)
        if !RegExMatch(text, "^\d+$") || text + 0 > pair[3] {
            MsgBox(pair[2] . " must be a whole number from 0 to " . pair[3] . ".", "Strategy Builder", "Icon!")
            pair[1].Focus()
            return false
        }
    }
    return true
}

ShowBuilderEntityMenu(*) {
    menu := Menu()
    menu.Add("Edit selected monkey", EditBuilderEntity)
    menu.Add("Delete selected monkey and its actions", DeleteBuilderEntity)
    menu.Show()
}

DeleteBuilderEntity(*) {
    global EntityLV
    if !EntityLV.GetNext()
        return
    DeleteSelectedEntity()
    NewBuilderAction()
    NewBuilderEntity()
}

ShowBuilderActionMenu(*) {
    menu := Menu()
    menu.Add("Edit selected action", LoadSelectedActionForEdit)
    menu.Add("Delete selected action", DeleteSelectedUpgrade)
    menu.Show()
}

ShowBuilderTools(*) {
    menu := Menu()
    menu.Add("Show / hide monkey labels", ToggleMonkeyOverlay)
    menu.Add("Remap all placement coordinates", RemapAllPlacementCoordinates)
    menu.Add()
    menu.Add("Clear strategy", ClearBuilderStrategy)
    menu.Show()
}

ImportBuilderStrategy(*) {
    global Entities
    previousEntities := Entities
    ImportStrategyScript()
    if Entities != previousEntities
        ResetBuilderEditors()
}

ClearBuilderStrategy(*) {
    global Entities
    previousEntities := Entities
    ClearAll()
    if Entities != previousEntities
        ResetBuilderEditors()
}

ResetBuilderEditors() {
    NewBuilderEntity()
    NewBuilderAction()
    RefreshBuilderRoundHint()
}

CloseStrategyBuilder(*) {
    ExitApp()
}

CleanupStrategyBuilder(*) {
    global BuilderChromeMessageReady, BuilderHeaders, UIDarkButtons
    static cleanedUp := false
    if cleanedUp
        return 0
    cleanedUp := true

    ; ExitApp clears globals while Windows is still sending paint messages.
    ; Detach our handlers first, while the GUI and its controls are still valid.
    if BuilderChromeMessageReady {
        OnMessage(0x84, StrategyBuilderChromeHitTest, 0)
        OnMessage(0x83, StrategyBuilderClientArea, 0)
        OnMessage(0x85, StrategyBuilderFramePaint, 0)
        OnMessage(0x86, StrategyBuilderFramePaint, 0)
        OnMessage(0x138, StrategyBuilderCheckboxColor, 0)
        OnMessage(0x135, StrategyBuilderCheckboxColor, 0)
        OnMessage(0x231, CloseBuilderDropdowns, 0)
        BuilderChromeMessageReady := false
    }

    SetTimer(PollUICustomControls, 0)
    SetTimer(PollDarkDropdowns, 0)
    OnMessage(0x20A, UICustomControlMouseWheel, 0)
    OnMessage(0x20A, DarkDropdownMouseWheel, 0)
    for button in UIDarkButtons
        button.ActionPending := false

    ; Remove native header callbacks before their owning ListViews disappear.
    for headerHwnd, header in BuilderHeaders {
        try DllCall("comctl32\RemoveWindowSubclass", "Ptr", header.control.Hwnd,
            "Ptr", GetBuilderHeaderSubclassCallback(), "UPtr", 0x42544436, "Int")
    }
    BuilderHeaders.Clear()
    HideMonkeyOverlay()
    return 0
}

StyleBuilderEdit(control) {
    control.SetFont("s9 Norm cF4F7FB", "Segoe UI")
    control.Opt("Background10161D")
}

OnDifficultyChanged(*) {
    global DifficultyDDL, ModeDDL
    RefreshModeChoicesForDifficulty(DifficultyDDL.Text, ModeDDL.Text)
    OnModeChanged()
}

RefreshModeChoicesForDifficulty(difficulty, preferredMode := "Standard") {
    global ModeDDL, ModeChoicesByDifficulty
    if !ModeChoicesByDifficulty.Has(difficulty)
        return false
    ModeDDL.Delete()
    ModeDDL.Add(ModeChoicesByDifficulty[difficulty])
    if !ChooseDropdownText(ModeDDL, preferredMode)
        ModeDDL.Choose(1)
    return true
}

OnModeChanged(*) {
    global ModeDDL, DifficultyDDL, StatusText
    global ImportedStartRound, ImportedEndRound, IsImportingStrategy
    global BuilderRoundHint
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
    RefreshBuilderRoundHint()
}

RefreshBuilderRoundHint() {
    global DifficultyDDL, ModeDDL, ImportedStartRound, ImportedEndRound, BuilderRoundHint
    bounds := GetBuilderRoundBounds(DifficultyDDL.Text, ModeDDL.Text, ImportedStartRound, ImportedEndRound)
    BuilderRoundHint.Text := "Rounds " . bounds.startRound . "-" . bounds.endRound . " | 0 = setup"
}

OnEntityTypeChanged(*) {
    global EntityTypeDDL, HeroDDL, EntityNameEdit
    type := EntityTypeDDL.Text
    HeroDDL.Enabled := type = "Hero"
    EntityNameEdit.Value := GetNextEntityName(type)
    ApplyDefaultTargetingForType(type)
}

ApplyDefaultTargetingForType(type) {
    global TargetingDDL
    defaults := Map("Ace", "Circle", "Dartling", "Normal", "Heli", "Follow Mouse", "Mortar", "Target", "SpikeFactory", "Normal")
    ChooseDropdownText(TargetingDDL, defaults.Has(type) ? defaults[type] : "First")
}

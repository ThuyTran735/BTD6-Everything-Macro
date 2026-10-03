#Requires AutoHotkey v2.0

; v3 file note: Owns Queue Profile globals and builds the main profile manager window.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.


global QueueProfilesGui := ""
global QueueProfileDropdown := ""
global QueueProfileFavoriteButton := ""
global QueueProfileFavoriteHelpBadge := ""
global QueueProfileStatusText := ""
global QueueProfileSummaryText := ""
global QueueProfileDescriptionEdit := ""
global QueueProfileNotesScrollTrack := ""
global QueueProfileNotesScrollThumb := ""
global QueueProfileNotesWheelHooked := false
global QueueProfileRepeatEdit := ""
global QueueProfileRepeatMinusButton := ""
global QueueProfileRepeatPlusButton := ""
global QueueProfileDetailsLoading := false
global QueueProfileMoreGui := ""
global QueueProfileRecords := []

global QueueProfileNameGui := ""
global QueueProfileNameEdit := ""
global QueueProfileNameErrorText := ""
global QueueProfileNameResult := ""
global QueueProfileNameFinished := false


ShowQueueProfilesManager(*) {
    global QueueProfilesGui
    global QueueProfileDropdown
    global QueueProfileFavoriteButton
    global QueueProfileFavoriteHelpBadge
    global QueueProfileStatusText
    global QueueProfileSummaryText
    global QueueProfileDescriptionEdit
    global QueueProfileNotesScrollTrack
    global QueueProfileNotesScrollThumb
    global QueueProfileNotesWheelHooked
    global QueueProfileRepeatEdit
    global QueueProfileRepeatMinusButton
    global QueueProfileRepeatPlusButton
    global MacroRunning
    global UIColorBackground
    global UIColorAccent
    global UIColorPrimaryText
    global UIColorSecondaryText
    global UIColorMutedText
    global UIColorSuccess
    global UIColorInputBorder
    global UIColorInputBackground
    global UIColorInputText
    global UIColorControlBorder

    if MacroRunning {
        return
    }

    CloseAllDarkDropdowns()
    CloseContextHelp()
    CloseAllSecondaryMenus()

    QueueProfilesGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox",
        GetVersionedTitle("Queue Profiles")
    )
    QueueProfilesGui.BackColor := UIColorBackground


    EnableCustomWindowChrome(QueueProfilesGui)
    AddCustomWindowBorder(QueueProfilesGui, 680, 490)

    AddUIOutlinedText(QueueProfilesGui, "QUEUE PROFILES", 20, 18, 640, 34, 13, "Center")

    CreateHelpBadgeForHeader(
        QueueProfilesGui,
        680,
        "QUEUE PROFILES",
        "Save complete queue setups and load them later.`n`nNotes and repeat count save automatically. Use MORE for duplicate, rename, export, import, and delete."
    )

    SetUIBodyFont(QueueProfilesGui, 9, UIColorSecondaryText)
    QueueProfilesGui.Add(
        "Text",
        "x20 y55 w640 h20 Center c" . UIColorSecondaryText . " BackgroundTrans",
        "Save, describe, repeat, and reuse complete queue setups"
    )

    ; Match the card-based visual hierarchy used by the refreshed launcher,
    ; Settings, Add Queue, and Modes screens without changing profile behavior.
    AddUICard(QueueProfilesGui, 16, 82, 648, 92)
    AddUICard(QueueProfilesGui, 16, 182, 648, 92)
    AddUICard(QueueProfilesGui, 16, 280, 648, 84)
    AddUICard(QueueProfilesGui, 16, 378, 648, 60)
    AddUICard(QueueProfilesGui, 16, 444, 648, 30)

    profileLabel := AddUIOutlinedText(QueueProfilesGui, "SELECT PROFILE", 40, 88, 600, 22, 9)
    QueueProfileDropdown := CreateDarkDropdown(
        QueueProfilesGui,
        40,
        112,
        600,
        ["No saved profiles"],
        1,
        5
    )

    QueueProfileFavoriteButton := CreateFavoriteButtonForField(QueueProfilesGui, QueueProfileDropdown)
    QueueProfileFavoriteButton.OnEvent("Click", ToggleSelectedQueueProfileFavorite)

    QueueProfileFavoriteHelpBadge := CreateFavoriteHelpBadgeForField(
        QueueProfilesGui,
        QueueProfileDropdown,
        "FAVORITES",
        "Click ☆ to favorite the selected profile.`n`n★ means it is a favorite. Favorite profiles stay at the top of the list."
    )

    CreateHelpBadgeForField(
        QueueProfilesGui,
        QueueProfileDropdown,
        profileLabel,
        "PROFILE",
        "Choose a saved Queue Profile.`n`nYou can review it, load it, update it, or use MORE for extra actions."
    )

    SetUIBodyBoldFont(QueueProfilesGui, 8, UIColorMutedText)
    QueueProfileSummaryText := QueueProfilesGui.Add(
        "Text",
        "x40 y154 w600 h22 Center c" . UIColorMutedText . " BackgroundTrans",
        "NO PROFILE SELECTED"
    )

    AddUIOutlinedText(QueueProfilesGui, "DESCRIPTION / NOTES", 40, 190, 260, 22, 9)
    CreateHelpBadge(
        QueueProfilesGui,
        205,
        192,
        "PROFILE NOTES",
        "Write notes about this profile.`n`nYour changes save automatically after you stop typing."
    )

    SetUIBodyBoldFont(QueueProfilesGui, 8, UIColorMutedText)
    QueueProfilesGui.Add(
        "Text",
        "x480 y195 w160 h18 Right c" . UIColorMutedText . " BackgroundTrans",
        "SAVES AUTOMATICALLY"
    )

    QueueProfilesGui.Add(
        "Progress",
        "x39 y217 w602 h50 c" . UIColorInputBorder
        . " Background" . UIColorInputBorder . " Disabled",
        100
    )

    SetUIBodyFont(QueueProfilesGui, 10, UIColorPrimaryText)
    QueueProfileDescriptionEdit := QueueProfilesGui.Add(
        "Edit",
        "x41 y219 w580 h46 Limit2000 Multi WantReturn c" . UIColorInputText
        . " Background" . UIColorInputBackground,
        ""
    )
    ApplyDarkControlTheme(QueueProfileDescriptionEdit)
    QueueProfileDescriptionEdit.OnEvent("Change", QueueProfileNotesChanged)

    QueueProfileNotesScrollTrack := QueueProfilesGui.Add(
        "Progress",
        "x630 y223 w6 h38 c" . UIColorControlBorder
        . " Background" . UIColorControlBorder . " Disabled",
        100
    )
    QueueProfileNotesScrollThumb := QueueProfilesGui.Add(
        "Progress",
        "x630 y223 w6 h38 c" . UIColorAccent
        . " Background" . UIColorAccent . " Disabled",
        100
    )
    QueueProfileNotesScrollTrack.Visible := false
    QueueProfileNotesScrollThumb.Visible := false

    if !QueueProfileNotesWheelHooked {
        OnMessage(0x020A, QueueProfileNotesMouseWheel)
        QueueProfileNotesWheelHooked := true
    }

    AddUIOutlinedText(QueueProfilesGui, "REPEAT ENTIRE PROFILE", 40, 286, 210, 22, 9)
    CreateHelpBadge(
        QueueProfilesGui,
        203,
        288,
        "REPEAT PROFILE",
        "Choose how many times the entire profile should repeat when loaded.`n`nThis saves automatically, and the totals update right away."
    )

    QueueProfileRepeatMinusButton := CreateDarkButton(
        QueueProfilesGui,
        40,
        313,
        42,
        44,
        "-",
        11
    )

    QueueProfilesGui.Add(
        "Progress",
        "x91 y313 w76 h44 c" . UIColorInputBorder
        . " Background" . UIColorInputBorder . " Disabled",
        100
    )

    SetUIBodyBoldFont(QueueProfilesGui, 11, UIColorPrimaryText)
    QueueProfileRepeatEdit := QueueProfilesGui.Add(
        "Edit",
        "x93 y315 w72 h40 Center Limit2 c" . UIColorInputText
        . " Background" . UIColorInputBackground,
        "1"
    )
    ApplyDarkControlTheme(QueueProfileRepeatEdit)
    QueueProfileRepeatEdit.OnEvent("Change", QueueProfileRepeatChanged)

    QueueProfileRepeatPlusButton := CreateDarkButton(
        QueueProfilesGui,
        176,
        313,
        42,
        44,
        "+",
        11
    )

    QueueProfileRepeatMinusButton.OnEvent(
        "Click",
        AdjustQueueProfileRepeat.Bind(-1)
    )
    QueueProfileRepeatPlusButton.OnEvent(
        "Click",
        AdjustQueueProfileRepeat.Bind(1)
    )

    SetUIBodyBoldFont(QueueProfilesGui, 8, UIColorSecondaryText)
    QueueProfilesGui.Add(
        "Text",
        "x238 y323 w402 h24 c" . UIColorSecondaryText . " BackgroundTrans",
        "VALID RANGE: 1-99  |  TOTALS UPDATE AUTOMATICALLY"
    )

    loadButton := CreateDarkButton(QueueProfilesGui, 40, 386, 112, 44, "LOAD PROFILE", 7)
    saveButton := CreateDarkButton(QueueProfilesGui, 162, 386, 112, 44, "SAVE CURRENT", 7)
    updateButton := CreateDarkButton(QueueProfilesGui, 284, 386, 112, 44, "UPDATE", 8)
    moreButton := CreateDarkButton(QueueProfilesGui, 406, 386, 112, 44, "MORE", 8)
    closeButton := CreateDarkButton(QueueProfilesGui, 528, 386, 112, 44, "BACK", 8, "Default")

    CreateHelpBadgeForButton(QueueProfilesGui, loadButton, "LOAD PROFILE", "Loads this profile into the queue.`n`nYour current queue is replaced, and the saved repeat amount is applied.")
    CreateHelpBadgeForButton(QueueProfilesGui, saveButton, "SAVE CURRENT", "Saves your current queue as a new Queue Profile.")
    CreateHelpBadgeForButton(QueueProfilesGui, updateButton, "UPDATE PROFILE", "Updates the selected profile with your current queue.`n`nIts name, favorite status, notes, and repeat amount stay the same.")
    CreateHelpBadgeForButton(QueueProfilesGui, moreButton, "MORE ACTIONS", "Opens extra profile tools: Duplicate, Rename, Export, Import, and Delete.")
    CreateHelpBadgeForButton(
        QueueProfilesGui,
        closeButton,
        "BACK",
        "Returns to the Queue Manager.`n`nYour current queue and saved profiles are not changed."
    )

    loadButton.OnEvent("Click", LoadSelectedQueueProfile)
    saveButton.OnEvent("Click", SaveCurrentQueueProfile)
    updateButton.OnEvent("Click", UpdateSelectedQueueProfile)
    moreButton.OnEvent("Click", ShowQueueProfileMoreActions)
    closeButton.OnEvent("Click", CloseQueueProfilesAndReturnToQueue)

    QueueProfileDropdown.OnEvent("Change", QueueProfileSelectionChanged)
    QueueProfilesGui.OnEvent("Close", CloseQueueProfilesAndReturnToQueue)
    QueueProfilesGui.OnEvent("Escape", CloseQueueProfilesAndReturnToQueue)

    SetUIBodyBoldFont(QueueProfilesGui, 8, UIColorSuccess)
    QueueProfileStatusText := QueueProfilesGui.Add(
        "Text",
        "x40 y448 w600 h22 Center c" . UIColorSuccess . " BackgroundTrans",
        "READY"
    )

    QueueProfilesGui.Show("Hide w680 h490")
    ApplyDarkWindowStyle(QueueProfilesGui)
    RefreshQueueProfilesManager(false)
    QueueProfilesGui.Show("w680 h490 Center")
}



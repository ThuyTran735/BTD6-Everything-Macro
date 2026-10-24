#Requires AutoHotkey v2.0

; Keep help next to the builder so labels and explanations can change together.
; A blank result means the label is descriptive text, not an editable control.
GetBuilderHelpText(label, group := "") {
    label := StrLower(Trim(label))
    group := StrLower(Trim(group))

    switch label {
        case "import", "import .ahk":
            return "Open an existing .ahk strategy to edit its placements and supported actions. Import replaces the current editor contents, so save your work first. The file is read as text; it is never run. If an action is unsupported, the builder tells you what was skipped."
        case "tools":
            return "Show monkey labels over the game, remap placement coordinates with F4, or clear the strategy. Remapping keeps the existing rounds and actions. Press Esc during remapping to restore every original placement point."
        case "?", "help", "strategy builder":
            return "Start in Monkeys to add placements, then use Actions to schedule upgrades and other steps. Export checks the strategy and creates its .ahk code. The builder never plays the strategy. Use the small ? beside a control for details about that control."
        case "-", "minimize":
            return "Minimize the builder while you inspect the game. Your editor contents stay open. Return to the builder from the Windows taskbar."
        case "x", "close":
            return "Close the Strategy Builder. Save your strategy from Export first if you want to keep your changes."
        case "map name":
            return "Enter the name of the BTD6 map used by this strategy, such as Dark Castle. This name is saved in the strategy's map settings."
        case "category":
            return "Choose the map's category: Beginner, Intermediate, Advanced, or Expert. Match the category shown in BTD6 for your selected map."
        case "difficulty":
            return "Choose Easy, Medium, or Hard. The Game mode choices update to match. Impoppable and CHIMPS are listed under Hard; Deflation uses Easy."
        case "game mode", "mode":
            return "Choose the game mode. The builder writes its starting and ending rounds automatically: Easy 1-40, Medium 1-60, Hard 3-80, Impoppable/CHIMPS 6-100, or Deflation 31-60. Round 0 is pregame setup. Changing mode restores these defaults instead of imported limits."
        case "function name", "function":
            return "Name the function written into the generated .ahk file. Use letters, numbers, and underscores, such as DarkCastleImpoppable. The builder removes unsupported characters and adds a prefix if the name begins with a number."
        case "wingmonkey knowledge", "wingmonkey mk":
            return "Match this setting to whether Wingmonkey Monkey Knowledge is enabled in your game. The choice is saved with the strategy settings."
        case "monkeys", "monkey details", "placements":
            return "Add each monkey or hero with a unique name, placement point, and round. Double-click a placement row to edit it. Deleting a monkey also removes its scheduled actions."
        case "actions", "action details", "scheduled actions":
            return "Choose an action type, fill in the fields shown, and add it to the schedule. Double-click an action to edit that row. Export sorts by round and delay; actions with the same timing keep their entered order, with placements first."
        case "export", "strategy preview":
            return "Generate a code preview, copy the current strategy, or save an .ahk file. The builder checks placements, coordinates, and action order before exporting. Copy and Save regenerate from your latest saved editor entries."
        case "name", "monkey name":
            return "Give this monkey a unique name, such as Dart A or Farm B. Actions use that name to find the right monkey. Saving a rename updates its existing scheduled actions too."
        case "type":
            return "Choose the monkey type. Select Hero to enable the hero picker. Each strategy can contain one hero. Changing the type also suggests a name and a starting targeting mode."
        case "hero":
            return "Choose the hero to use after selecting Hero as the type. Set its placement point and round like a monkey. The builder does not create tower upgrade actions for heroes."
        case "starting targeting", "initial targeting":
            return "Choose the targeting setting the monkey should start with. Use a Targeting action to change it later. Some tower types use their own aiming helpers instead of the normal targeting cycle."
        case "place x", "placement x", "placement coordinates":
            return "Enter the monkey's horizontal position on the 1920 × 1080 game screen: X is 0-1919 and Y is 0-1079. F2 can capture both values from the mouse position."
        case "placement y":
            return "Enter the monkey's vertical position on the game screen, from 0 to 1079. Pair it with Placement X, or use F2 to capture both coordinates."
        case "y":
            return group = "monkeys"
                ? "Enter the placement's vertical screen position, from 0 to 1079. F2 captures both X and Y."
                : "Enter the vertical screen position, from 0 to 1079, together with its X value. Optional tower coordinates select a moved monkey; Spike Factory Set Target coordinates mark the spike destination. Leave an optional pair completely blank to use the placement point."
        case "f2 capture", "capture coordinates (f2)":
            return "Hide the builder, move the mouse to the desired placement point in BTD6, and press F2. Press Esc to cancel. F2 also captures the current mouse position directly while the builder is open. It records coordinates without placing a monkey."
        case "place round", "placement round":
            return "Use round 0 to place this monkey before the game starts, or a later round to place it during the game. Actions for the monkey must happen after its placement. In Deflation, use 0 or rounds 31-60."
        case "round", "round 0 = pregame setup":
            return "Use round 0 for pregame setup, or a live round within the range shown beside the map settings. For example, Impoppable starts on round 6 and Deflation starts on 31. Game speed actions need a live round and cannot use round 0."
        case "delay (ms)", "delay", "placement delay":
            return "1000 milliseconds is one second. On a normal round, this is the time from the round being detected, not an extra wait after the previous action. At round 0, the delay is a pause before this entry. Use 0 for no added delay."
        case "add monkey":
            return "Add the placement currently shown in the form. When editing an existing row, this button becomes Save changes and updates that row. Add or save the entry before exporting; unfinished form edits are not part of the saved model."
        case "new":
            return group = "monkeys"
                ? "Leave the current monkey edit without changing its saved row and prepare another placement. The builder suggests the next unused name, clears coordinates and delay, and keeps the last placement round."
                : "Leave the current action edit without changing its saved row. Keep the last action type, monkey, and round, while clearing coordinate overrides and resetting delay for the next action."
        case "row options":
            return group = "monkeys"
                ? "Select a placement row, then choose Edit or Delete. Deleting a monkey also removes actions linked to it. You can also double-click the row to edit it or right-click to open these options."
                : "Select an action row, then choose Edit or Delete. Editing saves back to the same position. Double-click a row to edit it, or right-click to open these options."
        case "action type":
            return "Choose Upgrade, Targeting, Sell, Ability, Game speed, Repeat clicks, or a banana collection toggle. Only the fields needed by that action are shown. Repeat clicks uses a screen point, click count, and interval without selecting a monkey."
        case "monkey":
            return "Select the monkey or hero this action affects. Add it in Monkeys first. Changing the selection clears coordinate overrides so a position from another monkey is not reused accidentally."
        case "upgrade path (for example, 024)", "upgrade path", "upgrade":
            return "Enter three target tiers, such as 024 for 0-2-4. Each digit must be 0-5. Use at most two paths, with only one above tier 2. The macro buys missing tiers; it does not remove upgrades already purchased."
        case "tower x", "optional tower x", "optional tower y", "tower coordinates":
            return "For Upgrade or Sell, enter where the monkey is currently located if the map has moved it. Leave both X and Y blank to use its original placement point. Both values are required together. F3 captures the pair."
        case "f3 capture", "capture (f3)":
            return "Hide the builder, point at the monkey's current location, and press F3 to capture its selection coordinates for Upgrade or Sell. Press Esc to cancel. This records a point without clicking or upgrading the monkey."
        case "targeting mode", "target":
            return "Choose the targeting setting to apply to the selected monkey. Choices depend on its type. Spike Factory Set Target needs destination coordinates; Dartling, Heli, and Mortar aiming require helpers the action editor does not currently offer."
        case "target x", "target / tower x", "target / tower y", "target coordinates":
            return "For Spike Factory Set Target, these are the spike destination coordinates. For ordinary targeting, they optionally select a monkey that has moved from its placement point. Enter both X and Y together. F5 captures the pair."
        case "f5 capture", "f5":
            return "Hide the builder, move the mouse to the target point, and press F5. Press Esc to cancel. For Spike Factory Set Target, capture the spike destination; for ordinary targeting, capture the monkey's current location."
        case "click x", "click y":
            return "Enter the screen point to left-click: X 0-1919 and Y 0-1079 for the 1920 × 1080 game. Both values are required. F6 captures the point without clicking it. This action does not need a selected monkey."
        case "click count":
            return "Enter how many left-clicks to send at the chosen point. Use a whole number of at least 1. The macro finishes this sequence before moving to the next scheduled action."
        case "interval (ms)":
            return "The pause between clicks, in milliseconds: 1000 is one second. Use 0 for no added pause. This is separate from the action's scheduled Delay. There is no interval after the last click, so one click has no repeat wait. Input and detection take some time too."
        case "f6 capture", "f6":
            return "Hide the builder, point at the game location, and press F6 to fill Click X and Click Y. Press Esc to cancel. F6 also captures directly while Repeat clicks is selected. Capturing only records the point; it does not click the game."
        case "ability hotkey", "ability":
            return "Enter the BTD6 key for the ability to use, such as 1, 2, or 3. Schedule it after that ability becomes available. This is a global hotkey action and does not need a selected monkey."
        case "game speed", "speed":
            return "Choose Normal or Fast on a live round, such as 6 or later for Impoppable. Do not use round 0. Fast scans its icon first; if missing, it presses Space, waits 250 ms, and scans again, up to five attempts. It reports failure if Fast cannot be confirmed. Normal still uses the tracked speed."
        case "enable banana collection", "disable banana collection":
            return "Turn automatic banana collection on or off at the selected round and delay. It applies to all eligible Banana Farms during idle strategy time and does not need a selected monkey."
        case "add action":
            return "Add the action shown in the form. When editing a row, Save changes replaces that row without moving it. Invalid edits leave the original action unchanged. Save the row before exporting to include your changes."
        case "save changes":
            return group = "monkeys"
                ? "Update the monkey row currently being edited. Renames also update its scheduled actions. Choose New to leave the saved row unchanged instead."
                : "Replace the action row currently being edited, keeping its schedule position. Invalid changes leave the original row intact. Choose New to leave the saved action unchanged."
        case "generate", "generate template":
            return "Check the saved placements and actions, then rebuild the code preview. The builder reports problems such as missing monkeys, impossible upgrade paths, or actions before placement or after selling. Generating code does not run it."
        case "copy":
            return "Regenerate the strategy from the latest saved editor entries, validate it, and copy the complete .ahk code to the clipboard. A stale preview is not reused."
        case "save .ahk":
            return "Regenerate and validate the strategy, then choose where to save the .ahk file. Save changes in any row you are editing first. The file is created without running the strategy."
        case "got it":
            return "Close this explanation and return to the builder."
    }
    return ""
}

ShowBuilderControlHelp(title, text, *) {
    global MainGui, BuilderHelpGui, BuilderButtons
    global UIFontHeading, UIFontBody, UIColorBackground, UIColorPrimaryText, UIColorLabelText

    if Trim(text) = ""
        return false

    if BuilderHelpGui {
        for control in BuilderHelpGui {
            if BuilderButtons.Has(control.Hwnd)
                BuilderButtons.Delete(control.Hwnd)
        }
        BuilderHelpGui.Destroy()
    }

    BuilderHelpGui := Gui("-Caption +Border +Owner" . MainGui.Hwnd, "Strategy Builder help - " . title)
    BuilderHelpGui.BackColor := UIColorBackground
    CreateStrategyBuilderBorder(BuilderHelpGui, 540, 332)
    BuilderHelpGui.SetFont("s14 Norm c" . UIColorPrimaryText, UIFontHeading)
    BuilderHelpGui.AddText("x24 y22 w492 h48", StrUpper(title))
    BuilderHelpGui.SetFont("s10 Norm c" . UIColorLabelText, UIFontBody)
    BuilderHelpGui.AddText("x24 y82 w492 h170", text)
    close := BuilderDarkButton(BuilderHelpGui, 352, 276, 164, 32, "GOT IT", 9, "Success")
    close.OnEvent("Click", CloseBuilderHelp)
    BuilderHelpGui.OnEvent("Close", CloseBuilderHelp)
    BuilderHelpGui.OnEvent("Escape", CloseBuilderHelp)
    MainGui.Opt("+Disabled")
    BuilderHelpGui.Show("w540 h332")
    return true
}

#Requires AutoHotkey v2.0

; Shows temporary, click-through labels at the saved monkey positions.
; The small text helpers below keep generated names and quoted strings valid.

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
        ; E0x20 lets mouse input pass through the label to the game underneath.
        overlay := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        overlay.BackColor := "010203"
        overlay.SetFont("s10 w600 cFFD45C", "Segoe UI")
        overlay.AddText("x0 y0 w20 h26 Center +0x200", "+")
        overlay.AddText("x20 y0 w175 h26 +0x200", entity.name " (" entity.type ")")

        overlayX := entity.x - 10
        overlayY := entity.y - 13
        ; Set the color key before the first frame. Showing an opaque window
        ; first briefly flashes a dark rectangle over the map.
        WinSetTransColor("010203", overlay.Hwnd)
        overlay.Show("NA x" overlayX " y" overlayY " w195 h26")
        MonkeyOverlayWindows.Push(overlay)
    }

    MonkeyOverlayVisible := true
    StatusText.Text := "Showing " Entities.Length " monkey label(s)"
    return true
}

HideMonkeyOverlay(*) {
    global MonkeyOverlayWindows, MonkeyOverlayVisible

    ; Destroy old windows instead of hiding them so refreshes cannot leave stale labels behind.
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
    ; AutoHotkey string literals escape a quote by doubling it.
    q := Chr(34)
    return StrReplace(text, q, q q)
}

GetBuilderSuggestedFunctionName(mapName, difficulty, gameMode) {
    mapName := Trim(mapName)
    if mapName = "" || mapName = "MAP NAME"
        return ""

    ; Keep possessives and names like Three Mines 'Round together before
    ; capitalizing each word. Standard scripts use Easy, Medium, or Hard.
    mapName := StrReplace(StrReplace(mapName, "'", ""), Chr(0x2019), "")
    mapWords := Trim(RegExReplace(mapName, "[^A-Za-z0-9]+", " "))
    suffix := Trim(gameMode) = "Standard" ? Trim(difficulty) : Trim(gameMode)
    suffix := RegExReplace(suffix, "[^A-Za-z0-9]", "")
    if mapWords = "" || suffix = ""
        return ""

    ; Mode choices already have the right spelling, including CHIMPS and HP.
    return SanitizeFunctionName(StrReplace(StrTitle(mapWords), " ", "") . suffix)
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


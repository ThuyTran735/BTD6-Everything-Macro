#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\Lib\FindText.ahk
#Include ..\Scripts\MapData.ahk

; Scans every real map pattern in MapData.ahk and shows which ones
; FindText can currently see on the BTD6 screen.

global PatternTestGui := Gui("+AlwaysOnTop", "Map Pattern Test")
global SummaryText := ""
global PatternList := ""
global LastResults := ""

BuildPatternTestGui()

; F8 works even while BTD6 is active, so you can change pages and rescan fast.
Hotkey("F8", ScanMapPatterns)

BuildPatternTestGui() {
    global PatternTestGui, SummaryText, PatternList

    PatternTestGui.SetFont("s10", "Segoe UI")

    PatternTestGui.AddText(
        "xm ym w700",
        "Open the BTD6 map selection screen, then click Scan or press F8."
    )

    PatternTestGui.AddText(
        "xm y+4 w700",
        "Only patterns that are actually found are listed below. Double-click a result to see where it matched."
    )

    SummaryText := PatternTestGui.AddText(
        "xm y+12 w700",
        "No scan yet."
    )

    PatternList := PatternTestGui.AddListView(
        "xm y+8 w700 r16 Grid",
        ["Map", "Category", "Page", "X", "Y"]
    )

    PatternList.ModifyCol(1, 240)
    PatternList.ModifyCol(2, 120)
    PatternList.ModifyCol(3, 60)
    PatternList.ModifyCol(4, 80)
    PatternList.ModifyCol(5, 80)

    scanButton := PatternTestGui.AddButton(
        "xm y+10 w120 h32 Default",
        "Scan (F8)"
    )
    scanButton.OnEvent("Click", ScanMapPatterns)

    copyButton := PatternTestGui.AddButton(
        "x+10 yp w120 h32",
        "Copy Results"
    )
    copyButton.OnEvent("Click", CopyPatternResults)

    closeButton := PatternTestGui.AddButton(
        "x+10 yp w120 h32",
        "Close"
    )
    closeButton.OnEvent("Click", ClosePatternTest)

    PatternList.OnEvent("DoubleClick", HighlightPatternMatch)
    PatternTestGui.OnEvent("Close", ClosePatternTest)

    PatternTestGui.Show()
}

ScanMapPatterns(*) {
    global MapData, PatternTestGui, SummaryText, PatternList, LastResults

    if !WinExist("ahk_exe BloonsTD6.exe") {
        MsgBox("BTD6 is not open. Open the game and try again.", "Map Pattern Test")
        return
    }

    ; Hide this window before scanning so it cannot cover a map card.
    PatternTestGui.Hide()
    WinActivate("ahk_exe BloonsTD6.exe")

    try WinWaitActive("ahk_exe BloonsTD6.exe",, 2)
    Sleep(250)

    PatternList.Delete()

    checkedCount := 0
    foundCount := 0
    skippedCount := 0
    resultsText := ""

    for mapName, mapInfo in MapData {
        pattern := mapInfo.pattern

        ; Ignore unfinished entries in MapData.ahk.
        if mapName = "" || pattern = "" || InStr(pattern, "YOUR_") {
            skippedCount += 1
            continue
        }

        checkedCount += 1

        if FindText(
            &matchX,
            &matchY,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            pattern
        ) {
            foundCount += 1

            PatternList.Add(
                "",
                mapName,
                mapInfo.category,
                mapInfo.page,
                matchX,
                matchY
            )

            resultsText .= mapName
                . " | " . mapInfo.category
                . " | Page " . mapInfo.page
                . " | X=" . matchX
                . " Y=" . matchY
                . "`r`n"
        }
    }

    if foundCount = 0
        resultsText := "No map patterns were found on the current screen.`r`n"

    LastResults := resultsText

    SummaryText.Text := "Checked " . checkedCount
        . " real patterns | Found " . foundCount
        . " | Skipped " . skippedCount . " blank/placeholder entries"

    PatternTestGui.Show()
}

CopyPatternResults(*) {
    global LastResults

    if LastResults = "" {
        MsgBox("Run a scan first.", "Map Pattern Test")
        return
    }

    A_Clipboard := LastResults
    ToolTip("Pattern results copied")
    SetTimer(HidePatternTestToolTip, -1000)
}

; Highlighting moves the pointer and shows a label; it does not click or select the map.
HighlightPatternMatch(listView, rowNumber) {
    global PatternTestGui

    if rowNumber = 0
        return

    mapName := listView.GetText(rowNumber, 1)
    matchX := listView.GetText(rowNumber, 4) + 0
    matchY := listView.GetText(rowNumber, 5) + 0

    PatternTestGui.Hide()

    if WinExist("ahk_exe BloonsTD6.exe") {
        WinActivate("ahk_exe BloonsTD6.exe")
        try WinWaitActive("ahk_exe BloonsTD6.exe",, 2)
        Sleep(150)

        MouseMove(matchX, matchY, 0)
        ToolTip("Matched: " . mapName, matchX + 15, matchY + 15)
        Sleep(1500)
        ToolTip()
    }

    PatternTestGui.Show()
}

HidePatternTestToolTip() {
    ToolTip()
}

ClosePatternTest(*) {
    ExitApp()
}

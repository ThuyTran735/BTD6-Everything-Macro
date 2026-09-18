#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\Scripts\IncludeAll.ahk

; Lightweight shared-code smoke test.
; This does not click or type into BTD6.

checks := []
checks.Push(["Hero hotkey", TowerHotkeys.Has("Hero") && TowerHotkeys["Hero"] = "u"])
checks.Push(["Deflation prerequisite", GetGameModePrerequisite("Deflation") = "Primary Only"])
checks.Push(["CHIMPS prerequisite", GetGameModePrerequisite("CHIMPS") = "Impoppable"])
checks.Push(["Logs directory", InStr(GetLogsDirectory(), "UserData\Logs") > 0])
checks.Push(["Monkey Meadow map data", MapData.Has("Monkey Meadow") && MapData["Monkey Meadow"].category = "Beginner"])

passed := 0
report := "BTD6 Everything Macro " . GetAppVersionLabel() . " - Core Smoke Test`n"

for check in checks {
    ok := check[2]
    passed += ok ? 1 : 0
    report .= "`n" (ok ? "PASS" : "FAIL") " - " check[1]
}

report .= "`n`n" passed "/" checks.Length " checks passed."

MsgBox(report, "BTD6 " . GetAppVersionLabel() . " Test")
ExitApp()
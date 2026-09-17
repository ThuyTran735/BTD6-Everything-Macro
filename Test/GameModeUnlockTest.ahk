#Requires AutoHotkey v2.0
#SingleInstance Force

; V1.5 automatic game-mode unlock end-to-end test.
; Launch the REAL Deflation map script so prerequisite path discovery uses
; the same filename/location rules as production runs.

testScript := A_ScriptDir "\..\Maps\Beginner\In The Loop\Easy\InTheLoopDeflation.ahk"

if !FileExist(testScript) {
    MsgBox(
        "Could not find the Deflation strategy used by this test:"
        "`n`n" testScript,
        "BTD6 V1.5 Unlock Test"
    )
    ExitApp()
}

runToken := FormatTime(, "yyyyMMddHHmmss") "_" Random(1000, 9999)
resultPath := A_Temp "\BTD6EverythingMacro_RunResult_" runToken ".ini"

try FileDelete(resultPath)

command := '"' A_AhkPath '" "' testScript '" --btd6-run-token=' runToken ' --btd6-cycle=1'

try {
    RunWait(command)
} catch Error as err {
    MsgBox(
        "Could not launch the map strategy."
        "`n`n" err.Message,
        "BTD6 V1.5 Unlock Test"
    )
    ExitApp()
}

if !FileExist(resultPath) {
    MsgBox(
        "The map strategy exited without writing a V1.5 run result."
        "`nCheck the latest file in UserData\Logs for details.",
        "BTD6 V1.5 Unlock Test"
    )
    ExitApp()
}

status := IniRead(resultPath, "Result", "Status", "Unknown")
reason := IniRead(resultPath, "Result", "Reason", "")

try FileDelete(resultPath)

if status = "Success" {
    MsgBox(
        "Game-mode unlock test completed successfully."
        "`n`nRequested mode: Deflation",
        "BTD6 V1.5 Unlock Test"
    )
} else {
    MsgBox(
        "Game-mode unlock test failed."
        "`n`nStatus: " status
        "`nReason: " (reason != "" ? reason : "No reason returned")
        "`n`nCheck UserData\Logs for the full run log.",
        "BTD6 V1.5 Unlock Test"
    )
}

ExitApp()
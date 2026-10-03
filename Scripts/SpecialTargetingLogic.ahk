#Requires AutoHotkey v2.0


; v3 file note: Handles the SpecialTargeting part of the macro. Keep this focused so run bugs are easier to trace later.

ClickSpecialTargetPoint(targetX, targetY) {
    ; Shared special/manual targeting flow:
    ; PgDn -> 300 ms -> target click -> 250 ms -> close panel -> 100 ms settle.
    Send("{PgDn}")
    Sleep(300)

    Click(targetX, targetY)
    Sleep(250)

    ; Special/manual targeting leaves the tower upgrade panel open.
    ; Close it so later placement/upgrade actions always start cleanly.
    CloseCachedUpgradePanel(100)

    return true
}
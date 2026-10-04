#Requires AutoHotkey v2.0


; v3 file note: Handles the SpecialTargeting part of the macro. Keep this focused so run bugs are easier to trace later.

ClickSpecialTargetPoint(targetX, targetY) {
    ; Shared special/manual targeting flow:
    ; PgDn -> 300 ms -> target click -> 250 ms -> close panel -> 300 ms settle.
    Send("{PgDn}")
    Sleep(300)

    Click(targetX, targetY)
    Sleep(250)

    ; This action selected the tower itself, so close that known panel once.
    ; Do not scan the screen and guess whether some other panel is open.
    SendEscapeAndWait()

    return true
}
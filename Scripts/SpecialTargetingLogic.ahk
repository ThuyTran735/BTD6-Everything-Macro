#Requires AutoHotkey v2.0


; Shared PgDn-and-click sequence for towers with a manual target point.

ClickSpecialTargetPoint(targetX, targetY) {
    ; Shared special/manual targeting flow:
    ; PgDn -> 300 ms -> target click -> 250 ms -> close panel -> 300 ms settle.
    Send("{PgDn}")
    Sleep(300)

    ClickMapPoint(targetX, targetY)
    Sleep(250)

    ; This action selected the tower itself, so close that known panel once.
    ; Do not scan the screen and guess whether some other panel is open.
    SendEscapeAndWait()

    return true
}
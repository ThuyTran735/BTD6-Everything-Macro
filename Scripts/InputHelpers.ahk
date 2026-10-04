#Requires AutoHotkey v2.0

; Small shared input helpers so timing-sensitive key presses stay consistent.

SendEscapeAndWait(waitMs := 300) {
    ; BTD6's panel/menu close animation needs time to finish before the next
    ; scripted input. Never let an Esc settle for less than 300 ms.
    Send("{Esc}")
    Sleep(Max(300, waitMs))
}

#Requires AutoHotkey v2.0

; v3 file note: Handles the Version part of the macro. Keep this focused so run bugs are easier to trace later.

; Single source of truth for the installed application's version.
; Change only this value when bumping the local/runtime version.
global AppVersion := "3.2.1"

GetAppVersion() {
    global AppVersion
    return AppVersion
}

GetAppVersionLabel() {
    return "v" . GetAppVersion()
}

GetVersionedTitle(baseTitle) {
    return baseTitle . " - " . GetAppVersionLabel()
}
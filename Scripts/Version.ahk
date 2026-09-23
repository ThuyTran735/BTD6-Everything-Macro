#Requires AutoHotkey v2.0

; Single source of truth for the installed application's version.
; Change only this value when bumping the local/runtime version.
global AppVersion := "2.2.2"

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
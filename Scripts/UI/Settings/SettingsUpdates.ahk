#Requires AutoHotkey v2.0

; A short status animation confirms the click before the update request begins.

CheckForUpdatesFromSettings(*) {
    global SettingsUpdateCheckActive
    global SettingsUpdateCheckFrame

    if SettingsUpdateCheckActive
        return

    ; Let the normal custom-button press/release animation finish first, then
    ; show a short visible checking sequence before the synchronous web request.
    SettingsUpdateCheckActive := true
    SettingsUpdateCheckFrame := 1
    ShowSettingsUpdateCheckFrame()
    SetTimer(AdvanceSettingsUpdateCheckAnimation, -260)
}


ShowSettingsUpdateCheckFrame() {
    global SettingsUpdateCheckFrame

    frames := [
        "CHECKING FOR UPDATES.",
        "CHECKING FOR UPDATES..",
        "CHECKING FOR UPDATES..."
    ]

    if SettingsUpdateCheckFrame >= 1 && SettingsUpdateCheckFrame <= frames.Length
        SetSettingsStatus(frames[SettingsUpdateCheckFrame])
}


AdvanceSettingsUpdateCheckAnimation(*) {
    global SettingsUpdateCheckFrame

    SettingsUpdateCheckFrame += 1

    if SettingsUpdateCheckFrame <= 3 {
        ShowSettingsUpdateCheckFrame()
        SetTimer(AdvanceSettingsUpdateCheckAnimation, -260)
        return
    }

    SetTimer(RunSettingsUpdateCheck, -80)
}


RunSettingsUpdateCheck(*) {
    global SettingsUpdateCheckActive

    try {
        result := GetGitHubUpdateStatus()

        if !result.ok {
            SetSettingsStatus("Update check failed: " . result.error)
            return
        }

        if result.updateAvailable {
            ShowLauncherUpdateNotice(result.latestVersion)
            SetSettingsStatus(
                "Update available: v" . result.latestVersion
                . "   |   Installed: v" . result.currentVersion
            )
            return
        }

        if CompareMacroVersions(result.latestVersion, result.currentVersion) = 0 {
            SetSettingsStatus("You're up to date. Installed version: v" . result.currentVersion)
            return
        }

        SetSettingsStatus(
            "This copy is newer than GitHub. Installed: v" . result.currentVersion
            . "   |   GitHub: v" . result.latestVersion
        )
    }
    ; Failed requests must also release the guard so another check can be attempted.
    finally {
        SettingsUpdateCheckActive := false
    }
}



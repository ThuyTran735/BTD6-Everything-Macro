#Requires AutoHotkey v2.0

; Update checking for the public GitHub repository.
; The remote version is read directly from Scripts/Version.ahk.

global UpdateRepositoryUrl := "https://github.com/ThuyTran735/BTD6-Everything-Macro"
global UpdateVersionApiUrl := "https://api.github.com/repos/ThuyTran735/BTD6-Everything-Macro/contents/Scripts/Version.ahk"
global UpdateVersionRawUrl := "https://raw.githubusercontent.com/ThuyTran735/BTD6-Everything-Macro/main/Scripts/Version.ahk"
global UpdateLegacyVersionApiUrl := "https://api.github.com/repos/ThuyTran735/BTD6-Everything-Macro/contents/Scripts/UpdateChecker.ahk"
global UpdateLegacyVersionRawUrl := "https://raw.githubusercontent.com/ThuyTran735/BTD6-Everything-Macro/main/Scripts/UpdateChecker.ahk"


global UpdateCheckAnimationFrames := [
    "SEARCHING FOR UPDATES.",
    "SEARCHING FOR UPDATES..",
    "SEARCHING FOR UPDATES..."
]
global UpdateCheckAnimationIndex := 0
global UpdateCheckAnimationActive := false


GetUpdateSettingsFilePath() {
    return A_ScriptDir . "\UserData\Settings.ini"
}


IsAutoUpdateCheckEnabled() {
    try {
        value := IniRead(GetUpdateSettingsFilePath(), "Updates", "AutoCheckEnabled", "1")
        return value != "0"
    }

    return true
}


SetAutoUpdateCheckEnabled(enabled) {
    settingsDir := A_ScriptDir . "\UserData"

    if !DirExist(settingsDir)
        DirCreate(settingsDir)

    IniWrite(
        enabled ? "1" : "0",
        GetUpdateSettingsFilePath(),
        "Updates",
        "AutoCheckEnabled"
    )
}


NormalizeMacroVersion(version) {
    version := Trim(version)
    version := RegExReplace(version, "i)^v", "")
    return version
}


CompareMacroVersions(leftVersion, rightVersion) {
    leftParts := StrSplit(NormalizeMacroVersion(leftVersion), ".")
    rightParts := StrSplit(NormalizeMacroVersion(rightVersion), ".")

    Loop 3 {
        leftValue := A_Index <= leftParts.Length ? (leftParts[A_Index] + 0) : 0
        rightValue := A_Index <= rightParts.Length ? (rightParts[A_Index] + 0) : 0

        if leftValue > rightValue
            return 1

        if leftValue < rightValue
            return -1
    }

    return 0
}


ParseVersionFromVersionFile(body) {
    if RegExMatch(
        body,
        "i)AppVersion\s*:=\s*\x22([0-9]+(?:\.[0-9]+){1,2})\x22",
        &match
    ) {
        return NormalizeMacroVersion(match[1])
    }

    return ""
}


ParseVersionFromLegacyUpdateChecker(body) {
    if RegExMatch(
        body,
        "i)MacroCurrentVersion\s*:=\s*\x22([0-9]+(?:\.[0-9]+){1,2})\x22",
        &match
    ) {
        return NormalizeMacroVersion(match[1])
    }

    return ""
}


FetchVersionText(url, useGitHubApi := false) {
    
    ; Add a unique query value so WinHTTP/CDN/proxy caches cannot reuse an old version file.
    separator := InStr(url, "?") ? "&" : "?"
    requestUrl := url . separator . "_=" . A_TickCount

    request := ComObject("WinHttp.WinHttpRequest.5.1")
    request.SetTimeouts(2500, 2500, 2500, 5000)
    request.Open("GET", requestUrl, false)
    request.SetRequestHeader("User-Agent", "BTD6-Everything-Macro-v" . GetAppVersion())
    request.SetRequestHeader("Cache-Control", "no-cache, no-store, max-age=0")
    request.SetRequestHeader("Pragma", "no-cache")

    if useGitHubApi {
        ; GitHub returns Version.ahk itself instead of JSON when this media type is requested.
        request.SetRequestHeader("Accept", "application/vnd.github.raw+json")
        request.SetRequestHeader("X-GitHub-Api-Version", "2022-11-28")
    }

    request.Send()

    if request.Status != 200
        throw Error("GitHub returned HTTP " . request.Status . ".")

    return request.ResponseText
}


FetchLatestGitHubVersion() {
    global UpdateVersionApiUrl
    global UpdateVersionRawUrl
    global UpdateLegacyVersionApiUrl
    global UpdateLegacyVersionRawUrl

    errors := []

    ; Preferred source for all new builds: the centralized version file.
    try {
        body := FetchVersionText(UpdateVersionApiUrl, true)
        version := ParseVersionFromVersionFile(body)

        if version != "" {
            return {
                ok: true,
                latestVersion: version,
                source: "GitHub Version.ahk",
                error: ""
            }
        }

        errors.Push("Version.ahk API did not contain AppVersion")
    }
    catch as err {
        errors.Push("Version.ahk API: " . err.Message)
    }

    try {
        body := FetchVersionText(UpdateVersionRawUrl, false)
        version := ParseVersionFromVersionFile(body)

        if version != "" {
            return {
                ok: true,
                latestVersion: version,
                source: "Raw Version.ahk",
                error: ""
            }
        }

        errors.Push("Raw Version.ahk did not contain AppVersion")
    }
    catch as err {
        errors.Push("Raw Version.ahk: " . err.Message)
    }

    ; Transition fallback for repositories that have not committed Version.ahk yet.
    ; Older v1.6/v1.6.1 builds stored the version in UpdateChecker.ahk.
    try {
        body := FetchVersionText(UpdateLegacyVersionApiUrl, true)
        version := ParseVersionFromLegacyUpdateChecker(body)

        if version != "" {
            return {
                ok: true,
                latestVersion: version,
                source: "Legacy GitHub UpdateChecker.ahk",
                error: ""
            }
        }

        errors.Push("Legacy UpdateChecker API did not contain MacroCurrentVersion")
    }
    catch as err {
        errors.Push("Legacy UpdateChecker API: " . err.Message)
    }

    try {
        body := FetchVersionText(UpdateLegacyVersionRawUrl, false)
        version := ParseVersionFromLegacyUpdateChecker(body)

        if version != "" {
            return {
                ok: true,
                latestVersion: version,
                source: "Legacy raw UpdateChecker.ahk",
                error: ""
            }
        }

        errors.Push("Legacy raw UpdateChecker did not contain MacroCurrentVersion")
    }
    catch as err {
        errors.Push("Legacy raw UpdateChecker: " . err.Message)
    }

    return {
        ok: false,
        latestVersion: "",
        source: "",
        error: errors.Length ? errors[errors.Length] : "Could not read a remote version."
    }
}


GetGitHubUpdateStatus() {
    
    remote := FetchLatestGitHubVersion()

    if !remote.ok {
        return {
            ok: false,
            currentVersion: GetAppVersion(),
            latestVersion: "",
            source: "",
            updateAvailable: false,
            error: remote.error
        }
    }

    return {
        ok: true,
        currentVersion: GetAppVersion(),
        latestVersion: remote.latestVersion,
        source: remote.source,
        updateAvailable: CompareMacroVersions(remote.latestVersion, GetAppVersion()) > 0,
        error: ""
    }
}



ShowLauncherUpdateNotice(version) {
    global UpdateCheckText
    global UpdateLinkText
    global UIColorSuccess

    try {
        if !UpdateCheckText
            return

        UpdateCheckText.Move(38, 348, 200, 18)
        UpdateCheckText.Opt("+Left")
        UpdateCheckText.SetFont("c" . UIColorSuccess)
        UpdateCheckText.Text := "UPDATE AVAILABLE: v" . version
        UpdateCheckText.Visible := true

        if UpdateLinkText {
            UpdateLinkText.Move(238, 348, 112, 18)
            UpdateLinkText.Opt("+Left")
            UpdateLinkText.Text := "Click to Update"
            UpdateLinkText.Visible := true
        }
    }
}


SetLauncherUpdateCheckStatus(text, color := "") {
    global UpdateCheckText
    global UpdateLinkText
    global UIColorMutedText

    if !UpdateCheckText
        return

    if color = ""
        color := UIColorMutedText

    try {
        if UpdateLinkText
            UpdateLinkText.Visible := false

        UpdateCheckText.Move(20, 348, 350, 18)
        UpdateCheckText.Opt("+Center")
        UpdateCheckText.SetFont("c" . color)

        ; Erase the previous frame before drawing the next one so update
        ; animation text cannot ghost over an older update-result message.
        UpdateCheckText.Text := ""
        DllCall(
            "RedrawWindow",
            "Ptr", UpdateCheckText.Hwnd,
            "Ptr", 0,
            "Ptr", 0,
            "UInt", 0x85
        )

        UpdateCheckText.Text := text
        UpdateCheckText.Visible := true
        DllCall(
            "RedrawWindow",
            "Ptr", UpdateCheckText.Hwnd,
            "Ptr", 0,
            "Ptr", 0,
            "UInt", 0x85
        )
    }
}


HideLauncherUpdateCheckStatus() {
    global UpdateCheckText
    global UpdateLinkText

    try {
        if UpdateCheckText {
            UpdateCheckText.Text := ""
            UpdateCheckText.Visible := false
        }

        if UpdateLinkText
            UpdateLinkText.Visible := false
    }
}

OpenUpdateRepository(*) {
    global UpdateRepositoryUrl
    Run(UpdateRepositoryUrl)
    ExitApp()
}


StartStartupUpdateCheck(*) {
    global UpdateCheckAnimationIndex
    global UpdateCheckAnimationActive

    if !IsAutoUpdateCheckEnabled()
        return

    UpdateCheckAnimationIndex := 1
    UpdateCheckAnimationActive := true
    ShowStartupUpdateAnimationFrame()
    SetTimer(AdvanceStartupUpdateCheckAnimation, 325)
}


ShowStartupUpdateAnimationFrame() {
    global UpdateCheckAnimationFrames
    global UpdateCheckAnimationIndex

    if UpdateCheckAnimationIndex < 1
        return

    if UpdateCheckAnimationIndex > UpdateCheckAnimationFrames.Length
        return

    SetLauncherUpdateCheckStatus(UpdateCheckAnimationFrames[UpdateCheckAnimationIndex])
}


AdvanceStartupUpdateCheckAnimation(*) {
    global UpdateCheckAnimationFrames
    global UpdateCheckAnimationIndex
    global UpdateCheckAnimationActive

    if !UpdateCheckAnimationActive {
        SetTimer(AdvanceStartupUpdateCheckAnimation, 0)
        return
    }

    UpdateCheckAnimationIndex += 1

    if UpdateCheckAnimationIndex <= UpdateCheckAnimationFrames.Length {
        ShowStartupUpdateAnimationFrame()
        return
    }

    SetTimer(AdvanceStartupUpdateCheckAnimation, 0)
    UpdateCheckAnimationActive := false
    RunStartupUpdateCheck()
}


RunStartupUpdateCheck(*) {
    if !IsAutoUpdateCheckEnabled()
        return

    result := GetGitHubUpdateStatus()

    if !result.ok {
        HideLauncherUpdateCheckStatus()
        UpdateStatus("READY")
        return
    }

    if result.updateAvailable {
        ShowLauncherUpdateNotice(result.latestVersion)
        return
    }

    HideLauncherUpdateCheckStatus()
    UpdateStatus("READY")
}
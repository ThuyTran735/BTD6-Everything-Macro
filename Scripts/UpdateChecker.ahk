#Requires AutoHotkey v2.0

; V1.6 update checking for the public GitHub repository.
; The remote version is read from the README line:
;   Current version: V1.6

global MacroCurrentVersion := "1.6"
global UpdateRepositoryUrl := "https://github.com/ThuyTran735/BTD6-Everything-Macro"
global UpdateReadmeApiUrl := "https://api.github.com/repos/ThuyTran735/BTD6-Everything-Macro/readme"
global UpdateReadmeUrl := "https://raw.githubusercontent.com/ThuyTran735/BTD6-Everything-Macro/main/README.md"


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


ParseVersionFromReadme(body) {
    if RegExMatch(
        body,
        "i)Current\s+version\s*:\s*V?([0-9]+(?:\.[0-9]+){1,2})",
        &match
    ) {
        return NormalizeMacroVersion(match[1])
    }

    return ""
}


FetchReadmeText(url, useGitHubApi := false) {
    global MacroCurrentVersion

    ; Add a unique query value so WinHTTP/CDN/proxy caches cannot reuse an old README.
    separator := InStr(url, "?") ? "&" : "?"
    requestUrl := url . separator . "_=" . A_TickCount

    request := ComObject("WinHttp.WinHttpRequest.5.1")
    request.SetTimeouts(2500, 2500, 2500, 5000)
    request.Open("GET", requestUrl, false)
    request.SetRequestHeader("User-Agent", "BTD6-Everything-Macro-V" . MacroCurrentVersion)
    request.SetRequestHeader("Cache-Control", "no-cache, no-store, max-age=0")
    request.SetRequestHeader("Pragma", "no-cache")

    if useGitHubApi {
        ; GitHub returns README.md itself instead of JSON when this media type is requested.
        request.SetRequestHeader("Accept", "application/vnd.github.raw+json")
        request.SetRequestHeader("X-GitHub-Api-Version", "2022-11-28")
    }

    request.Send()

    if request.Status != 200
        throw Error("GitHub returned HTTP " . request.Status . ".")

    return request.ResponseText
}


FetchLatestGitHubVersion() {
    global UpdateReadmeApiUrl
    global UpdateReadmeUrl

    apiError := ""

    ; Primary path: GitHub API. This avoids stale raw.githubusercontent.com CDN data.
    try {
        body := FetchReadmeText(UpdateReadmeApiUrl, true)
        version := ParseVersionFromReadme(body)

        if version != "" {
            return {
                ok: true,
                latestVersion: version,
                source: "GitHub API",
                error: ""
            }
        }

        apiError := "GitHub API README did not contain a Current version line."
    }
    catch as err {
        apiError := err.Message
    }

    ; Fallback path: raw README with an explicit cache-busting query parameter.
    try {
        body := FetchReadmeText(UpdateReadmeUrl, false)
        version := ParseVersionFromReadme(body)

        if version != "" {
            return {
                ok: true,
                latestVersion: version,
                source: "Raw README fallback",
                error: ""
            }
        }

        return {
            ok: false,
            latestVersion: "",
            source: "",
            error: "Could not find the Current version line in README.md. API: " . apiError
        }
    }
    catch as err {
        return {
            ok: false,
            latestVersion: "",
            source: "",
            error: "GitHub API: " . apiError . " | Raw README: " . err.Message
        }
    }
}


GetGitHubUpdateStatus() {
    global MacroCurrentVersion

    remote := FetchLatestGitHubVersion()

    if !remote.ok {
        return {
            ok: false,
            currentVersion: MacroCurrentVersion,
            latestVersion: "",
            source: "",
            updateAvailable: false,
            error: remote.error
        }
    }

    return {
        ok: true,
        currentVersion: MacroCurrentVersion,
        latestVersion: remote.latestVersion,
        source: remote.source,
        updateAvailable: CompareMacroVersions(remote.latestVersion, MacroCurrentVersion) > 0,
        error: ""
    }
}



ShowLauncherUpdateNotice(version) {
    global StatusText
    global UpdateLinkText
    global UIColorSuccess

    try {
        if !StatusText
            return

        StatusText.Move(38, 356, 200, 20)
        StatusText.Opt("+Left")
        StatusText.SetFont("c" . UIColorSuccess)
        StatusText.Text := "UPDATE AVAILABLE: V" . version

        if UpdateLinkText {
            UpdateLinkText.Move(238, 356, 112, 20)
            UpdateLinkText.Opt("+Left")
            UpdateLinkText.Text := "Click to Update"
            UpdateLinkText.Visible := true
        }
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

    UpdateStatus(UpdateCheckAnimationFrames[UpdateCheckAnimationIndex])
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
        UpdateStatus("READY")
        return
    }

    if result.updateAvailable {
        ShowLauncherUpdateNotice(result.latestVersion)
        return
    }

    UpdateStatus("READY")
}
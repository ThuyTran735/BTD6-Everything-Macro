#Requires AutoHotkey v2.0

; Event runs use the normal child-process lifecycle. Only candidate selection
; changes; continuous play ends only when stopped or no candidate can run.
global CollectionEventRunActive := false
global CollectionEventRunGeneration := 0
global CollectionEventCandidates := []
global CollectionEventExcludedPaths := Map()
global CollectionEventCurrentCandidate := ""
global CollectionEventNeedsSelection := false
global CollectionEventSetupPending := false
global CollectionEventNoticeGui := ""
global CollectionEventNoticeAccepted := false


IsCurrentCollectionEventRun(generation) {
    global CollectionEventRunActive
    global CollectionEventRunGeneration
    global MacroRunning
    global CycleStatusClosing

    return CollectionEventRunActive && MacroRunning && !CycleStatusClosing
        && generation = CollectionEventRunGeneration
}


ClearCollectionEventRunState() {
    global CollectionEventRunActive
    global CollectionEventRunGeneration
    global CollectionEventCandidates
    global CollectionEventExcludedPaths
    global CollectionEventCurrentCandidate
    global CollectionEventNeedsSelection

    ; Any interrupted scanner belongs to the old generation after this point.
    CollectionEventRunGeneration++
    CollectionEventRunActive := false
    CollectionEventCandidates := []
    CollectionEventExcludedPaths := Map()
    CollectionEventCurrentCandidate := ""
    CollectionEventNeedsSelection := false
}


ShowCollectionEventNotice() {
    global CollectionEventNoticeGui
    global CollectionEventNoticeAccepted
    global LauncherGui
    global UIColorBackground
    global UIColorSecondaryText

    CollectionEventNoticeAccepted := false
    CloseAllDarkDropdowns()
    CloseContextHelp()
    ownerOption := LauncherGui ? " +Owner" . LauncherGui.Hwnd : ""
    CollectionEventNoticeGui := Gui(
        "+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox" . ownerOption,
        "Auto Collection Event"
    )
    CollectionEventNoticeGui.BackColor := UIColorBackground
    EnableCustomWindowChrome(CollectionEventNoticeGui)
    AddCustomWindowBorder(CollectionEventNoticeGui, 560, 332)
    AddUIOutlinedText(CollectionEventNoticeGui, "AUTO COLLECTION EVENT", 24, 24, 512, 34, 13, "Center")
    AddUICard(CollectionEventNoticeGui, 24, 76, 512, 172)
    SetUIBodyFont(CollectionEventNoticeGui, 10, UIColorSecondaryText)
    CollectionEventNoticeGui.Add(
        "Text", "x40 y92 w480 h140 c" . UIColorSecondaryText . " BackgroundTrans",
        "Expert maps only, using Impoppable strategies.`n`n"
        . "Each cycle prefers a supported event-marked map. Otherwise, it chooses a random supported Expert map.`n`n"
        . "Runs continuously until you stop the macro. Unavailable maps are skipped."
    )
    continueButton := CreateDarkButton(CollectionEventNoticeGui, 24, 264, 250, 44, "START EVENT", 8)
    cancelButton := CreateDarkButton(CollectionEventNoticeGui, 286, 264, 250, 44, "CANCEL", 8, "Default")
    CreateHelpBadgeForButton(
        CollectionEventNoticeGui, continueButton, "START EVENT",
        "Runs supported Expert Impoppable strategies continuously.`n`n"
        . "Prefers event-marked maps. Otherwise, chooses a random supported map, excluding Dark Dungeons.`n`n"
        . "Press Ctrl + Shift + X to stop immediately."
    )
    CreateHelpBadgeForButton(
        CollectionEventNoticeGui, cancelButton, "CANCEL",
        "Closes this notice without starting an event run."
    )
    continueButton.OnEvent("Click", CloseCollectionEventNotice.Bind(true))
    cancelButton.OnEvent("Click", CloseCollectionEventNotice.Bind(false))
    CollectionEventNoticeGui.OnEvent("Close", CloseCollectionEventNotice.Bind(false))
    CollectionEventNoticeGui.OnEvent("Escape", CloseCollectionEventNotice.Bind(false))
    ApplyDarkWindowStyle(CollectionEventNoticeGui)
    CollectionEventNoticeGui.Show("w560 h332 Center")
    noticeHwnd := CollectionEventNoticeGui.Hwnd
    WinWaitClose("ahk_id " . noticeHwnd)
    return CollectionEventNoticeAccepted
}


CloseCollectionEventNotice(accepted, *) {
    global CollectionEventNoticeGui
    global CollectionEventNoticeAccepted

    CloseContextHelp()
    CollectionEventNoticeAccepted := accepted
    if CollectionEventNoticeGui {
        try CollectionEventNoticeGui.Destroy()
    }
    CollectionEventNoticeGui := ""
}


StartAutoCollectionEventRun(*) {
    global CollectionEventSetupPending
    global CollectionEventRunActive
    global CollectionEventRunGeneration
    global CollectionEventCandidates
    global CollectionEventNeedsSelection
    global MacroRunning
    global LauncherGui
    global ForceLauncherVisible
    global RepeatScriptPath
    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted
    global UIColorError

    if MacroRunning || CollectionEventSetupPending
        return false

    CollectionEventSetupPending := true
    try {
        ; Keep the launcher inactive through setup so another
        ; click cannot start a different mode while this request is waiting.
        CloseModePicker()
        CloseScriptPicker()
        CloseQueueManager()
        CloseQueueJobBuilder()
        LauncherGui.Opt("+Disabled")
        candidates := DiscoverCollectionEventStrategies()
        if candidates.Length = 0 {
            UpdateStatus("NO EXPERT IMPOPPABLE SCRIPTS", UIColorError)
            return false
        }

        ; This information is always shown, even when generic confirmations
        ; are disabled. The existing Monkey Knowledge preference still applies.
        if !ShowCollectionEventNotice()
            return false
        if !ShowExpertImpoppableWarningIfNeeded()
            return false

        ; Hotkeys still yield while a dialog is open. Recheck ownership at start.
        if MacroRunning
            return false

        candidates := DiscoverCollectionEventStrategies()
        if candidates.Length = 0 {
            UpdateStatus("NO EXPERT IMPOPPABLE SCRIPTS", UIColorError)
            return false
        }

        ClearMacroContinuation()
        ClearRepeatRunState()
        ClearQueueExecutionState()
        ClearCycleStopRequest()
        CollectionEventRunActive := true
        CollectionEventCandidates := candidates
        CollectionEventNeedsSelection := true
        generation := CollectionEventRunGeneration

        RepeatScriptPath := ""
        ; Zero marks an open-ended total. A remaining value of one keeps the
        ; existing continuation path alive until cancellation clears the state.
        RepeatRunTotal := 0
        RepeatRunRemaining := 1
        RepeatRunCompleted := 0
        ForceLauncherVisible := false
        ClearLauncherReturnPending()
        SetLauncherRunSuppressed(true)
        SetRunHistoryCurrentSource("AUTO COLLECTION EVENT")
        CloseAllDarkDropdowns()
        CloseModePicker()
        CloseScriptPicker()
        CloseQueueManager()

        MacroRunning := true
        LauncherGui.Hide()
        RunStartupLoadingAnimation()

        ; Cancellation during startup owns cleanup and must not resurrect a HUD.
        if !CollectionEventRunActive || !MacroRunning || generation != CollectionEventRunGeneration
            return false
        LauncherGui.Hide()
        ShowCycleStatusUI()
        return StartNextQueuedRun()
    }
    finally {
        try LauncherGui.Opt("-Disabled")
        CollectionEventSetupPending := false
    }
}


PrepareCollectionEventCycle(generation, isRetry := false, defeatRestart := false) {
    global CollectionEventCandidates
    global CollectionEventExcludedPaths
    global CollectionEventCurrentCandidate
    global CollectionEventNeedsSelection
    global RepeatScriptPath
    global QueueCurrentRetryCount
    global UIColorWarning

    if !IsCurrentCollectionEventRun(generation)
        return false

    ; A defeat retry is already in the restarted map and must keep its strategy.
    if defeatRestart || (isRetry && !CollectionEventNeedsSelection)
        return true

    UpdateStatus("FINDING EVENT MAP...", UIColorWarning)
    try {
        if !SwitchToFullscreen() {
            StopCollectionEventRun("COULD NOT PREPARE BTD6 FULLSCREEN", generation)
            return false
        }
        if !IsCurrentCollectionEventRun(generation)
            return false

        ; Promos can obscure Play before the first scan or between event runs.
        ; The generation guard prevents a cancelled selection from resuming.
        homeResult := HandleHomeMenuInterruptions(IsCurrentCollectionEventRun.Bind(generation))
        if !IsCurrentCollectionEventRun(generation)
            return false
        if homeResult = "pending" {
            ; A nested call must wait for the reward owner, not start a map.
            CollectionEventNeedsSelection := true
            ScheduleMacroContinuation("event-reselect")
            return false
        }
        if homeResult = "blocked" {
            StopCollectionEventRun(GetHomeMenuInterruptionReason(), generation)
            return false
        }

        ; Chest clicks belong only on a positively recognized Home screen.
        ; Rejected candidates may leave us in a difficulty or mode menu.
        homeReady := IsHomeScreenVisible()
        if !IsCurrentCollectionEventRun(generation)
            return false
        if homeReady
            RunPreMapDailyChestIfEnabled()
        if !IsCurrentCollectionEventRun(generation)
            return false

        result := SelectCollectionEventStrategy(
            CollectionEventCandidates,
            CollectionEventExcludedPaths,
            IsCurrentCollectionEventRun.Bind(generation)
        )
        if !IsCurrentCollectionEventRun(generation)
            return false

        if result.status = "pending" {
            ; A reward can arrive inside map recovery after the first Home probe.
            ; Leave the current owner alone and retry selection on continuation.
            CollectionEventNeedsSelection := true
            ScheduleMacroContinuation("event-reselect")
            return false
        }
        if result.status != "selected" {
            reason := result.HasOwnProp("reason") && result.reason != ""
                ? result.reason : "NO USABLE EXPERT IMPOPPABLE MAPS"
            StopCollectionEventRun(reason, generation)
            return false
        }

        CollectionEventCurrentCandidate := result.candidate
        RepeatScriptPath := result.candidate.scriptPath
        CollectionEventNeedsSelection := false
        QueueCurrentRetryCount := 0
        UpdateStatus(
            (result.marked ? "EVENT MAP: " : "EXPERT MAP: ") . result.candidate.mapName,
            UIColorWarning
        )
        return true
    }
    catch Error as err {
        StopCollectionEventRun("EVENT MAP SELECTION FAILED: " . err.Message, generation)
        return false
    }
}


HandleCollectionEventCandidateUnavailable(reason) {
    global CollectionEventRunActive
    global CollectionEventRunGeneration
    global CollectionEventCurrentCandidate
    global CollectionEventExcludedPaths
    global CollectionEventNeedsSelection
    global UIColorWarning

    if !CollectionEventRunActive || InStr(reason, "EVENT CANDIDATE UNAVAILABLE") != 1
        return false
    generation := CollectionEventRunGeneration
    if !IsCurrentCollectionEventRun(generation)
        return true
    if !IsObject(CollectionEventCurrentCandidate) {
        StopCollectionEventRun(reason, generation)
        return true
    }

    pathKey := StrLower(StrReplace(CollectionEventCurrentCandidate.scriptPath, "/", "\"))
    CollectionEventExcludedPaths[pathKey] := true
    CollectionEventNeedsSelection := true
    UpdateStatus("TRYING ANOTHER EXPERT MAP...", UIColorWarning)
    if IsCurrentCollectionEventRun(generation)
        ScheduleMacroContinuation("event-reselect")
    return true
}


StopCollectionEventRun(reason, generation) {
    global MacroRunning
    global RunningPid
    global ActiveRunToken
    global ForceLauncherVisible
    global UIColorError

    if !IsCurrentCollectionEventRun(generation)
        return
    MacroRunning := false
    RunningPid := 0
    ClearChildRunResult(ActiveRunToken)
    ActiveRunToken := ""
    DestroyCycleStatusUI()
    ClearMacroContinuation()
    ClearRepeatRunState()
    ClearQueueExecutionState()
    ClearCycleStopRequest()
    ForceLauncherVisible := true
    ClearLauncherReturnPending()
    SetLauncherRunSuppressed(false)
    RecordRunHistoryFailure(reason)
    UpdateStatus("EVENT RUN STOPPED", UIColorError)
    ShowLauncher(true)
    ; Report terminal selection failures even if generic confirmations are off.
    MsgBox(reason, "Auto Collection Event")
}

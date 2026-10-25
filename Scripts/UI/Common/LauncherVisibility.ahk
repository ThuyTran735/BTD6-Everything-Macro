#Requires AutoHotkey v2.0

; Controls launcher visibility and the delay between child runs.
; Run suppression owns the screen until completion, cancellation, or an error releases it.

SetLauncherRunSuppressed(
    suppressed
) {
    global LauncherGui
    global LauncherRunSuppressed


    LauncherRunSuppressed :=
        !!suppressed


    if !LauncherGui {
        return
    }


    windowTitle :=
        "ahk_id "
        . LauncherGui.Hwnd


    if LauncherRunSuppressed {

        ; Transparency is intentional in addition to Hide().
        ; BTD6 can briefly change fullscreen/window composition
        ; while Play is opening the map screen. Even if Windows
        ; redraws the hidden tool window for a frame, opacity 0
        ; prevents the launcher from becoming visible.
        try {
            WinSetTransparent(
                0,
                windowTitle
            )
        }


        try {
            LauncherGui.Hide()
        }


        return
    }


    ; Restore normal opacity before the launcher is shown again.
    try {
        WinSetTransparent(
            255,
            windowTitle
        )
    }
}


BeginLauncherReturnPending() {
    global LauncherReturnPending
    global LauncherReturnPendingTick


    LauncherReturnPending :=
        true


    LauncherReturnPendingTick :=
        A_TickCount
}


ClearLauncherReturnPending() {
    global LauncherReturnPending
    global LauncherReturnPendingTick


    LauncherReturnPending :=
        false


    LauncherReturnPendingTick :=
        0
}


ScheduleMacroContinuation(
    action
) {
    global MacroContinuationAction
    global MacroContinuationTick


    MacroContinuationAction :=
        action


    MacroContinuationTick :=
        A_TickCount


    SetTimer(
        ContinueMacroWhenReady,
        250
    )
}


ClearMacroContinuation() {
    global MacroContinuationAction
    global MacroContinuationTick


    SetTimer(
        ContinueMacroWhenReady,
        0
    )


    MacroContinuationAction :=
        ""


    MacroContinuationTick :=
        0
}


IsCurrentHomePopupContinuation(action, tick) {
    global MacroRunning
    global CycleStatusClosing
    global MacroContinuationAction
    global MacroContinuationTick

    ; A popup wait may yield to Stop or a replacement continuation.
    return MacroRunning && !CycleStatusClosing
        && MacroContinuationAction = action && MacroContinuationTick = tick
}


ContinueMacroWhenReady() {
    global MacroRunning
    global MacroContinuationAction
    global MacroContinuationTick
    global UIColorError


    if MacroContinuationAction = "" {

        ClearMacroContinuation()

        return
    }


    if !MacroRunning {

        ClearMacroContinuation()

        return
    }

    ; Candidate rejection happens before gameplay. The selector handles bounded
    ; recovery from the mode menu, so it need not wait for the Home timeout.
    if MacroContinuationAction = "event-reselect" {
        ClearMacroContinuation()
        StartNextQueuedRun(true)
        return
    }

    ; A Home promo can hide Play, so dismiss recognized interruptions before
    ; waiting for Home or handing control to the chest and event-map routines.
    continuationAction := MacroContinuationAction
    continuationTick := MacroContinuationTick
    isCurrent := IsCurrentHomePopupContinuation.Bind(continuationAction, continuationTick)
    homeResult := HandleHomeMenuInterruptions(isCurrent)
    if !isCurrent.Call()
        return
    ; A reward sequence owns its full wait. Neither a busy owner nor a failure
    ; may fall through to the ordinary eight-second Home-detection fallback.
    if homeResult = "pending"
        return
    if homeResult = "blocked" {
        reason := GetHomeMenuInterruptionReason()
        CancelMacroCycles()
        RecordRunHistoryFailure(reason)
        UpdateStatus("COLLECTION REWARDS FAILED", UIColorError)
        MsgBox(reason, "Collection Event Rewards")
        return
    }

    homeReady :=
        IsHomeScreenVisible()
    if !isCurrent.Call()
        return


    ; Home detection gets a short grace period; the timeout prevents a missed
    ; frame from leaving the continuation timer waiting indefinitely.
    timedOut :=
        continuationTick
        && A_TickCount
            - continuationTick
            >= 8000


    if (
        !homeReady
        && !timedOut
    ) {
        return
    }


    ; Consume this scheduled action before starting another child so it runs once.
    action :=
        continuationAction


    ClearMacroContinuation()


    if action = "next-run" {

        StartNextQueuedRun()

        return
    }


    if action = "retry-run" {

        StartNextQueuedRun(true)

        return
    }


    if action = "next-job" {

        StartNextQueueJob()
    }
}


ShowLauncher(
    activate := false
) {
    global LauncherGui
    global LauncherRunSuppressed
    global GuiWidth
    global GuiHeight
    global GuiX
    global GuiY


    ; Never permit a normal Show() while a run owns the screen.
    ; Call SetLauncherRunSuppressed(false) first for an explicit
    ; cancel/error/completion return to the launcher.
    if LauncherRunSuppressed {

        if IsLauncherVisible() {
            LauncherGui.Hide()
        }


        return false
    }


    PositionLauncher()


    options :=
        "x"
        . GuiX
        . " y"
        . GuiY
        . " w"
        . GuiWidth
        . " h"
        . GuiHeight


    if !activate {

        options :=
            "NA "
            . options
    }


    LauncherGui.Show(
        options
    )


    return true
}


HideLauncher() {
    global LauncherGui


    if IsLauncherVisible() {

        LauncherGui.Hide()
    }
}


CloseAllSecondaryMenus() {
    ; The main launcher stays visible while the user configures the macro.
    ; Only one secondary menu is allowed at a time.
    try CloseModePicker()
    try CloseScriptPicker()
    try CloseQueueManager()
    try DestroyQueueJobBuilder(false)
    try CloseQueueProfilesManager()
    try CloseSettingsUI()
    try CloseLogsUI()
    try CloseUserDataTransferUI()
    try CloseRunHistoryUI()
    try CloseRetryRecoveryUI()
}


IsLauncherVisible() {
    global LauncherGui


    if !LauncherGui {

        return false
    }


    return !!DllCall(
        "IsWindowVisible",
        "Ptr",
        LauncherGui.Hwnd
    )
}

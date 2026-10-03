#Requires AutoHotkey v2.0

; v3 file note: Handles launcher suppression, continuation, show/hide, and secondary-menu cleanup.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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


ContinueMacroWhenReady() {
    global MacroRunning
    global MacroContinuationAction
    global MacroContinuationTick


    if MacroContinuationAction = "" {

        ClearMacroContinuation()

        return
    }


    if !MacroRunning {

        ClearMacroContinuation()

        return
    }


    homeReady :=
        IsHomeScreenVisible()


    timedOut :=
        MacroContinuationTick
        && A_TickCount
            - MacroContinuationTick
            >= 8000


    if (
        !homeReady
        && !timedOut
    ) {
        return
    }


    action :=
        MacroContinuationAction


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
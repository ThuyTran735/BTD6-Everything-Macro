#Requires AutoHotkey v2.0


PositionLauncher() {
    global LauncherGui
    global GuiWidth
    global GuiHeight
    global GuiX
    global GuiY


    screenLeft := 0
    screenTop := 0
    screenRight := 1920
    screenBottom := 1080


    windowWidth :=
        GuiWidth


    windowHeight :=
        GuiHeight


    rect :=
        Buffer(
            16,
            0
        )


    gotRect :=
        DllCall(
            "GetWindowRect",
            "Ptr",
            LauncherGui.Hwnd,
            "Ptr",
            rect.Ptr,
            "Int"
        )


    if gotRect {

        rectLeft :=
            NumGet(
                rect,
                0,
                "Int"
            )


        rectTop :=
            NumGet(
                rect,
                4,
                "Int"
            )


        rectRight :=
            NumGet(
                rect,
                8,
                "Int"
            )


        rectBottom :=
            NumGet(
                rect,
                12,
                "Int"
            )


        measuredWidth :=
            rectRight
            - rectLeft


        measuredHeight :=
            rectBottom
            - rectTop


        if measuredWidth > 0 {

            windowWidth :=
                measuredWidth
        }


        if measuredHeight > 0 {

            windowHeight :=
                measuredHeight
        }
    }


    GuiX :=
        screenLeft


    GuiY :=
        screenBottom
        - windowHeight


    if GuiX < screenLeft {

        GuiX :=
            screenLeft
    }


    if GuiY < screenTop {

        GuiY :=
            screenTop
    }


    if GuiX + windowWidth > screenRight {

        GuiX :=
            screenRight
            - windowWidth
    }


    if GuiY + windowHeight > screenBottom {

        GuiY :=
            screenBottom
            - windowHeight
    }


    GuiX :=
        Round(
            GuiX
        )


    GuiY :=
        Round(
            GuiY
        )
}


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


ApplyModernWindowStyle() {
    global LauncherGui


    ApplyDarkWindowStyle(
        LauncherGui
    )
}


ApplyDarkWindowStyle(
    guiObject
) {
    try {

        darkMode :=
            Buffer(
                4,
                0
            )


        NumPut(
            "Int",
            1,
            darkMode,
            0
        )


        DllCall(
            "dwmapi\DwmSetWindowAttribute",
            "Ptr",
            guiObject.Hwnd,
            "Int",
            20,
            "Ptr",
            darkMode.Ptr,
            "Int",
            4
        )
    }


    try {

        cornerPreference :=
            Buffer(
                4,
                0
            )


        NumPut(
            "Int",
            2,
            cornerPreference,
            0
        )


        DllCall(
            "dwmapi\DwmSetWindowAttribute",
            "Ptr",
            guiObject.Hwnd,
            "Int",
            33,
            "Ptr",
            cornerPreference.Ptr,
            "Int",
            4
        )
    }
}


ApplyDarkControlTheme(
    control
) {
    global UIColorInputBackground
    global UIColorInputText


    if !control {

        return
    }


    ; Use a flat native edit surface and let our custom Progress border
    ; provide the outline. This keeps every input consistent with the
    ; rest of the dark UI instead of inheriting a Windows light edge.
    try {
        control.Opt(
            "-Border -E0x200 -VScroll -HScroll c"
            . UIColorInputText
            . " Background"
            . UIColorInputBackground
        )
    }


    ; Remove the native horizontal/vertical scrollbar style bits directly.
    ; Some Windows themes can keep drawing the small up/down arrow chrome
    ; on Edit controls even after -VScroll/-HScroll has been applied.
    try {
        style := DllCall(
            "GetWindowLongPtr",
            "Ptr",
            control.Hwnd,
            "Int",
            -16,
            "Ptr"
        )

        style &= ~0x00300000

        DllCall(
            "SetWindowLongPtr",
            "Ptr",
            control.Hwnd,
            "Int",
            -16,
            "Ptr",
            style,
            "Ptr"
        )

        DllCall(
            "SetWindowPos",
            "Ptr",
            control.Hwnd,
            "Ptr",
            0,
            "Int",
            0,
            "Int",
            0,
            "Int",
            0,
            "Int",
            0,
            "UInt",
            0x37
        )
    }


    try {

        DllCall(
            "uxtheme\SetWindowTheme",
            "Ptr",
            control.Hwnd,
            "Str",
            "DarkMode_Explorer",
            "Str",
            ""
        )
    }


    try {

        DllCall(
            "RedrawWindow",
            "Ptr",
            control.Hwnd,
            "Ptr",
            0,
            "Ptr",
            0,
            "UInt",
            0x85
        )
    }
}


UpdateStatus(
    text,
    color := ""
) {
    global StatusText
    global UIColorSuccess


    if !StatusText {

        return
    }


    if color = "" {

        color :=
            UIColorSuccess
    }


    StatusText.SetFont(
        "c"
        . color
    )


    StatusText.Text :=
        text
}


IsInGameScreen() {
    global NavigationPatterns


    if !NavigationPatterns.Has(
        "Settings"
    ) {

        return false
    }


    return PatternExists(
        NavigationPatterns[
            "Settings"
        ]
    )
}


CreateChildRunToken() {
    return A_TickCount . "-" . Random(100000, 999999)
}


GetChildRunResultPath(token) {
    if token = ""
        return ""

    return A_Temp . "\\BTD6EverythingMacro_RunResult_" . token . ".ini"
}


ClearChildRunResult(token) {
    path := GetChildRunResultPath(token)
    if path = ""
        return

    try FileDelete(path)
}


ReadChildRunResult(token) {
    result := {
        status: "Missing",
        reason: "NO RESULT REPORTED"
    }

    path := GetChildRunResultPath(token)
    if path = "" || !FileExist(path)
        return result

    try {
        result.status := IniRead(path, "Result", "Status", "Missing")
        result.reason := IniRead(path, "Result", "Reason", "")
    }

    try FileDelete(path)
    return result
}


GetCycleStopRequestPath() {
    return A_Temp
        . "\BTD6EverythingMacro_StopCycles.flag"
}


ClearCycleStopRequest() {
    stopFile :=
        GetCycleStopRequestPath()


    try {
        FileDelete(
            stopFile
        )
    }
}


ConsumeCycleStopRequest() {
    stopFile :=
        GetCycleStopRequestPath()


    if !FileExist(
        stopFile
    ) {

        return false
    }


    try {
        FileDelete(
            stopFile
        )
    }


    return true
}


MonitorLauncherState() {
    global MacroRunning
    global RunningPid
    global ActiveRunToken

    global RepeatRunTotal
    global RepeatRunRemaining
    global RepeatRunCompleted

    global QueueRunning
    global QueueActiveJobIndex
    global QueueTotalJobs
    global QueueCompletedRuns
    global QueueCurrentRetryCount

    global ForceLauncherVisible
    global StartupLoadingActive
    global LauncherRunSuppressed
    global LauncherReturnPending
    global LauncherReturnPendingTick

    global LauncherGui

    global UIColorSuccess
    global UIColorError


    ; Do not let the normal launcher appear on top
    ; of the fake startup loading screen.
    if StartupLoadingActive {

        if IsLauncherVisible() {
            LauncherGui.Hide()
        }


        return
    }


    ; Explicit cancel/error requests are allowed to return to the
    ; launcher immediately. They override the transition guard.
    if ForceLauncherVisible {

        ClearLauncherReturnPending()
        SetLauncherRunSuppressed(false)


        if !IsLauncherVisible() {

            ShowLauncher(
                false
            )
        }


        return
    }


    if MacroRunning {

        ; While the child process is alive, suppression is a hard
        ; invariant. This also re-applies opacity 0 if Windows
        ; changed window composition during a BTD6 transition.
        SetLauncherRunSuppressed(true)


        if (
            RunningPid
            && !ProcessExist(
                RunningPid
            )
        ) {

            RunningPid :=
                0


            if ConsumeCycleStopRequest() {

                childResult := ReadChildRunResult(ActiveRunToken)
                ActiveRunToken := ""

                stopReason := (
                    childResult.status = "Failed"
                    && childResult.reason != ""
                )
                    ? childResult.reason
                    : "MAP SEARCH STOPPED"


                MacroRunning :=
                    false


                HideCycleStatusUI()


                ClearRepeatRunState()
                ClearQueueExecutionState()


                ForceLauncherVisible :=
                    true


                ClearLauncherReturnPending()
                SetLauncherRunSuppressed(false)


                UpdateStatus(
                    stopReason,
                    UIColorError
                )


                RecordRunHistoryFailure(
                    stopReason
                )


                ShowLauncher(
                    true
                )


                return
            }


            childResult := ReadChildRunResult(ActiveRunToken)
            ActiveRunToken := ""


            if childResult.status != "Success" {

                reason := childResult.reason != ""
                    ? childResult.reason
                    : "CHILD SCRIPT FAILED"


                if (
                    QueueRunning
                    && IsQueueAutoRetryEnabled()
                    && GetQueueRetryLimit() > 0
                    && QueueCurrentRetryCount < GetQueueRetryLimit()
                ) {
                    QueueCurrentRetryCount++

                    UpdateStatus(
                        "RETRY "
                        . QueueCurrentRetryCount
                        . " / "
                        . GetQueueRetryLimit(),
                        UIColorError
                    )

                    UpdateCycleStatusUI()
                    ScheduleMacroContinuation("retry-run")
                    return
                }


                queueWasRunning := QueueRunning

                MacroRunning := false
                HideCycleStatusUI()

                ClearRepeatRunState()
                ClearQueueExecutionState()
                ClearMacroContinuation()

                ForceLauncherVisible := true
                ClearLauncherReturnPending()
                SetLauncherRunSuppressed(false)

                UpdateStatus(
                    queueWasRunning
                        ? "QUEUE FAILED"
                        : "RUN FAILED",
                    UIColorError
                )

                RecordRunHistoryFailure(reason)
                ShowLauncher(true)
                return
            }


            QueueCurrentRetryCount := 0


            RepeatRunCompleted++


            RecordRunHistoryCycle()


            if QueueRunning {

                QueueCompletedRuns++
            }


            UpdateCycleStatusUI()


            if RepeatRunRemaining > 0 {

                nextRun :=
                    RepeatRunCompleted
                    + 1


                UpdateStatus(
                    "RUN "
                    . nextRun
                    . " OF "
                    . RepeatRunTotal,
                    UIColorSuccess
                )


                ; Keep suppression active and wait until BTD6 is
                ; actually back on Home before launching the next
                ; child cycle. A timeout fallback prevents a stale
                ; Home detector from permanently stalling the run.
                ScheduleMacroContinuation(
                    "next-run"
                )


                return
            }


            if (
                QueueRunning
                && QueueActiveJobIndex < QueueTotalJobs
            ) {

                UpdateStatus(
                    "JOB "
                    . QueueActiveJobIndex
                    . " OF "
                    . QueueTotalJobs
                    . " COMPLETE",
                    UIColorSuccess
                )


                ; The current job is finished. Keep the launcher
                ; suppressed while BTD6 returns Home, then start
                ; the next queued job automatically.
                ScheduleMacroContinuation(
                    "next-job"
                )


                return
            }


            queueWasRunning :=
                QueueRunning


            if queueWasRunning {

                completedRuns :=
                    QueueCompletedRuns
            }
            else {

                completedRuns :=
                    RepeatRunCompleted
            }


            MacroRunning :=
                false


            RecordRunHistorySuccess()


            CompleteCycleStatusUI()


            Sleep(
                400
            )


            HideCycleStatusUI()


            ClearRepeatRunState()
            ClearCycleStopRequest()


            if queueWasRunning {

                if completedRuns = 1 {

                    UpdateStatus(
                        "QUEUE COMPLETE - 1 RUN",
                        UIColorSuccess
                    )
                }
                else {

                    UpdateStatus(
                        "QUEUE COMPLETE - "
                        . completedRuns
                        . " RUNS",
                        UIColorSuccess
                    )
                }


                ClearQueueExecutionState()
            }
            else if completedRuns = 1 {

                UpdateStatus(
                    "COMPLETED 1 RUN",
                    UIColorSuccess
                )
            }
            else {

                UpdateStatus(
                    "COMPLETED "
                    . completedRuns
                    . " RUNS",
                    UIColorSuccess
                )
            }


            ClearMacroContinuation()


            ; The child can disappear during a menu/fullscreen
            ; transition. Do not immediately interpret that as
            ; permission to paint the launcher. Wait until Home is
            ; positively visible; use a fallback only for a real
            ; child failure that never reaches Home.
            BeginLauncherReturnPending()


            return
        }
        else {

            UpdateCycleStatusUI()


            if IsLauncherVisible() {
                LauncherGui.Hide()
            }


            return
        }
    }


    if LauncherReturnPending {

        if IsHomeScreenVisible() {

            ; Final-cycle completion is an explicit return to the
            ; launcher. Keep it visible until the user starts another
            ; run instead of allowing the normal screen monitor to
            ; hide it again on the next timer tick.
            ForceLauncherVisible :=
                true


            ClearLauncherReturnPending()
            SetLauncherRunSuppressed(false)


            ShowLauncher(
                true
            )


            return
        }


        ; A genuine script error may terminate away from Home.
        ; Keep the launcher invisible long enough for normal BTD6
        ; transitions to settle, then give control back to the user.
        if (
            LauncherReturnPendingTick
            && A_TickCount
                - LauncherReturnPendingTick
                < 8000
        ) {

            SetLauncherRunSuppressed(true)


            return
        }


        ; Fallback return: do not fall through into IsInGameScreen().
        ; That could immediately hide the launcher again and strand
        ; the user with no UI after a completed cycle.
        ForceLauncherVisible :=
            true


        ClearLauncherReturnPending()
        SetLauncherRunSuppressed(false)


        ShowLauncher(
            true
        )


        return
    }


    ; Idle/configuration state: keep the launcher visible regardless of
    ; the current BTD6 screen. It only hides during an actual run.
    if !IsLauncherVisible() {

        ShowLauncher(
            false
        )
    }
}
#Requires AutoHotkey v2.0

; v3 file note: Watches the child macro state and decides when the launcher should come back.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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


                canRetry :=
                    IsQueueAutoRetryEnabled()
                    && GetQueueRetryLimit() > 0
                    && QueueCurrentRetryCount < GetQueueRetryLimit()

                defeatFailure :=
                    InStr(reason, "DEFEAT") = 1

                ; Queue retries keep their existing behavior for any
                ; failure. Manual/EXP runs now also retry real defeats.
                if (
                    canRetry
                    && (QueueRunning || defeatFailure)
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

                    ; A defeat leaves BTD6 on the defeat screen, so a
                    ; normal fresh-process retry cannot navigate from Home.
                    ; Restart the map first, then launch the same strategy
                    ; in a fresh process that resumes from the restarted map.
                    if defeatFailure {
                        if HandleDefeat() {
                            StartNextQueuedRun(true, true)
                            return
                        }

                        reason := "DEFEAT - RESTART RECOVERY FAILED"
                    }
                    else {
                        ScheduleMacroContinuation("retry-run")
                        return
                    }
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
#Requires AutoHotkey v2.0

; Moves through victory screens or restarts a defeated run.
; These transitions release modifiers before clicks so held keys cannot change the menu action.

HandleVictory() {
    global GameStatePatterns


    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        GameStatePatterns["VictoryNext"]
    ) {
        return false
    }


    ReleaseMacroModifierKeys()


    Click(
        X,
        Y
    )


    Sleep(
        700
    )


    Loop 30 {

        if FindText(
            &X,
            &Y,
            0,
            0,
            A_ScreenWidth,
            A_ScreenHeight,
            0,
            0,
            GameStatePatterns["VictoryHome"]
        ) {

            ReleaseMacroModifierKeys()


            Click(
                X,
                Y
            )


            ; Home may appear before its collection rewards finish loading.
            ; Let that transition settle before checking popups or ending the run.
            Sleep(
                3000
            )


            ReleaseMacroModifierKeys()


            ; Logged-out players can receive a login
            ; prompt after returning Home.
            HandleLoginNotNowPrompt(
                3000
            )

            ; Home promos can appear after the login prompt or a finished game.
            ; Clear them even when this is the last requested cycle.
            homeResult := HandleHomeMenuInterruptions()
            if homeResult = "blocked"
                return false
            if homeResult = "pending"
                return SetRunFailureReason("COLLECTION REWARDS BUSY", "Another handler still owns the reward screen")


            ReleaseMacroModifierKeys()


            return true
        }


        Sleep(
            200
        )
    }


    ToolTip(
        "Could not find Home button after victory."
    )


    return false
}


HandleDefeat() {
    global GameStatePatterns


    if !GameStatePatterns.Has(
        "Restart"
    ) {

        ToolTip(
            "Restart pattern is missing."
        )


        return false
    }


    firstRestart :=
        GameStatePatterns["Restart"]


    if !FindText(
        &X,
        &Y,
        0,
        0,
        A_ScreenWidth,
        A_ScreenHeight,
        0,
        0,
        firstRestart
    ) {

        ToolTip(
            "Could not find first Restart button."
        )


        return false
    }


    Click(
        X,
        Y
    )


    Sleep(
        500
    )


    ; Some modes show a second restart confirmation.
    if GameStatePatterns.Has(
        "Restart Confirm"
    ) {

        confirmPattern :=
            GameStatePatterns[
                "Restart Confirm"
            ]


        Loop 15 {

            if FindText(
                &X,
                &Y,
                0,
                0,
                A_ScreenWidth,
                A_ScreenHeight,
                0,
                0,
                confirmPattern
            ) {

                Click(
                    X,
                    Y
                )


                Sleep(
                    700
                )


                return true
            }


            Sleep(
                200
            )
        }


        ToolTip(
            "Could not find second Restart button."
        )


        Sleep(
            1500
        )


        ToolTip()


        return false
    }


    return true
}



#Requires AutoHotkey v2.0

; v3 file note: Handles victory and defeat so the runner can finish or retry cleanly.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

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


            Sleep(
                700
            )


            ReleaseMacroModifierKeys()


            ; Logged-out players can receive a login
            ; prompt after returning Home.
            HandleLoginNotNowPrompt(
                3000
            )


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



#Requires AutoHotkey v2.0


global GameModePrerequisites := Map(
    ; Easy
    "Primary Only", "Standard",
    "Deflation", "Primary Only",

    ; Medium
    "Military Only", "Standard",
    "Apopalypse", "Military Only",
    "Reverse", "Standard",

    ; Hard - Magic branch
    "Magic Monkeys Only", "Standard",
    "Double HP MOABs", "Magic Monkeys Only",
    "Half Cash", "Double HP MOABs",

    ; Hard - ABR branch
    "Alternate Bloons Rounds", "Standard",
    "Impoppable", "Alternate Bloons Rounds",
    "CHIMPS", "Impoppable"
)


global GameModeScriptSuffixes := Map(
    "Primary Only", "PrimaryOnly",
    "Deflation", "Deflation",

    "Military Only", "MilitaryOnly",
    "Apopalypse", "Apopalypse",
    "Reverse", "Reverse",

    "Magic Monkeys Only", "MagicOnly",
    "Double HP MOABs", "DoubleHPMOABs",
    "Half Cash", "HalfCash",

    "Alternate Bloons Rounds", "AlternateBloonsRounds",
    "Impoppable", "Impoppable",
    "CHIMPS", "CHIMPS"
)


GetGameModePrerequisite(gameMode) {
    global GameModePrerequisites


    if !GameModePrerequisites.Has(gameMode)
        return false


    return GameModePrerequisites[gameMode]
}


GetGameModeScriptSuffix(gameMode, difficulty) {
    global GameModeScriptSuffixes


    ; Standard scripts use the difficulty as their suffix.
    ;
    ; Examples:
    ;
    ; InTheLoopEasy.ahk
    ; InTheLoopMedium.ahk
    ; InTheLoopHard.ahk
    if gameMode = "Standard"
        return difficulty


    if !GameModeScriptSuffixes.Has(gameMode)
        return false


    return GameModeScriptSuffixes[gameMode]
}


GetCurrentMapScriptBaseName() {
    global RunConfig


    scriptName := A_ScriptName


    if SubStr(scriptName, -4) = ".ahk"
        scriptName := SubStr(
            scriptName,
            1,
            StrLen(scriptName) - 4
        )


    currentSuffix := GetGameModeScriptSuffix(
        RunConfig.gameMode,
        RunConfig.difficulty
    )


    if !currentSuffix
        return false


    suffixLength := StrLen(currentSuffix)


    if suffixLength > StrLen(scriptName)
        return false


    if SubStr(
        scriptName,
        StrLen(scriptName) - suffixLength + 1
    ) != currentSuffix {
        return false
    }


    return SubStr(
        scriptName,
        1,
        StrLen(scriptName) - suffixLength
    )
}


GetPrerequisiteScriptPath(gameMode) {
    global RunConfig


    prerequisite := GetGameModePrerequisite(
        gameMode
    )


    if !prerequisite
        return false


    baseName := GetCurrentMapScriptBaseName()


    if !baseName
        return false


    prerequisiteSuffix := GetGameModeScriptSuffix(
        prerequisite,
        RunConfig.difficulty
    )


    if !prerequisiteSuffix
        return false


    return (
        A_ScriptDir
        "\"
        baseName
        prerequisiteSuffix
        ".ahk"
    )
}


TryRunPrerequisiteMode(gameMode) {
    prerequisite := GetGameModePrerequisite(
        gameMode
    )


    if !prerequisite {
        ToolTip(
            "No prerequisite configured."
            "`nGame mode: " gameMode
        )

        Sleep(2000)
        ToolTip()

        return false
    }


    prerequisiteScript := GetPrerequisiteScriptPath(
        gameMode
    )


    if !prerequisiteScript {
        ToolTip(
            "Could not determine prerequisite script."
            "`nRequested: " gameMode
            "`nRequired: " prerequisite
        )

        Sleep(2500)
        ToolTip()

        return false
    }


    if !FileExist(prerequisiteScript) {
        ToolTip(
            "Required game mode is locked."
            "`nRequested: " gameMode
            "`nRequired: " prerequisite
            "`nMissing strategy:"
            "`n" prerequisiteScript
        )

        Sleep(3500)
        ToolTip()

        return false
    }


    ToolTip(
        gameMode " is locked."
        "`nRunning prerequisite:"
        "`n" prerequisite
    )

    Sleep(1500)
    ToolTip()


    quote := Chr(34)


    command := (
        quote
        A_AhkPath
        quote
        " "
        quote
        prerequisiteScript
        quote
    )


    RunWait(command)


    ; The prerequisite script should finish back
    ; at the home screen after Victory handling.
    Sleep(1000)


    return true
}
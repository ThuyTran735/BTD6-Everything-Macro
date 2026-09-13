#Requires AutoHotkey v2.0

#Include ..\..\..\..\Scripts\IncludeAll.ahk


MonkeyMeadowEasy() {
    global RunConfig := {
        category: "Beginner",
        map: "Monkey Meadow",
        difficulty: "Easy",
        gameMode: "Standard",

        hero: "Quincy",

        ; Maximum number of attempts before giving up.
        maxAttempts: 3,

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 495,
            y: 504,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart A", {
            type: "Dart",
            x: 316,
            y: 405,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart B", {
            type: "Dart",
            x: 316,
            y: 200,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart C", {
            type: "Dart",
            x: 130,
            y: 509,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Dart D", {
            type: "Dart",
            x: 255,
            y: 604,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },

        "Boomerang A", {
            type: "Boomerang",
            x: 308,
            y: 508,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        }
    )


    strategy := [
        ; Round 0 = before Round 1 starts.

        [0, 0, () => PlaceTower(
            TowerSetup["Hero"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Dart A"]
        )],

        [0, 0, () => PlaceTower(
            TowerSetup["Boomerang A"]
        )],

        [2, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "002"
        )],

        [4, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "202"
        )],

        [6, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "002"
        )],

        [8, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "022"
        )],

        [10, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "023"
        )],

        [15, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "203"
        )],

        [15, 0, () => SetTargeting(
            TowerSetup["Boomerang A"],
            "Last"
        )],

        [23, 0, () => UpgradeTower(
            TowerSetup["Boomerang A"],
            "204"
        )],

        [27, 0, () => UpgradeTower(
            TowerSetup["Dart A"],
            "024"
        )],

        [28, 0, () => PlaceTower(
            TowerSetup["Dart B"]
        )],

        [28, 0, () => UpgradeTower(
            TowerSetup["Dart B"],
            "024"
        )],

        [34, 0, () => PlaceTower(
            TowerSetup["Dart C"]
        )],

        [34, 0, () => UpgradeTower(
            TowerSetup["Dart C"],
            "024"
        )],

        [38, 0, () => PlaceTower(
            TowerSetup["Dart D"]
        )],

        [38, 0, () => UpgradeTower(
            TowerSetup["Dart D"],
            "024"
        )],

        [40, 0, () => UseAbility("1")]
    ]


    if !NavigateToMap(
        RunConfig.category,
        RunConfig.map,
        RunConfig.difficulty,
        RunConfig.gameMode,
        RunConfig.hero
    ) {
        return false
    }


    if !WaitForGameLoad()
        return false


    maxAttempts := HasProp(RunConfig, "maxAttempts")
        ? RunConfig.maxAttempts
        : 3


    Loop maxAttempts {
        attempt := A_Index


        ResetRoundTracking()
        ResetTowerSetup()


        ; All tower placement, including Hero placement,
        ; is controlled by the strategy.
        pregameResult := RunPregameStrategy(
            strategy
        )


        if pregameResult = "Victory" {
            if !HandleVictory()
                return false

            return true
        }


        if pregameResult = "Defeat" {
            if attempt >= maxAttempts
                return false


            if !HandleDefeat()
                return false


            if !WaitForGameLoad()
                return false


            continue
        }


        if pregameResult = false
            return false


        ; Start clean round tracking immediately
        ; before Round 1 begins.
        ResetRoundTracking()


        if !StartGame()
            return false


        result := RunStrategy(
            strategy
        )


        if result = "Victory" {
            if !HandleVictory()
                return false

            return true
        }


        if result = "Defeat" {
            if attempt >= maxAttempts {
                ToolTip(
                    "Maximum attempts reached."
                    "`nAttempts: " attempt
                )

                Sleep(2000)
                ToolTip()

                return false
            }


            if !HandleDefeat()
                return false


            ; Restart returns us to Round 1.
            ; Wait until the game UI is ready again.
            if !WaitForGameLoad()
                return false


            continue
        }


        return false
    }


    return false
}

Sleep(3000)
MonkeyMeadowEasy()
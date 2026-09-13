#Requires AutoHotkey v2.0

#Include ..\Scripts\IncludeAll.ahk
; Delete this ^^^ Only here to stop error messages

; #Include Location Of IncludeAll.ahk


MapNameDifficultyMode() {
    global RunConfig := {
        category: "Beginner",
        map: "MAP NAME",
        difficulty: "Easy",
        gameMode: "Standard",

        ; Use false if this strategy does not need a hero.
        ; Example:
        ; hero: "Quincy"
        ; hero: false
        hero: false,

        ; Maximum number of attempts before giving up.
        maxAttempts: 3,

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false
    }


    global TowerSetup := Map(
        "Hero", {
            type: "Hero",
            x: 0,
            y: 0,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Tower A", {
            type: "Dart",
            x: 0,
            y: 0,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Sniper A", {
            type: "Sniper",
            x: 0,
            y: 0,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First"
        },


        "Ace A", {
            type: "Ace",
            x: 0,
            y: 0,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "Circle"
        },


        "Sub A", {
            type: "Sub",
            x: 0,
            y: 0,
            placed: false,
            upgrades: [0, 0, 0],
            targeting: "First",
            targetingBeforeSubmerge: "First",
            submerged: false
        }
    )


    strategy := [
        ; Round 0 = before Round 1 starts.

        ; Hero placement example.
        ; Place at Round 0:
        ;
        ; [0, 0, () => PlaceTower(
        ;     TowerSetup["Hero"]
        ; )],
        ;
        ; Or place later:
        ;
        ; [6, 0, () => PlaceTower(
        ;     TowerSetup["Hero"]
        ; )],


        ; Normal placement example
        [0, 0, () => PlaceTower(
            TowerSetup["Tower A"]
        )],


        ; Normal upgrade example
        [3, 0, () => UpgradeTower(
            TowerSetup["Tower A"],
            "002"
        )],


        ; Normal targeting example
        [5, 0, () => SetTargeting(
            TowerSetup["Tower A"],
            "Last"
        )],


        ; Another upgrade example
        [7, 0, () => UpgradeTower(
            TowerSetup["Tower A"],
            "022"
        )],


        ; Strong targeting example
        [10, 0, () => SetTargeting(
            TowerSetup["Tower A"],
            "Strong"
        )],


        ; Sniper placement example
        ; [0, 0, () => PlaceTower(
        ;     TowerSetup["Sniper A"]
        ; )],


        ; Elite Sniper example
        ; Once a Sniper reaches 050,
        ; Elite targeting becomes available to Snipers.
        ;
        ; [30, 0, () => UpgradeTower(
        ;     TowerSetup["Sniper A"],
        ;     "050"
        ; )],


        ; Elite targeting example
        ;
        ; [31, 0, () => SetTargeting(
        ;     TowerSetup["Sniper A"],
        ;     "Elite"
        ; )],


        ; Monkey Ace placement example
        ;
        ; [0, 0, () => PlaceTower(
        ;     TowerSetup["Ace A"]
        ; )],


        ; Normal Ace targeting examples:
        ;
        ; Circle
        ; Figure Infinite
        ; Figure Eight
        ;
        ; Wingmonkey is also available when:
        ; wingmonkeyMK: true
        ;
        ; [5, 0, () => SetTargeting(
        ;     TowerSetup["Ace A"],
        ;     "Figure Eight"
        ; )],


        ; Centered Path example.
        ; xx2 automatically changes the Ace
        ; targeting state to Centered Path.
        ;
        ; [10, 0, () => UpgradeTower(
        ;     TowerSetup["Ace A"],
        ;     "002"
        ; )],


        ; Change away from Centered Path later:
        ;
        ; [15, 0, () => SetTargeting(
        ;     TowerSetup["Ace A"],
        ;     "Circle"
        ; )],


        ; Wingmonkey example:
        ; Requires wingmonkeyMK: true
        ;
        ; [15, 0, () => SetTargeting(
        ;     TowerSetup["Ace A"],
        ;     "Wingmonkey"
        ; )],


        ; Monkey Sub placement example
        ;
        ; [0, 0, () => PlaceTower(
        ;     TowerSetup["Sub A"]
        ; )],


        ; Submerge becomes available at 3xx+
        ;
        ; [10, 0, () => UpgradeTower(
        ;     TowerSetup["Sub A"],
        ;     "300"
        ; )],


        ; Submerge with Page Down
        ;
        ; [11, 0, () => SetSubmerge(
        ;     TowerSetup["Sub A"],
        ;     true
        ; )],


        ; Unsubmerge
        ;
        ; [20, 0, () => SetSubmerge(
        ;     TowerSetup["Sub A"],
        ;     false
        ; )],


        ; Normal Sub targeting still works separately
        ;
        ; [21, 0, () => SetTargeting(
        ;     TowerSetup["Sub A"],
        ;     "Strong"
        ; )],


        ; Mid-round action example.
        ; This means 5000 ms into Round 20.
        ; [20, 5000, () => UseAbility("1")]
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


        ; Start clean tracking immediately
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


            ; Restart puts us back at Round 1.
            ; Wait for the in-game Settings
            ; button again before rebuilding.
            if !WaitForGameLoad()
                return false


            continue
        }


        return false
    }


    return false
}


MapNameDifficultyMode()
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
        ;
        ; Examples:
        ; hero: "Quincy"
        ; hero: false
        hero: false,

        ; Maximum number of attempts before giving up.
        maxAttempts: 3,

        ; Set true if Wingmonkey Monkey Knowledge is enabled.
        wingmonkeyMK: false,

        ; Deflation only:
        ;
        ; Deflation starts on Round 31 and ends on Round 60.
        ; Uncomment these when creating a Deflation strategy.
        ;
        ; Also change:
        ; gameMode: "Standard",
        ;
        ; to:
        ; gameMode: "Deflation",
        ;
        ; startRound: 31,
        ; endRound: 60,
        ;
        ; Round 0 is still used for the initial Deflation setup.
        ; After StartGame(), actual round tracking begins at Round 31.
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
        ; Round 0 = before the first actual round starts.
        ;
        ; Normal Easy:
        ; Round 0 -> setup
        ; Round 1 -> first actual round
        ; Round 40 -> final round
        ;
        ; Deflation:
        ; Round 0 -> setup
        ; Round 31 -> first actual round
        ; Round 60 -> final round


        ; Hero placement example.
        ;
        ; Place during Round 0:
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


        ; Normal tower placement
        [0, 0, () => PlaceTower(
            TowerSetup["Tower A"]
        )],


        ; Normal upgrade
        [3, 0, () => UpgradeTower(
            TowerSetup["Tower A"],
            "002"
        )],


        ; Normal targeting
        [5, 0, () => SetTargeting(
            TowerSetup["Tower A"],
            "Last"
        )],


        ; Another upgrade
        [7, 0, () => UpgradeTower(
            TowerSetup["Tower A"],
            "022"
        )],


        ; Strong targeting
        [10, 0, () => SetTargeting(
            TowerSetup["Tower A"],
            "Strong"
        )],


        ; Sniper placement
        ;
        ; [0, 0, () => PlaceTower(
        ;     TowerSetup["Sniper A"]
        ; )],


        ; Elite Sniper
        ;
        ; Once a Sniper reaches 050,
        ; Elite targeting becomes available.
        ;
        ; [30, 0, () => UpgradeTower(
        ;     TowerSetup["Sniper A"],
        ;     "050"
        ; )],


        ; Elite targeting
        ;
        ; [31, 0, () => SetTargeting(
        ;     TowerSetup["Sniper A"],
        ;     "Elite"
        ; )],


        ; Monkey Ace placement
        ;
        ; [0, 0, () => PlaceTower(
        ;     TowerSetup["Ace A"]
        ; )],


        ; Normal Ace targeting:
        ;
        ; Circle
        ; Figure Infinite
        ; Figure Eight
        ;
        ; [5, 0, () => SetTargeting(
        ;     TowerSetup["Ace A"],
        ;     "Figure Eight"
        ; )],


        ; Centered Path
        ;
        ; xx2 automatically updates the tracked
        ; targeting state to Centered Path.
        ;
        ; [10, 0, () => UpgradeTower(
        ;     TowerSetup["Ace A"],
        ;     "002"
        ; )],


        ; Change away from Centered Path
        ;
        ; [15, 0, () => SetTargeting(
        ;     TowerSetup["Ace A"],
        ;     "Circle"
        ; )],


        ; Wingmonkey
        ;
        ; Requires:
        ; wingmonkeyMK: true
        ;
        ; [15, 0, () => SetTargeting(
        ;     TowerSetup["Ace A"],
        ;     "Wingmonkey"
        ; )],


        ; Monkey Sub placement
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


        ; Submerge
        ;
        ; [11, 0, () => SetSubmerge(
        ;     TowerSetup["Sub A"],
        ;     true
        ; )],


        ; Unsubmerge
        ;
        ; The Sub returns to its previous targeting.
        ;
        ; [20, 0, () => SetSubmerge(
        ;     TowerSetup["Sub A"],
        ;     false
        ; )],


        ; Normal Sub targeting
        ;
        ; Do not change normal targeting while
        ; the Sub is submerged.
        ;
        ; [21, 0, () => SetTargeting(
        ;     TowerSetup["Sub A"],
        ;     "Strong"
        ; )],


        ; Mid-round action
        ;
        ; 5000 ms into Round 20:
        ;
        ; [20, 5000, () => UseAbility("1")]
    ]


    ; MapRunner.ahk handles:
    ;
    ; - Navigation
    ; - Game loading
    ; - Round 0 strategy
    ; - Starting the game
    ; - Round tracking
    ; - Strategy execution
    ; - Victory
    ; - Defeat
    ; - Retries
    ;
    ; The map file only needs:
    ;
    ; - RunConfig
    ; - TowerSetup
    ; - strategy

    return RunMapStrategy(strategy)
}


MapNameDifficultyMode()
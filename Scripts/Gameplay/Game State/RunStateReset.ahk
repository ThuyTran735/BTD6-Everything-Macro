#Requires AutoHotkey v2.0

; v3 file note: Resets tower state and releases modifier keys between runs.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

ResetTowerSetup() {
    global TowerSetup
    global EliteSniperActive


    EliteSniperActive :=
        false


    for name, tower in TowerSetup {

        tower.placed :=
            false


        if HasProp(
            tower,
            "upgrades"
        ) {

            tower.upgrades :=
                [0, 0, 0]
        }


        if tower.type = "Ace" {

            tower.targeting :=
                "Circle"
        }
        else if tower.type = "Heli" {

            tower.targeting :=
                "Follow Mouse"
        }
        else if tower.type = "Dartling" {

            tower.targeting :=
                "Normal"
        }
        else if tower.type = "Mortar" {

            tower.targeting :=
                "Target"
        }
        else if tower.type = "SpikeFactory" {

            tower.targeting :=
                "Normal"
        }
        else {

            tower.targeting :=
                "First"
        }


        if tower.type = "Mortar" {

            tower.targetSet := false
            tower.targetX := 0
            tower.targetY := 0
        }


        if tower.type = "Sub" {

            tower.targeting :=
                "First"


            tower.targetingBeforeSubmerge :=
                "First"


            tower.submerged :=
                false
        }
    }


    return true
}


ReleaseMacroModifierKeys() {
    SendEvent(
        "{LAlt Up}"
        . "{RAlt Up}"
        . "{LCtrl Up}"
        . "{RCtrl Up}"
        . "{LShift Up}"
        . "{RShift Up}"
        . "{LWin Up}"
        . "{RWin Up}"
    )


    Sleep(
        50
    )
}
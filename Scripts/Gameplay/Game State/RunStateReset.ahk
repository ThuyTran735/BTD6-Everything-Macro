#Requires AutoHotkey v2.0

; Clears the saved placement, upgrade, and targeting state before another run.
; The strategy keeps its tower records, but their live game state must start fresh.

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


        ; Aim points from the previous run are no longer evidence of a configured mortar.
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


; Release both physical sides so a stopped macro cannot leave later menu clicks modified.
ReleaseMacroModifierKeys(releaseStoppedInputs := false) {
    releaseKeys :=
        "{LAlt Up}"
        . "{RAlt Up}"
        . "{LCtrl Up}"
        . "{RCtrl Up}"
        . "{LShift Up}"
        . "{RShift Up}"
        . "{LWin Up}"
        . "{RWin Up}"

    ; Forced process termination skips the child's finally blocks. Only the
    ; launcher stop path requests these extra releases, after that child exits.
    if releaseStoppedInputs
        releaseKeys := "{Blind}" . GetStoppedMacroInputReleases() . releaseKeys

    SendEvent(releaseKeys)


    Sleep(
        50
    )
}


GetStoppedMacroInputReleases() {
    global TowerHotkeys
    global UpgradeHotkeys

    keys := Map()
    keys.CaseSense := "Off"
    keys["LButton"] := true
    keys["Esc"] := true
    bindings := []
    if IsSet(TowerHotkeys) && TowerHotkeys is Map
        bindings.Push(TowerHotkeys)
    if IsSet(UpgradeHotkeys) && UpgradeHotkeys is Map
        bindings.Push(UpgradeHotkeys)

    for hotkeys in bindings {
        for bindingName, heldBinding in hotkeys {
            if RegExMatch(heldBinding, "^\{([A-Za-z0-9]+)\}$", &match)
                heldKey := match[1]
            else if StrLen(heldBinding) = 1 && heldBinding != "{" && heldBinding != "}"
                heldKey := heldBinding
            else
                continue
            keys[heldKey] := true
        }
    }

    ; Key-up events do not select a tower, buy an upgrade, or press Escape.
    releases := ""
    for heldKey, unused in keys
        releases .= "{" . heldKey . " Up}"
    return releases
}

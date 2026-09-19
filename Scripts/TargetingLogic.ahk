#Requires AutoHotkey v2.0


global EliteSniperActive := false


global TargetingProfiles := Map(
    "Standard", [
        "First",
        "Last",
        "Close",
        "Strong"
    ],

    "SniperElite", [
        "First",
        "Last",
        "Close",
        "Strong",
        "Elite"
    ],

    "AceNormal", [
        "Circle",
        "Figure Infinite",
        "Figure Eight"
    ],

    "AceWingmonkey", [
        "Circle",
        "Figure Infinite",
        "Figure Eight",
        "Wingmonkey"
    ],

    "AceCentered", [
        "Circle",
        "Figure Infinite",
        "Figure Eight",
        "Centered Path"
    ],

    "AceCenteredWingmonkey", [
        "Circle",
        "Figure Infinite",
        "Figure Eight",
        "Centered Path",
        "Wingmonkey"
    ]
)


GetTargetingProfile(tower) {
    global RunConfig
    global EliteSniperActive


    if tower.type = "Sniper" {
        if EliteSniperActive
            return "SniperElite"

        return "Standard"
    }


    if tower.type = "Ace" {
        hasCenteredPath := (
            HasProp(tower, "upgrades")
            && tower.upgrades[3] >= 2
        )


        hasWingmonkey := (
            HasProp(RunConfig, "wingmonkeyMK")
            && RunConfig.wingmonkeyMK
        )


        if hasCenteredPath {
            if hasWingmonkey
                return "AceCenteredWingmonkey"

            return "AceCentered"
        }


        if hasWingmonkey
            return "AceWingmonkey"


        return "AceNormal"
    }


    return "Standard"
}


GetDefaultTargeting(tower) {
    global TargetingProfiles


    if tower.type = "Dartling"
        return "Normal"


    if tower.type = "Heli"
        return "Follow Mouse"


    if tower.type = "Mortar"
        return "Target"


    profileName := GetTargetingProfile(tower)


    if !TargetingProfiles.Has(profileName)
        throw Error("Unknown targeting profile: " profileName)


    return TargetingProfiles[profileName][1]
}


SetTargeting(tower, targetMode) {
    global TargetingProfiles

    if !HasProp(tower, "placed") || !tower.placed
        return false

    if tower.type = "Dartling" {
        throw Error(
            "Use SetDartlingTargeting() or AimDartling() for Dartling Gunners."
        )
    }

    if tower.type = "Heli" {
        throw Error(
            "Use LockHeliInPlace() or RetargetHeli() for Heli Pilots."
        )
    }

    if tower.type = "Mortar" {
        throw Error(
            "Use SetMortarTarget() or RetargetMortar() for Mortar Monkeys."
        )
    }

    ; A submerged Monkey Sub should be surfaced
    ; before changing its normal targeting.
    if tower.type = "Sub" {
        if HasProp(tower, "submerged") && tower.submerged
            return false
    }

    profileName := GetTargetingProfile(tower)


    if !HasProp(tower, "placed") || !tower.placed
        return false


    profileName := GetTargetingProfile(tower)


    if !TargetingProfiles.Has(profileName)
        throw Error("Unknown targeting profile: " profileName)


    targetingOrder := TargetingProfiles[profileName]


    if !HasProp(tower, "targeting")
        tower.targeting := targetingOrder[1]


    currentIndex := 0
    targetIndex := 0


    for index, mode in targetingOrder {
        if mode = tower.targeting
            currentIndex := index

        if mode = targetMode
            targetIndex := index
    }


    if currentIndex = 0 {
        throw Error(
            "Current targeting mode '" tower.targeting
            "' does not exist in profile '" profileName "'."
        )
    }


    if targetIndex = 0 {
        throw Error(
            "Targeting mode '" targetMode
            "' does not exist in profile '" profileName "'."
        )
    }


    if currentIndex = targetIndex
        return true


    if !IsUpgradeTowerSelected(tower) {
        ClearSelectedUpgradeTower()
        Click(tower.x, tower.y)
        Sleep(250)
    }


    profileLength := targetingOrder.Length


    forwardSteps := Mod(
        targetIndex - currentIndex + profileLength,
        profileLength
    )


    ; Always cycle forward through targeting modes.
    ; Reverse targeting (Ctrl+Tab) is intentionally not used here.
    Loop forwardSteps {
        Send("{Tab}")
        Sleep(30)
    }


    tower.targeting := targetMode


    Send("{Esc}")
    ClearSelectedUpgradeTower()
    Sleep(20)


    return true
}
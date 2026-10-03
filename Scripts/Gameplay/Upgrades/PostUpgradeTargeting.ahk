#Requires AutoHotkey v2.0

; v3 file note: Updates special targeting state after upgrades that change how a tower aims.
; Split out in v3.0.0 so this part is easier to find without scrolling forever.

CaptureUpgradeButtonSignature(
    x,
    y
) {
    offsets := [
        [-48, -18], [-24, -18], [0, -18], [24, -18], [48, -18],
        [-48, 0],   [-24, 0],   [0, 0],   [24, 0],   [48, 0],
        [-48, 18],  [-24, 18],  [0, 18],  [24, 18],  [48, 18]
    ]


    signature :=
        ""


    for offset in offsets {
        sampleX :=
            Max(
                0,
                Min(
                    A_ScreenWidth - 1,
                    x + offset[1]
                )
            )


        sampleY :=
            Max(
                0,
                Min(
                    A_ScreenHeight - 1,
                    y + offset[2]
                )
            )


        signature .=
            Format(
                "{:06X}",
                PixelGetColor(
                    sampleX,
                    sampleY
                ) & 0xFFFFFF
            )
    }


    return signature
}


UpdateTargetingAfterUpgrade(
    tower,
    upgradedPath
) {
    global EliteSniperActive


    if tower.type = "Sniper" {

        if (
            upgradedPath = "Middle"
            && tower.upgrades[2] = 5
        ) {

            EliteSniperActive :=
                true


            tower.targeting :=
                "Elite"
        }
    }


    if tower.type = "Ace" {

        if (
            upgradedPath = "Bottom"
            && tower.upgrades[3] = 2
        ) {

            tower.targeting :=
                "Centered Path"
        }
    }


    ; Buying Pursuit (2xx) automatically switches a Heli Pilot to Pursuit.
    ; Keep our stored targeting state synchronized so a later
    ; LockHeliInPlace() knows how many targeting steps are needed.
    if tower.type = "Heli" {

        if (
            upgradedPath = "Top"
            && tower.upgrades[1] = 2
        ) {

            tower.targeting :=
                "Pursuit"
        }
    }


    return true
}
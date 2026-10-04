#Requires AutoHotkey v2.0

; v3.0.1: Shared upgrade-panel constants/helpers. This file intentionally
; does not scan for panels or send Esc. Each action is responsible for
; closing only the panel it knows it opened.

global UpgradePoints := Map(
    "Left", Map(
        "Top", [260, 486],
        "Middle", [258, 639],
        "Bottom", [262, 791]
    ),

    "Right", Map(
        "Top", [1483, 487],
        "Middle", [1484, 638],
        "Bottom", [1483, 786]
    )
)


global UpgradeHotkeys := Map(
    "Top", ",",
    "Middle", ".",
    "Bottom", "/"
)


IsFastDeflationPregameUpgrade() {
    global IsPregame
    global RunConfig

    try {
        return IsPregame && RunConfig.gameMode = "Deflation"
    }

    return false
}
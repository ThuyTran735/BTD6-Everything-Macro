#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\Scripts\IncludeAll.ahk

; v3.4.0 Banana Farm collection test for BTD6 Sandbox mode.
; Load a Sandbox match first. F8 places three Farms and starts the real
; collection logic at these coordinates:
;   Farm A: 1000, 200
;   Farm B: 1456, 717
;   Farm C: 434, 732
;
; F8  = place all three Farms and start collection
; F9  = pause / resume collection
; F5  = reset all Farms to 000 (all should be collected)
; F6  = simulate Farm A as 030 Monkey Bank (Farm A should stop being visited)
; F7  = simulate Farm B as 003 Marketplace (Farm B should stop being visited)
; Esc = exit test
;
; Sandbox has no configured round OCR area in RoundConfig.ahk, so this test
; intentionally skips round detection and heavy game-state scans. Its only job
; is to verify fast Banana Farm collection. Each Farm is hovered for 300 ms,
; then the next Farm is visited immediately.

global RunConfig := {
    category: "Test",
    map: "Banana Farm Collection Test",
    difficulty: "Sandbox",
    gameMode: "Sandbox",
    hero: "Quincy",
    wingmonkeyMK: false,
    startRound: 1,
    endRound: 999
}

global TowerSetup := Map(
    "Farm A", {
        type: "Farm",
        x: 1000,
        y: 200,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Farm B", {
        type: "Farm",
        x: 1456,
        y: 717,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    },
    "Farm C", {
        type: "Farm",
        x: 434,
        y: 732,
        placed: false,
        upgrades: [0, 0, 0],
        targeting: "First"
    }
)

global BananaCollectionTestRunning := false
global BananaCollectionTestPaused := false

ResetTowerSetup()
ResetBananaCollection()
ShowBananaCollectionTestStatus("READY - OPEN BTD6 SANDBOX")

F8::StartBananaCollectionTest()
F9::ToggleBananaCollectionTest()
F5::ResetBananaCollectionTestUpgrades()
F6::SetBananaCollectionTestUpgrade("Farm A", [0, 3, 0], "FARM A -> 030 BANK")
F7::SetBananaCollectionTestUpgrade("Farm B", [0, 0, 3], "FARM B -> 003 MARKETPLACE")
Esc::ExitBananaCollectionTest()

StartBananaCollectionTest() {
    global TowerSetup
    global BananaCollectionTestRunning
    global BananaCollectionTestPaused

    if BananaCollectionTestRunning {
        return
    }

    if !WinExist("ahk_exe BloonsTD6.exe") {
        MsgBox(
            "BTD6 is not open. Open the game, enter Sandbox, and try again.",
            "Banana Farm Collection Test"
        )
        return
    }

    WinActivate("ahk_exe BloonsTD6.exe")
    try WinWaitActive("ahk_exe BloonsTD6.exe",, 2)
    Sleep(150)

    farmNames := ["Farm A", "Farm B", "Farm C"]

    for farmName in farmNames {
        farm := TowerSetup[farmName]

        if farm.placed {
            continue
        }

        ShowBananaCollectionTestStatus(
            "PLACING " . farmName . " AT " . farm.x . ", " . farm.y
        )

        if !PlaceTower(farm) {
            ShowBananaCollectionTestStatus(farmName . " PLACEMENT FAILED")
            return
        }
    }

    EnableBananaCollection()

    BananaCollectionTestRunning := true
    BananaCollectionTestPaused := false

    RunBananaCollectionTestLoop()
}

RunBananaCollectionTestLoop() {
    global BananaCollectionTestRunning
    global BananaCollectionTestPaused

    while BananaCollectionTestRunning {
        if BananaCollectionTestPaused {
            ShowBananaCollectionTestStatus("PAUSED")
            Sleep(30)
            continue
        }

        ; Sandbox intentionally skips GetCurrentRound() and CheckGameState().
        ; Those are production concerns; this test is meant to show the real
        ; Farm-to-Farm collection speed without several-second FindText scans.
        ;
        ; Normal strategy runs still read the round before every Farm visit.
        ; If a popup blocks that round read, the existing missing-round recovery
        ; handles the popup before collection continues.

        ; The real collector visits one eligible Farm at a time for 300 ms.
        collected := CollectBananasWhileIdle()

        if collected {
            ShowBananaCollectionTestStatus("COLLECTING - 300 MS PER FARM")
            Sleep(5)
        }
        else {
            ShowBananaCollectionTestStatus("NO FARM NEEDS COLLECTION")
            Sleep(20)
        }
    }
}

ToggleBananaCollectionTest() {
    global BananaCollectionTestRunning
    global BananaCollectionTestPaused

    if !BananaCollectionTestRunning {
        StartBananaCollectionTest()
        return
    }

    BananaCollectionTestPaused := !BananaCollectionTestPaused

    if BananaCollectionTestPaused {
        DisableBananaCollection()
    }
    else {
        EnableBananaCollection()
    }
}

ResetBananaCollectionTestUpgrades() {
    global TowerSetup

    for farmName in ["Farm A", "Farm B", "Farm C"] {
        TowerSetup[farmName].upgrades := [0, 0, 0]
    }

    ShowBananaCollectionTestStatus("ALL FARMS -> 000")
}

SetBananaCollectionTestUpgrade(farmName, upgrades, label) {
    global TowerSetup

    TowerSetup[farmName].upgrades := upgrades
    ShowBananaCollectionTestStatus(label)
}

ExitBananaCollectionTest() {
    DisableBananaCollection()
    ToolTip()
    ExitApp()
}

ShowBananaCollectionTestStatus(status) {
    global TowerSetup
    global BananaCollectionEnabled

    farmA := TowerSetup["Farm A"]
    farmB := TowerSetup["Farm B"]
    farmC := TowerSetup["Farm C"]

    ToolTip(
        "BANANA FARM COLLECTION TEST - SANDBOX"
        . "`nStatus: " . status
        . "`nCollection enabled: " . (BananaCollectionEnabled ? "YES" : "NO")
        . "`nRound scan: SKIPPED IN SANDBOX"
        . "`nGame-state scan: SKIPPED IN SANDBOX"
        . "`n"
        . "`nFarm A 1000,200 | " . GetFarmCollectionTestState(farmA)
        . "`nFarm B 1456,717 | " . GetFarmCollectionTestState(farmB)
        . "`nFarm C 434,732 | " . GetFarmCollectionTestState(farmC)
        . "`n"
        . "`nF8 = Place 3 Farms + Start"
        . "`nF9 = Pause / Resume"
        . "`nF5 = All Farms -> 000"
        . "`nF6 = Farm A -> 030 Bank"
        . "`nF7 = Farm B -> 003 Marketplace"
        . "`nEsc = Exit",
        20,
        120
    )
}

GetFarmCollectionTestState(farm) {
    upgrades := farm.upgrades[1] . farm.upgrades[2] . farm.upgrades[3]

    return (
        "Placed=" . (farm.placed ? "YES" : "NO")
        . " Upgrades=" . upgrades
        . " Collect=" . (FarmNeedsBananaCollection(farm) ? "YES" : "NO")
    )
}
#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

; v3 file note: Upgrade logic is split by job now: timing, panel state, buying, waiting, and post-upgrade targeting. This file just keeps the old include path working.
; The split is organization-only; callers can keep including this file like before.

#Include Gameplay\Upgrades\UpgradeState.ahk
#Include Gameplay\Upgrades\UpgradePanelState.ahk
#Include Gameplay\Upgrades\UpgradeFlow.ahk
#Include Gameplay\Upgrades\UpgradePanelDetection.ahk
#Include Gameplay\Upgrades\UpgradeWait.ahk
#Include Gameplay\Upgrades\LockedUpgradeHandling.ahk
#Include Gameplay\Upgrades\UpgradePurchase.ahk
#Include Gameplay\Upgrades\PostUpgradeTargeting.ahk
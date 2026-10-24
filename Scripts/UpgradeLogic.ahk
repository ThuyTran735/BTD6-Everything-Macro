#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk

; Public upgrade entry point for strategies. The modules below share panel and timing state for detection, waiting, purchase, and targeting changes.

#Include Gameplay\Upgrades\UpgradeState.ahk
#Include Gameplay\Upgrades\UpgradePanelState.ahk
#Include Gameplay\Upgrades\UpgradeFlow.ahk
#Include Gameplay\Upgrades\UpgradePanelDetection.ahk
#Include Gameplay\Upgrades\UpgradeWait.ahk
#Include Gameplay\Upgrades\LockedUpgradeHandling.ahk
#Include Gameplay\Upgrades\UpgradePurchase.ahk
#Include Gameplay\Upgrades\PostUpgradeTargeting.ahk
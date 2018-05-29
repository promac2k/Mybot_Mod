
; #FUNCTION# ====================================================================================================================
; Name ..........: Double Train
; Description ...:
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Demen
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func DoubleTrain()

	If Not $g_bDoubleTrain Then Return
	Local $bSetlog = True
	If $g_bDoubleTrainDone Then $bSetlog = False

	If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Double train army")
	StartGainCost()
	OpenArmyOverview(False, "DoubleTrain()")

	Local $bNeedReCheckTroopTab = False, $bNeedReCheckSpellTab = False
	Local $bDoubleTrainTroop = False, $bDoubleTrainSpell = False

	; Troop
	OpenTroopsTab(False, "DoubleTrain()")
	If _Sleep(250) Then Return

	Local $Step = 1
	While 1
		Local $TroopCamp = GetCurrentArmy(43, 160)
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking Troop tab: " & $TroopCamp[0] & "/" & $TroopCamp[1] * 2)
		If $TroopCamp[1] = 0 Then ExitLoop

		If $TroopCamp[0] < $TroopCamp[1] Then ; 200/260
			If (ProfileSwitchAccountEnabled() And $g_abAccountNo[$g_iCurAccount] And $g_abDonateOnly[$g_iCurAccount]) Or $g_iCommandStop = 0 Then
				Setlog("Not full camp. Trying to top-up for donating", $COLOR_ACTION)
				FillTroopCamp($TroopCamp[2])
				$bDoubleTrainTroop = TrainFullQueue(False, $bSetlog)
				ExitLoop
			EndIf
			DeleteQueued("Troops")
			$bNeedReCheckTroopTab = True
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". DeleteQueued('Troops'). $bNeedReCheckTroopTab: " & $bNeedReCheckTroopTab, $COLOR_DEBUG)

		ElseIf $TroopCamp[0] = $TroopCamp[1] Then ; 260/260
			$bDoubleTrainTroop = TrainFullQueue(False, $bSetlog)
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". TrainFullQueue(). $bDoubleTrainTroop: " & $bDoubleTrainTroop, $COLOR_DEBUG)

		ElseIf $TroopCamp[0] < $TroopCamp[1] * 2 Then ; 261-519/520
			; just in case queue is messed up after donation
			RemoveExtraTroopsQueue()
			If _Sleep(500) Then Return
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
			$Step += 1
			If $Step = 6 Then ExitLoop
			ContinueLoop

		ElseIf $TroopCamp[0] = $TroopCamp[1] * 2 Then
			$bDoubleTrainTroop = True
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". $bDoubleTrainTroop: " & $bDoubleTrainTroop, $COLOR_DEBUG)
		EndIf
		ExitLoop
	WEnd

	; Spell
	OpenSpellsTab(False, "DoubleTrain()")
	If _Sleep(250) Then Return
	$Step = 1
	While 1
		Local $SpellCamp = GetCurrentArmy(43, 160)
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking Spell tab: " & $SpellCamp[0] & "/" & $SpellCamp[1] * 2)
		If $SpellCamp[1] = 0 Then ExitLoop

		If $SpellCamp[0] < $SpellCamp[1] Then ; 0-10/11
			If (ProfileSwitchAccountEnabled() And $g_abAccountNo[$g_iCurAccount] And $g_abDonateOnly[$g_iCurAccount]) Or $g_iCommandStop = 0 Then
				Setlog("Not full spell camp. Trying to top-up for donating", $COLOR_ACTION)
				FillSpellCamp($SpellCamp[2])
				$bDoubleTrainSpell = TrainFullQueue(True, $bSetlog)
				ExitLoop
			EndIf
			DeleteQueued("Spells")
			$bNeedReCheckSpellTab = True
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". DeleteQueued('Spells'). $bNeedReCheckSpellTab: " & $bNeedReCheckSpellTab, $COLOR_DEBUG)

		ElseIf $SpellCamp[0] = $SpellCamp[1] Then ; 11/22
			$bDoubleTrainSpell = TrainFullQueue(True, $bSetlog)
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". TrainFullQueue(True). $bDoubleTrainSpell: " & $bDoubleTrainSpell, $COLOR_DEBUG)

		ElseIf $SpellCamp[0] < $SpellCamp[1] * 2 Then ; 12-21/22
			; just in case queue is messed up after donation
			RemoveExtraTroopsQueue()
			If _Sleep(500) Then Return
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
			$Step += 1
			If $Step = 6 Then ExitLoop
			ContinueLoop

		ElseIf $SpellCamp[0] = $SpellCamp[1] * 2 Then
			$bDoubleTrainSpell = True
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". $bDoubleTrainSpell: " & $bDoubleTrainSpell, $COLOR_DEBUG)
		EndIf
		ExitLoop
	WEnd

	If $bNeedReCheckTroopTab Or $bNeedReCheckSpellTab Then
		OpenArmyTab(False, "DoubleTrain()")
		Local $aWhatToRemove = WhatToTrain(True)
		Local $rRemoveExtraTroops = RemoveExtraTroops($aWhatToRemove)
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("RemoveExtraTroops(): " & $rRemoveExtraTroops, $COLOR_DEBUG)

		If $rRemoveExtraTroops = 1 Or $rRemoveExtraTroops = 2 Then
			For $i = 0 To UBound($aWhatToRemove) - 1
				If _ArraySearch($g_asTroopShortNames, $aWhatToRemove[$i][0]) >= 0 Then $bNeedReCheckTroopTab = True
				If _ArraySearch($g_asSpellShortNames, $aWhatToRemove[$i][0]) >= 0 Then $bNeedReCheckSpellTab = True
				If $bNeedReCheckTroopTab And $bNeedReCheckSpellTab Then ExitLoop
			Next
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$bNeedReCheckTroopTab: " & $bNeedReCheckTroopTab & "$bNeedReCheckSpellTab: " & $bNeedReCheckSpellTab, $COLOR_DEBUG)
		EndIf

		Local $bForceBrewSpells = $g_bForceBrewSpells
		$g_bForceBrewSpells = True
		Local $aWhatToTrain = WhatToTrain()
		If $bNeedReCheckTroopTab Then
			TrainUsingWhatToTrain($aWhatToTrain) ; troop
			$bDoubleTrainTroop = TrainFullQueue(False, $bSetlog)
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("TrainFullQueue(). $bDoubleTrainTroop: " & $bDoubleTrainTroop, $COLOR_DEBUG)
		EndIf
		If $bNeedReCheckSpellTab Then
			TrainUsingWhatToTrain($aWhatToTrain, True) ; spell
			$bDoubleTrainSpell = TrainFullQueue(True, $bSetlog)
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("TrainFullQueue(). $bDoubleTrainSpell: " & $bDoubleTrainSpell, $COLOR_DEBUG)
		EndIf
		$g_bForceBrewSpells = $bForceBrewSpells
	EndIf

	If _Sleep(250) Then Return
	ClickP($aAway, 2, 0, "#0346") ;Click Away
	If _Sleep(250) Then Return

	$g_bDoubleTrainDone = $bDoubleTrainTroop And $bDoubleTrainSpell
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$g_bDoubleTrainDone: " & $g_bDoubleTrainDone, $COLOR_DEBUG)

	If ProfileSwitchAccountEnabled() Then $g_abDoubleTrainDone[$g_iCurAccount] = $g_bDoubleTrainDone

	EndGainCost("Double Train")

EndFunc   ;==>DoubleTrain

Func TrainFullQueue($bSpellOnly = False, $bSetlog = True)
	Local $ToReturn[1][2] = [["Arch", 0]]
	; Troops
	For $i = 0 To $eTroopCount - 1
		Local $troopIndex = $g_aiTrainOrder[$i]
		If $g_aiArmyCompTroops[$troopIndex] > 0 Then
			$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
			$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompTroops[$troopIndex]
			ReDim $ToReturn[UBound($ToReturn) + 1][2]
		EndIf
	Next
	; Spells
	For $i = 0 To $eSpellCount - 1
		Local $BrewIndex = $g_aiBrewOrder[$i]
		If TotalSpellsToBrewInGUI() = 0 Then ExitLoop
		If $g_aiArmyCompSpells[$BrewIndex] > 0 Then
			$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
			$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompSpells[$BrewIndex]
			ReDim $ToReturn[UBound($ToReturn) + 1][2]
		EndIf
	Next

	If $ToReturn[0][0] = "Arch" And $ToReturn[0][1] = 0 Then Return False; Error

	Local $bIsFullArmywithHeroesAndSpells = $g_bIsFullArmywithHeroesAndSpells
	$g_bIsFullArmywithHeroesAndSpells = True

	TrainUsingWhatToTrain($ToReturn, $bSpellOnly)
	If _Sleep($bSpellOnly ? 1000 : 500) Then Return

	$g_bIsFullArmywithHeroesAndSpells = $bIsFullArmywithHeroesAndSpells

	Local $CampOCR = GetCurrentArmy(43, 160)
	If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking " & ($bSpellOnly ? "spell tab: " : "troop tab: ") & $CampOCR[0] & "/" & $CampOCR[1] * 2)
	If $CampOCR[0] = $CampOCR[1] * 2 Then
		Return True
	Else
		Return False
	EndIf

EndFunc   ;==>TrainFullQueue

Func FillTroopCamp($iRemaining)
	Local $ToTrain[1][2] = [["Arch", 0]]

	Local $TrainOrder[$eTroopCount] = [$eGole, $eLava, $ePekk, $eDrag, $eHeal, $eWitc, $eBabyD, $eValk, $eMine, $eBowl, $eGiant, $eBall, $eHogs, $eWiza, $eWall, $eMini, $eBarb, $eArch, $eGobl]

	For $i = 0 To $eTroopCount - 1
		Local $troopIndex = $TrainOrder[$i]
		Local $iNotYetTrained = $g_aiArmyCompTroops[$troopIndex] - $g_aiCurrentTroops[$troopIndex]
		If $iNotYetTrained > 0 Then
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("  - $iNotYetTrained: " & $g_asTroopShortNames[$troopIndex] & " x" & $iNotYetTrained, $COLOR_DEBUG)
			Local $iCanTrain = Int($iRemaining / $g_aiTroopSpace[$troopIndex])
			If $iCanTrain > 0 Then
				$ToTrain[UBound($ToTrain) - 1][0] = $g_asTroopShortNames[$troopIndex]
				$ToTrain[UBound($ToTrain) - 1][1] = _Min($iCanTrain, $iNotYetTrained)
				$iRemaining -= $ToTrain[UBound($ToTrain) - 1][1] * $g_aiTroopSpace[$troopIndex]
				If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("  - $ToTrain: " & $ToTrain[UBound($ToTrain) - 1][0] & " x" & $ToTrain[UBound($ToTrain) - 1][1] & ". Remaining: " & $iRemaining, $COLOR_DEBUG)
				ReDim $ToTrain[UBound($ToTrain) + 1][2]
			EndIf
		EndIf
	Next

	While $iRemaining > 0
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("  Still not full camp, missing: " & $iRemaining, $COLOR_DEBUG)
		For $i = 0 To $eTroopCount - 1
			Local $troopIndex = $TrainOrder[$i]
			If $g_aiArmyCompTroops[$troopIndex] > 0 Then
				Local $iCanTrain2 = $iRemaining / $g_aiTroopSpace[$troopIndex]
				If $iCanTrain2 >= 1 Then
					$ToTrain[UBound($ToTrain) - 1][0] = $g_asTroopShortNames[$troopIndex]
					$ToTrain[UBound($ToTrain) - 1][1] = Int($iCanTrain2)
					$iRemaining -= $ToTrain[UBound($ToTrain) - 1][1] * $g_aiTroopSpace[$troopIndex]
					If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog(($iRemaining = 0 ? "  - Final $ToTrain: " : "  - $ToTrain: ") & $ToTrain[UBound($ToTrain) - 1][0] & " x" & $ToTrain[UBound($ToTrain) - 1][1], $COLOR_DEBUG)
					If $iRemaining = 0 Then ExitLoop
					ReDim $ToTrain[UBound($ToTrain) + 1][2]
				EndIf
			EndIf
		Next
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("  Still not full camp. Try fill up with " & $iRemaining & ($iRemaining > 1 ? " Archers" : " Archer" ), $COLOR_DEBUG)
		$ToTrain[UBound($ToTrain) - 1][0] = "Arch"
		$ToTrain[UBound($ToTrain) - 1][1] = $iRemaining
		ExitLoop
	WEnd

	TrainUsingWhatToTrain($ToTrain)

EndFunc   ;==>FillTroopCamp

Func FillSpellCamp($iRemaining)
	Local $ToTrain[1][2] = [["Arch", 0]]

	For $i = 0 To $eSpellCount - 1
		Local $iNotYetBrewed = $g_aiArmyCompSpells[$i] - $g_aiCurrentSpells[$i]
		If $iNotYetBrewed > 0 Then
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("  - $iNotYetBrewed: " & $g_asSpellShortNames[$i] & " x" & $iNotYetBrewed, $COLOR_DEBUG)

			Local $iCanTrain = Int($iRemaining / $g_aiSpellSpace[$i])
			If $iCanTrain > 0 Then
				$ToTrain[UBound($ToTrain) - 1][0] = $g_asSpellShortNames[$i]
				$ToTrain[UBound($ToTrain) - 1][1] = _Min($iCanTrain, $iNotYetBrewed)
				$iRemaining -= $ToTrain[UBound($ToTrain) - 1][1] * $g_aiSpellSpace[$i]
				If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("  - $ToTrain: " & $ToTrain[UBound($ToTrain) - 1][0] & " x" & $ToTrain[UBound($ToTrain) - 1][1] & ". Remaining: " & $iRemaining, $COLOR_DEBUG)
				ReDim $ToTrain[UBound($ToTrain) + 1][2]
			EndIf
		EndIf
	Next

	While $iRemaining > 0
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("  Still not full camp, missing: " & $iRemaining, $COLOR_DEBUG)
		For $i = 0 To $eSpellCount - 1
			If $g_aiArmyCompSpells[$i] > 0 Then
				Local $iCanTrain2 = $iRemaining / $g_aiSpellSpace[$i]
				If $iCanTrain2 >= 1 Then
					$ToTrain[UBound($ToTrain) - 1][0] = $g_asSpellShortNames[$i]
					$ToTrain[UBound($ToTrain) - 1][1] = Int($iCanTrain2)
					$iRemaining -= $ToTrain[UBound($ToTrain) - 1][1] * $g_aiSpellSpace[$i]
					If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog(($iRemaining = 0 ? "  - Final $ToTrain: " : "  - $ToTrain: ") & $ToTrain[UBound($ToTrain) - 1][0] & " x" & $ToTrain[UBound($ToTrain) - 1][1], $COLOR_DEBUG)
					If $iRemaining = 0 Then ExitLoop
					ReDim $ToTrain[UBound($ToTrain) + 1][2]
				EndIf
			EndIf
		Next
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("  Still not full camp. Try fill up with " & $iRemaining & ($iRemaining > 1 ? " Hastes" : " Haste" ), $COLOR_DEBUG)
		$ToTrain[UBound($ToTrain) - 1][0] = "HaSpell"
		$ToTrain[UBound($ToTrain) - 1][1] = $iRemaining
		ExitLoop
	WEnd

	TrainUsingWhatToTrain($ToTrain, True)

EndFunc   ;==>FillSpellCamp

Func DoubleQuickTrain()

	If Not $g_bDoubleTrain Or $g_bIsFullArmywithHeroesAndSpells Then Return

	Local $bSetlog = True
	If $g_bDoubleTrainDone Then $bSetlog = False

	If $bSetlog Then SetLog("Double quick train army")

	Local $bDoubleTrainTroop = False, $bDoubleTrainSpell = False

	; Troop
	OpenTroopsTab(False, "DoubleQuickTrain()")
	If _Sleep(250) Then Return

	Local $Step = 1
	While 1
		Local $TroopCamp = GetCurrentArmy(43, 160)
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking Troop tab: " & $TroopCamp[0] & "/" & $TroopCamp[1] * 2)
		If $TroopCamp[0] > $TroopCamp[1] And $TroopCamp[0] < $TroopCamp[1] * 2 Then ; 500/520
			RemoveExtraTroopsQueue()
			If _Sleep(500) Then Return
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
			$Step += 1
			If $Step = 6 Then ExitLoop
			ContinueLoop
		ElseIf $TroopCamp[0] = $TroopCamp[1] * 2 Then
			$bDoubleTrainTroop = True
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". $bDoubleTrainTroop: " & $bDoubleTrainTroop, $COLOR_DEBUG)
		EndIf
		ExitLoop
	WEnd

	; Spell
	OpenSpellsTab(False, "DoubleQuickTrain()")
	If _Sleep(250) Then Return
	$Step = 1
	While 1
		Local $SpellCamp = GetCurrentArmy(43, 160)
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking Spell tab: " & $SpellCamp[0] & "/" & $SpellCamp[1] * 2)
		If $SpellCamp[0] > $SpellCamp[1] And $SpellCamp[0] < $SpellCamp[1] * 2 Then ; 20/22
			RemoveExtraTroopsQueue()
			If _Sleep(500) Then Return
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
			$Step += 1
			If $Step = 6 Then ExitLoop
			ContinueLoop
		ElseIf $SpellCamp[0] = $SpellCamp[1] * 2 Then
			$bDoubleTrainSpell = True
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". $bDoubleTrainSpell: " & $bDoubleTrainSpell, $COLOR_DEBUG)
		EndIf
		ExitLoop
	WEnd

	If Not $bDoubleTrainTroop Or Not $bDoubleTrainSpell Then
		OpenQuickTrainTab(False, "DoubleQuickTrain()")
		If _Sleep(500) Then Return
		Local $iMultiClick = 1
		If $g_bChkMultiClick Then $iMultiClick = _Max(Ceiling(($SpellCamp[1] * 2 - $SpellCamp[0]) / 2), 1)
		TrainArmyNumber($g_bQuickTrainArmy, $iMultiClick)
	Else
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Full queue, skip Double Quick Train")
	EndIf

	If _Sleep(250) Then Return

	$g_bDoubleTrainDone = True
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$g_bDoubleTrainDone: " & $g_bDoubleTrainDone, $COLOR_DEBUG)
	If ProfileSwitchAccountEnabled() Then $g_abDoubleTrainDone[$g_iCurAccount] = $g_bDoubleTrainDone

EndFunc   ;==>DoubleQuickTrain

Func GetCurrentArmy($x_start, $y_start)

	Local $aResult[3] = [0, 0, 0]
	If Not $g_bRunState Then Return $aResult

	; [0] = Current Army  | [1] = Total Army Capacity  | [2] = Remain Space for the current Army
	Local $iOCRResult = getArmyCapacityOnTrainTroops($x_start, $y_start)

	If StringInStr($iOCRResult, "#") Then
		Local $aTempResult = StringSplit($iOCRResult, "#", $STR_NOCOUNT)
		$aResult[0] = Number($aTempResult[0])
		$aResult[1] = Number($aTempResult[1]) / 2
		$aResult[2] = $aResult[1] - $aResult[0]
		If $aResult[1] <= 11 Then
			Local $TotalSpellsToBrewInGUI = TotalSpellsToBrewInGUI()
			If $aResult[1] <> $TotalSpellsToBrewInGUI Or $aResult[1] <> $g_iTotalSpellValue Then
				SetLog("Your total spell setting is not the same as actual total spell camp: (" & $TotalSpellsToBrewInGUI & "/" & $g_iTotalSpellValue & "/" & $aResult[1] & ")", $COLOR_DEBUG)
				SetLog("Double train may not work well", $COLOR_DEBUG)
			EndIf
		ElseIf $aResult[1] <> $g_iTotalCampSpace Then
			SetLog("Your troop combo is not the same as actual total troop camp. (" & $g_iTotalCampSpace & "/" & $aResult[1] & ")", $COLOR_DEBUG)
			SetLog("Double train may not work well", $COLOR_DEBUG)
		EndIf
	Else
		SetLog("DEBUG | ERROR on GetCurrentArmy", $COLOR_ERROR)
	EndIf

	Return $aResult

EndFunc   ;==>GetCurrentArmy
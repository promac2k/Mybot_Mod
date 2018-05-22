
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

	If Not $g_bDoubleTrain Or $g_bIsFullArmywithHeroesAndSpells Then Return
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
		Local $TroopCamp = GetOCRCurrent(43, 160)
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking Troop tab: " & $TroopCamp[0] & "/" & $TroopCamp[1] * 2)

		If $TroopCamp[0] < $TroopCamp[1] Then ; 200/520
			DeleteQueued("Troops")
			$bNeedReCheckTroopTab = True
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". DeleteQueued('Troops'). $bNeedReCheckTroopTab: " & $bNeedReCheckTroopTab, $COLOR_DEBUG)

		ElseIf $TroopCamp[0] = $TroopCamp[1] Then ; 260/520
			$bDoubleTrainTroop = TrainFullQueue(False, $bSetlog)
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". TrainFullQueue(). $bDoubleTrainTroop: " & $bDoubleTrainTroop, $COLOR_DEBUG)

		ElseIf $TroopCamp[0] < $TroopCamp[1] * 2 Then ; 500/520
			; just in case queue is messed up after donation
			RemoveExtraTroopsQueue()
			If _Sleep(500) Then Return
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
			$Step += 1
			If $Step = 3 Then ExitLoop
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
		Local $SpellCamp = GetOCRCurrent(43, 160)
		Local $TotalSpellToBrew = TotalSpellsToBrewInGUI()
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$SpellCamp[1]: " & $SpellCamp[1] & ", $TotalSpellToBrew: " & $TotalSpellToBrew, $COLOR_DEBUG)
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking Spell tab: " & $SpellCamp[0] & "/" & $TotalSpellToBrew * 2)

		If $SpellCamp[0] < $TotalSpellToBrew Then ; 10/22
			DeleteQueued("Spells")
			$bNeedReCheckSpellTab = True
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". DeleteQueued('Spells'). $bNeedReCheckSpellTab: " & $bNeedReCheckSpellTab, $COLOR_DEBUG)

		ElseIf $SpellCamp[0] = $TotalSpellToBrew Then ; 11/22
			$bDoubleTrainSpell = TrainFullQueue(True, $bSetlog)
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". TrainFullQueue(True). $bDoubleTrainSpell: " & $bDoubleTrainSpell, $COLOR_DEBUG)

		ElseIf $SpellCamp[0] < $TotalSpellToBrew * 2 Then ; 20/22
			; just in case queue is messed up after donation
			If $TotalSpellToBrew < $SpellCamp[1] Then
				DeleteQueued("Spells")
				$bNeedReCheckSpellTab = True
				If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". DeleteQueued('Spells'). $bNeedReCheckSpellTab: " & $bNeedReCheckSpellTab, $COLOR_DEBUG)
			Else
				RemoveExtraTroopsQueue()
				If _Sleep(500) Then Return
				If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
				$Step += 1
				If $Step = 3 Then ExitLoop
				ContinueLoop
			EndIf

		ElseIf $SpellCamp[0] = $TotalSpellToBrew * 2 Then
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
	Local $bForceBrewSpells = $g_bForceBrewSpells

	$g_bIsFullArmywithHeroesAndSpells = True
	$g_bForceBrewSpells = True

	TrainUsingWhatToTrain($ToReturn, $bSpellOnly)
	If _Sleep($bSpellOnly ? 1000 : 500) Then Return

	$g_bIsFullArmywithHeroesAndSpells = $bIsFullArmywithHeroesAndSpells
	$g_bForceBrewSpells = $bForceBrewSpells

	Local $CampOCR = GetOCRCurrent(43, 160)
	If $bSpellOnly Then $CampOCR[1] = TotalSpellsToBrewInGUI()
	If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking " & ($bSpellOnly ? "spell tab: " : "troop tab: ") & $CampOCR[0] & "/" & $CampOCR[1] * 2)
	If $CampOCR[0] = $CampOCR[1] * 2 Then
		Return True
	Else
		Return False
	EndIf

EndFunc   ;==>TrainFullQueue

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
		Local $TroopCamp = GetOCRCurrent(43, 160)
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking Troop tab: " & $TroopCamp[0] & "/" & $TroopCamp[1] * 2)
		If $TroopCamp[0] > $TroopCamp[1] And $TroopCamp[0] < $TroopCamp[1] * 2 Then ; 500/520
			RemoveExtraTroopsQueue()
			If _Sleep(500) Then Return
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
			$Step += 1
			If $Step = 3 Then ExitLoop
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
		Local $SpellCamp = GetOCRCurrent(43, 160)
		If $bSetlog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Checking Spell tab: " & $SpellCamp[0] & "/" & $SpellCamp[1] * 2)
		If $SpellCamp[1] = 0 Then $bDoubleTrainSpell = True
		If $SpellCamp[0] > $SpellCamp[1] And $SpellCamp[0] < $SpellCamp[1] * 2 Then ; 20/22
			RemoveExtraTroopsQueue()
			If _Sleep(500) Then Return
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
			$Step += 1
			If $Step = 3 Then ExitLoop
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

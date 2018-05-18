; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderStatus
; Description ...: This function will read remaining time of the earliest builder to be free
;                  It will also update the statistics to the GUI.
; Syntax ........: BuilderStatus()
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

Func BuilderStatus()

	Static $iUpdateTimeInit = 0
	Static $iaUpdateTimeInit[8] = [0, 0, 0, 0, 0, 0, 0, 0]

	Static $iLastCheck = 0
	Static $iaLastCheck[8] = [0, 0, 0, 0, 0, 0, 0, 0]


	If ProfileSwitchAccountEnabled() Then
		For $i = 0 To 7
			If $g_aiBuilderTime[$i] = 0 Then $iaUpdateTimeInit[$i] = 0
			If $g_aiBuilderTime[$i] > 0 And $iaUpdateTimeInit[$i] <> 0 Then
				$g_aiBuilderTime[$i] = Round($g_aiBuilderTime[$i] - TimerDiff($iaUpdateTimeInit[$i]) / 60000, 2)
				SetDebugLog("Update Builder Time Acc[" & $i & "]: " & $g_aiBuilderTime[$i] & "m")
				$iaUpdateTimeInit[$i] = TimerInit()
			EndIf
		Next
		$g_iBuilderTime = $g_aiBuilderTime[$g_iCurAccount]
		$iUpdateTimeInit = $iaUpdateTimeInit[$g_iCurAccount]
	EndIf

	Local $iTimeToCheck = _Min($g_iBuilderTime, 6 * 60) - TimerDiff($iLastCheck) / 60000 ; in minutes
	If $g_iBuilderTime > 0 And $iUpdateTimeInit <> 0 And $iTimeToCheck > 0 Then ;6 hours
		Local $sTimeToCheck = Int($iTimeToCheck / 60) & "h " & Round(Mod($iTimeToCheck, 60), 0) & "m"
		SetDebugLog("Builder Time is still " & $g_iBuilderTime & "m, time to check: " & $sTimeToCheck)

		$g_iBuilderTime = Round($g_iBuilderTime - TimerDiff($iUpdateTimeInit) / 60000, 2)
		$iUpdateTimeInit = TimerInit()
		SetDebugLog("Update Builder Time: " & $g_iBuilderTime & "m")
		Return
	EndIf

	If $g_iFreeBuilderCount >= $g_iTotalBuilderCount Then Return
	SetDebugLog("Getting soonest builder time")

	If IsMainPage() Then Click(293, 32) ; click builder's nose for poping out information

	If _Sleep(1000) Then Return

	Local $sBuilderTime = QuickMIS("OCR", @ScriptDir & "\imgxml\BuilderTime", 335, 102, 335 + 124, 102 + 14, True)
	If $sBuilderTime = "none" Then Return

	$g_iBuilderTime = ConvertOCRLongTime("Builder Time", $sBuilderTime, False)
	SetDebugLog("$sResult QuickMIS OCR: " & $sBuilderTime & " (" & Round($g_iBuilderTime,2) & " minutes)")

	$iLastCheck = TimerInit()
	$iUpdateTimeInit = $iLastCheck
	If ProfileSwitchAccountEnabled() Then
		$g_aiBuilderTime[$g_iCurAccount] = $g_iBuilderTime
		$iaLastCheck[$g_iCurAccount] = $iLastCheck
		$iaUpdateTimeInit[$g_iCurAccount] = $iUpdateTimeInit
	EndIf

	ClickP($aAway, 2, 0, "#0000") ;Click Away
EndFunc   ;==>getBuilderTime

Func ConvertOCRLongTime($WhereRead, $ToConvert, $bSetLog = True) ; Convert longer time with days - hours - minutes - seconds

	Local $iRemainTimer = 0, $aResult, $iDay = 0, $iHour = 0, $iMinute = 0, $iSecond = 0

	If $ToConvert <> "" Then
		If StringInStr($ToConvert, "d") > 1 Then
			$aResult = StringSplit($ToConvert, "d", $STR_NOCOUNT)
			; $aResult[0] will be the Day and the $aResult[1] will be the rest
			$iDay = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "h") > 1 Then
			$aResult = StringSplit($ToConvert, "h", $STR_NOCOUNT)
			$iHour = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "m") > 1 Then
			$aResult = StringSplit($ToConvert, "m", $STR_NOCOUNT)
			$iMinute = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "s") > 1 Then
			$aResult = StringSplit($ToConvert, "s", $STR_NOCOUNT)
			$iSecond = Number($aResult[0])
		EndIf

		$iRemainTimer = Round($iDay * 24 * 60 + $iHour * 60 + $iMinute + $iSecond / 60, 2)
		If $iRemainTimer = 0 And $g_bDebugSetlog Then SetLog($WhereRead & ": Bad OCR string", $COLOR_ERROR)

		If $bSetLog Then SetLog($WhereRead & " time: " & StringFormat("%.2f", $iRemainTimer) & " min", $COLOR_INFO)

	Else
		If $g_bDebugSetlog Then SetLog("Can not read remaining time for " & $WhereRead, $COLOR_ERROR)
	EndIf
	Return $iRemainTimer
EndFunc   ;==>ConvertOCRLongTime

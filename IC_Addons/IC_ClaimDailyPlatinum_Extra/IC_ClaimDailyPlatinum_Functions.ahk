class IC_ClaimDailyPlatinum_Functions
{
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	UpdateSharedSettings()
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			SharedRunData.CDP_UpdateSettingsFromFile(IC_ClaimDailyPlatinum_Component.SettingsPath)
			return true
		}
		return false
	}
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "" && Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
			return true
		return false
	}

	GetAllRegexMatches(haystack,needle) {
		matches := []
		while n := RegExMatch(haystack,"O)" needle,match,n?n+1:1) { ;loop through all matches
			index := matches.length()+1
			loop % match.count() ;check how many subpatterns were found, add them to the array
				matches.push(match.value(a_index))
		}
		return matches
	}
	
}
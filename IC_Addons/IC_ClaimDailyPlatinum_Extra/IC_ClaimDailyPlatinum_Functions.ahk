class IC_ClaimDailyPlatinum_Functions
{
	static SettingsPath := A_LineFile . "\..\ClaimDailyPlatinum_Settings.json"

	InjectAddon()
	{
		local splitStr := StrSplit(A_LineFile, "\")
		local addonDirLoc := splitStr[(splitStr.Count()-1)]
		local addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_ClaimDailyPlatinum_Addon.ahk`n"
		FileAppend, %addonLoc%, %g_BrivFarmModLoc%
	}
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "" && Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
			return true
		return false
	}

	GetAllRegexMatches(haystack,needle)
	{
		matches := []
		while n := RegExMatch(haystack,"O)" needle,match,n?n+1:1)
		{
			index := matches.length()+1
			loop % match.count()
				matches.push(match.value(a_index))
		}
		return matches
	}
	
	ServerCall(callIdent,params)
	{
		params .= g_ServerCall.dummyData . "&user_id=" . g_ServerCall.userID . "&hash=" . g_ServerCall.userHash . "&instance_id=" . g_ServerCall.instanceID
		return g_ServerCall.ServerCall(callIdent,params)
	}
	
}
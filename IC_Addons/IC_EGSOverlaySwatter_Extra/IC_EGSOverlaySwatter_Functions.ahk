class IC_EGSOverlaySwatter_Functions
{
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	UpdateSharedSettings()
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			SharedRunData.EGSOS_UpdateSettingsFromFile(IC_EGSOverlaySwatter_Component.SettingsPath)
			return true
		}
		return false
	}
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "" AND Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
			return true
		return false
	}
	
	IsFolder(inputFolder)
	{
		return InStr(FileExist(inputFolder),"D")
	}
	
	FilesList(dir) {
		local list := []
		Loop, Files, %dir%\*.*, DRF
		{
			if (!RegExMatch(A_LoopFileExt, "i)(txt|exe)"))
				continue
			local currFile := A_LoopFileFullPath
			if (InStr(currFile, "SelfUpdateStaging"))
				continue
			if (RegExMatch(A_LoopFileName, "EOSOverlayRenderer-Win(32|64)-Shipping"))
				list.push(currFile)
		}
		return list
	}
	
}
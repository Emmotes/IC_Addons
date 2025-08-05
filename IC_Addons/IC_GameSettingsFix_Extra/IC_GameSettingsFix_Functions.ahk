Class IC_GameSettingsFix_Functions
{
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	UpdateSharedSettings()
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			SharedRunData.GSF_UpdateSettingsFromFile(IC_GameSettingsFix_Component.SettingsPath)
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
	
	IsNumber(inputText)
	{
		if inputText is number
			return true
		return false
	}
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	ConvertLevelUpIndexFromUI(g_GSF_levelUpIndexUI)
	{
		switch g_GSF_levelUpIndexUI
		{
			case "x1": return 0
			case "x10": return 1
			case "x25": return 2
			case "x100": return 3
			default: return 4
		}
	}
	
	ConvertLevelUpIndexToUI(g_GSF_levelUpIndexVal)
	{
		switch g_GSF_levelUpIndexVal
		{
			case 0: return "x1"
			case 1: return "x10"
			case 2: return "x25"
			case 3: return "x100"
			default: return "Next Upg"
		}
	}
	
	; ======================
	; ===== MISC STUFF =====
	; ======================
	
	ProfilesList(dir)
	{
		local list := []
		if (!this.IsFolder(dir))
			return list
		Loop, Files, %dir%\*.json, DRF
		{
			list.push(A_LoopFileName)
		}
		return list
	}
	
	IsFolder(inputFolder)
	{
		return InStr(FileExist(inputFolder),"D")
	}
	
	IsReadOnly(gameSettingsFileLoc)
	{
		FileGetAttrib, GSF_fileAttributes, %gameSettingsFileLoc%
		if (InStr(GSF_fileAttributes, "R"))
			return true
		return false
	}
	
}
class IC_GameSettingsFix_Functions
{
	static SettingsPath := A_LineFile . "\..\GameSettingsFix_Settings.json"
	static ProfilesPath := A_LineFile . "\..\profiles\"
	static HotkeyReplacements := {"load_formation_1":"Q","load_formation_2":"W","load_formation_3":"E","go_to_previous_area":"LeftArrow","go_to_next_area":"RightArrow","toggle_auto_progress":"G"}
	
	InjectAddon()
	{
		local splitStr := StrSplit(A_LineFile, "\")
		local addonDirLoc := splitStr[(splitStr.Count()-1)]
		local addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_GameSettingsFix_Addon.ahk`n"
		FileAppend, %addonLoc%, %g_BrivFarmModLoc%
	}
	
	UpdateSharedSettings()
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			SharedRunData.GSF_UpdateSettingsFromFile(this.SettingsPath)
			return true
		}
		return false
	}
	
	UpdateProfilesDDL(nameToSelect := "")
	{
		local ddlList := ""
		local foundName := false
		for k,v in this.ProfilesList(this.ProfilesPath)
		{
			local profileName := StrReplace(v, ".json", "")
			ddlList .= profileName "|"
			if (profileName == nameToSelect)
			{
				ddlList .= "|"
				foundName := true
			}
		}
		GuiControl, ICScriptHub:, GSF_Profiles, |
		GuiControl, ICScriptHub:, GSF_Profiles, % ddlList
		Gui, Submit, NoHide
	}
	
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
	
	AddFileToGUIList(GSF_settingsFileLoc)
	{
		local restore_gui_on_return := GUIFunctions.LV_Scope("ICScriptHub", "GSF_SettingsFileLocation")
		LV_Delete()
		LV_Add(,GSF_settingsFileLoc)
		LV_ModifyCol(1)
	}
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "" AND Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
			return true
		return false
	}
	
	IsFolder(GSF_inputFolder)
	{
		return InStr(FileExist(GSF_inputFolder),"D")
	}
	
	IsReadOnly(settingsFileLoc)
	{
		FileGetAttrib, fileAttributes, %settingsFileLoc%
		if (InStr(fileAttributes, "R"))
			return true
		return false
	}
	
	ConvertLevelUpIndexFromUI(levelUpIndexUI)
	{
		switch levelUpIndexUI
		{
			case "x1": return 0
			case "x10": return 1
			case "x25": return 2
			case "x100": return 3
			default: return 4
		}
	}
	
	ConvertLevelUpIndexToUI(levelUpIndexVal)
	{
		switch levelUpIndexVal
		{
			case 0: return "x1"
			case 1: return "x10"
			case 2: return "x25"
			case 3: return "x100"
			default: return "Next Upg"
		}
	}
	
	IsNumber(inputText)
	{
		if inputText is number
			return true
		return false
	}
	
	GSF_FixGameSettings(GSF_CurrSettingsFileLoc := "")
	{
		if (GSF_CurrSettingsFileLoc == "")
			return
		GSF_Settings := g_SharedData.GSF_Settings
		if (GSF_Settings == "") {
			GSF_Settings := g_GameSettingsFix.Settings
			if (GSF_Settings == "")
				return
		}
		if (FileExist(GSF_CurrSettingsFileLoc))
		{
			if (IC_GameSettingsFix_Functions.IsReadOnly(GSF_CurrSettingsFileLoc))
				return "Game settings file is set to read-only. Please disable that immediately."
			GSF_settingsData := this.GSF_ReadAndEditSettingsString(GSF_CurrSettingsFileLoc, GSF_Settings)
			if (GSF_settingsData != "")
				return this.GSF_WriteSettingsStringToFile(GSF_CurrSettingsFileLoc, GSF_settingsData)
			else
				return "Settings didn't need changing."
		}
	}
	
	GSF_ReadAndEditSettingsString(GSF_raessSettingsFileLoc, GSF_raessSettings)
	{
		local GSF_settingsFile
		local madeChanges := false
		FileRead, GSF_settingsFile, %GSF_raessSettingsFileLoc%
		for k,v in GSF_raessSettings
		{
			if (k == "CurrentProfile")
				continue
			if (k == "HKsRequired")
			{
				for k,v in this.HotkeyReplacements
				{
					GSF_before := GSF_settingsFile
					GSF_after := RegExReplace(GSF_before, "(""" . k . """: +[^""]+"")[^""]+"",?[`n`r]+(?:[^`n`r\Q]\E]*[`n`r]+)*( +])", "$1" . v . """`r`n$2")
					if (GSF_before != GSF_after) {
						GSF_SettingsFile := GSF_after
						madeChanges := true
					}
				}
			}
			else if (k == "HKsSwap25100" && v)
			{
				GSF_before := GSF_settingsFile
				GSF_after := RegExReplace(GSF_before, "(""hero_level_10"": +\[)([^]]+)]", "$1`r`n            ""LeftShift""`r`n        ]")
				GSF_after := RegExReplace(GSF_after, "(""hero_level_25"": +\[)([^]]+)]", "$1`r`n            ""LeftControl""`r`n        ]")
				GSF_after := RegExReplace(GSF_after, "(""hero_level_100"": +\[)([^]]+)]", "$1`r`n            ""LeftShift"",`r`n            ""LeftControl""`r`n        ]")
				if (GSF_before != GSF_after) {
					GSF_SettingsFile := GSF_after
					madeChanges := true
				}
			}
			else
			{
				GSF_before := GSF_settingsFile
				GSF_after := RegExReplace(GSF_before, """" k """: (false|true)", """" k """: " (v ? "true" : "false"))
				if (GSF_before != GSF_after) {
					GSF_settingsFile := GSF_after
					madeChanges := true
					continue
				}
				GSF_after := RegExReplace(GSF_before, """" k """: ([0-9]+)", """" k """: " v)
				if (GSF_before != GSF_after) {
					GSF_settingsFile := GSF_after
					madeChanges := true
				}
			}
		}
		if (madeChanges)
			return GSF_settingsFile
		return ""
	}
	
	GSF_WriteSettingsStringToFile(GSF_wsstfFileLoc, GSF_settingsData)
	{
		local GSF_newFile := FileOpen(GSF_wsstfFileLoc, "w")
		if (!IsObject(GSF_newFile))
			return ""
		GSF_newFile.Write(GSF_settingsData)
		GSF_newFile.Close()
		return "The game settings file has been fixed."
	}
	
}
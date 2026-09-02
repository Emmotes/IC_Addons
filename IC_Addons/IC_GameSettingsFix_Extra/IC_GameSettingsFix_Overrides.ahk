class IC_GameSettingsFix_SharedData_Added_Class ; Added to IC_SharedData_Class
{
	GSF_UpdateSettingsFromFile(fileName := "")
	{
		if (fileName == "")
			fileName := IC_GameSettingsFix_Functions.SettingsPath
		settings := g_SF.LoadObjectFromJSON(fileName)
		if (!IsObject(settings))
			return false
		for k,v in settings
			g_BrivUserSettingsFromAddons[ "GSF_" k ] := v
		settings.Delete("CurrentProfile")
		this.GSF_Settings := settings
		if (this.GSF_FixedCounter == "")
			this.GSF_FixedCounter := 0
	}
}

; Overrides: OpenIC()
class IC_GameSettingsFix_SharedFunctions_Class extends IC_SharedFunctions_Class
{
	OpenIC()
	{
		this.GSF_FixGameSettings()
		base.OpenIC()
	}
}

class IC_GameSettingsFix_SharedFunctions_Added_Class ; Added to IC_SharedFunctions_Class
{
	GSF_FixGameSettings()
	{
		result := IC_GameSettingsFix_Functions.GSF_FixGameSettings(g_SharedData.GSF_GameSettingsFileLocation)
		g_SharedData.GSF_Status := result
		if (result == "The game settings file has been fixed.")
			g_SharedData.GSF_FixedCounter++
	}
}
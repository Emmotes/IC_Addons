class IC_GameSettingsFix_SharedData_Class extends IC_SharedData_Class
{

    GSF_UpdateSettingsFromFile(fileName := "")
    {
        if (fileName == "")
            fileName := IC_GameSettingsFix_Component.SettingsPath
        settings := g_SF.LoadObjectFromJSON(fileName)
        if (!IsObject(settings))
            return false
		for k,v in settings
			g_BrivUserSettingsFromAddons[ "GSF_" k ] := v
    }
	
}
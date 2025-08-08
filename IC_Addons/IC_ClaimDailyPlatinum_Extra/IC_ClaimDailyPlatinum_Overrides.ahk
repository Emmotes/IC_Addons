class IC_ClaimDailyPlatinum_SharedData_Class extends IC_SharedData_Class
{

    CDP_UpdateSettingsFromFile(fileName := "")
    {
        if (fileName == "")
            fileName := IC_ClaimDailyPlatinum_Functions.SettingsPath
        settings := g_SF.LoadObjectFromJSON(fileName)
        if (!IsObject(settings))
            return false
		for k,v in settings
			g_BrivUserSettingsFromAddons[ "CDP_" k ] := v
    }
	
}
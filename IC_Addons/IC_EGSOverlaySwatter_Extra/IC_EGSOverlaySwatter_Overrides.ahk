class IC_EGSOverlaySwatter_SharedData_Added_Class ; Added to IC_SharedData_Class
{
    EGSOS_UpdateSettingsFromFile(fileName := "")
    {
        if (fileName == "")
            fileName := IC_EGSOverlaySwatter_Component.SettingsPath
        settings := g_SF.LoadObjectFromJSON(fileName)
        if (!IsObject(settings))
            return false
		for k,v in settings
			g_BrivUserSettingsFromAddons[ "EGSOS_" k ] := v
    }
}
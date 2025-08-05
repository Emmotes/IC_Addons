class IC_EGSOverlaySwatter_SharedData_Class extends IC_SharedData_Class
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

class IC_EGSOverlaySwatter_BrivGemFarm_Class extends IC_BrivSharedFunctions_Class
{

}
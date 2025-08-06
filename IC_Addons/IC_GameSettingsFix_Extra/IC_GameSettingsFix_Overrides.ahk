class IC_GameSettingsFix_SharedData_Class extends IC_SharedData_Class
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

	GSF_FixGameSettings()
	{
		GSF_CurrSettingsFileLoc := g_SharedData.GSF_GameSettingsFileLocation
		if (GSF_CurrSettingsFileLoc == "")
			return
		if (g_SharedData.GSF_Settings == "")
			return
		if (FileExist(GSF_CurrSettingsFileLoc))
		{
			if (IC_GameSettingsFix_Functions.IsReadOnly(GSF_CurrSettingsFileLoc))
			{
				g_SharedData.GSF_Status := "Game settings file is set to read-only. Please disable that immediately."
				return
			}
			GSF_settingsData := this.GSF_ReadAndEditSettingsString(GSF_CurrSettingsFileLoc)
			if (GSF_settingsData != "")
				this.GSF_WriteSettingsStringToFile(GSF_settingsData)
			else
				g_SharedData.GSF_Status := "Settings didn't need changing."
		}
	}
	
	GSF_ReadAndEditSettingsString(GSF_raessSettingsFileLoc)
	{
		local GSF_settingsFile
		local madeChanges := false
		FileRead, GSF_settingsFile, %GSF_raessSettingsFileLoc%
		for k,v in g_SharedData.GSF_Settings
		{
			if (k == "CurrentProfile")
				continue
			g_GSF_before := GSF_settingsFile
			g_GSF_after := RegExReplace(g_GSF_before, """" k """: (false|true)", """" k """: " (v ? "true" : "false"))
			if (g_GSF_before != g_GSF_after) {
				GSF_settingsFile := g_GSF_after
				madeChanges := true
				continue
			}
			g_GSF_after := RegExReplace(g_GSF_before, """" k """: ([0-9]+)", """" k """: " v)
			if (g_GSF_before != g_GSF_after) {
				GSF_settingsFile := g_GSF_after
				madeChanges := true
			}
		}
		if (madeChanges)
			return GSF_settingsFile
		return ""
	}
	
	GSF_WriteSettingsStringToFile(GSF_settingsData)
	{
		local GSF_newFile := FileOpen(g_SharedData.GSF_GameSettingsFileLocation, "w")
		if (!IsObject(GSF_newFile))
			return
		GSF_newFile.Write(GSF_settingsData)
		GSF_newFile.Close()
		g_SharedData.GSF_Status := "The game settings file has been fixed."
		g_SharedData.GSF_FixedCounter++
	}

	OpenIC()
	{
		this.GSF_FixGameSettings()
		
		timeoutVal := 32000 + 90000 ; 32s + waitforgameready timeout
		loadingDone := false
		g_SharedData.LoopString := "Starting Game"
		WinGetActiveTitle, savedActive
		this.SavedActiveWindow := savedActive
		StartTime := A_TickCount
		while ( !loadingZone AND ElapsedTime < timeoutVal )
		{
			this.Hwnd := 0
			ElapsedTime := A_TickCount - StartTime
			if(ElapsedTime < timeoutVal)
				this.OpenProcessAndSetPID(timeoutVal - ElapsedTime)
			ElapsedTime := A_TickCount - StartTime
			if(ElapsedTime < timeoutVal)
				this.SetLastActiveWindowWhileWaingForGameExe(timeoutVal - ElapsedTime)
			Process, Priority, % this.PID, Realtime
			this.ActivateLastWindow()
			this.Memory.OpenProcessReader()
			ElapsedTime := A_TickCount - StartTime
			if(ElapsedTime < timeoutVal)
				loadingZone := this.WaitForGameReady()
			if(loadingZone)
				this.ResetServerCall()
			Sleep, 62
			ElapsedTime := A_TickCount - StartTime
		}
		if(ElapsedTime >= timeoutVal)
			return -1 ; took too long to open
		else
			return 0
	}
	
}
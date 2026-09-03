#include %A_LineFile%\..\IC_DMFishingMinigame_Functions.ahk
#include %A_LineFile%\..\IC_DMFishingMinigame_GUI.ahk

global g_DMFishingMinigame := new IC_DMFishingMinigame_Component
global g_DMFishingMinigameGUI := new IC_DMFishingMinigame_GUI
g_SF.hWnd := WinExist("ahk_exe " . g_userSettings[ "ExeName"])
g_SF.Memory.OpenProcessReader()
g_DMFishingMinigameGUI.Init()
g_DMFishingMinigame.Init()

class IC_DMFishingMinigame_Component
{
	Running := false
	TimerFunctions := {}
	DisplayStatusTimeout := -1
	MessageStickyTimer := 6000

	DefaultSettings := {"compX":-90,"compY":180,"skipX":-127,"skipY":-77,"restX":122,"restY":-141,"S1":false,"S2":false,"S3":false,"S4":false,"S5":true,"S7":false,"S8":false,"S9":false,"S10":false,"S11":false,"S12":false}
	Settings := {}
	
	CurrSeat := 0
	TotalResets := 0

	GameWidth := 0
	GameHeight := 0
	
	; ==========================
	; ===== Main Functions =====
	; ==========================
	
	DMFishingMinigame()
	{
		this.TotalResets := 0
		this.UpdateMainStatus("Start.")
		if (IC_DMFishingMinigame_Functions.IsGameClosed())
		{
			this.UpdateMainStatus("The game is off - cannot proceed. Stopping.")
			this.StopFishing()
			return
		}
		if (!g_SF.Memory.ReadHeroIsOwned(99))
		{
			this.UpdateMainStatus("Dungeon Master isn't owned. Stopping.")
			this.StopFishing()
			return
		}
		this.GameWidth := g_SF.Memory.ReadScreenWidth()
		this.GameHeight := g_SF.Memory.ReadScreenHeight()
		if (this.GameWidth == "" || !this.IsNumber(this.GameWidth) || this.GameHeight == "" || !this.IsNumber(this.GameHeight))
		{
			this.UpdateMainStatus("Can't memory read the game size. Stopping.")
			this.StopFishing()
			return
		}
		this.GameWidthHalf := Round(this.GameWidth / 2, 0)
		this.GameHeightHalf := Round(this.GameHeight / 2, 0)
		Loop
		{
			this.UpdateMainStatus("")
			if (!this.Running)
				break
			this.CurrSeat := IC_DMFishingMinigame_Functions.ReadDMSpecialGuest()
			Sleep, 1500
			if (!this.IsNumber(this.CurrSeat) || this.CurrSeat < 1 || this.CurrSeat > 12 || this.CurrSeat == 6)
			{
				this.UpdateMainStatus("There aren't any unavailable champions to pick. Stopping.")
				this.StopFishing()
				return
			}
			this.UpdateGUI()
			if (this.Settings["S"+this.CurrSeat] == true)
			{
				MsgBox, % "Complete after " . this.TotalResets . " resets."
				this.UpdateMainStatus("Complete after " . this.TotalResets . " resets.")
				this.StopFishing()
				return
			}
			dmfm_result := IC_DMFishingMinigame_Functions.RestartAdventure()
			if (dmfm_result != "success")
			{
				this.UpdateMainStatus(dmfm_result . " Stopping.")
				this.StopFishing()
				return
			}
			this.TotalResets += 1
			this.UpdateGUI()
			Sleep, 100
		}
		this.UpdateMainStatus("Stopped.")
		this.ToggleAllSeatCheckboxes("Enable")
	}
	
	IsNumber(inputText)
	{
		if inputText is number
			return true
		return false
	}
	
	; =======================================
	; ===== Initialisation and Settings =====
	; =======================================

	Init()
	{
		this.LoadSettings()
		this.UpdateMainStatus(IC_DMFishingMinigame_GUI.ReadyMessage)
	}
	
	LoadSettings(pathToGetDMFMSettings := "")
	{
		Global
		writeSettings := false
		if (pathToGetDMFMSettings == "")
			pathToGetDMFMSettings := IC_DMFishingMinigame_Functions.SettingsPath
		this.Settings := g_SF.LoadObjectFromJSON(pathToGetDMFMSettings)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.SanityCheckSettings())
			writeSettings := true
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(pathToGetDMFMSettings, this.Settings)

		GuiControl, ICScriptHub:, DMFM_CompleteCoordsX, % this.Settings["compX"]
		GuiControl, ICScriptHub:, DMFM_CompleteCoordsY, % this.Settings["compY"]
		GuiControl, ICScriptHub:, DMFM_SkipCoordsX, % this.Settings["skipX"]
		GuiControl, ICScriptHub:, DMFM_SkipCoordsY, % this.Settings["skipY"]
		GuiControl, ICScriptHub:, DMFM_RestartCoordsX, % this.Settings["restX"]
		GuiControl, ICScriptHub:, DMFM_RestartCoordsY, % this.Settings["restY"]
		loop, 12
		{
			if (A_Index == 6)
				continue
			GuiControl, ICScriptHub:, DMFM_Seat%A_Index%, % this.Settings["S"+A_Index]
		}
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide

		GuiControlGet,DMFM_CompleteCoordsX, ICScriptHub:, DMFM_CompleteCoordsX
		this.Settings["compX"] := DMFM_CompleteCoordsX
		GuiControlGet,DMFM_CompleteCoordsY, ICScriptHub:, DMFM_CompleteCoordsY
		this.Settings["compY"] := DMFM_CompleteCoordsY
		GuiControlGet,DMFM_SkipCoordsX, ICScriptHub:, DMFM_SkipCoordsX
		this.Settings["skipX"] := DMFM_SkipCoordsX
		GuiControlGet,DMFM_SkipCoordsY, ICScriptHub:, DMFM_SkipCoordsY
		this.Settings["skipY"] := DMFM_SkipCoordsY
		GuiControlGet,DMFM_RestartCoordsX, ICScriptHub:, DMFM_RestartCoordsX
		this.Settings["restX"] := DMFM_RestartCoordsX
		GuiControlGet,DMFM_RestartCoordsY, ICScriptHub:, DMFM_RestartCoordsY
		this.Settings["restY"] := DMFM_RestartCoordsY

		loop, 12
		{
			if (A_Index == 6)
				continue
			GuiControlGet,DMFM_Seat%A_Index%, ICScriptHub:, DMFM_Seat%A_Index%
			this.Settings["S"+A_Index] := DMFM_Seat%A_Index%
		}
		this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		g_SF.WriteObjectToJSON(IC_DMFishingMinigame_Functions.SettingsPath, this.Settings)
		this.UpdateMainStatus("Saved settings.")
	}
	
	SetDefaultSettings()
	{
		this.Settings := {}
		for k,v in this.DefaultSettings
			this.Settings[k] := v
	}
	
	CheckMissingOrExtraSettings()
	{
		for k,v in this.DefaultSettings
			if (this.Settings[k] == "")
				this.Settings[k] := v
		for k,v in this.Settings
			if (!this.DefaultSettings.HasKey(k))
				this.Settings.Delete(k)
	}
	
	SanityCheckSettings()
	{
		local sanityChecked := false
		local compX
		local compY
		local skipX
		local skipY
		local restX
		local restY

		GuiControlGet,compX, ICScriptHub:, DMFM_CompleteCoordsX
		GuiControlGet,compY, ICScriptHub:, DMFM_CompleteCoordsY
		GuiControlGet,skipX, ICScriptHub:, DMFM_SkipCoordsX
		GuiControlGet,skipY, ICScriptHub:, DMFM_SkipCoordsY
		GuiControlGet,restX, ICScriptHub:, DMFM_RestartCoordsX
		GuiControlGet,restY, ICScriptHub:, DMFM_RestartCoordsY

		if compX is not number
		{
			GuiControl, ICScriptHub:, DMFM_CompleteCoordsX, % this.DefaultSettings["compX"]
			this.Settings["compX"] := this.DefaultSettings["compX"]
			sanityChecked := true
		}
		if compY is not number
		{
			GuiControl, ICScriptHub:, DMFM_CompleteCoordsY, % this.DefaultSettings["compY"]
			this.Settings["compY"] := this.DefaultSettings["compY"]
			sanityChecked := true
		}
		if skipX is not number
		{
			GuiControl, ICScriptHub:, DMFM_SkipCoordsX, % this.DefaultSettings["skipX"]
			this.Settings["skipX"] := this.DefaultSettings["skipX"]
			sanityChecked := true
		}
		if skipY is not number
		{
			GuiControl, ICScriptHub:, DMFM_SkipCoordsY, % this.DefaultSettings["skipY"]
			this.Settings["skipY"] := this.DefaultSettings["skipY"]
			sanityChecked := true
		}
		if restX is not number
		{
			GuiControl, ICScriptHub:, DMFM_RestartCoordsX, % this.DefaultSettings["restX"]
			this.Settings["restX"] := this.DefaultSettings["restX"]
			sanityChecked := true
		}
		if restY is not number
		{
			GuiControl, ICScriptHub:, DMFM_RestartCoordsY, % this.DefaultSettings["restY"]
			this.Settings["restY"] := this.DefaultSettings["restY"]
			sanityChecked := true
		}

		return sanityChecked
	}
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	UpdateMainStatus(status)
	{
		GuiControlGet,DMFM_StatusText, ICScriptHub:, DMFM_StatusText
		DMFM_TimerIsUp := this.GetTickCount() - this.DisplayStatusTimeout >= this.MessageStickyTimer
		if (status == "" && !DMFM_TimerIsUp)
			status := DMFM_StatusText
		if (status != "" && DMFM_TimerIsUp)
			this.DisplayStatusTimeout := this.GetTickCount()
		if (status == "")
			status := "Running."
		GuiControl, ICScriptHub:Text, DMFM_StatusText, % status
		Gui, Submit, NoHide
	}
	
	UpdateGUI()
	{
		GuiControl, ICScriptHub:, DMFM_CurrSeat, % this.CurrSeat
		GuiControl, ICScriptHub:, DMFM_NumResets, % this.TotalResets
	}

	ToggleAllSeatCheckboxes(dmfm_enableType)
	{
		loop, 12
		{
			if (A_Index == 6)
				Continue
			GuiControl, ICScriptHub:%dmfm_enableType%, DMFM_Seat%A_Index%
		}
	}

	ToggleStartStopButtons(dmfm_start, dmfm_stop)
	{
		GuiControl, ICScriptHub:%dmfm_start%, DMFM_StartFishing
		GuiControl, ICScriptHub:%dmfm_stop%, DMFM_StopFishing
	}
	
	; =========================
	; ===== RUNNING STUFF =====
	; =========================
	
	StartFishing()
	{
		CoordMode, Mouse, Client
		this.SaveSettings()
		this.ToggleAllSeatCheckboxes("Disable")
		this.ToggleStartStopButtons("Disable", "Enable")
		this.Running := true
		this.DMFishingMinigame()
	}
	
	StopFishing()
	{
		this.Running := false
		this.ToggleAllSeatCheckboxes("Enable")
		this.ToggleStartStopButtons("Enable", "Disable")
	}
	
	GetTickCount()
	{
		return IC_DMFishingMinigame_Functions.GetTickCount()
	}

}

Hotkey, ^+F3, DMFM_StopFishingBooks

DMFM_StopFishingBooks()
{
    g_DMFishingMinigame.StopFishing()
}
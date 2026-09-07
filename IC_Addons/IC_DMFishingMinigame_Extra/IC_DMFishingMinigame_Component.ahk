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

	DefaultSettings := {"coordMode":"TextSearch","c_compX":0,"c_compY":0,"c_skipX":0,"c_skipY":0,"c_restX":0,"c_restY":0,"S1":false,"S2":false,"S3":false,"S4":false,"S5":true,"S7":false,"S8":false,"S9":false,"S10":false,"S11":false,"S12":false}
	Settings := {}
	
	SanityCheckedCustom := false
	CurrSeat := 0
	TotalResets := 0

	PreviousInstanceId := ""
	GameWidth := 0
	GameHeight := 0
	
	; ==========================
	; ===== Main Functions =====
	; ==========================
	
	DMFishingMinigame()
	{
        g_SF.Hwnd := WinExist("ahk_exe " . g_userSettings[ "ExeName"])
		currInstanceId := g_SF.Memory.ReadInstanceID()
		if (this.PreviousInstanceId == "" || currInstanceId == "" || this.PreviousInstanceId != currInstanceId)
		{
        	g_SF.Memory.OpenProcessReader()
			this.PreviousInstanceId := g_SF.Memory.ReadInstanceID()
		}

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
				MsgBox, % "DM got seat " . this.CurrSeat . " after " . this.TotalResets . " resets."
				this.UpdateMainStatus("DM got seat " . this.CurrSeat . " after " . this.TotalResets . " resets.")
				this.StopFishing()
				return
			}
			dmfm_result := IC_DMFishingMinigame_Functions.RestartAdventure(this.SanityCheckedCustom)
			this.SanityCheckedCustom := true
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
		this.ToggleAllSettingsUI("Enable")
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
		this.CurrSeat := IC_DMFishingMinigame_Functions.ReadDMSpecialGuest()
		this.TotalResets := 0
		this.UpdateGUI()
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
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if (this.SanityCheckSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(pathToGetDMFMSettings, this.Settings)

		GuiControl, ICScriptHub:, DMFM_CompleteCoordsX, % this.Settings["c_compX"]
		GuiControl, ICScriptHub:, DMFM_CompleteCoordsY, % this.Settings["c_compY"]
		GuiControl, ICScriptHub:, DMFM_SkipCoordsX, % this.Settings["c_skipX"]
		GuiControl, ICScriptHub:, DMFM_SkipCoordsY, % this.Settings["c_skipY"]
		GuiControl, ICScriptHub:, DMFM_RestartCoordsX, % this.Settings["c_restX"]
		GuiControl, ICScriptHub:, DMFM_RestartCoordsY, % this.Settings["c_restY"]
		loop, 12
		{
			if (A_Index == 6)
				continue
			GuiControl, ICScriptHub:, DMFM_Seat%A_Index%, % this.Settings["S"+A_Index]
		}

		GuiControl, ICScriptHub:Choose, DMFM_CoordMode, % this.Settings["coordMode"]
		this.SetCoordModeUI()
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide

		GuiControlGet,DMFM_CompleteCoordsX, ICScriptHub:, DMFM_CompleteCoordsX
		this.Settings["c_compX"] := DMFM_CompleteCoordsX
		GuiControlGet,DMFM_CompleteCoordsY, ICScriptHub:, DMFM_CompleteCoordsY
		this.Settings["c_compY"] := DMFM_CompleteCoordsY
		GuiControlGet,DMFM_SkipCoordsX, ICScriptHub:, DMFM_SkipCoordsX
		this.Settings["c_skipX"] := DMFM_SkipCoordsX
		GuiControlGet,DMFM_SkipCoordsY, ICScriptHub:, DMFM_SkipCoordsY
		this.Settings["c_skipY"] := DMFM_SkipCoordsY
		GuiControlGet,DMFM_RestartCoordsX, ICScriptHub:, DMFM_RestartCoordsX
		this.Settings["c_restX"] := DMFM_RestartCoordsX
		GuiControlGet,DMFM_RestartCoordsY, ICScriptHub:, DMFM_RestartCoordsY
		this.Settings["c_restY"] := DMFM_RestartCoordsY
		
		GuiControlGet,DMFM_CoordMode, ICScriptHub:, DMFM_CoordMode
		this.Settings["coordMode"] := DMFM_CoordMode

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
		local modified := false
		for k,v in this.DefaultSettings
			if (this.Settings[k] == "")
			{
				this.Settings[k] := v
				modified := true
			}
		for k,v in this.Settings.Clone()
			if (!this.DefaultSettings.HasKey(k))
			{
				this.Settings.Delete(k)
				modified := true
			}
		return modified
	}
	
	SanityCheckSettings()
	{
		local sanityChecked := false

		if (this.Settings["c_compX"] == "" || !this.IsNumber(this.Settings["c_compX"]))
		{
			MsgBox, % "c_compX is not a number " . this.Settings["c_compX"]
			GuiControl, ICScriptHub:, DMFM_CompleteCoordsX, % this.DefaultSettings["c_compX"]
			this.Settings["c_compX"] := this.DefaultSettings["c_compX"]
			sanityChecked := true
		}
		if (this.Settings["c_compY"] == "" || !this.IsNumber(this.Settings["c_compY"]))
		{
			GuiControl, ICScriptHub:, DMFM_CompleteCoordsY, % this.DefaultSettings["c_compY"]
			this.Settings["c_compY"] := this.DefaultSettings["c_compY"]
			sanityChecked := true
		}
		if (this.Settings["c_skipX"] == "" || !this.IsNumber(this.Settings["c_skipX"]))
		{
			GuiControl, ICScriptHub:, DMFM_SkipCoordsX, % this.DefaultSettings["c_skipX"]
			this.Settings["c_skipX"] := this.DefaultSettings["c_skipX"]
			sanityChecked := true
		}
		if (this.Settings["c_skipY"] == "" || !this.IsNumber(this.Settings["c_skipY"]))
		{
			GuiControl, ICScriptHub:, DMFM_SkipCoordsY, % this.DefaultSettings["c_skipY"]
			this.Settings["c_skipY"] := this.DefaultSettings["c_skipY"]
			sanityChecked := true
		}
		if (this.Settings["c_restX"] == "" || !this.IsNumber(this.Settings["c_restX"]))
		{
			GuiControl, ICScriptHub:, DMFM_RestartCoordsX, % this.DefaultSettings["c_restX"]
			this.Settings["c_restX"] := this.DefaultSettings["c_restX"]
			sanityChecked := true
		}
		if (this.Settings["c_restY"] == "" || !this.IsNumber(this.Settings["c_restY"]))
		{
			GuiControl, ICScriptHub:, DMFM_RestartCoordsY, % this.DefaultSettings["c_restY"]
			this.Settings["c_restY"] := this.DefaultSettings["c_restY"]
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
		GuiControl, ICScriptHub:, DMFM_CurrSeat, % this.CurrSeat == "" ? "Can't read memory." : this.CurrSeat == "0" ? "Special Guest Star not available." : this.CurrSeat
		GuiControl, ICScriptHub:, DMFM_NumResets, % this.TotalResets
	}

	ToggleAllSettingsUI(dmfm_enableType)
	{
		GuiControl, ICScriptHub:%dmfm_enableType%, DMFM_CoordMode
		for k,v in ["Complete", "Skip", "Restart"]
		{
			GuiControl, ICScriptHub:%dmfm_enableType%, DMFM_%v%CoordsX
			GuiControl, ICScriptHub:%dmfm_enableType%, DMFM_%v%CoordsY
		}
		loop, 12
		{
			if (A_Index == 6)
				Continue
			GuiControl, ICScriptHub:%dmfm_enableType%, DMFM_Seat%A_Index%
		}
	}

	SetCoordModeUI()
	{
		local cMode
		local visType
		local ctrlName
		local ctrlType
		GuiControlGet,cMode, ICScriptHub:, DMFM_CoordMode
		if (cMode == g_DMFishingMinigameGUI.currentCoordMode)
			return

		hideControls := cMode != "Custom"

		for k,v in g_DMFishingMinigameGUI.settingsHideableControls
			if (hideControls)
				v.Hide()
			else
				v.Show()

		settingsGroupBox := g_DMFishingMinigameGUI.settingsGroupBox.controlId
		settingsGroupBoxH := g_DMFishingMinigameGUI.gboxhSettings[hideControls ? 1 : 2]
		GuiControlGet, pos, ICScriptHub:Pos, DMFM_SettingsGBox
		if (posH != settingsGroupBoxH) {
			GuiControl, ICScriptHub:MoveDraw, %settingsGroupBox%, h%settingsGroupBoxH%

			heightDiff := g_DMFishingMinigameGUI.gboxhSettings[2] - g_DMFishingMinigameGUI.gboxhSettings[1]
			for k,v in g_DMFishingMinigameGUI.restMoveableControls
			{
				controlId := v.controlId
				GuiControlGet, oldPos, ICScriptHub:Pos, %controlId%
				y := oldPosY + heightDiff * (hideControls ? -1 : 1)
				GuiControl, ICScriptHub:Move, %controlId%, y%y%
				; Fix bug with moving when there's a tab.
				GuiControlGet, bugPos, ICScriptHub:Pos, %controlId%
				y -= Abs(heightDiff - Abs(bugPosY - oldPosY))
				GuiControl, ICScriptHub:MoveDraw, %controlId%, y%y%
			}
		}

		if (cMode == "TextSearch")
			g_DMFishingMinigameGUI.settingsCoordModeDDLB1.Show()
		else
			g_DMFishingMinigameGUI.settingsCoordModeDDLB1.Hide()

		if (cMode == "Formulaic")
			g_DMFishingMinigameGUI.settingsCoordModeDDLB2.Show()
		else
			g_DMFishingMinigameGUI.settingsCoordModeDDLB2.Hide()

		if (cMode == "Custom")
			g_DMFishingMinigameGUI.settingsCoordModeDDLB3.Show()
		else
			g_DMFishingMinigameGUI.settingsCoordModeDDLB3.Hide()

		g_DMFishingMinigameGUI.currentCoordMode := cMode
	}

	ToggleUIBetweenRunningStates()
	{
		for k,v in g_DMFishingMinigameGUI.disableWhileRunningControls
			if (this.Running)
				v.Disable()
			else
				v.Enable()
		for k,v in g_DMFishingMinigameGUI.disableWhileNotRunningControls
			if (this.Running)
				v.Enable()
			else
				v.Disable()
	}
	
	; =========================
	; ===== RUNNING STUFF =====
	; =========================
	
	StartFishing()
	{
		CoordMode, Mouse, Client
		this.SaveSettings()
		this.Running := true
		this.SanityCheckedCustom := false
		this.ToggleAllSettingsUI("Disable")
		this.ToggleUIBetweenRunningStates("Disable", "Enable")
		this.DMFishingMinigame()
	}
	
	StopFishing()
	{
		this.Running := false
		this.ToggleAllSettingsUI("Enable")
		this.ToggleUIBetweenRunningStates("Enable", "Disable")
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
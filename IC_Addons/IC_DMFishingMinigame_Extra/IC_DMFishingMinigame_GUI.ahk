#include %A_LineFile%\..\IC_DMFishingMinigame_GUI_Control.ahk

GUIFunctions.AddTab("DM Fishing")

Gui, ICScriptHub:Tab, DM Fishing
GUIFunctions.UseThemeTextColor("DefaultTextColor", 700)
Gui, ICScriptHub:Add, GroupBox, Section x125 y+0 w390 h39, Status
Gui, ICScriptHub:Font, w400
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Add, Text, xs12 ys16 w366 vDMFM_StatusText, % IC_DMFishingMinigame_GUI.InitMessage
GUIFunctions.UseThemeTextColor("DefaultTextColor")

DMFM_SaveSettings()
{
	global
	g_DMFishingMinigame.SaveSettings()
}

DMFM_CoordMode()
{
	global
	g_DMFishingMinigame.SetCoordModeUI()
}

DMFM_StartFishing()
{
	global
	g_DMFishingMinigame.StartFishing()
}

DMFM_StopFishing()
{
	global
	g_DMFishingMinigame.StopFishing()
}

DMFM_ReadNow()
{
	g_DMFishingMinigame.CurrSeat := IC_DMFishingMinigame_Functions.ReadDMSpecialGuest()
	g_DMFishingMinigame.UpdateGUI()
}

DMFM_TestButton()
{
	; Do nothing.
}

class IC_DMFishingMinigame_GUI
{
	static InitMessage := "Initialising..."
	static ReadyMessage := "Ready to start fishing."
	static gboxhSettings := [95, 190]

	disableWhileRunningControls := []
	disableWhileNotRunningControls := []
	settingsHideableControls := []
	restMoveableControls := []
	settingsGroupBox := ""
	settingsCoordModeDDLB1 := ""
	settingsCoordModeDDLB2 := ""
	settingsCoordModeDDLB3 := ""

	currentCoordMode := "Default"

	Init()
	{
		global
		this.BuildGUI()
		this.CreateTooltips()
	}

	BuildGUI()
	{
		global
		Gui, ICScriptHub:Add, Button, xs-106 ys10 w100 h25 vDMFM_SaveSettings gDMFM_SaveSettings, `Save Settings

		GuiControlGet, pos, ICScriptHub:Pos, DMFM_StatusText
		DMFM_lineHeight := posH
		DMFM_lineDiff := 4
		DMFM_initLineDiff := 16
		DMFM_col1w := 150
		DMFM_col2w := 250
		DMFM_col2x := 15 + DMFM_col1w + 15
		DMFM_coordX := 10
		DMFM_coordCol1 := 165
		DMFM_coordCol2 := 200
		DMFM_coordXw := 5
		DMFM_coordEditw := 30

		; ===== Settings =====
		settingsGroupBoxH := this.gboxhSettings[1]
		this.settingsGroupBox := this.AddControl("DMFM_SettingsGBox", "GroupBox", "Section x15 ys+39 w500 h" settingsGroupBoxH, "Settings")
		this.AddControl("DMFM_SettingsBlurb", "Text", "xs15 ys+" DMFM_initLineDiff " w400", "Pick which seats are acceptable Special Guest Stars:")
		seatCounter := 1
		cbY := Round(DMFM_initLineDiff * 1.5 + DMFM_lineHeight,0)
		loop, 12
		{
			if (A_Index == 6)
				continue
			xPos := 13 + ((seatCounter - 1) * 42)
			this.AddControl("DMFM_Seat" A_Index "H", "Text", "xs" xPos " ys+" cbY " w23 +Right", A_Index ":")
			xPos += 25
			ctrlSeatCb := this.AddControl("DMFM_Seat" A_Index, "Checkbox", "xs" xPos " ys" cbY)
			this.disableWhileRunningControls.Push(ctrlSeatCb)
			seatCounter++
		}

		this.AddControl("DMFM_CoordModeH", "Text", "xs10 y+" DMFM_initLineDiff " w95 +Right", "Mouse Coordinates:")
		ddlOffset := DMFM_lineHeight + 3
		settingsCoordModeDDL := this.AddControl("DMFM_CoordMode", "DDL", "gDMFM_CoordMode x+5 y+-" ddlOffset " w100", "Default||Custom|FindText|")
		this.disableWhileRunningControls.Push(settingsCoordModeDDL)
		this.settingsCoordModeDDLB1 := this.AddControl("DMFM_CoordModeB1", "Text", "x+5 y+-" ddlOffset " w270", "These should work for most. Change mode if they don't.")
		GuiControlGet, pos, ICScriptHub:Pos, DMFM_CoordModeB1
		this.settingsCoordModeDDLB3 := this.AddControl("DMFM_CoordModeB3", "Text", "x" posX " y" posY " w270 Hidden", "Text search. Should be more reliable and slightly faster.")

		for k,name in ["Complete", "Skip", "Restart"]
		{
			typeBlurb := name == "Complete" ? "Complete Adventure" : name == "Skip" ? "Skip Completion Stats" : "Restart Adventure"
			typeCoordsH := this.AddControl("DMFM_" name "CoordsH", "Text", "xs" DMFM_coordX " y+" DMFM_initLineDiff " w" DMFM_coordCol1 " +Right Hidden", typeBlurb " Coordinates:")
			GuiControlGet, pos, ICScriptHub:Pos, DMFM_%name%CoordsH
			posEditOffset := posY - 4
			typeCoordsXH := this.AddControl("DMFM_" name "CoordsXH", "Text", "x+5 y" posY " w" DMFM_coordXw " +Right Hidden", "X:")
			typeCoordsX := this.AddControl("DMFM_" name "CoordsX", "Edit", "x+5 y" posEditOffset " w" DMFM_coordEditw " +Right Hidden")
			typeCoordsYH := this.AddControl("DMFM_" name "CoordsYH", "Text", "x+5 y" posY " w" DMFM_coordXw " +Right Hidden", "Y:")
			typeCoordsY := this.AddControl("DMFM_" name "CoordsY", "Edit", "x+5 y" posEditOffset " w" DMFM_coordEditw " +Right Hidden")
			this.disableWhileRunningControls.Push(typeCoordsX)
			this.disableWhileRunningControls.Push(typeCoordsY)
			this.settingsHideableControls.Push(typeCoordsH)
			this.settingsHideableControls.Push(typeCoordsXH)
			this.settingsHideableControls.Push(typeCoordsX)
			this.settingsHideableControls.Push(typeCoordsYH)
			this.settingsHideableControls.Push(typeCoordsY)
		}

		GuiControlGet, pos, ICScriptHub:Pos, DMFM_CompleteCoordsY
		posX += 45
		posY -= 32
		this.settingsCoordModeDDLB2 := this.AddControl("DMFM_CoordModeB2", "Text", "x" posX " y" posY " w200 Hidden", "Use AHK's Window Spy tool to find`n these coordinates by right-clicking`nAHK in the task-bar.`n1. Make sure the game is the active`n     window.`n2. Hover your move over the required`n     buttons in-game.`n3. Copy Mouse Position: Client. It will`n     be in the form X,Y.")
		this.settingsHideableControls.Push(this.settingsCoordModeDDLB2)

		; ===== Info Box =====
		infoGroupBoxH := 60
		infoGroupBox := this.AddControl("DMFM_InfoBox", "GroupBox", "Section x15 ys+" settingsGroupBoxH " w500 h" infoGroupBoxH, "Information")
		infoCurrSeatH := this.AddControl("DMFM_CurrSeatH", "Text", "xs15 ys+" DMFM_initLineDiff " w" DMFM_col1w " +Right", "Current Seat:")
		infoCurrSeat := this.AddControl("DMFM_CurrSeat", "Text", "xs" DMFM_col2x " y+-" DMFM_lineHeight " w" DMFM_col2w)
		infoNumResetsH := this.AddControl("DMFM_NumResetsH", "Text", "xs15 y+" DMFM_lineDiff " w" DMFM_col1w " +Right", "Num Resets:")
		infoNumResets := this.AddControl("DMFM_NumResets", "Text", "xs" DMFM_col2x " y+-" DMFM_lineHeight " w" DMFM_col2w)
		this.restMoveableControls.Push(infoGroupBox)
		this.restMoveableControls.Push(infoCurrSeatH)
		this.restMoveableControls.Push(infoCurrSeat)
		this.restMoveableControls.Push(infoNumResetsH)
		this.restMoveableControls.Push(infoNumResets)
		
		; ===== Fishing Buttons =====
		fishingGroupBoxH := 52
		fishingGroupBox := this.AddControl("DMFM_FishingBox", "GroupBox", "Section x15 ys+" infoGroupBoxH " w500 h" fishingGroupBoxH)
		fishingStart := this.AddControl("DMFM_StartFishing", "Button", "xs15 ys17 w150 gDMFM_StartFishing", "Start Fishing")
		fishingStop := this.AddControl("DMFM_StopFishing", "Button", "x+10 ys17 w150 gDMFM_StopFishing Disabled", "Stop Fishing")
		fishingReadNow := this.AddControl("DMFM_ReadNow", "Button", "x+10 ys17 w150 gDMFM_ReadNow", "Check Current Seat")
		this.disableWhileRunningControls.Push(fishingStart)
		this.disableWhileRunningControls.Push(fishingReadNow)
		this.disableWhileNotRunningControls.Push(fishingStop)
		this.restMoveableControls.Push(fishingGroupBox)
		this.restMoveableControls.Push(fishingStart)
		this.restMoveableControls.Push(fishingStop)
		this.restMoveableControls.Push(fishingReadNow)
		
		; ===== Hotkey Note =====
		hotkeyGroupBoxH := 40
		hotkeyGroupBox := this.AddControl("DMFM_HotkeyGroupBox", "GroupBox", "Section x15 ys+" fishingGroupBoxH " w500 h" hotkeyGroupBoxH)
		hotkeyNote := this.AddControl("DMFM_HotkeyNote", "Text", "xs15 ys+" DMFM_initLineDiff " w450", "Ctrl+Shift+F3 will stop fishing in-case you need control of your mouse back.")
		this.restMoveableControls.Push(hotkeyGroupBox)
		this.restMoveableControls.Push(hotkeyNote)

		;testButton := this.AddControl("DMFM_TestButton", "Button", "xs15 y+50 w150 gDMFM_TestButton", "Test")
		;this.restMoveableControls.Push(testButton)
	}

	AddControl(controlId, controlType, options, text := "")
	{
		return new IC_DMFishingMinigame_GUI_Control(controlId, controlType, options, text)
	}
	
	CreateTooltips()
	{
		GUIFunctions.AddToolTip("DMFM_CompleteCoordsH", "This is the 'Complete' button that shows on the 'Complete Adventure' dialog.")
		GUIFunctions.AddToolTip("DMFM_SkipCoordsH", "This is the 'Skip' button that shows once an adventure has just ended while the completion stats are animating.")
		GUIFunctions.AddToolTip("DMFM_RestartCoordsH", "This is the 'Restart' button that shows once an adventure has ended and the completion stats have finished animating.")
		GUIFunctions.AddToolTip("DMFM_CurrSeatH", "The seat of DM's current Special Guest Star.")
		GUIFunctions.AddToolTip("DMFM_NumResetsH", "The amount of times the current fishing trip has reset the adventure.")
	}
	
}
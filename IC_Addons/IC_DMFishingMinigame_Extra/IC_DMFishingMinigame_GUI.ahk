;#include %A_LineFile%\..\..\..\SharedFunctions\CSharpRNG.ahk

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

/*
DMFM_TestButton()
{
	global
    msglog := A_LineFile . "\..\logTheStuff.txt"
	msgmsg := ""

	currPos := IC_DMFishingMinigame_Functions.ClickCompleteAdventure()
	hWnd := g_SF.hWnd
	WinActivate, ahk_id %hWnd%
	MouseMove, currPos[1], currPos[2]

	msgmsg .= IC_DMFishingMinigame_Functions.ReadDMSpecialGuest()

	file := FileOpen(msglog, "w")
	file.write(msgmsg)
	file.close()
}
*/

class IC_DMFishingMinigame_GUI
{
	static InitMessage := "Initialising..."
	static ReadyMessage := "Ready to start fishing."

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
		DMFM_gboxhSettings := 153
		GUIFunctions.UseThemeTextColor("HeaderTextColor", 700)
		Gui, ICScriptHub:Add, GroupBox, Section x15 ys+39 w500 h%DMFM_gboxhSettings%, Settings
		GUIFunctions.UseThemeTextColor("DefaultTextColor", 400)
		Gui, ICScriptHub:Add, Text, xs15 ys+%DMFM_initLineDiff% w400, Pick which seats are acceptable Special Guest Stars:
		dmfm_counter := 1
		cbY := DMFM_initLineDiff * 1.5 + DMFM_lineHeight
		loop, 12
		{
			if (A_Index == 6)
				continue
			xPos := 13 + ((dmfm_counter - 1) * 42)
			Gui, ICScriptHub:Add, Text, vDMFM_Seat%A_Index%H xs%xPos% ys+%cbY% w23 +Right, %A_Index%:
			xPos += 25
			Gui, ICScriptHub:Add, Checkbox, vDMFM_Seat%A_Index% xs%xPos% ys+%cbY%,
			dmfm_counter++
		}

		Gui, ICScriptHub:Add, Text, vDMFM_CompleteCoordsH xs%DMFM_coordX% y+%DMFM_initLineDiff% w%DMFM_coordCol1% +Right, Complete Adventure Coordinates:
		GuiControlGet, pos, ICScriptHub:Pos, DMFM_CompleteCoordsH
		posEditOffset := posY - 4
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordXw% +Right, X:
		Gui, ICScriptHub:Add, Edit, vDMFM_CompleteCoordsX x+5 y%posEditOffset% w%DMFM_coordEditw% +Right, 
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordXw% +Right, Y:
		Gui, ICScriptHub:Add, Edit, vDMFM_CompleteCoordsY x+5 y%posEditOffset% w%DMFM_coordEditw% +Right, 
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordCol2%, with respect to the game's centre.

		Gui, ICScriptHub:Add, Text, vDMFM_SkipCoordsH xs%DMFM_coordX% y+%DMFM_initLineDiff% w%DMFM_coordCol1% +Right, Skip Button Coordinates:
		GuiControlGet, pos, ICScriptHub:Pos, DMFM_SkipCoordsH
		posEditOffset := posY - 4
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordXw% +Right, X:
		Gui, ICScriptHub:Add, Edit, vDMFM_SkipCoordsX x+5 y%posEditOffset% w%DMFM_coordEditw% +Right, 
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordXw% +Right, Y:
		Gui, ICScriptHub:Add, Edit, vDMFM_SkipCoordsY x+5 y%posEditOffset% w%DMFM_coordEditw% +Right, 
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordCol2%, with respect to the game's bottom-right.

		Gui, ICScriptHub:Add, Text, vDMFM_RestartCoordsH xs%DMFM_coordX% y+%DMFM_initLineDiff% w%DMFM_coordCol1% +Right, Restart Button Coordinates:
		GuiControlGet, pos, ICScriptHub:Pos, DMFM_RestartCoordsH
		posEditOffset := posY - 4
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordXw% +Right, X:
		Gui, ICScriptHub:Add, Edit, vDMFM_RestartCoordsX x+5 y%posEditOffset% w%DMFM_coordEditw% +Right, 
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordXw% +Right, Y:
		Gui, ICScriptHub:Add, Edit, vDMFM_RestartCoordsY x+5 y%posEditOffset% w%DMFM_coordEditw% +Right, 
		Gui, ICScriptHub:Add, Text, x+5 y%posY% w%DMFM_coordCol2%, with respect to the game's bottom-middle.

		; ===== Info Box =====
		DMFM_gboxhInfo := 60
		GUIFunctions.UseThemeTextColor("HeaderTextColor", 700)
		Gui, ICScriptHub:Add, GroupBox, Section x15 ys+%DMFM_gboxhSettings% w500 h%DMFM_gboxhInfo%,
		GUIFunctions.UseThemeTextColor("DefaultTextColor", 400)
		Gui, ICScriptHub:Add, Text, vDMFM_CurrSeatH xs15 ys+%DMFM_initLineDiff% w%DMFM_col1w% +Right, Current Seat:
		Gui, ICScriptHub:Add, Text, vDMFM_CurrSeat xs%DMFM_col2x% y+-%DMFM_lineHeight% w%DMFM_col2w%, 
		Gui, ICScriptHub:Add, Text, vDMFM_NumResetsH xs15 y+%DMFM_lineDiff% w%DMFM_col1w% +Right, Num Resets:
		Gui, ICScriptHub:Add, Text, vDMFM_NumResets xs%DMFM_col2x% y+-%DMFM_lineHeight% w%DMFM_col2w%, 
		
		; ===== Fishing Buttons =====
		DMFM_gboxhButtons := 52
		GUIFunctions.UseThemeTextColor("HeaderTextColor", 700)
		Gui, ICScriptHub:Add, GroupBox, Section x15 ys+%DMFM_gboxhInfo% w500 h%DMFM_gboxhButtons%,
		GUIFunctions.UseThemeTextColor("DefaultTextColor", 400)
		Gui, ICScriptHub:Add, Button, xs15 ys17 w150 vDMFM_StartFishing gDMFM_StartFishing, `Start Fishing
		Gui, ICScriptHub:Add, Button, x+10 ys17 w150 vDMFM_StopFishing gDMFM_StopFishing Disabled, `Stop Fishing
		;Gui, ICScriptHub:Add, Button, x+10 ys17 w150 vDMFM_TestButton gDMFM_TestButton, `Test
		
		; ===== Hotkey Note =====
		DMFM_gboxhHotkey := 40
		GUIFunctions.UseThemeTextColor("HeaderTextColor", 700)
		Gui, ICScriptHub:Add, GroupBox, Section x15 ys+%DMFM_gboxhButtons% w500 h%DMFM_gboxhHotkey%,
		GUIFunctions.UseThemeTextColor("DefaultTextColor", 400)
		Gui, ICScriptHub:Add, Text, xs15 ys+%DMFM_initLineDiff% w450, Ctrl+Shift+F3 will stop fishing for if you run into issues with it stealing the mouse.
	}
	
	CreateTooltips()
	{
		GUIFunctions.AddToolTip("DMFM_CurrSeatH", "The seat of DM's current Special Guest Star.")
		GUIFunctions.AddToolTip("DMFM_NumResetsH", "The amount of times the current fishing trip has reset the adventure.")
	}
	
}
#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\IC_EGSOverlaySwatter_Functions.ahk
#include %A_LineFile%\..\IC_EGSOverlaySwatter_Overrides.ahk

GUIFunctions.AddTab("EGS Overlay Swatter")
global g_EGSOverlaySwatter := new IC_EGSOverlaySwatter_Component

Gui, ICScriptHub:Tab, EGS Overlay Swatter
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Add, Text, x15 y+15, EGS Overlay Swatter:
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Button, x145 y+-15 w100 vg_EGSOverlaySwatterSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_EGSOverlaySwatter, "SaveSettings")
GuiControl,ICScriptHub: +g, g_EGSOverlaySwatterSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, x145 y+-13 w400 vg_EGSOS_StatusText, Waiting for Gem Farm to start

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h180 vg_EGSOS_SettingsGroupBox, Settings
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, xs15 ys+30 vg_EGSOS_DisableOverlay, Disable EGS Overlay?
Gui, ICScriptHub:Add, Text, xs15 y+15 w200 vg_EGSOS_EGSFolderLocationH, EGS Install Folder:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs25 y+10 w450 r3 vg_EGSOS_EGSFolderLocation, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Checkbox, xs15 y+15 vg_EGSOS_CheckDefaultFolder, Also Check Default Folder?  (C:\Program Files (x86)\Epic Games)

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+185 Section w500 h190 vg_EGSOS_InfoGroupBox, Info
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, xs15 ys+30 w110 +Right vg_EGSOS_OverlayStatusH, Current Overlay Status:
Gui, ICScriptHub:Add, Text, xs130 y+-13 w350 vg_EGSOS_OverlayStatus, Unknown
GUIFunctions.UseThemeTextColor("TableTextColor")
Gui, ICScriptHub:Add, ListView, xs15 y+15 w470 r5 vg_EGSOS_OverlayFilesList, Overlay Files
GUIFunctions.UseThemeListViewBackgroundColor("g_EGSOS_OverlayFilesList")
GUIFunctions.UseThemeTextColor("DefaultTextColor")

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+195 Section w500 h65, On Demand
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Button, xs15 ys25 w150 vg_EGSOverlaySwatterEnableNow_Clicked, `Enable Overlay Now
buttonFunc := ObjBindMethod(g_EGSOverlaySwatter, "RestoreOverlayFilesNow")
GuiControl,ICScriptHub: +g, g_EGSOverlaySwatterEnableNow_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Button, x+10 ys25 w150 vg_EGSOverlaySwatterDisableNow_Clicked, `Disable Overlay Now
buttonFunc := ObjBindMethod(g_EGSOverlaySwatter, "SwatOverlayFilesNow")
GuiControl,ICScriptHub: +g, g_EGSOverlaySwatterDisableNow_Clicked, % buttonFunc

if(IsObject(IC_BrivGemFarm_Component))
{
	g_EGSOverlaySwatter.InjectAddon()
}
else
{
	GuiControl, ICScriptHub:Text, g_EGSOS_StatusText, WARNING: This addon needs IC_BrivGemFarm enabled.
	Gui, Submit, NoHide
	return
}

g_EGSOverlaySwatter.Init()

Class IC_EGSOverlaySwatter_Component
{
	static SettingsPath := A_LineFile . "\..\EGSOverlaySwatter_Settings.json"

	TimerFunctions := {}
	EGSPlatformID := 21
	DefaultSettings := {"DisableOverlay":true,"EGSFolder":"C:\Program Files (x86)\Epic Games","CheckDefaultFolder":false}
	Settings := {}
	DisableOverlay := this.DefaultSettings["DisableOverlay"]
	EGSFolder := this.DefaultSettings["EGSFolder"]
	CheckDefaultFolder := this.DefaultSettings["CheckDefaultFolder"]
	EGSFolderExists := true
	MadeChanges := false
	Error := 0
	PlatformID := ""

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================

	InjectAddon()
	{
		local splitStr := StrSplit(A_LineFile, "\")
		local addonDirLoc := splitStr[(splitStr.Count()-1)]
		local addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_EGSOverlaySwatter_Addon.ahk`n"
		FileAppend, %addonLoc%, %g_BrivFarmModLoc%
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_EGSOverlaySwatter, "CreateTimedFunctions"))
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_EGSOverlaySwatter, "StartTimedFunctions"))
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_EGSOverlaySwatter, "GetPlatformID"))
		g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(g_EGSOverlaySwatter, "StopTimedFunctions"))
	}
	
	Init()
	{
		Global
		Gui, Submit, NoHide
		this.LoadSettings()
		;this.CreateTooltips()
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
	}
	
	LoadSettings()
	{
		Global
		Gui, Submit, NoHide
		writeSettings := false
		this.Settings := g_SF.LoadObjectFromJSON(IC_EGSOverlaySwatter_Component.SettingsPath)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(IC_EGSOverlaySwatter_Component.SettingsPath, this.Settings)
		GuiControl, ICScriptHub:, g_EGSOS_DisableOverlay, % this.Settings["DisableOverlay"]
		GuiControl, ICScriptHub:, g_EGSOS_EGSFolderLocation, % this.Settings["EGSFolder"]
		GuiControl, ICScriptHub:, g_EGSOS_CheckDefaultFolder, % this.Settings["CheckDefaultFolder"]
		this.DisableOverlay := this.Settings["DisableOverlay"]
		this.EGSFolder := this.Settings["EGSFolder"]
		this.CheckDefaultFolder := this.Settings["CheckDefaultFolder"]
		this.EGSFolderExists := IC_EGSOverlaySwatter_Functions.IsFolder(this.EGSFolder)
		IC_EGSOverlaySwatter_Functions.UpdateSharedSettings()
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide
		local sanityChecked := this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		
		this.Settings["DisableOverlay"] := g_EGSOS_DisableOverlay
		this.Settings["EGSFolder"] := g_EGSOS_EGSFolderLocation
		this.Settings["CheckDefaultFolder"] := g_EGSOS_CheckDefaultFolder
		this.DisableOverlay := g_EGSOS_DisableOverlay
		this.EGSFolder := g_EGSOS_EGSFolderLocation
		this.CheckDefaultFolder := g_EGSOS_CheckDefaultFolder
		
		g_SF.WriteObjectToJSON(IC_EGSOverlaySwatter_Component.SettingsPath, this.Settings)
		IC_EGSOverlaySwatter_Functions.UpdateSharedSettings()
		if (!sanityChecked)
			this.UpdateMainStatus("Saved settings.")
	}
	
	SanityCheckSettings()
	{
		local sanityChecked := false
		if (g_EGSOS_CheckDefaultFolder AND g_EGSOS_EGSFolderLocation == this.DefaultSettings["EGSFolder"])
		{
			g_EGSOS_CheckDefaultFolder := false
			GuiControl, ICScriptHub:, g_EGSOS_CheckDefaultFolder, % g_EGSOS_CheckDefaultFolder
			this.UpdateMainStatus("Save Error. EGS Folder is default. Disabling Check Default.")
			sanityChecked := true
		}
		this.EGSFolderExists := IC_EGSOverlaySwatter_Functions.IsFolder(g_EGSOS_EGSFolderLocation)
		if (!this.EGSFolderExists)
		{
			g_EGSOS_DisableOverlay := false
			GuiControl, ICScriptHub:, g_EGSOS_DisableOverlay, % g_EGSOS_DisableOverlay
			this.UpdateMainStatus("Save Error. EGS Folder does not exist. Cannot disable.")
		}
		return sanityChecked
	}
	
	SetDefaultSettings()
	{
		this.Settings := {}
		for k,v in this.DefaultSettings
			this.Settings[k] := v
	}
	
	CheckMissingOrExtraSettings()
	{
		local madeEdit := false
		for k,v in this.DefaultSettings
		{
			if (this.Settings[k] == "") {
				this.Settings[k] := v
				madeEdit := true
			}
		}
		for k,v in this.Settings
		{
			if (!this.DefaultSettings.HasKey(k)) {
				this.Settings.Delete(k)
				madeEdit := true
			}
		}
		return madeEdit
	}
	
	CreateTooltips()
	{
		;EGSFolderLocationTT := GUIFunctions.GetToolTipTarget("g_EGSOS_EGSFolderLocationH")
		;g_MouseToolTips[EGSFolderLocationTT] := "The location where you have installed EGS."
	}
	
	UpdateSharedSettings()
	{
		if (IC_EGSOverlaySwatter_Functions.UpdateSharedSettings())
		{
			for k,v in this.TimerFunctions
			{
				if (v == 1234)
				{
					SetTimer, %k%, Off
					SetTimer, %k%, Delete
				}
			}
		}
	}
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	UpdateEGSOverlaySwatter()
	{
		if (this.PlatformID != this.EGSPlatformID)
			return
		else if (!this.EGSFolderExists)
		{
			this.UpdateMainStatus("Saved EGS Folder Location does not exist.")
			return
		}
		this.UpdateMainStatus("Idle. Waiting for next game close.")
		if (IC_EGSOverlaySwatter_Functions.IsGameClosed())
		{
			if (this.InstanceID == "")
				return
			this.SwatOverlayFiles(this.DisableOverlay)
			this.InstanceID := ""
		}
		else
		{
			if (this.InstanceID == "")
				this.InstanceID := g_SF.Memory.ReadInstanceID()
		}
	}
	
	SwatOverlayFiles(disableTheOverlays)
	{
		this.UpdateMainStatus("Game is closed. Checking Overlay Status.")
		this.EGSFolderExists := IC_EGSOverlaySwatter_Functions.IsFolder(this.EGSFolder)
		overlayFiles := IC_EGSOverlaySwatter_Functions.FilesList(this.EGSFolder)
		if (this.CheckDefaultFolder AND IC_EGSOverlaySwatter_Functions.IsFolder(this.DefaultSettings["EGSFolder"]))
		{
			for k,v in IC_EGSOverlaySwatter_Functions.FilesList(this.DefaultSettings["EGSFolder"])
			{
				overlayFiles.push(v)
			}
		}
		if (ObjLength(overlayFiles) == 0)
		{
			this.AddFilesToGUIList([])
			if (disableTheOverlays)
				this.UpdateOverlayStatus("No overlay files can be found - already disabled.")
			else
				this.UpdateOverlayStatus("Cannot enable overlay because no overlay files exist.")
		}
		else
		{
			this.ToggleOverlayFiles(overlayFiles,disableTheOverlays)
			if (this.MadeChanges)
				this.UpdateMainStatus("EGS Overlay files have been " (disableTheOverlays ? "disabled" : "enabled") ".")
			this.UpdateOverlayStatus(disableTheOverlays ? "Disabled." : "Enabled.")
			if (this.Error > 0)
				this.UpdateOverlayStatus("One or more overlay files could not be renamed. Need to run as admin.")
		}
	}
	
	ToggleOverlayFiles(overlayFiles,disableTheOverlays)
	{
		if (ObjLength(overlayFiles) == 0)
			return
		filesRenamed := []
		this.Error := 0
		for k,v in overlayFiles
		{
			egsosAdded := false
			if (disableTheOverlays AND !InStr(v, ".txt")) ; Overlay file is not disabled.
			{
				vWithTxt := % v ".txt"
				FileMove, %v%, %vWithTxt%, 1
				if (ErrorLevel == 0)
				{
					this.MadeChanges := true
					filesRenamed.push(wWithTxt)
					egsosAdded := true
				}
				else
					this.Error := 1
			}
			else if (!disableTheOverlays AND InStr(v, ".txt")) ; Overlay is disabled.
			{
				vWithoutTxt := SubStr(v, 1, -4)
				FileMove, %v%, %vWithoutTxt%, 1
				if (ErrorLevel == 0)
				{
					this.MadeChanges := true
					filesRenamed.push(vWithoutTxt)
					egsosAdded := true
				}
				else
					this.Error := 1
			}
			if (!egsosAdded)
				filesRenamed.push(v)
		}
		this.AddFilesToGUIList(filesRenamed)
	}
	
	SwatOverlayFilesNow()
	{
		if (!IC_EGSOverlaySwatter_Functions.IsGameClosed())
		{
			MsgBox, 48, Error, Cannot disable the overlay files while the game is running.
			return
		}
		this.SwatOverlayFiles(true)
	}
	
	RestoreOverlayFilesNow()
	{
		if (!IC_EGSOverlaySwatter_Functions.IsGameClosed())
		{
			MsgBox, 48, Error, Cannot enable the overlay files while the game is running.
			return
		}
		this.SwatOverlayFiles(false)
	}
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	UpdateMainStatus(status)
	{
		GuiControl, ICScriptHub:Text, g_EGSOS_StatusText, % status
		Gui, Submit, NoHide
	}
	
	UpdateOverlayStatus(status)
	{
		GuiControl, ICScriptHub:Text, g_EGSOS_OverlayStatus, % status
		Gui, Submit, NoHide
	}
	
	AddFilesToGUIList(filesRenamed)
	{
		local restore_gui_on_return := GUIFunctions.LV_Scope("ICScriptHub", "g_EGSOS_OverlayFilesList")
		LV_Delete()
		for k,v in filesRenamed
		{
			local newV := StrReplace(v, "\\", "\")
			LV_Add(,newV)
		}
		if (ObjLength(filesRenamed) > 0)
			LV_ModifyCol(1)
		else
			LV_ModifyCol(500)
	}
	
	; =======================
	; ===== TIMED STUFF =====
	; =======================
	
	; Adds timed functions (typically to be started when briv gem farm is started)
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer :=  ObjBindMethod(this, "UpdateEGSOverlaySwatter")
		this.TimerFunctions[fncToCallOnTimer] := 1000
		fncToCallOnTimer := ObjBindMethod(this, "UpdateSharedSettings")
		this.TimerFunctions[fncToCallOnTimer] := 1234
	}

	; Starts the saved timed functions (typically to be started when briv gem farm is started)
	StartTimedFunctions()
	{
		for k,v in this.TimerFunctions
		{
			SetTimer, %k%, %v%, 0
		}
	}
	
	; Called when briv gem farm is started
	GetPlatformID()
	{
		this.PlatformID := g_SF.Memory.ReadPlatform()
		if (this.PlatformID != this.EGSPlatformID)
		{
			GuiControl, ICScriptHub:Hide, g_EGSOverlaySwatterSave_Clicked
			GuiControl, ICScriptHub:Hide, g_EGSOS_SettingsGroupBox
			GuiControl, ICScriptHub:Hide, g_EGSOS_DisableOverlay
			GuiControl, ICScriptHub:Hide, g_EGSOS_EGSFolderLocationH
			GuiControl, ICScriptHub:Hide, g_EGSOS_EGSFolderLocation
			GuiControl, ICScriptHub:Hide, g_EGSOS_CheckDefaultFolder
			GuiControl, ICScriptHub:Hide, g_EGSOS_InfoGroupBox
			GuiControl, ICScriptHub:Hide, g_EGSOS_OverlayStatusH
			GuiControl, ICScriptHub:Hide, g_EGSOS_OverlayStatus
			GuiControl, ICScriptHub:Hide, g_EGSOS_OverlayFilesList
			this.StopTimedFunctions()
			this.UpdateMainStatus("Why have you enabled this addon? You're not on the EGS platform.")
		}
	}

	; Stops the saved timed functions (typically to be stopped when briv gem farm is stopped)
	StopTimedFunctions()
	{
		for k,v in this.TimerFunctions
		{
			SetTimer, %k%, Off
			SetTimer, %k%, Delete
		}
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
	}
	
}
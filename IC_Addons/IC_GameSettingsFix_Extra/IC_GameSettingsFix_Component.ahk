#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\IC_GameSettingsFix_Functions.ahk
#include %A_LineFile%\..\IC_GameSettingsFix_Overrides.ahk

GUIFunctions.AddTab("Game Settings Fix")
global g_GameSettingsFix := new IC_GameSettingsFix_Component

Gui, ICScriptHub:Tab, Game Settings Fix
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Add, Text, x15 y+15, Game Settings Fix:
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Button, x145 y+-18 w100 vg_GameSettingsFixSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_GameSettingsFix, "SaveSettings")
GuiControl,ICScriptHub: +g, g_GameSettingsFixSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, x145 y+-13 w400 vg_GSF_StatusText, Waiting for Gem Farm to start

global g_GSF_col1w := 180
global g_GSF_col2w := 70
global g_GSF_col3w := 180
global g_GSF_col1x := 15
global g_GSF_col2x := 205
global g_GSF_col3x := 290
global g_GSF_ypos := 20
global g_GSF_xpos := 15

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h55, Profiles
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, xs%g_GSF_xpos% ys+24 w38 +Right, Profiles:
g_GSF_xpos += 48
Gui, ICScriptHub:Add, DDL, xs%g_GSF_xpos% y+-17 w150 vg_GSF_Profiles, 
g_GSF_xpos += 160
GuiControlGet, pos, ICScriptHub:Pos, g_GSF_Profiles
posY -= 1
Gui, ICScriptHub:Add, Button, xs%g_GSF_xpos% y%posY% w80 vg_GameSettingsFixSaveProfile_Clicked, `Save Profile
buttonFunc := ObjBindMethod(g_GameSettingsFix, "SaveProfile")
GuiControl,ICScriptHub: +g, g_GameSettingsFixSaveProfile_Clicked, % buttonFunc
g_GSF_xpos += 90
Gui, ICScriptHub:Add, Button, xs%g_GSF_xpos% y%posY% w80 vg_GameSettingsFixLoadProfile_Clicked, `Load Profile
buttonFunc := ObjBindMethod(g_GameSettingsFix, "LoadProfile")
GuiControl,ICScriptHub: +g, g_GameSettingsFixLoadProfile_Clicked, % buttonFunc
g_GSF_xpos += 90
Gui, ICScriptHub:Add, Button, xs%g_GSF_xpos% y%posY% w80 vg_GameSettingsFixDeleteProfile_Clicked, `Delete Profile
buttonFunc := ObjBindMethod(g_GameSettingsFix, "DeleteProfile")
GuiControl,ICScriptHub: +g, g_GameSettingsFixDeleteProfile_Clicked, % buttonFunc

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+60 Section w500 h345, Settings
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, Setting
Gui, ICScriptHub:Add, Text, xs%g_GSF_col2x% ys%g_GSF_ypos% w%g_GSF_col2w%, Value
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% ys%g_GSF_ypos% w%g_GSF_col3w%, Recommended
Gui, ICScriptHub:Font, w400
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_TargetFramerateH, TargetFramerate:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right vg_GSF_TargetFramerate, 600
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, 600 (Maybe more - maybe less)
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_PercentOfParticlesSpawnedH, PercentOfParticlesSpawned:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right vg_GSF_PercentOfParticlesSpawned, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, 0
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_resolution_xH, resolution_x:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right vg_GSF_resolution_x, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_resolution_yH, resolution_y:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right vg_GSF_resolution_y, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_resolution_fullscreenH, resolution_fullscreen:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_resolution_fullscreen,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_ReduceFramerateWhenNotInFocusH, ReduceFramerateWhenNotInFocus:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_ReduceFramerateWhenNotInFocus,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Unchecked
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_FormationSaveIncludeFeatsCheckH, FormationSaveIncludeFeatsCheck:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_FormationSaveIncludeFeatsCheck,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Unchecked
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_LevelupAmountIndexH, LevelupAmountIndex:
Gui, ICScriptHub:Add, DDL, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% vg_GSF_LevelupAmountIndex, x1|x10|x25|x100|Next Upg||
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Next Upg or x100 w/ Level Up Addon
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_UseConsolePortraitsH, UseConsolePortraits:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_UseConsolePortraits,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_NarrowHeroBoxesH, NarrowHeroBoxes:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_NarrowHeroBoxes,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_ShowAllHeroBoxesH, ShowAllHeroBoxes:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_ShowAllHeroBoxes,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_NeverOpenActiveTasksH, NeverOpenActiveTasks:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_NeverOpenActiveTasks,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Checked

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+350 Section w500 h140, Info
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, xs15 ys+30 w125, Num Times Fixed Settings:
Gui, ICScriptHub:Add, Text, xs150 y+-13 w200 vg_GSF_NumTimesFixed, 0
GUIFunctions.UseThemeTextColor("TableTextColor")
Gui, ICScriptHub:Add, ListView, xs15 y+15 w470 r2 vg_GSF_SettingsFileLocation, Settings File Location
GUIFunctions.UseThemeListViewBackgroundColor("g_GSF_SettingsFileLocation")
GUIFunctions.UseThemeTextColor("DefaultTextColor")

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+145 Section w500 h65, On Demand
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Button, xs15 ys25 w100 vg_GameSettingsFixForceFix_Clicked, `Fix Settings Now
buttonFunc := ObjBindMethod(g_GameSettingsFix, "FixSettingsNow")
GuiControl,ICScriptHub: +g, g_GameSettingsFixForceFix_Clicked, % buttonFunc

if(IsObject(IC_BrivGemFarm_Component))
{
	g_GameSettingsFix.InjectAddon()
	g_GameSettingsFix.Init()
}
else
{
	GuiControl, ICScriptHub:Text, g_GSF_StatusText, WARNING: This addon needs IC_BrivGemFarm enabled.
	Gui, Submit, NoHide
	return
}

Class IC_GameSettingsFix_Component
{
	static SettingsPath := A_LineFile . "\..\GameSettingsFix_Settings.json"
	static ProfilesPath := A_LineFile . "\..\profiles\"
	
	WaitingMessage := "Waiting for Gem Farm to start."
	ReadOnlyMessage := "Game settings file is set to read-only. Please disable that immediately."

	Injected := false
	TimerFunctions := {}
	DefaultSettings := {"TargetFramerate":600,"PercentOfParticlesSpawned":0,"resolution_x":1280,"resolution_y":720,"resolution_fullscreen":false,"ReduceFramerateWhenNotInFocus":false,"LevelupAmountIndex":3,"UseConsolePortraits":false,"FormationSaveIncludeFeatsCheck":false,"NarrowHeroBoxes":true,"ShowAllHeroBoxes":true,"NeverOpenActiveTasks":true,"CurrentProfile":""}
	Settings := {}
	GameSettingsFileLocation := ""
	InstanceID := ""
	MadeChanges := false
	FixedCounter := 0
	CurrentProfile := this.DefaultSettings["CurrentProfile"]
	ReadOnly := false

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================

	InjectAddon()
	{
		local splitStr := StrSplit(A_LineFile, "\")
		local addonDirLoc := splitStr[(splitStr.Count()-1)]
		local addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_GameSettingsFix_Addon.ahk`n"
		FileAppend, %addonLoc%, %g_BrivFarmModLoc%
		this.Injected := true
	}
	
	Init()
	{
		if (!this.Injected)
			return
		this.LoadSettings()
		this.UpdateProfilesDDL(this.CurrentProfile)
		this.CreateTooltips()
		this.FindSettingsFile()
		this.UpdateMainStatus(this.WaitingMessage)
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_GameSettingsFix, "CreateTimedFunctions"))
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_GameSettingsFix, "StartTimedFunctions"))
		g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(g_GameSettingsFix, "StopTimedFunctions"))
	}
	
	LoadSettings(gsfPathToGetSettings := "")
	{
		Global
		writeSettings := false
		if (gsfPathToGetSettings == "")
			gsfPathToGetSettings := this.SettingsPath
		this.Settings := g_SF.LoadObjectFromJSON(gsfPathToGetSettings)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(gsfPathToGetSettings, this.Settings)
		GuiControl, ICScriptHub:, g_GSF_TargetFramerate, % this.Settings["TargetFramerate"]
		GuiControl, ICScriptHub:, g_GSF_PercentOfParticlesSpawned, % this.Settings["PercentOfParticlesSpawned"]
		GuiControl, ICScriptHub:, g_GSF_resolution_x, % this.Settings["resolution_x"]
		GuiControl, ICScriptHub:, g_GSF_resolution_y, % this.Settings["resolution_y"]
		GuiControl, ICScriptHub:, g_GSF_resolution_fullscreen, % this.Settings["resolution_fullscreen"]
		GuiControl, ICScriptHub:, g_GSF_ReduceFramerateWhenNotInFocus, % this.Settings["ReduceFramerateWhenNotInFocus"]
		GuiControl, ICScriptHub:Choose, g_GSF_LevelupAmountIndex, % IC_GameSettingsFix_Functions.ConvertLevelUpIndexToUI(this.Settings["LevelupAmountIndex"])
		GuiControl, ICScriptHub:, g_GSF_UseConsolePortraits, % this.Settings["UseConsolePortraits"]
		GuiControl, ICScriptHub:, g_GSF_FormationSaveIncludeFeatsCheck, % this.Settings["FormationSaveIncludeFeatsCheck"]
		GuiControl, ICScriptHub:, g_GSF_NarrowHeroBoxes, % this.Settings["NarrowHeroBoxes"]
		GuiControl, ICScriptHub:, g_GSF_ShowAllHeroBoxes, % this.Settings["ShowAllHeroBoxes"]
		GuiControl, ICScriptHub:, g_GSF_NeverOpenActiveTasks, % this.Settings["NeverOpenActiveTasks"]
		this.CurrentProfile := this.Settings["CurrentProfile"]
		IC_GameSettingsFix_Functions.UpdateSharedSettings()
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide
		local sanityChecked := this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		this.Settings["TargetFramerate"] := g_GSF_TargetFramerate
		this.Settings["PercentOfParticlesSpawned"] := g_GSF_PercentOfParticlesSpawned
		this.Settings["resolution_x"] := g_GSF_resolution_x
		this.Settings["resolution_y"] := g_GSF_resolution_y
		this.Settings["resolution_fullscreen"] := g_GSF_resolution_fullscreen
		this.Settings["ReduceFramerateWhenNotInFocus"] := g_GSF_ReduceFramerateWhenNotInFocus
		this.Settings["LevelupAmountIndex"] := IC_GameSettingsFix_Functions.ConvertLevelUpIndexFromUI(g_GSF_LevelupAmountIndex)
		this.Settings["UseConsolePortraits"] := g_GSF_UseConsolePortraits
		this.Settings["FormationSaveIncludeFeatsCheck"] := g_GSF_FormationSaveIncludeFeatsCheck
		this.Settings["NarrowHeroBoxes"] := g_GSF_NarrowHeroBoxes
		this.Settings["ShowAllHeroBoxes"] := g_GSF_ShowAllHeroBoxes
		this.Settings["NeverOpenActiveTasks"] := g_GSF_NeverOpenActiveTasks
		this.Settings["CurrentProfile"] := this.CurrentProfile
		g_SF.WriteObjectToJSON(this.SettingsPath, this.Settings)
		IC_GameSettingsFix_Functions.UpdateSharedSettings()
		if (!sanityChecked)
			this.UpdateMainStatus("Saved settings.")
	}
	
	SanityCheckSettings()
	{
		local sanityChecked := false
		if (!IC_GameSettingsFix_Functions.IsNumber(g_GSF_TargetFramerate) OR g_GSF_TargetFramerate <= 20)
		{
			g_GSF_TargetFramerate := this.DefaultSettings["TargetFramerate"]
			GuiControl, ICScriptHub:, g_GSF_TargetFramerate, % g_GSF_TargetFramerate
			sanityChecked := true
			this.UpdateMainStatus("Save Error. TargetFramerate was an invalid number.")
		}
		if (!IC_GameSettingsFix_Functions.IsNumber(g_GSF_PercentOfParticlesSpawned) OR g_GSF_PercentOfParticlesSpawned < 0 OR g_GSF_PercentOfParticlesSpawned > 100)
		{
			g_GSF_PercentOfParticlesSpawned := this.DefaultSettings["PercentOfParticlesSpawned"]
			GuiControl, ICScriptHub:, g_GSF_PercentOfParticlesSpawned, % g_GSF_PercentOfParticlesSpawned
			sanityChecked := true
			this.UpdateMainStatus("Save Error. PercentOfParticlesSpawned was an invalid number.")
		}
		if (!IC_GameSettingsFix_Functions.IsNumber(g_GSF_resolution_x) OR g_GSF_resolution_x < 0)
		{
			g_GSF_resolution_x := this.DefaultSettings["resolution_x"]
			GuiControl, ICScriptHub:, g_GSF_resolution_x, % g_GSF_resolution_x
			sanityChecked := true
			this.UpdateMainStatus("Save Error. resolution_x was an invalid number.")
		}
		if (!IC_GameSettingsFix_Functions.IsNumber(g_GSF_resolution_y) OR g_GSF_resolution_y < 0)
		{
			g_GSF_resolution_y := this.DefaultSettings["resolution_y"]
			GuiControl, ICScriptHub:, g_GSF_resolution_y, % g_GSF_resolution_y
			sanityChecked := true
			this.UpdateMainStatus("Save Error. resolution_y was an invalid number.")
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
		TargetFramerateTT := GUIFunctions.GetToolTipTarget("g_GSF_TargetFramerateH")
		ParticlesTT := GUIFunctions.GetToolTipTarget("g_GSF_PercentOfParticlesSpawnedH")
		ResolutionXTT := GUIFunctions.GetToolTipTarget("g_GSF_resolution_xH")
		ResolutionYTT := GUIFunctions.GetToolTipTarget("g_GSF_resolution_yH")
		ResolutionFSTT := GUIFunctions.GetToolTipTarget("g_GSF_resolution_fullscreenH")
		ReduceFPSFocusTT := GUIFunctions.GetToolTipTarget("g_GSF_ReduceFramerateWhenNotInFocusH")
		IncludeFeatsTT := GUIFunctions.GetToolTipTarget("g_GSF_FormationSaveIncludeFeatsCheckH")
		LevelUpIndexTT := GUIFunctions.GetToolTipTarget("g_GSF_LevelupAmountIndexH")
		ConsolePortraitsTT := GUIFunctions.GetToolTipTarget("g_GSF_UseConsolePortraitsH")
		NarrowBenchTT := GUIFunctions.GetToolTipTarget("g_GSF_NarrowHeroBoxesH")
		ShowAllBoxesTT := GUIFunctions.GetToolTipTarget("g_GSF_ShowAllHeroBoxesH")
		NeverOpenActiveTasksTT := GUIFunctions.GetToolTipTarget("g_GSF_NeverOpenActiveTasksH")
		g_MouseToolTips[TargetFramerateTT] := "Settings -> Graphics -> Target Framerate:`nThis sets the upper-limit for FPS for the game."
		g_MouseToolTips[ParticlesTT] := "Settings -> Graphics -> Particle Amount:`nThe graphics for some abilities can create other little graphical effects`ncalled particles. This sets the proportion of them that can be created."
		g_MouseToolTips[ResolutionXTT] := "Settings -> Display -> Resolution:`nThe width of your game window in pixels."
		g_MouseToolTips[ResolutionYTT] := "Settings -> Display -> Resolution:`nThe height of your game window in pixels."
		g_MouseToolTips[ResolutionFSTT] := "Settings -> Display -> Fullscreen:`nDetermines whether the game covers the entire screen or not."
		g_MouseToolTips[ReduceFPSFocusTT] := "Settings -> Graphics -> Reduce framerate when in background:`nThis will limit the fps of the game (and therefore slow it down) while`nit's hidden behind other windows."
		g_MouseToolTips[IncludeFeatsTT] := "Formation Manager -> Include currently equipped Feats with save:`nDetermines whether a formation save will have feats included or not`nwhen saved."
		g_MouseToolTips[LevelUpIndexTT] := "Level Up Button (Left of BUD/Ultimate bar):`nDetermines how champions are levelled up."
		g_MouseToolTips[ConsolePortraitsTT] := "Settings -> Interface -> Console UI Portraits:`nDetermines whether the portraits for the champions on the bench are the`ncreepy ones that stare into your soul or not."
		g_MouseToolTips[NarrowBenchTT] := "Settings -> Interface -> Narrow Bench Boxes:`nDetermines whether you can see all champions on the bench on low`nresolutions or not."
		g_MouseToolTips[ShowAllBoxesTT] := "Settings -> Interface -> Show All Bench Seats:`nDetermines whether you can see all champions on the bench even`nif you can't afford to unlock them yet."
		g_MouseToolTips[NeverOpenActiveTasksTT] := "Settings -> General -> Never Open Active Tasks`nDetermines whether the Active Tasks menu will pop up once per day."
	}
	
	SaveProfile()
	{
		local profileName
		local defaultText := this.CurrentProfile
		WinGetPos, xPos, yPos,,, 
		InputBox, profileName, Profile Name, Input the profile name:,,375,129,,,,,%defaultText%
		isCanceled := ErrorLevel
		while ((!GUIFunctions.TestInputForAlphaNumericDash(profileName) AND !isCanceled) OR profileName == "")
		{
			if (profileName == "")
				errMsg := "Cannot use an empty name."
			else
				errMsg := "Can only contain letters numbers or dashes."
			InputBox, profileName, Profile Name, %errMsg%`nInput the profile name:,,375,144,,,,,%defaultText%
			isCanceled := ErrorLevel
		}
		if (isCanceled)
		{
			this.UpdateMainStatus("Cancelled saving profile.")
			return
		}
		local profilePath := this.ProfilesPath . profileName . ".json"
		if (FileExist(profilePath))
		{
			MsgBox, 52, Overwrite?, This profile already exists. Overwrite it?
			IfMsgBox, No
			{
				this.UpdateMainStatus("Cancelled saving profile.")
				return
			}
		}
		this.CurrentProfile := profileName
		this.SaveSettings()
		local profileSettings = {}
		for k,v in this.Settings
		{
			profileSettings.push(k, v)
		}
		if (!IC_GameSettingsFix_Functions.IsFolder(this.ProfilesPath))
			FileCreateDir, % this.ProfilesPath
		g_SF.WriteObjectToJSON(profilePath, this.Settings)
		this.UpdateProfilesDDL(profileName)
		this.UpdateMainStatus("Saved profile: " profileName)
	}
	
	LoadProfile()
	{
		Global
		Gui, Submit, NoHide
		g_GSF_CurrProfilePath := this.ProfilesPath g_GSF_Profiles ".json"
		g_GSF_ProfileSettings := g_SF.LoadObjectFromJSON(g_GSF_CurrProfilePath)
		this.Settings := {}
		for k,v in g_GSF_ProfileSettings
		{
			this.Settings.push(k, v)
		}
		this.LoadSettings(g_GSF_CurrProfilePath)
		this.SaveSettings()
		this.UpdateMainStatus("Loaded profile: " g_GSF_Profiles)
	}
	
	DeleteProfile()
	{
		Global
		Gui, Submit, NoHide
		MsgBox, 52, Delete?, Are you sure you want to delete the '%g_GSF_Profiles%' profile?
		IfMsgBox, No
		{
			this.UpdateMainStatus("Cancelled deleting profile.")
			return
		}
		g_GSF_CurrProfilePath := this.ProfilesPath g_GSF_Profiles ".json"
		FileDelete, % g_GSF_CurrProfilePath
		if (ErrorLevel > 0)
			this.UpdateMainStatus("Failed to delete profile for unknown reasons.")
		else
			this.UpdateMainStatus("Deleted profile: " g_GSF_Profiles)
		if (g_GSF_Profiles == this.CurrentProfile)
		{
			this.CurrentProfile := ""
			this.SaveSettings()
		}
		this.UpdateProfilesDDL(this.CurrentProfile)
	}
	
	UpdateSharedSettings()
	{
		if (IC_GameSettingsFix_Functions.UpdateSharedSettings())
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
	
	UpdateGameSettingsFix()
	{
		if (this.ReadOnly)
		{
			this.UpdateMainStatus(this.ReadOnlyMessage)
			this.ReadOnly := IC_GameSettingsFix_Functions.IsReadOnly(this.GameSettingsFileLocation)
			if (this.ReadOnly)
				return
		}
		this.UpdateMainStatus("Idle. Waiting for next game close.")
		if (IC_GameSettingsFix_Functions.IsGameClosed())
		{
			if (this.InstanceID == "")
				return
			this.FixGameSettings()
			this.InstanceID := ""
		}
		else
		{
			if (this.GameSettingsFileLocation == "")
				this.FindSettingsFile()
			if (this.InstanceID == "")
				this.InstanceID := g_SF.Memory.ReadInstanceID()
		}
	}
	
	FixGameSettings()
	{
		this.UpdateMainStatus("Game is closed. Verifying settings.")
		if (this.GameSettingsFileLocation != "" AND FileExist(this.GameSettingsFileLocation))
		{
			this.ReadOnly := IC_GameSettingsFix_Functions.IsReadOnly(this.GameSettingsFileLocation)
			if (this.ReadOnly)
			{
				this.UpdateMainStatus(this.ReadOnlyMessage)
				return
			}
			g_GSF_settingsFile := this.ReadAndEditSettingsString(this.GameSettingsFileLocation)
			if (this.MadeChanges)
				this.WriteSettingsStringToFile(g_GSF_settingsFile, this.GameSettingsFileLocation)
		}
	}
	
	FindSettingsFile()
	{
		installPath := g_UserSettings["InstallPath"] ;Contains filename
		SplitPath, installPath,, settingsFileLoc
		settingsFileLoc .= "\IdleDragons_Data\StreamingAssets\localSettings.json"
		if (!FileExist(settingsFileLoc))
		{
			if (IC_GameSettingsFix_Functions.IsGameClosed())
				return
			webRequestLogLoc := g_SF.Memory.GetWebRequestLogLocation()
			if (!InStr(webRequestLogLoc, "webRequestLog"))
				return
			settingsFileLoc := StrReplace(webRequestLogLoc, "downloaded_files\webRequestLog.txt", "localSettings.json")
		}
		if (settingsFileLoc == "" || !FileExist(settingsFileLoc))
			return
		this.GameSettingsFileLocation := settingsFileLoc
		this.ReadOnly := IC_GameSettingsFix_Functions.IsReadOnly(settingsFileLoc)
		this.AddFileToGUIList(settingsFileLoc)
	}
	
	ReadAndEditSettingsString(g_GSF_settingsFileLoc)
	{
		local g_GSF_settingsFile
		this.MadeChanges := false
		FileRead, g_GSF_settingsFile, %g_GSF_settingsFileLoc%
		for k,v in this.Settings
		{
			g_GSF_before := g_GSF_settingsFile
			g_GSF_after := RegExReplace(g_GSF_before, """" k """: (false|true)", """" k """: " (v ? "true" : "false"))
			if (g_GSF_before != g_GSF_after) {
				g_GSF_settingsFile := g_GSF_after
				this.MadeChanges := true
				continue
			}
			g_GSF_after := RegExReplace(g_GSF_before, """" k """: ([0-9]+)", """" k """: " v)
			if (g_GSF_before != g_GSF_after) {
				g_GSF_settingsFile := g_GSF_after
				this.MadeChanges := true
			}
		}
		return g_GSF_settingsFile
	}
	
	WriteSettingsStringToFile(g_GSF_SettingsFile, g_GSF_settingsFileLoc)
	{
		g_GSF_newFile := FileOpen(g_GSF_settingsFileLoc, "w")
		if (!IsObject(g_GSF_newFile))
		{
			this.UpdateMainStatus("Error. Could not write to the settings file this time.")
			return
		}
		g_GSF_newFile.Write(g_GSF_settingsFile)
		g_GSF_newFile.Close()
		this.UpdateMainStatus("Game settings file had changes. Corrected.")
		this.FixedCounter++
		GuiControl, ICScriptHub:, g_GSF_NumTimesFixed, % this.FixedCounter
	}
	
	FixSettingsNow()
	{
		if (!IC_GameSettingsFix_Functions.IsGameClosed())
		{
			MsgBox, 48, Error, Cannot change settings while the game is running.
			return
		}
		this.ReadOnly := IC_GameSettingsFix_Functions.IsReadOnly(this.GameSettingsFileLocation)
		if (this.ReadOnly)
		{
			MsgBox, 48, Error, The game settings file is read-only. Cannot change it.
			return
		}
		this.FixGameSettings()
	}
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	UpdateMainStatus(status)
	{
		GuiControl, ICScriptHub:Text, g_GSF_StatusText, % status
		Gui, Submit, NoHide
	}
	
	AddFileToGUIList(settingsFileLoc)
	{
		local restore_gui_on_return := GUIFunctions.LV_Scope("ICScriptHub", "g_GSF_SettingsFileLocation")
		LV_Delete()
		LV_Add(,settingsFileLoc)
		LV_ModifyCol(1)
	}
	
	UpdateProfilesDDL(nameToSelect := "")
	{
		local ddlList := ""
		local foundName := false
		for k,v in IC_GameSettingsFix_Functions.ProfilesList(this.ProfilesPath)
		{
			local profileName := StrReplace(v, ".json", "")
			ddlList .= profileName "|"
			if (profileName == nameToSelect)
			{
				ddlList .= "|"
				foundName := true
			}
		}
		GuiControl, ICScriptHub:, g_GSF_Profiles, |
		GuiControl, ICScriptHub:, g_GSF_Profiles, % ddlList
		Gui, Submit, NoHide
	}
	
	; =======================
	; ===== TIMER STUFF =====
	; =======================
	
	; Adds timed functions (typically to be started when briv gem farm is started)
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer := ObjBindMethod(this, "UpdateGameSettingsFix")
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

	; Stops the saved timed functions (typically to be stopped when briv gem farm is stopped)
	StopTimedFunctions()
	{
		for k,v in this.TimerFunctions
		{
			SetTimer, %k%, Off
			SetTimer, %k%, Delete
		}
		this.UpdateMainStatus(this.WaitingMessage)
	}
	
}
Class IC_PotionSustain_Component
{
	static SettingsPath := A_LineFile . "\..\PotionSustain_Settings.json"
	Injected := false
	Settings := {}
	TimerFunctions := ""
	SanitySize := 5000
	
	DefaultSettings := {"SmallThreshMin":30,"SmallThreshMax":60,"AutomateThreshMin":15,"AutomateThreshMax":45,"Alternate":true,"DisableSmalls":false,"DisableMediums":false,"DisableLarges":false,"DisableHuges":false,"EnableISB":true,"ISBThreshMin":75,"ISBThreshMax":90,"EnableFSB":false,"FSBType":g_PS_Brackets[1]}
	UserData := ""
	RunsCount := -1
	ModronResetZone := -1
	PotIDs := {"s":74,"m":75,"l":76,"h":77,"gh":1723}
	PotAmounts := {"s":-1,"m":-1,"l":-1,"h":-1,"gh":0}
	PotZones := {"l":3060,"m":1185,"s":665}
	PotZonesGH := {"l":2305,"m":895,"s":480}
	ChestSmallPotMinThresh := this.DefaultSettings["SmallThreshMin"]
	ChestSmallPotMaxThresh := this.DefaultSettings["SmallThreshMax"]
	ChestSmallPotWaxing := false
	AutomatePotMinThresh := this.DefaultSettings["AutomateThreshMin"]
	AutomatePotMaxThresh := this.DefaultSettings["AutomateThreshMax"]
	ChestSmallPotBuying := false
	EnableAlternating := this.DefaultSettings["Alternate"]
	WaxingPots := {"s":false,"m":false,"l":false,"h":false}
	Using := "Using"
	NotEnough := "Not Enough"
	Blocked := "Blocked"
	ListSize := 0
	ModronCallParams := ""
	InstanceId := ""
	FoundHighAreaPot := false
	EnableISB := this.DefaultSettings["EnableISB"]
	ISBThreshMin := this.DefaultSettings["ISBThreshMin"]
	ISBThreshMax := this.DefaultSettings["ISBThreshMax"]
	ISBSanityGap := 30
	ISBWaxingPots := {"s":true,"m":true,"l":true,"h":true}
	EnableFSB := this.DefaultSettings["EnableFSB"]
	FSBType := this.DefaultSettings["FSBType"]
	DisableSmall := this.DefaultSettings["DisableSmalls"]
	DisableMedium := this.DefaultSettings["DisableMediums"]
	DisableLarge := this.DefaultSettings["DisableLarges"]
	DisableHuge := this.DefaultSettings["DisableHuges"]
	GemHunter := 0
	ModronSaveCallResponse := ""
	PendingCall := false
	OfflineDone := true
	BadMemoryRead := false
	
	; ======================
	; ===== TEST STUFF =====
	; ======================
	
	Test()
	{
	
	}

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================

	InjectAddon()
	{
		local splitStr := StrSplit(A_LineFile, "\")
		local addonDirLoc := splitStr[(splitStr.Count()-1)]
		local addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_PotionSustain_Addon.ahk`n"
		FileAppend, %addonLoc%, %g_BrivFarmModLoc%
	}
	
	; GUI startup
	Init()
	{
		Global
		Gui, Submit, NoHide
		this.LoadSettings()
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
		GuiControl, ICScriptHub:, g_PS_SmallPotCountStatus, Unknown
		this.CreateTimedFunctions()
		this.OverrideGemFarmBuyOpenCheckboxes()
		this.RunsCount := g_SF.Memory.ReadResetsCount()
		this.Start()
	}
	
	OverrideGemFarmBuyOpenCheckboxes()
	{
		GuiControl, ICScriptHub:Text, BuySilversCheck, Buy silver chests? (Overridden by Potion Sustain)
		GuiControl, ICScriptHub:Text, BuyGoldsCheck, Buy gold chests? (Overridden by Potion Sustain)
		GuiControl, ICScriptHub:Text, OpenSilversCheck, Open silver chests? (Overridden by Potion Sustain)
		GuiControl, ICScriptHub:Text, OpenGoldsCheck, Open gold chests? (Overridden by Potion Sustain)
		GuiControl, ICScriptHub:Move, BuySilversCheck,w400
		GuiControl, ICScriptHub:Move, BuyGoldsCheck,w400
		GuiControl, ICScriptHub:Move, OpenSilversCheck,w400
		GuiControl, ICScriptHub:Move, OpenGoldsCheck,w400
		GuiControl, ICScriptHub:Disable, BuySilversCheck
		GuiControl, ICScriptHub:Disable, BuyGoldsCheck
		GuiControl, ICScriptHub:Disable, OpenSilversCheck
		GuiControl, ICScriptHub:Disable, OpenGoldsCheck
	}
	
	; Loads settings from the addon's setting.json file.
	LoadSettings(psForceDefault := false)
	{
		Gui, Submit, NoHide
		psWriteSettings := false
		this.Settings := g_SF.LoadObjectFromJSON(this.SettingsPath)
		if(!IsObject(this.Settings) || psForceDefault)
		{
			this.SetDefaultSettings()
			psWriteSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			psWriteSettings := true
		if(psWriteSettings)
			g_SF.WriteObjectToJSON(this.SettingsPath, this.Settings)
		GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMin, % this.Settings["SmallThreshMin"]
		GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMax, % this.Settings["SmallThreshMax"]
		GuiControl, ICScriptHub:, g_PS_AutomateThreshMin, % this.Settings["AutomateThreshMin"]
		GuiControl, ICScriptHub:, g_PS_AutomateThreshMax, % this.Settings["AutomateThreshMax"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_EnableAlternating, % this.Settings["Alternate"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_DisableSmalls, % this.Settings["DisableSmalls"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_DisableMediums, % this.Settings["DisableMediums"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_DisableLarges, % this.Settings["DisableLarges"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_DisableHuges, % this.Settings["DisableHuges"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_IncreaseSustainBracket, % this.Settings["EnableISB"]
		GuiControl, ICScriptHub:, g_PS_IncreaseBracketThreshMin, % this.Settings["ISBThreshMin"]
		GuiControl, ICScriptHub:, g_PS_IncreaseBracketThreshMax, % this.Settings["ISBThreshMax"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_ForceSustainBracket, % this.Settings["EnableFSB"]
		GuiControl, ICScriptHub:ChooseString, g_PS_SpecificSustainBracket, % this.Settings["FSBType"]
		this.ChestSmallPotMinThresh := this.Settings["SmallThreshMin"]
		this.ChestSmallPotMaxThresh := this.Settings["SmallThreshMax"]
		this.AutomatePotMinThresh := this.Settings["AutomateThreshMin"]
		this.AutomatePotMaxThresh := this.Settings["AutomateThreshMax"]
		this.EnableAlternating := this.Settings["Alternate"]
		this.DisableSmall := this.Settings["DisableSmalls"]
		this.DisableMedium := this.Settings["DisableMediums"]
		this.DisableLarge := this.Settings["DisableLarges"]
		this.DisableHuge := this.Settings["DisableHuges"]
		this.EnableISB := this.Settings["EnableISB"]
		this.ISBThreshMin := this.Settings["ISBThreshMin"]
		this.ISBThreshMax := this.Settings["ISBThreshMax"]
		this.EnableFSB := this.Settings["EnableFSB"]
		this.FSBType := this.Settings["FSBType"]
		this.UpdateSharedSettings()
		this.UpdateGUI()
	}
	
	; Saves settings to addon's setting.json file.
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide
		this.ListSize := 0
		local sanityChecked := this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		this.Settings["SmallThreshMin"] := g_PS_ChestSmallThreshMin
		this.Settings["SmallThreshMax"] := g_PS_ChestSmallThreshMax
		this.Settings["AutomateThreshMin"] := g_PS_AutomateThreshMin
		this.Settings["AutomateThreshMax"] := g_PS_AutomateThreshMax
		this.Settings["Alternate"] := g_PS_Checkbox_EnableAlternating
		this.Settings["DisableSmalls"] := g_PS_Checkbox_DisableSmalls
		this.Settings["DisableMediums"] := g_PS_Checkbox_DisableMediums
		this.Settings["DisableLarges"] := g_PS_Checkbox_DisableLarges
		this.Settings["DisableHuges"] := g_PS_Checkbox_DisableHuges
		this.Settings["EnableISB"] := g_PS_Checkbox_IncreaseSustainBracket
		this.Settings["ISBThreshMin"] := g_PS_IncreaseBracketThreshMin
		this.Settings["ISBThreshMax"] := g_PS_IncreaseBracketThreshMax
		this.Settings["EnableFSB"] := g_PS_Checkbox_ForceSustainBracket
		this.Settings["FSBType"] := g_PS_SpecificSustainBracket
		this.ChestSmallPotMinThresh := g_PS_ChestSmallThreshMin
		this.ChestSmallPotMaxThresh := g_PS_ChestSmallThreshMax
		this.AutomatePotMinThresh := g_PS_AutomateThreshMin
		this.AutomatePotMaxThresh := g_PS_AutomateThreshMax
		this.EnableAlternating := g_PS_Checkbox_EnableAlternating
		this.DisableSmall := g_PS_Checkbox_DisableSmalls
		this.DisableMedium := g_PS_Checkbox_DisableMediums
		this.DisableLarge := g_PS_Checkbox_DisableLarges
		this.DisableHuge := g_PS_Checkbox_DisableHuges
		this.EnableISB := g_PS_Checkbox_IncreaseSustainBracket
		this.ISBThreshMin := g_PS_IncreaseBracketThreshMin
		this.ISBThreshMax := g_PS_IncreaseBracketThreshMax
		this.EnableFSB := g_PS_Checkbox_ForceSustainBracket
		this.FSBType := g_PS_SpecificSustainBracket
		if (!this.EnableAlternating)
		{
			this.ModronCallParams := ""
			try ; avoid thrown errors when comobject is not available.
			{
				SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
				if (SharedRunData.PSBGF_Running() != "") {
					SharedRunData.PSBGF_SetModronCallParams(this.ModronCallParams)
				}
			}
		}
		g_SF.WriteObjectToJSON(this.SettingsPath, this.Settings)
		this.UpdateSharedSettings()
		if (!sanityChecked)
			this.UpdateMainStatus("Saved settings.")
		this.UpdateGUI()
	}
	
	SaveDefaultSettings()
	{
		this.LoadSettings(true)
	}
	
	UpdateSharedSettings()
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			SharedRunData.PSBGF_UpdateSettingsFromFile()
			return true
		}
		return false
	}
	
	SanityCheckSettings()
	{
		local sanityGap := 15
		local sanityChecked := false
		if (!this.IsNumber(g_PS_ChestSmallThreshMin) OR g_PS_ChestSmallThreshMin < 1 OR !this.IsNumber(g_PS_ChestSmallThreshMax) OR g_PS_ChestSmallThreshMax < 1 OR !this.IsNumber(g_PS_AutomateThreshMin) OR g_PS_AutomateThreshMin < 1 OR !this.IsNumber(g_PS_AutomateThreshMax) OR g_PS_AutomateThreshMax < 1 OR !this.IsNumber(g_PS_IncreaseBracketThreshMin) OR g_PS_IncreaseBracketThreshMin < 1 OR !this.IsNumber(g_PS_IncreaseBracketThreshMax) OR g_PS_IncreaseBracketThreshMax < 1)
		{
			g_PS_ChestSmallThreshMin := this.DefaultSettings["SmallThreshMin"]
			g_PS_ChestSmallThreshMax := this.DefaultSettings["SmallThreshMax"]
			g_PS_AutomateThreshMin := this.DefaultSettings["AutomateThreshMin"]
			g_PS_AutomateThreshMax := this.DefaultSettings["AutomateThreshMax"]
			g_PS_IncreaseBracketThreshMin := this.DefaultSettings["ISBThreshMin"]
			g_PS_IncreaseBracketThreshMax := this.DefaultSettings["ISBThreshMax"]
			GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMin, % g_PS_ChestSmallThreshMin
			GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMax, % g_PS_ChestSmallThreshMax
			GuiControl, ICScriptHub:, g_PS_AutomateThreshMin, % g_PS_AutomateThreshMin
			GuiControl, ICScriptHub:, g_PS_AutomateThreshMax, % g_PS_AutomateThreshMax
			GuiControl, ICScriptHub:, g_PS_IncreaseBracketThreshMin, % g_PS_IncreaseBracketThreshMin
			GuiControl, ICScriptHub:, g_PS_IncreaseBracketThreshMax, % g_PS_IncreaseBracketThreshMax
			this.UpdateMainStatus("Save Error. Invalid input found in thresholds. Restored defaults.")
			sanityChecked := true
		}
		if (g_PS_ChestSmallThreshMax < g_PS_ChestSmallThreshMin+sanityGap)
		{
			g_PS_ChestSmallThreshMax := (g_PS_ChestSmallThreshMin + sanityGap)
			GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMax, % g_PS_ChestSmallThreshMax
			this.UpdateMainStatus("Save Error. Small maximum threshold too low vs minimum. Increased.")
			sanityChecked := true
		}
		if (g_PS_AutomateThreshMax < g_PS_AutomateThreshMin+sanityGap)
		{
			g_PS_AutomateThreshMax := (g_PS_AutomateThreshMin + sanityGap)
			GuiControl, ICScriptHub:, g_PS_AutomateThreshMax, % g_PS_AutomateThreshMax
			this.UpdateMainStatus("Save Error. Automation maximum threshold too low vs minimum. Increased.")
			sanityChecked := true
		}
		if (g_PS_ChestSmallThreshMin < g_PS_AutomateThreshMin+sanityGap)
		{
			g_PS_ChestSmallThreshMin := (g_PS_AutomateThreshMin + sanityGap)
			GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMin, % g_PS_ChestSmallThreshMin
			if (g_PS_ChestSmallThreshMax < (g_PS_ChestSmallThreshMin)+sanityGap)
			{
				g_PS_ChestSmallThreshMax := (g_PS_ChestSmallThreshMin + sanityGap)
				GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMax, % g_PS_ChestSmallThreshMax
			}
			this.UpdateMainStatus("Save Error. Small minimum threshold too low vs automation minimum. Increased.")
			sanityChecked := true
		}
		if (g_PS_Checkbox_EnableAlternating AND g_PS_Checkbox_DisableSmalls AND g_PS_Checkbox_DisableMediums AND g_PS_Checkbox_DisableLarges AND g_PS_Checkbox_DisableHuges)
		{
			g_PS_Checkbox_EnableAlternating := false
			GuiControl, ICScriptHub:, g_PS_Checkbox_EnableAlternating, % g_PS_Checkbox_EnableAlternating
			this.UpdateMainStatus("Save Error. All Potions Disabled. Disabling Automate Modron Potions.")
			sanityChecked := true
		}
		if (g_PS_IncreaseBracketThreshMin < (g_PS_AutomateThreshMax + this.ISBSanityGap))
		{
			g_PS_IncreaseBracketThreshMin := g_PS_AutomateThreshMax + this.ISBSanityGap
			GuiControl, ICScriptHub:, g_PS_IncreaseBracketThreshMin, % g_PS_IncreaseBracketThreshMin
			this.UpdateMainStatus("Save Error. ISB threshold too low vs automation maximum. Increased.")
			sanityChecked := true
		}
		if (g_PS_IncreaseBracketThreshMax < g_PS_IncreaseBracketThreshMin+sanityGap)
		{
			g_PS_IncreaseBracketThreshMax := (g_PS_IncreaseBracketThreshMin + sanityGap)
			GuiControl, ICScriptHub:, g_PS_IncreaseBracketThreshMax, % g_PS_IncreaseBracketThreshMax
			this.UpdateMainStatus("Save Error. ISB maximum threshold too low vs minimum. Increased.")
			sanityChecked := true
		}
		if (g_PS_Checkbox_IncreaseSustainBracket AND g_PS_Checkbox_ForceSustainBracket)
		{
			g_PS_Checkbox_IncreaseSustainBracket := false
			g_PS_Checkbox_ForceSustainBracket := false
			GuiControl, ICScriptHub:, g_PS_Checkbox_IncreaseSustainBracket, % g_PS_Checkbox_IncreaseSustainBracket
			GuiControl, ICScriptHub:, g_PS_Checkbox_ForceSustainBracket, % g_PS_Checkbox_ForceSustainBracket
			this.UpdateMainStatus("Save Error. Cannot enable ISB and FSB at the same time. Disabled both.")
			sanityChecked := true
		}
		if (g_PS_SpecificSustainBracket != g_PS_Brackets[1] AND g_PS_SpecificSustainBracket != g_PS_Brackets[2] AND g_PS_SpecificSustainBracket != g_PS_Brackets[3] AND g_PS_SpecificSustainBracket != g_PS_Brackets[4])
		{
			g_PS_SpecificSustainBracket := g_PS_Brackets[1]
			GuiControl, ICScriptHub:ChooseString, g_PS_SpecificSustainBracket, % g_PS_SpecificSustainBracket
			this.UpdateMainStatus("Save Error. Invalid Specific Sustain Bracket. Reset to default.")
			sanityChecked := true
		}
		if (g_PS_Checkbox_ForceSustainBracket AND ((g_PS_SpecificSustainBracket == g_PS_Brackets[2] AND g_PS_Checkbox_DisableSmalls) OR (g_PS_SpecificSustainBracket == g_PS_Brackets[3] AND g_PS_Checkbox_DisableMediums) OR (g_PS_SpecificSustainBracket == g_PS_Brackets[4] AND g_PS_Checkbox_DisableLarges)))
		{
			g_PS_Checkbox_ForceSustainBracket := false
			GuiControl, ICScriptHub:, g_PS_Checkbox_ForceSustainBracket, % g_PS_Checkbox_ForceSustainBracket
			this.UpdateMainStatus("Save Error. Specific Sustain Bracket is a disabled potion. Disabling FSB.")
			sanityChecked := true
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
	
	RepeatUpdateSharedSettings()
	{
		if (this.UpdateSharedSettings())
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

	; Updates status on a timer
	UpdateTick()
	{
		this.UpdateAutomationStatus("Idle.")
		psCurrRuns := g_SF.Memory.ReadResetsCount()
		if (psCurrRuns > 0 AND (this.PotAmounts["s"] < 0 OR (this.ListSize == 0 AND this.EnableAlternating) OR this.RunsCount != psCurrRuns))
		{
			this.UpdateAutomationStatus("Recalculating...")
			this.RunsCount := psCurrRuns
			this.GemHunter := this.ReadActiveGemHunter()
			this.UpdatePotAmounts()
			this.DetermineWaxingWaning()
			if (this.PotAmounts["s"] >= 0 AND this.PotAmounts["s"] <= this.ChestSmallPotMinThresh AND this.ChestSmallPotMinThresh >= 0)
				this.ChestSmallPotBuying := true
			else if (this.PotAmounts["s"] >= this.ChestSmallPotMaxThresh)
				this.ChestSmallPotBuying := false
			
			if (this.EnableAlternating)
				this.ModronCallParams := this.GetModronCallParamsFromMemory(this.CalculateAutomationBuffs())
			try ; avoid thrown errors when comobject is not available.
			{
				this.ModronResetZone := g_SF.Memory.GetModronResetArea()
				SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
				if (SharedRunData.PSBGF_Running() == "") ; Addon running check
				{
					this.UpdateAutomationStatus("Connection to gem farm script is broken. Restart script.")
					this.UpdateMainStatus("Connection to gem farm script is broken. Restart script.")
					GuiControl, ICScriptHub:Text, g_PS_AbleSustainSmallStatus, Unknown
					GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, Unknown
				}
				else if (SharedRunData.PSBGF_Running())
				{
					this.UpdateMainStatus("Running.")
					g_PS_Running := true
					psInstanceId := g_SF.Memory.ReadInstanceID()
					if (psInstanceId != this.InstanceId AND psInstanceId != "" AND psInstanceId > 0)
					{
						this.InstanceId := psInstanceId
						SharedRunData.PSBGF_SetInstanceId(psInstanceId)
					}
					if (this.ChestSmallPotBuying != SharedRunData.PSBGF_GetBuySilvers())
						SharedRunData.PSBGF_SetBuySilvers(this.ChestSmallPotBuying)
					this.ModronSaveCallResponse := SharedRunData.PSBGF_GetResponse()
				}
			}
			catch
			{
				this.UpdateAutomationStatus("Not Running.")
				this.UpdateMainStatus("Waiting for Gem Farm to start.")
				GuiControl, ICScriptHub:Text, g_PS_AbleSustainSmallStatus, Unknown
				GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, Unknown
			}
		}
		try {
			if (this.EnableAlternating)
			{
				SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
				if (SharedRunData.PSBGF_Running())
				{
					if (SharedRunData.PSBGF_GetModronCallParams() == "Sent")
					{
						this.ModronCallParams := ""
						SharedRunData.PSBGF_SetModronCallParams("")
					}
					if (SharedRunData.PSBGF_GetModronCallParams() != this.ModronCallParams)
						SharedRunData.PSBGF_SetModronCallParams(this.ModronCallParams)
					this.PendingCall := (SharedRunData.PSBGF_GetModronCallParams() != "")
				}
				else
				{
					this.UpdateAutomationStatus("Unable to communicate with Gem Farm script.")
				}
			}
			else
			{
				this.UpdateAutomationStatus("Disabled.")
			}
		}
		this.UpdateGUI()
	}
	
	UpdatePotAmounts()
	{
		size := g_SF.Memory.ReadInventoryItemsCount()
		if (size < 0 OR size > this.SanitySize)
			return
		loop, %size%
		{
			psBuffID := g_SF.Memory.ReadInventoryBuffIDBySlot(A_Index)
			psAmount := g_SF.Memory.ReadInventoryBuffCountBySlot(A_Index)
			for k,v in this.PotIDs
			{
				if (psBuffID==v)
					this.PotAmounts[k] := psAmount
			}
		}
		for k,v in this.PotAmounts
		{
			if (v == -1)
				this.PotAmounts[k] := 0
		}
	}
	
	DetermineWaxingWaning()
	{
		if (!this.EnableAlternating)
		{
			for k,v in this.PotAmounts
			{
				this.WaxingPots[k] := false
			}
			return
		}
		if (!this.EnableISB)
		{
			for k,v in this.PotAmounts
			{
				this.ISBWaxingPots[k] := false
			}
		}
		for k,v in this.PotAmounts
		{
			if (v <= this.AutomatePotMinThresh)
				this.WaxingPots[k] := true
			else if (v >= this.AutomatePotMaxThresh)
				this.WaxingPots[k] := false
			if (v <= this.ISBThreshMin)
				this.ISBWaxingPots[k] := true
			else if (v >= this.ISBThreshMax)
				this.ISBWaxingPots[k] := false
		}
	}
	
	CalculateAutomationBuffs()
	{
		local restore_gui_on_return := GUIFunctions.LV_Scope("ICScriptHub", "g_PS_AutomateList")
		LV_Delete()
		this.ListSize := 0
		; Bad modron read - flee.
		if (this.ModronResetZone < 1)
			return
		; Bad threshold read - flee.
		if (this.AutomatePotMinThresh < 0 OR this.AutomatePotMaxThresh < 0)
			return
		; Bad pot reads - flee.
		for k,v in this.PotAmounts
		{
			if (v < 0)
				return
		}
		; Sustaining mediums.
		; Only use if modron reset is 1175+ (or 885+GH) and medium pots are above the minimum threshold.
		local potPool := this.GemHunter > 0 ? this.PotZonesGH : this.PotZones
		psCalcAuto := {}
		if (this.EnableFSB)
		{
			if (this.FSBType == g_PS_Brackets[4])
				psCalcAuto := this.CalculateSustainLarges()
			else if (this.FSBType == g_PS_Brackets[3])
				psCalcAuto := this.CalculateSustainMediums()
			else if (this.FSBType == g_PS_Brackets[2])
				psCalcAuto := this.CalculateSustainSmalls()
			else
				psCalcAuto := this.CalculateSustainNone()
			this.UpdateSustainBracketHeader(1)
		}
		else
		{
			; Sustaining larges.
			; Only use if modron reset is 3025+ (or 2290+GH) and large pots are above the minimum threshold and large pots are not disabled.
			local psIncreased := false
			if (!this.DisableLarge AND this.EnableISB AND ((this.PotAmounts["l"] >= this.ISBThreshMin AND !this.ISBWaxingPots["l"]) OR (this.PotAmounts["l"] >= this.ISBThreshMax))) {
				psCalcAuto := this.CalculateSustainLarges()
				psIncreased := true
			}
			else if (!this.DisableLarge AND this.ModronResetZone >= potPool["l"] AND this.PotAmounts["l"] > this.AutomatePotMinThresh)
			{
				psCalcAuto := this.CalculateSustainLarges()
			}
			; Sustaining mediums.
			; Only use if modron reset is 1175+ (or 885+GH) and medium pots are above the minimum threshold and medium pots are not disabled.
			else if (!this.DisableMedium AND this.EnableISB AND ((this.PotAmounts["m"] >= this.ISBThreshMin AND !this.ISBWaxingPots["m"]) OR (this.PotAmounts["m"] >= this.ISBThreshMax)))
			{
				psCalcAuto := this.CalculateSustainMediums()
				psIncreased := true
			}
			else if (!this.DisableMedium AND this.ModronResetZone >= potPool["m"] AND this.PotAmounts["m"] > this.AutomatePotMinThresh)
			{
				psCalcAuto := this.CalculateSustainMediums()
			}
			; Sustaining smalls.
			; Only use if modron reset is 665+ (or 475+GH) and small pots are above the minimum threshold and small pots are not disabled.
			else if (!this.DisableSmall AND this.EnableISB AND ((this.PotAmounts["s"] >= this.ISBThreshMin AND !this.ISBWaxingPots["s"]) OR (this.PotAmounts["s"] >= this.ISBThreshMax)))
			{
				psCalcAuto := this.CalculateSustainSmalls()
				psIncreased := true
			}
			else if (!this.DisableSmall AND this.ModronResetZone >= potPool["s"] AND this.PotAmounts["s"] > this.AutomatePotMinThresh)
			{
				psCalcAuto := this.CalculateSustainSmalls()
			}
			; Sustaining nothing.
			; Only use as a last resort.
			else
				psCalcAuto := this.CalculateSustainNone()
			if (psIncreased)
				this.UpdateSustainBracketHeader(2)
			else
				this.UpdateSustainBracketHeader()
		}
		LV_ModifyCol(1, 45)
		LV_ModifyCol(2, 65)
		LV_ModifyCol(3, 75)
		Gui, Submit, NoHide
		return psCalcAuto
	}
	
	CalculateSustainLarges()
	{
		; Set can use larges.
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, % g_PS_Brackets[4] "."
		psCalcAuto := {this.PotIDs["l"]:1}
		psStatus := ["---","---","---","---"]
		if (!this.DisableMedium AND this.PotAmounts["m"] >= this.AutomatePotMinThresh AND !this.WaxingPots["m"])
		{
			psCalcAuto[this.PotIDs["m"]] := 1
			psStatus[1] := this.Using
		}
		else if (!this.DisableHuge AND this.PotAmounts["h"] >= this.AutomatePotMinThresh AND !this.WaxingPots["h"])
		{
			psCalcAuto[this.PotIDs["h"]] := 1
			psStatus[1] := this.DisableMedium ? this.Blocked : this.NotEnough
			psStatus[2] := this.Using
		}
		else if (!this.DisableSmall AND this.PotAmounts["s"] >= this.AutomatePotMinThresh AND !this.WaxingPots["s"])
		{
			psCalcAuto[this.PotIDs["s"]] := 1
			psStatus[1] := this.DisableMedium ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.Using
		}
		else
		{
			psStatus[1] := this.DisableMedium ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.DisableSmall ? this.Blocked : this.NotEnough
			psStatus[4] := this.Using
		}
		LV_Add(,1,"l + m",psStatus[1])
		LV_Add(,2,"l + h",psStatus[2])
		LV_Add(,3,"l + s",psStatus[3])
		LV_Add(,4,"l",psStatus[4])
		this.ListSize := 4
		return psCalcAuto
	}
	
	CalculateSustainMediums()
	{
		; Set can use mediums.
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, % g_PS_Brackets[3] "."
		psCalcAuto := {this.PotIDs["m"]:1}
		psStatus := ["---","---","---","---"]
		if (!this.DisableLarge AND this.PotAmounts["l"] >= this.AutomatePotMinThresh AND !this.WaxingPots["l"])
		{
			psCalcAuto[this.PotIDs["l"]] := 1
			psStatus[1] := this.Using
		}
		else if (!this.DisableHuge AND this.PotAmounts["h"] >= this.AutomatePotMinThresh AND !this.WaxingPots["h"])
		{
			psCalcAuto[this.PotIDs["h"]] := 1
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.Using
		}
		else if (!this.DisableSmall AND this.PotAmounts["s"] >= this.AutomatePotMinThresh AND !this.WaxingPots["s"])
		{
			psCalcAuto[this.PotIDs["s"]] := 1
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.Using
		}
		else
		{
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.DisableSmall ? this.Blocked : this.NotEnough
			psStatus[4] := this.Using
		}
		LV_Add(,1,"m + l",psStatus[1])
		LV_Add(,2,"m + h",psStatus[2])
		LV_Add(,3,"m + s",psStatus[3])
		LV_Add(,4,"m",psStatus[4])
		this.ListSize := 4
		return psCalcAuto
	}
	
	CalculateSustainSmalls()
	{
		; Set can use smalls.
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, % g_PS_Brackets[2] "."
		psCalcAuto := {this.PotIDs["s"]:1}
		psStatus := ["---","---","---","---"]
		if (!this.DisableLarge AND this.PotAmounts["l"] >= this.AutomatePotMinThresh AND !this.WaxingPots["l"])
		{
			psCalcAuto[this.PotIDs["l"]] := 1
			psStatus[1] := this.Using
		}
		else if (!this.DisableHuge AND this.PotAmounts["h"] >= this.AutomatePotMinThresh AND !this.WaxingPots["h"])
		{
			psCalcAuto[this.PotIDs["h"]] := 1
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.Using
		}
		else if (!this.DisableMedium AND this.PotAmounts["m"] >= this.AutomatePotMinThresh AND !this.WaxingPots["m"])
		{
			psCalcAuto[this.PotIDs["m"]] := 1
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.Using
		}
		else
		{
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.DisableMedium ? this.Blocked : this.NotEnough
			psStatus[4] := this.Using
		}
		LV_Add(,1,"s + l",psStatus[1])
		LV_Add(,2,"s + h",psStatus[2])
		LV_Add(,3,"s + m",psStatus[3])
		LV_Add(,4,"s",psStatus[4])
		this.ListSize := 4
		return psCalcAuto
	}
	
	CalculateSustainNone()
	{
		; Set can use smalls.
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, % g_PS_Brackets[1] "."
		psCalcAuto := {}
		psStatus := ["---","---","---","---"]
		if (!this.DisableLarge AND this.PotAmounts["l"] >= this.AutomatePotMinThresh AND !this.WaxingPots["l"])
		{
			psCalcAuto[this.PotIDs["l"]] := 1
			psStatus[1] := this.Using
		}
		else if (!this.DisableHuge AND this.PotAmounts["h"] >= this.AutomatePotMinThresh AND !this.WaxingPots["h"])
		{
			psCalcAuto[this.PotIDs["h"]] := 1
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.Using
		}
		else if (!this.DisableMedium AND this.PotAmounts["m"] >= this.AutomatePotMinThresh AND !this.WaxingPots["m"])
		{
			psCalcAuto[this.PotIDs["m"]] := 1
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.Using
		}
		else if (!this.DisableSmall)
		{
			psCalcAuto[this.PotIDs["s"]] := 1
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.DisableMedium ? this.Blocked : this.NotEnough
			psStatus[4] := this.Using
		}
		else
		{
			psStatus[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			psStatus[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			psStatus[3] := this.DisableMedium ? this.Blocked : this.NotEnough
			psStatus[4] := this.DisableSmall ? this.Blocked : this.NotEnough
		}
		LV_Add(,1,"l",psStatus[1])
		LV_Add(,2,"h",psStatus[2])
		LV_Add(,3,"m",psStatus[3])
		LV_Add(,4,"s",psStatus[4])
		this.ListSize := 4
		return psCalcAuto
	}
	
	CheckUserDataForGemHunter(buffs)
	{
		for k,v in buffs
		{
			if (v.buff_id == 1723)
				return v.remaining_time
		}
		return 0
	}
	
	GetModronCallParamsFromMemory(calcAutoIn)
	{
		local psModronSaveIndex := g_SF.Memory.GetCurrentModronSaveSlot()
		local psModronSaves := g_SF.Memory.GameManager.game.gameInstances[g_SF.Memory.GameInstance].Controller.userData.ModronHandler.modronSaves[psModronSaveIndex]
		
		local psModronId := psModronSaves.CoreID.Read()
		this.BadMemoryRead := (psModronId == "")
		if (this.BadMemoryRead)
			return ""
		local psCurrBuffs := this.ObjectifyDictionary(psModronSaves.Buffs.QuickClone(),,200)
		local psCalcAuto := this.AddNonSpeedPotsFromCurrBuffsToCalcAuto(psCurrBuffs,calcAutoIn)
		if (this.AreObjectsEqual(psCurrBuffs, psCalcAuto))
			return ""
		local psCalcAutoJson := this.JsonifyObject(psCalcAuto)
		local psFormsJson := this.JsonifyDictionary(psModronSaves.FormationSaves.QuickClone())
		
		if (psCalcAutoJson == "" OR psCalcAutoJson == "{}" OR psFormsJson == "" OR psFormsJson == "{}")
			return ""
			
		local psGameInstanceId := g_SF.Memory.ReadActiveGameInstance()
		
		local psParams := "&core_id=" . psModronId . "&grid=" . (g_SF.Memory.ReadModronGridArray(psModronSaves)) . "&game_instance_id=" . psGameInstanceId . "&formation_saves=" . psFormsJson . "&area_goal=" . (psModronSaves.targetArea.Read()) . "&buffs=" . psCalcAutoJson . "&checkin_timestamp=" . (this.GetNowEpoch() + 600000) . "&properties={""formation_enabled"":true,""toggle_preferences"":{""formation"":true,""reset"":true,""buff"":true}}" . "&user_id=" . (g_SF.Memory.ReadUserID()) . "&hash=" . (g_SF.Memory.ReadUserHash()) . "&language_id=1&timestamp=0&request_id=0&network_id=" . (g_SF.Memory.ReadPlatform()) . "&mobile_client_version=" . (g_SF.Memory.ReadBaseGameVersion()) . "&include_free_play_objectives=true&instance_key=1&offline_v2_build=1&localization_aware=true"
		return psParams
	}
	
	AddNonSpeedPotsFromCurrBuffsToCalcAuto(buffsObj,psCalcAuto)
	{
		this.FoundHighAreaPot := false
		if (!this.AreObjectsEqual(buffsObj, psCalcAuto))
		{
			for j,w in buffsObj
			{
				psHasPotID := this.HasValue(this.PotIDs,j)
				if (w > 1 AND psHasPotID AND !this.FoundHighAreaPot)
					this.FoundHighAreaPot := true
				if (!psHasPotID)
					psCalcAuto[j] := w
			}
		}
		return psCalcAuto
	}
	
	ReadActiveGemHunter()
	{
		local psBuffs := g_SF.Memory.GameManager.game.gameInstances[g_SF.Memory.GameInstance].BuffHandler.activeBuffs
		local psBuffsSize := psBuffs.size.Read()
		if(psBuffsSize <= 0 OR psBuffsSize > 1000)
			return 0
		loop, %psBuffsSize%
		{
			if (psBuffs[A_Index - 1].BaseEffectString.Read() == "increase_boss_gems_percent,50")
				return psBuffs[A_Index - 1].RemainingTime.Read()
		}
		return 0
	}
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	UpdateGUI()
	{
		local waxing := "Unavailable. Restocking."
		local waning := "Available."
		local abundant := "Abundant."
		local blocked := "Blocked by user."
		psSmallWaxStatus := this.DisableSmall ? blocked : (!this.ISBWaxingPots["s"] AND this.PotAmounts["s"] >= this.ISBThreshMin) OR (this.PotAmounts["s"] >= this.ISBThreshMax) ? abundant : this.WaxingPots["s"] ? waxing : waning
		psMediumWaxStatus := this.DisableMedium ? blocked : (!this.ISBWaxingPots["m"] AND this.PotAmounts["m"] >= this.ISBThreshMin) OR (this.PotAmounts["m"] >= this.ISBThreshMax) ? abundant : this.WaxingPots["m"] ? waxing : waning
		psLargeWaxStatus := this.DisableLarge ? blocked : (!this.ISBWaxingPots["l"] AND this.PotAmounts["l"] >= this.ISBThreshMin) OR (this.PotAmounts["l"] >= this.ISBThreshMax) ? abundant : this.WaxingPots["l"] ? waxing : waning
		psHugeWaxStatus := this.DisableHuge ? blocked : this.WaxingPots["h"] ? waxing : waning
		if (psSmallWaxStatus == waxing && psMediumWaxStatus == waxing && psLargeWaxStatus == waxing && psHugeWaxStatus == waxing)
			psSmallWaxStatus := "Forced available because nothing is available."
		GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, % this.PotAmounts["s"]
		GuiControl, ICScriptHub:Text, g_PS_MediumPotCountStatus, % this.PotAmounts["m"]
		GuiControl, ICScriptHub:Text, g_PS_LargePotCountStatus, % this.PotAmounts["l"]
		GuiControl, ICScriptHub:Text, g_PS_HugePotCountStatus, % this.PotAmounts["h"]
		GuiControl, ICScriptHub:Text, g_PS_GemHunterPotCountStatus, % this.PotAmounts["gh"]
		GuiControl, ICScriptHub:Text, g_PS_SmallPotWaxingStatus, % psSmallWaxStatus
		GuiControl, ICScriptHub:Text, g_PS_MediumPotWaxingStatus, % psMediumWaxStatus
		GuiControl, ICScriptHub:Text, g_PS_LargePotWaxingStatus, % psLargeWaxStatus
		GuiControl, ICScriptHub:Text, g_PS_HugePotWaxingStatus, % psHugeWaxStatus
		GuiControl, ICScriptHub:Text, g_PS_GemHunterStatus, % this.GemHunter > 0 ? "Active: " . (this.FmtSecs(this.GemHunter)) . " remaining." : "Inactive."
		GuiControl, ICScriptHub:Text, g_PS_BuyingSilversStatus, % this.ChestSmallPotBuying ? "Yes." : "No."
		Gui, Submit, NoHide
	}
	
	UpdateMainStatus(psStatus)
	{
		GuiControl, ICScriptHub:Text, g_PS_StatusText, % psStatus
		Gui, Submit, NoHide
	}
	
	UpdateAutomationStatus(psStatus)
	{
		if (!this.EnableAlternating)
		{
			psStatus := "Disabled."
			if (this.ListSize > 0)
			{
				restore_gui_on_return := GUIFunctions.LV_Scope("ICScriptHub", "g_PS_AutomateList")
				LV_Delete()
				this.ListSize := 0
			}
		}
		else if (psStatus == "Idle.")
		{
			if (this.ModronSaveCallResponse != "")
				psStatus := "Warning: Modron save call seems to have failed. Check logs."
			else if (this.BadMemoryRead)
				psStatus := "Warning: Bad memory read. Check imports / pointers."
			else if (this.PendingCall)
				psStatus := "Pending potion swapping. Waiting for next offline stack."
			else if (this.FoundHighAreaPot)
				psStatus := "Warning: A speed potion in the Modron has a zone greater than 1."
		}
		GuiControl, ICScriptHub:Text, g_PS_AutomationStatus, % psStatus
		Gui, Submit, NoHide
	}
	
	UpdateSustainBracketHeader(psForced := 0)
	{
		local psStatus := "Sustain Bracket"
		if (psForced == 1)
			psStatus .= " (Forced)"
		if (psForced == 2)
			psStatus .= " (Increased)"
		psStatus .= ":"
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketHeader, % psStatus
	}
	
	; =======================
	; ===== TIMER STUFF =====
	; =======================

	; Adds timed functions to be run when briv gem farm is started
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer := ObjBindMethod(this, "UpdateTick")
		this.TimerFunctions[fncToCallOnTimer] := 2000
		fncToCallOnTimer := ObjBindMethod(this, "RepeatUpdateSharedSettings")
		this.TimerFunctions[fncToCallOnTimer] := 1234
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(this, "Start"))
		g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(this, "Stop"))
	}

	Start()
	{
		this.UpdateTick()
		for k,v in this.TimerFunctions
			SetTimer, %k%, %v%, 0
		this.UpdateMainStatus("Running.")
	}

	Stop()
	{
		for k,v in this.TimerFunctions
		{
			SetTimer, %k%, Off
			SetTimer, %k%, Delete
		}
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
		GuiControl, ICScriptHub:Text, g_PS_AbleSustainSmallStatus, Unknown
		GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, Unknown
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, Unknown
		GuiControl, ICScriptHub:Text, g_PS_AutomationStatus, Unknown
		Gui, Submit, NoHide
	}
	
	; ======================
	; ===== MISC STUFF =====
	; ======================
	
	EncodeDecodeURI(str, encode := true, component := true) {
		static Doc, JS
		if !Doc {
			Doc := ComObjCreate("htmlfile")
			Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
			JS := Doc.parentWindow
			( Doc.documentMode < 9 && JS.execScript() )
		}
		ret := JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
		StringLower, ret, ret
		return ret
	}
	
	AreObjectsEqual(obj1 := "", obj2 := "")
	{
		if (obj1.Count() != obj2.Count())
			return false
		if (!IsObject(obj1))
			return !IsObject(obj2) AND (obj1 == obj2)
		for k,v in obj1
		{
			if (IsObject(v) AND !this.AreObjectsEqual(obj2[k], v))
				return false
			else if (!IsObject(v) AND obj2[k] != v)
				return false
			if (VarSetCapacity(k) != 0)
			{
				if (!obj2.HasKey(""k))
					return false
			}
			else
			{
				if (!obj2.HasKey(k))
					return false
			}
		}
		return true
	}
	
	ObjFullyClone(obj)
	{
		local nobj := obj.Clone()
		for k,v in nobj
			if IsObject(v)
				nobj[k] := A_ThisFunc.(v)
		return nobj
	}
	
	HasValue(obj,val)
	{
		for k,v in obj
			if (v == val)
				return true
		return false
	}
	
	JsonifyObject(obj)
	{
		if (!IsObject(obj))
			return obj
		psJsonObj := "{"
		psFirst := true
		for k,v in obj
		{
			if (psFirst)
				psFirst := false
			else
				psJsonObj .= ","
			if (IsObject(v))
				psJsonObj .= """" k """:" (this.JsonifyObject(v))
			else
				psJsonObj .= """" k """:" v
		}
		psJsonObj .= "}"
		return psJsonObj
	}
	
	JsonifyArray(arr)
	{
		if (!IsObject(arr))
			return arr
		psSize := arr.MaxIndex()
		psJsonArr := "["
		loop, %psSize%
		{
			if (A_Index > 1)
				psJsonArr .= ","
			if (IsObject(arr[A_Index]))
				psJsonArr .= (this.JsonifyArray(arr[A_Index]))
			else
				psJsonArr .= arr[A_Index]
		}
		psJsonArr .= "]"
		return psJsonArr
	}
	
	JsonifyDictionary(dict, sanityMin := 0, sanityMax := 50000)
	{
		local dictSize := dict.size.Read()
		if (dictSize < sanityMin OR dictSize > sanityMax)
			return ""
		local jsonDict := "{"
		loop, %dictSize%
		{
			if (A_Index > 1)
				jsonDict .= ","
			key := dict["key", A_Index - 1, true].Read()
			jsonDict .= """" key """:"
			if (dict[key].size.Read() > 0)
				jsonDict .= this.JsonifyDictionary(dict[key])
			else
				jsonDict .= dict[key].Read()
		}
		jsonDict .= "}"
		return jsonDict
	}
	
	ObjectifyDictionary(dict, sanityMin := 0, sanityMax := 50000)
	{
		local dictSize := dict.size.Read()
		if (dictSize < sanityMin OR dictSize > sanityMax)
			return ""
		local obj := {}
		loop, %dictSize%
		{
			key := dict["key", A_Index - 1, true].Read()
			if (dict[key].size.Read() > 0)
				obj[key] := this.ObjectifyDictionary(dict[key])
			else
				obj[key] := dict[key].Read()
		}
		return obj
	}
	
	GetNowEpoch()
	{
		local nowUTC := A_NowUTC
		nowUTC -= 19700101000000, S
		return nowUTC
	}
	
	FmtSecs(T, Fmt:="{:}d {:02}h {:02}m {:02}s") { ; v0.50 by SKAN on D36G/H @ tiny.cc/fmtsecs
		local D, H, M, HH, Q:=60, R:=3600, S:=86400
		T := Round(T)
		fmtTime := Format(Fmt, D:=T//S, H:=(T:=T-D*S)//R, M:=(T:=T-H*R)//Q, T-M*Q, HH:=D*24+H, HH*Q+M)
		fmtTime := RegExReplace(fmtTime, "m)^0d ", "")
		fmtTime := RegExReplace(fmtTime, "m)^00h ", "")
		fmtTime := RegExReplace(fmtTime, "m)^00m ", "")
		fmtTime := Trim(fmtTime)
		return fmtTime
	}
	
	IsNumber(inputText)
	{
		if inputText is number
			return true
		return false
	}
	
}
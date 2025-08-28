#include %A_LineFile%\..\IC_ClaimDailyPlatinum_Functions.ahk
#include %A_LineFile%\..\IC_ClaimDailyPlatinum_GUI.ahk

global g_ClaimDailyPlatinum := new IC_ClaimDailyPlatinum_Component

if(IsObject(IC_BrivGemFarm_Component))
{
	IC_ClaimDailyPlatinum_Functions.InjectAddon()
	global g_ClaimDailyPlatinum := new IC_ClaimDailyPlatinum_Component
	global g_ClaimDailyPlatinumGUI := new IC_ClaimDailyPlatinum_GUI
	g_ClaimDailyPlatinumGUI.Init()
	g_ClaimDailyPlatinum.Init()
}
else
{
	GuiControl, ICScriptHub:Text, CDP_StatusText, WARNING: This addon needs IC_BrivGemFarm enabled.
	return
}

Class IC_ClaimDailyPlatinum_Component
{
	
	TimerFunctions := {}
	DefaultSettings := {"Platinum":true,"Trials":true,"FreeOffer":true,"GuideQuests":true,"BonusChests":true,"Celebrations":true}
	Settings := {}
	; The timer for MainLoop:
	MainLoopCD := 60000 ; in milliseconds = 1 minute.
	; The starting cooldown for each type:
	StartingCD := 60000 ; in milliseconds = 1 minute.
	; The delay between when the server says a timer resets and when to check (for safety):
	SafetyDelay := 30000 ; in milliseconds = 30 seconds.
	; No Timer Delay (for when I can't find a timer in the data)
	NoTimerDelay := 28800000 ; in milliseconds = 8 hours.
	NoTimerDelayRNG := 1800000 ; in milliseconds = 30 minutes.
	; The current cooldown for each type:
	CurrentCD := {"Platinum":0,"Trials":0,"FreeOffer":0,"GuideQuests":0,"BonusChests":0,"Celebrations":0}
	; The amount of times each type has been claimed:
	Claimed := {"Platinum":0,"Trials":0,"FreeOffer":0,"GuideQuests":0,"BonusChests":0,"Celebrations":0}
	; The flags to tell the timers to pause if the script is waiting for the game to go offline.
	Claimable := {"Platinum":false,"Trials":false,"FreeOffer":false,"GuideQuests":false,"BonusChests":false,"Celebrations":false}
	; The names of each type
	Names := {"Platinum":"Daily Platinum","Trials":"Trials Rewards","FreeOffer":"Weekly Offers","GuideQuests":"Guide Quests","BonusChests":"Premium Bonus Chests","Celebrations":"Celebration Rewards"}
	FreeOfferIDs := []
	BonusChestIDs := []
	CelebrationCodes := []
	DailyBoostExpires := -1
	TrialsCampaignID := 0
	TrialsPresetStatuses := [["Trials Status","Tiamat Dies in","Trial Joinable in"],["Unknown","Tiamat is Dead","Inactive","Sitting in Lobby",""]]
	TrialsStatus := [1,5]
	TiamatHP := [40,75,130,200,290,430,610,860,1200,1600]
	StaggeredChecks := {"Platinum":1,"Trials":2,"FreeOffer":3,"GuideQuests":4,"BonusChests":5,"Celebrations":6}
	
	MemoryReadCheckInstanceIDs := {"Platinum":"","Trials":"","FreeOffer":"","GuideQuests":"","BonusChests":"","Celebrations":""}
	InstanceID := ""
	
	DisplayStatusTimeout := 0
	MessageStickyTimer := 8000
	
	; =======================================
	; ===== Initialisation and Settings =====
	; =======================================

	Init()
	{
		this.LoadSettings()
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "CreateTimedFunctions"))
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "StartTimedFunctions"))
		g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "StopTimedFunctions"))
	}
	
	LoadSettings()
	{
		Global
		Gui, Submit, NoHide
		writeSettings := false
		this.Settings := g_SF.LoadObjectFromJSON(IC_ClaimDailyPlatinum_Functions.SettingsPath)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(IC_ClaimDailyPlatinum_Functions.SettingsPath, this.Settings)
		GuiControl, ICScriptHub:, CDP_ClaimPlatinum, % this.Settings["Platinum"]
		GuiControl, ICScriptHub:, CDP_ClaimTrials, % this.Settings["Trials"]
		GuiControl, ICScriptHub:, CDP_ClaimFreeOffer, % this.Settings["FreeOffer"]
		GuiControl, ICScriptHub:, CDP_ClaimGuideQuests, % this.Settings["GuideQuests"]
		GuiControl, ICScriptHub:, CDP_ClaimBonusChests, % this.Settings["BonusChests"]
		GuiControl, ICScriptHub:, CDP_ClaimCelebrations, % this.Settings["Celebrations"]
		for k,v in this.Settings
			if (!v)
				this.CurrentCD[k] := -1
		IC_ClaimDailyPlatinum_Functions.UpdateSharedSettings()
		this.UpdateGUI()
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide
		;local sanityChecked := this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		
		GuiControlGet,CDP_ClaimPlatinum, ICScriptHub:, CDP_ClaimPlatinum
		GuiControlGet,CDP_ClaimTrials, ICScriptHub:, CDP_ClaimTrials
		GuiControlGet,CDP_ClaimFreeOffer, ICScriptHub:, CDP_ClaimFreeOffer
		GuiControlGet,CDP_ClaimGuideQuests, ICScriptHub:, CDP_ClaimGuideQuests
		GuiControlGet,CDP_ClaimBonusChests, ICScriptHub:, CDP_ClaimBonusChests
		GuiControlGet,CDP_ClaimCelebrations, ICScriptHub:, CDP_ClaimCelebrations
		this.Settings["Platinum"] := CDP_ClaimPlatinum
		this.Settings["Trials"] := CDP_ClaimTrials
		this.Settings["FreeOffer"] := CDP_ClaimFreeOffer
		this.Settings["GuideQuests"] := CDP_ClaimGuideQuests
		this.Settings["BonusChests"] := CDP_ClaimBonusChests
		this.Settings["Celebrations"] := CDP_ClaimCelebrations
		
		g_SF.WriteObjectToJSON(IC_ClaimDailyPlatinum_Functions.SettingsPath, this.Settings)
		IC_ClaimDailyPlatinum_Functions.UpdateSharedSettings()
		CDP_LoopCounter := 1
		for k,v in this.Settings
		{
			if (v && this.CurrentCD[k] <= A_TickCount)
			{
				this.CurrentCD[k] := A_TickCount + (this.MainLoopCD*CDP_LoopCounter)
				CDP_LoopCounter += 1
			}
			if (!v)
				this.CurrentCD[k] := -1
		}
		this.UpdateMainStatus("Saved settings.")
		this.UpdateGUI()
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
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	; This loop gets called once per MainLoopCD.
	MainLoop()
	{
		if (!IC_ClaimDailyPlatinum_Functions.IsGameClosed())
		{
			this.InstanceID := g_SF.Memory.ReadInstanceID()
			
			for k,v in this.CurrentCD
			{
				if (!this.Settings[k])
					continue
				; If it's not claimable - check if it can be claimed via memory reads.
				; - Prevent re-checking memory reads if it's been claimed during the current instance.
				; - Because claiming via calls doesn't update the memory read.
				if (!this.Claimable[k] && this.MemoryReadCheckInstanceIDs[CDP_key] != this.InstanceID)
					this.CallMemoryReadCheckClaimable(k)
				if (this.CurrentCD[k] <= A_TickCount)
				{
					; If it's not claimable - check if it can be claimed.
					if (!this.Claimable[k])
					{
						this.UpdateMainStatus("Checking " . this.Names[k] . ".")
						this.CallCheckClaimable(k)
						this.UpdateMainStatus("Checked " . this.Names[k] . ".")
					}
					; If it now is claimable - claim it.
					if (this.Claimable[k])
					{
						this.UpdateMainStatus("Claiming " . this.Names[k] . ".")
						this.Claim(k)
						this.CurrentCD[k] := A_TickCount + this.SafetyDelay
						this.Claimable[k] := false
					}
				}
			}
		}
		this.UpdateGUI()
	}
	
	CallCheckClaimable(CDP_key)
	{
		CDP_CheckedClaimable := this.CheckClaimable(CDP_key) ; Check if it is claimable (and when if not)
		this.Claimable[CDP_key] := CDP_CheckedClaimable[1] ; Claimable
		this.CurrentCD[CDP_key] := CDP_CheckedClaimable[2] ; Claimable Cooldown
	}
	
	CheckClaimable(CDP_key)
	{
        g_SF.ResetServerCall()
		if (CDP_key == "Platinum")
		{
			response := IC_ClaimDailyPlatinum_Functions.ServerCall("getdailyloginrewards", "")
			if (IsObject(response) && response.success)
			{
				CDP_num := 1 << (response.daily_login_details.today_index)
				if (response.daily_login_details.premium_active && response.daily_login_details.premium_expire_seconds > 0)
					this.DailyBoostExpires := A_TickCount + (response.daily_login_details.premium_expire_seconds * 1000)
				else
					this.DailyBoostExpires := 0
				if ((response.daily_login_details.rewards_claimed & CDP_num) > 0)
				{
					CDP_nextClaimSeconds := response.daily_login_details.next_claim_seconds
					if (CDP_nextClaimSeconds == 0)
						CDP_nextClaimSeconds := Mod(response.daily_login_details.next_reset_seconds, 86400)
					return [false, A_TickCount + (CDP_nextClaimSeconds * 1000) + this.SafetyDelay]
				}
				return [true, 0]
			}
		}
		else if (CDP_key == "Trials")
		{
			this.TrialsCampaignID := 0
			response := IC_ClaimDailyPlatinum_Functions.ServerCall("trialsrefreshdata", "")
			if (IsObject(response) && response.success)
			{
				CDP_trialsData := response.trials_data
				if (CDP_trialsData.pending_unclaimed_campaign != "")
				{
					this.TrialsCampaignID := CDP_trialsData.pending_unclaimed_campaign
					this.TrialsStatus := [1,2]
					return [true, 0]
				}
				CDP_trialsCampaigns := CDP_trialsData.campaigns
				CDP_trialsCampaignsSize := this.ArrSize(CDP_trialsCampaigns)
				if (CDP_trialsCampaigns != "" && CDP_trialsCampaignsSize > 0 && CDP_trialsCampaigns[1].started)
				{
					CDP_trialsCampaign := CDP_trialsCampaigns[1]
					CDP_currDPS := 0
					CDP_totalDamage := 0
					for k,v in CDP_trialsCampaign.players
					{
						CDP_currDPS += v.dps
						CDP_totalDamage += v.total_damage
					}
					CDP_tiamatHP := (this.TiamatHP[CDP_trialsCampaign.difficulty_id] * 10000000) - CDP_totalDamage
					CDP_timeTilTiamatDies := ((CDP_tiamatHP == "" || CDP_currDPS == "" || CDP_currDPS <= 0) ? 99999999 : (CDP_tiamatHP / CDP_currDPS))
					CDP_trialEndsIn := CDP_trialsCampaign.ends_in
					CDP_timeToCheck := Min(CDP_timeTilTiamatDies,CDP_trialEndsIn) * 500
					CDP_timeToCheck := Min(this.CalcNoTimerDelay(),CDP_timeToCheck)
					CDP_timeToCheck := Max(this.MainLoopCD,CDP_timeToCheck)
					this.TrialsStatus := [2,A_TickCount + CDP_timeTilTiamatDies * 1000]
					return [false, A_TickCount + CDP_timeToCheck]
				}
				if (CDP_trialsCampaigns != "" && CDP_trialsCampaignsSize > 0 && !CDP_trialsCampaigns[1].started)
				{
					this.TrialsStatus := [1,4]
					return [false, A_TickCount + this.CalcNoTimerDelay()]
				}
				if (CDP_trialsData.seconds_until_can_join_campaign != "")
				{
					CDP_timeTilNextTrial := A_TickCount + CDP_trialsData.seconds_until_can_join_campaign * 1000
					this.TrialsStatus := [3,CDP_timeTilNextTrial]
					return [false, A_TickCount + this.CalcNoTimerDelay()]
				}
			}
			this.TrialsStatus := [1,3]
			return [false, A_TickCount + this.CalcNoTimerDelay()]
		}
		else if (CDP_key == "FreeOffer")
		{
			this.FreeOfferIDs := []
			IC_ClaimDailyPlatinum_Functions.ServerCall("revealalacarteoffers", "")
			response := IC_ClaimDailyPlatinum_Functions.ServerCall("getalacarteoffers", "")
			if (IsObject(response) && response.success)
			{
				for k,v in response.offers.offers
				{
					if (v.type != "free" || v.cost > 0)
						continue
					if (!v.purchased)
						this.FreeOfferIDs.Push(v.offer_id)
				}
				if (this.ArrSize(this.FreeOfferIDs) > 0)
					return [true, 0]
				return [false, A_TickCount + (response.offers.time_remaining * 1000) + this.SafetyDelay]
			}
		}
		else if (CDP_key == "GuideQuests")
		{
			response := IC_ClaimDailyPlatinum_Functions.ServerCall("getcompletiondata", "")
			if (IsObject(response) && response.success)
			{
				for k,v in response.data.guidequest
				{
					if (v.complete == 1 && v.rewards_claimed == 0)
						return [true, 0]
				}
			}
			return [false, A_TickCount + this.CalcNoTimerDelay()]
		}
		else if (CDP_key == "BonusChests")
		{
			this.BonusChestIDs := []
			params := "&return_all_items_live=1&return_all_items_ever=0&show_hard_currency=1&prioritize_item_category=recommend"
			response := IC_ClaimDailyPlatinum_Functions.ServerCall("getshop", params)
			if (IsObject(response) && response.success)
			{
				for k,v in response.package_deals
					if (v.bonus_status == "0" && this.ArrSize(v.bonus_item) > 0)
						this.BonusChestIDs.Push(v.item_id)
				if (this.ArrSize(this.BonusChestIDs) > 0)
					return [true, 0]
			}
			return [false, A_TickCount + this.CalcNoTimerDelay()]
		}
		else if (CDP_key == "Celebrations")
		{
			this.CelebrationCodes := []
			wrlLoc := g_SF.Memory.GetWebRequestLogLocation()
			if (wrlLoc == "")
				return [false, A_TickCount + this.CalcNoTimerDelay()]
			webRequestLog := ""
			FileRead, webRequestLog, %wrlLoc%
			CDP_nextClaimSeconds := 9999999
			if (InStr(webRequestLog, """dialog"":"))
			{
				currMatches := IC_ClaimDailyPlatinum_Functions.GetAllRegexMatches(webRequestLog, """dialog"": ?""([^""]+)""")
				for k,v in currMatches
				{
					params := "&dialog=" . v . "&ui_type=standard"
					response := IC_ClaimDailyPlatinum_Functions.ServerCall("getdynamicdialog", params)
					if (IsObject(response) && response.success)
					{
						for l,b in response.dialog_data.elements
						{
							if (b.timer != "" && b.timer < CDP_nextClaimSeconds)
								CDP_nextClaimSeconds := b.timer
							if (b.type == "button" && InStr(b.text, "claim"))
								for j,c in b.actions
									if (c.action == "redeem_code")
										this.CelebrationCodes.Push(c.params.code)
						}
					}
				}
			}
			webRequestLog := ""
			if (this.ArrSize(this.CelebrationCodes) > 0)
				return [true, 0]
			if (CDP_nextClaimSeconds < 9999999)
				return [false, A_TickCount + (CDP_nextClaimSeconds * 1000) + this.SafetyDelay]
			else
				return [false, A_TickCount + this.CalcNoTimerDelay()]
		}
		return [false, A_TickCount + this.StartingCD]
	}
	
	CallMemoryReadCheckClaimable(CDP_key)
	{
		CDP_CheckedClaimable := this.MemoryReadCheckClaimable(CDP_key) ; Check if it is claimable by memory reading.
		if (CDP_CheckedClaimable == "")
			return
		this.Claimable[CDP_key] := CDP_CheckedClaimable[1] ; Claimable
		this.CurrentCD[CDP_key] := CDP_CheckedClaimable[2] ; Claimable Cooldown
	}
	
	MemoryReadCheckClaimable(CDP_key)
	{
		if (CDP_key == "GuideQuests")
		{
			numUnclaimedGuideQuests := g_SF.Memory.GameManager.game.gameInstances[g_SF.Memory.GameInstance].Screen.uiController.topBar.dpsMenuBox.menuBox.numberOfUnclaimedQuests.Read()
			if (numUnclaimedGuideQuests > 0)
				return [true, 0]
		}
		return ""
	}
	
	Claim(CDP_key)
	{
        g_SF.ResetServerCall()
		if (CDP_key == "Platinum")
		{
			params := "&is_boost=0"
			response := IC_ClaimDailyPlatinum_Functions.ServerCall("claimdailyloginreward", params)
			if (IsObject(response) && response.success)
			{
				if (response.daily_login_details.premium_active)
				{
					params := "&is_boost=1"
					response := IC_ClaimDailyPlatinum_Functions.ServerCall("claimdailyloginreward", params)
				}
				this.Claimed[CDP_key] += 1
			}
		}
		else if (CDP_key == "Trials")
		{
			params := "&campaign_id=" . (this.TrialsCampaignID)
			response := IC_ClaimDailyPlatinum_Functions.ServerCall("trialsclaimrewards", params)
			this.TrialsCampaignID := 0
			if (!IsObject(response) || !response.success)
			{
				; server call failed
				this.TrialsStatus := [1,1]
				return
			}
			this.Claimed[CDP_key] += 1
			this.TrialsStatus := [1,3]
		}
		else if (CDP_key == "FreeOffer")
		{
			for k,v in this.FreeOfferIDs
			{
				params := "&offer_id=" . v
				response := IC_ClaimDailyPlatinum_Functions.ServerCall("PurchaseALaCarteOffer", params)
				if (!IsObject(response) || !response.success)
				{
					; server call failed
					this.FreeOfferIDs := []
					return
				}
			}
			this.Claimed[CDP_key] += this.ArrSize(this.FreeOfferIDs)
			this.FreeOfferIDs := []
		}
		else if (CDP_key == "GuideQuests")
		{
			params := "&collection_quest_id=-1"
			response := IC_ClaimDailyPlatinum_Functions.ServerCall("claimcollectionquestrewards", params)
			if (IsObject(response) && response.success && response.awarded_items.success)
			{
				CDP_numGuideQuestsClaimed := this.ArrSize(response.awarded_items.rewards_claimed_quest_ids)
				if (CDP_numGuideQuestsClaimed > 0)
					this.Claimed[CDP_key] += CDP_numGuideQuestsClaimed
			}
		}
		else if (CDP_key == "BonusChests")
		{
			for k,v in this.BonusChestIDs
			{
				params := "&premium_item_id=" . v
				response := IC_ClaimDailyPlatinum_Functions.ServerCall("claimsalebonus", params)
				if (!IsObject(response) || !response.success)
				{
					; server call failed
					this.BonusChestIDs := []
					return
				}
			}
			this.Claimed[CDP_key] += this.ArrSize(this.BonusChestIDs)
			this.BonusChestIDs := []
		}
		else if (CDP_key == "Celebrations")
		{
			for k,v in this.CelebrationCodes
			{
				params := "&code=" . v
				response := IC_ClaimDailyPlatinum_Functions.ServerCall("redeemcoupon", params)
				if (!IsObject(response) || !response.success)
				{
					; server call failed
					this.CelebrationCodes := []
					return
				}
			}
			this.Claimed[CDP_key] += this.ArrSize(this.CelebrationCodes)
			this.CelebrationCodes := []
		}
		this.MemoryReadCheckInstanceIDs[CDP_key] := this.InstanceID
		this.UpdateMainStatus("Claimed " . this.Names[CDP_key] . ".")
	}
	
	; =======================
	; ===== TIMER STUFF =====
	; =======================
	
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer := ObjBindMethod(this, "MainLoop")
		this.TimerFunctions[fncToCallOnTimer] := this.MainLoopCD
		fncToCallOnTimer := ObjBindMethod(this, "UpdateMainStatus")
		this.TimerFunctions[fncToCallOnTimer] := 1000
	}

	StartTimedFunctions()
	{
		this.Running := true
		this.UpdateMainStatus("Started.")
		for k,v in this.TimerFunctions
			SetTimer, %k%, %v%, 0
		for k,v in this.CurrentCD
			this.CurrentCD[k] := A_TickCount + (this.StartingCD * this.StaggeredChecks[k])
		this.UpdateGUI()
	}

	StopTimedFunctions()
	{
		this.Running := false
		this.UpdateMainStatus(IC_ClaimDailyPlatinum_GUI.WaitingMessage)
		for k,v in this.TimerFunctions
		{
			SetTimer, %k%, Off
			SetTimer, %k%, Delete
		}
		for k,v in this.CurrentCD
		{
			this.CurrentCD[k] := 0
			this.Claimable[k] := false
		}
		this.UpdateGUI(true)
	}
	
	CalcNoTimerDelay()
	{
		return this.NoTimerDelay + this.RandInt(-this.NoTimerDelayRNG, this.NoTimerDelayRNG)
	}
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	UpdateMainStatus(status := "")
	{
		if (status == "")
		{
			CDP_TimerIsUp := A_TickCount - this.DisplayStatusTimeout >= this.MessageStickyTimer
			if (CDP_TimerIsUp)
				status := ""
			else
			{
				GuiControlGet,CDP_StatusText, ICScriptHub:, CDP_StatusText
				status := CDP_StatusText
			}
		}
		else
			this.DisplayStatusTimeout := A_TickCount
		if (status == "")
			status := "Idle."
		GuiControl, ICScriptHub:Text, CDP_StatusText, % status
		Gui, Submit, NoHide
	}
	
	UpdateGUI(CDP_clearStatuses := false)
	{
		if (CDP_clearStatuses || !this.Settings["Platinum"])
			this.DailyBoostExpires := -1
		if (CDP_clearStatuses || !this.Settings["Trials"])
			this.TrialsStatus := [1,5]
			
		if (this.TrialsStatus[1] == 3 && this.TrialsStatus[2] < A_TickCount)
			this.TrialsStatus := [1,3]
	
		GuiControl, ICScriptHub:, CDP_PlatinumTimer, % this.ProduceGUITimerMessage("Platinum")
		GuiControl, ICScriptHub:, CDP_TrialsTimer, % this.ProduceGUITimerMessage("Trials")
		GuiControl, ICScriptHub:, CDP_FreeOfferTimer, % this.ProduceGUITimerMessage("FreeOffer")
		GuiControl, ICScriptHub:, CDP_GuideQuestsTimer, % this.ProduceGUITimerMessage("GuideQuests")
		GuiControl, ICScriptHub:, CDP_BonusChestsTimer, % this.ProduceGUITimerMessage("BonusChests")
		GuiControl, ICScriptHub:, CDP_CelebrationsTimer, % this.ProduceGUITimerMessage("Celebrations")
		GuiControl, ICScriptHub:, CDP_PlatinumDaysCount, % this.ProduceGUIClaimedMessage("Platinum")
		GuiControl, ICScriptHub:, CDP_TrialsRewardsCount, % this.ProduceGUIClaimedMessage("Trials")
		GuiControl, ICScriptHub:, CDP_FreeOffersCount, % this.ProduceGUIClaimedMessage("FreeOffer")
		GuiControl, ICScriptHub:, CDP_GuideQuestsCount, % this.ProduceGUIClaimedMessage("GuideQuests")
		GuiControl, ICScriptHub:, CDP_BonusChestsCount, % this.ProduceGUIClaimedMessage("BonusChests")
		GuiControl, ICScriptHub:, CDP_CelebrationRewardsCount, % this.ProduceGUIClaimedMessage("Celebrations")
		
		GuiControl, ICScriptHub:, CDP_TrialsStatusHeader, % (this.TrialsPresetStatuses[1][this.TrialsStatus[1]]) . ":"
		GuiControl, ICScriptHub:, CDP_TrialsStatus, % (this.TrialsStatus[1] == 1 ? this.TrialsPresetStatuses[2][this.TrialsStatus[2]] : (this.FmtSecs(this.CeilMillisecondsToNearestMainLoopCDSeconds(this.TrialsStatus[2])) . (this.TrialsStatus[1] == 2 ? " (est)" : "")))
		GuiControl, ICScriptHub:, CDP_DailyBoostHeader, % "Daily Boost" . (this.DailyBoostExpires > 0 ? " Expires" : "") . ":"
		GuiControl, ICScriptHub:, CDP_DailyBoostExpires, % (this.DailyBoostExpires > 0 ? this.FmtSecs(this.CeilMillisecondsToNearestMainLoopCDSeconds(this.DailyBoostExpires)) : (this.DailyBoostExpires == 0 ? "Inactive" : ""))
		Gui, Submit, NoHide
	}
	
	ProduceGUITimerMessage(CDP_key)
	{
		if (this.Running)
		{
			if (!this.Settings[CDP_key])
				return "Disabled."
			; Ceil the remaining milliseconds to the nearest MainLoopCD so it never shows 00m.
			; Then turn it into seconds to format.
			return this.FmtSecs(this.CeilMillisecondsToNearestMainLoopCDSeconds(this.CurrentCD[CDP_key]))
		}
		return ""
	}
	
	ProduceGUIClaimedMessage(CDP_key)
	{
		if (this.Running)
			return this.Claimed[CDP_key]
		return ""
	}
	
	; ======================
	; ===== MISC STUFF =====
	; ======================
	
	FmtSecs(T, Fmt:="{:}d {:01}h {:02}m") { ; v0.50 by SKAN on D36G/H @ tiny.cc/fmtsecs
		local D, H, M, HH, Q:=60, R:=3600, S:=86400
		T := Round(T)
		fmtTime := Format(Fmt, D:=T//S, H:=(T:=T-D*S)//R, M:=(T:=T-H*R)//Q, T-M*Q, HH:=D*24+H, HH*Q+M)
		fmtTime := RegExReplace(fmtTime, "m)^0d ", "")
		fmtTime := RegExReplace(fmtTime, "m)^0h ", "")
		fmtTime := Trim(fmtTime)
		return fmtTime
	}
	
	CeilMillisecondsToNearestMainLoopCDSeconds(CDP_timer)
	{
		return (Ceil((CDP_timer - A_TickCount) / this.MainLoopCD) * this.MainLoopCD) / 1000
	}
	
	ArrSize(arr)
	{
		if (IsObject(arr))
		{
			CDP_currArrSize := arr.MaxIndex()
			if (CDP_currArrSize == "")
				return 0
			return CDP_currArrSize
		}
		return 0
	}
	
	ArrHasValue(arr,val)
	{
		for k,v in arr
			if (v == val)
				return true
		return false
	}

	RandInt(min,max)
	{
		r := min
		Random,r,min,max
		return r
	}
	
}
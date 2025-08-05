#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\IC_ClaimDailyPlatinum_Functions.ahk
#include %A_LineFile%\..\..\..\ServerCalls\IC_ServerCalls_Class.ahk

GUIFunctions.AddTab("Claim Daily Platinum")
global g_ClaimDailyPlatinum := new IC_ClaimDailyPlatinum_Component
global g_ServerCalls := new IC_ServerCalls_Class

Gui, ICScriptHub:Tab, Claim Daily Platinum
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Add, Text, x15 y+15, Claim Daily Platinum:
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Button, x145 y+-15 w100 vg_ClaimDailyPlatinumSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_ClaimDailyPlatinum, "SaveSettings")
GuiControl,ICScriptHub: +g, g_ClaimDailyPlatinumSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, x145 y+-13 w400 vg_CDP_StatusText, % IC_ClaimDailyPlatinum_Component.WaitingMessage

GuiControlGet, pos, ICScriptHub:Pos, g_CDP_StatusText
g_CDP_infoGap := 5
g_CDP_infoDist := 15
g_CDP_lineHeight := posH
g_CDP_gbCol1 := 15
g_CDP_gbCol2 := 273
g_CDP_gbWidth := 252
g_CDP_gbHeight1 := 100
g_CDP_gbHeight2 := g_CDP_gbHeight1 + g_CDP_lineHeight + g_CDP_infoGap
g_CDP_cbDist := 25
g_CDP_col1x := 15
g_CDP_col1w := 120
g_CDP_col2x := g_CDP_col1x + g_CDP_col1w + g_CDP_infoGap
g_CDP_col2w := 105

; Claim Daily Platinum - is tall due to daily boost line.
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x%g_CDP_gbCol1% y+10 Section w%g_CDP_gbWidth% h%g_CDP_gbHeight2%, Claim Daily Platinum
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimPlatinum xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Daily Platinum?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Platinum Days Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_PlatinumDaysCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_PlatinumTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, vg_CDP_DailyBoostHeader xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, 
Gui, ICScriptHub:Add, Text, vg_CDP_DailyBoostExpires xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

; Claim Trials Rewards - is tall due to trials status.
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x%g_CDP_gbCol2% ys+0 Section w%g_CDP_gbWidth% h%g_CDP_gbHeight2%, Claim Trials Rewards
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimTrials xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Trials Rewards?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Rewards Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_TrialsRewardsCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_TrialsTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, vg_CDP_TrialsStatusHeader xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, 
Gui, ICScriptHub:Add, Text, vg_CDP_TrialsStatus xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

; Claim Free Weekly Shop Offers - short.
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x%g_CDP_gbCol1% ys+%g_CDP_gbHeight2%+5 Section w%g_CDP_gbWidth% h%g_CDP_gbHeight1%, Claim Free Weekly Shop Offers
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimFreeOffer xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Free Weekly Shop Offers?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Free Offers Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_FreeOffersCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_FreeOfferTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

; Claim Guide Quest Rewards - short.
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x%g_CDP_gbCol2% ys+0 Section w%g_CDP_gbWidth% h%g_CDP_gbHeight1%, Claim Guide Quest Rewards
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimGuideQuests xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Guide Quest Rewards?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Rewards Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_GuideQuestsCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_GuideQuestsTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

; Claim Free Premium Pack Bonus Chests - short.
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x%g_CDP_gbCol1% ys+%g_CDP_gbHeight1%+5 Section w%g_CDP_gbWidth% h%g_CDP_gbHeight1%, Claim Free Premium Pack Bonus Chests
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimBonusChests xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Free Premium Pack Bonus Chests?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Bonus Chests Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_BonusChestsCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_BonusChestsTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

; Claim Celebration Rewards - short.
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x%g_CDP_gbCol2% ys+0 Section w%g_CDP_gbWidth% h%g_CDP_gbHeight1%, Claim Celebration Rewards
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimCelebrations xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Celebration Rewards?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Rewards Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_CelebrationRewardsCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_CelebrationsTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

if(IsObject(IC_BrivGemFarm_Component))
{
	g_ClaimDailyPlatinum.InjectAddon()
}

g_ClaimDailyPlatinum.Init()

Class IC_ClaimDailyPlatinum_Component
{
	static SettingsPath := A_LineFile . "\..\ClaimDailyPlatinum_Settings.json"
	static WaitingMessage := "Waiting for BrivGemFarm to Start."
	
	Injected := false
	Running := false
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
	
	UserID := ""
	UserHash := ""
	InstanceID := ""
	GameVersion := ""
	Platform := ""

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================

	InjectAddon()
	{
		local splitStr := StrSplit(A_LineFile, "\")
		local addonDirLoc := splitStr[(splitStr.Count()-1)]
		local addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_ClaimDailyPlatinum_Addon.ahk`n"
		FileAppend, %addonLoc%, %g_BrivFarmModLoc%
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "CreateTimedFunctions"))
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "StartTimedFunctions"))
		g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "StopTimedFunctions"))
		this.Injected := true
	}
	
	Init()
	{
		Global
		if (!this.Injected)
			return
		this.LoadSettings()
	}
	
	LoadSettings()
	{
		Global
		Gui, Submit, NoHide
		writeSettings := false
		this.Settings := g_SF.LoadObjectFromJSON(IC_ClaimDailyPlatinum_Component.SettingsPath)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(IC_ClaimDailyPlatinum_Component.SettingsPath, this.Settings)
		GuiControl, ICScriptHub:, g_CDP_ClaimPlatinum, % this.Settings["Platinum"]
		GuiControl, ICScriptHub:, g_CDP_ClaimTrials, % this.Settings["Trials"]
		GuiControl, ICScriptHub:, g_CDP_ClaimFreeOffer, % this.Settings["FreeOffer"]
		GuiControl, ICScriptHub:, g_CDP_ClaimGuideQuests, % this.Settings["GuideQuests"]
		GuiControl, ICScriptHub:, g_CDP_ClaimBonusChests, % this.Settings["BonusChests"]
		GuiControl, ICScriptHub:, g_CDP_ClaimCelebrations, % this.Settings["Celebrations"]
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
		
		this.Settings["Platinum"] := g_CDP_ClaimPlatinum
		this.Settings["Trials"] := g_CDP_ClaimTrials
		this.Settings["FreeOffer"] := g_CDP_ClaimFreeOffer
		this.Settings["GuideQuests"] := g_CDP_ClaimGuideQuests
		this.Settings["BonusChests"] := g_CDP_ClaimBonusChests
		this.Settings["Celebrations"] := g_CDP_ClaimCelebrations
		
		g_SF.WriteObjectToJSON(IC_ClaimDailyPlatinum_Component.SettingsPath, this.Settings)
		IC_ClaimDailyPlatinum_Functions.UpdateSharedSettings()
		;if (!sanityChecked)
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
	
	UpdateSharedSettings()
	{
		if (IC_ClaimDailyPlatinum_Functions.UpdateSharedSettings())
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
	
	; This loop gets called once per MainLoopCD.
	MainLoop()
	{
		this.UpdateMainStatus("Checking...")
		if (!IC_ClaimDailyPlatinum_Functions.IsGameClosed())
		{
			this.InstanceID := g_SF.Memory.ReadInstanceID()
			if (this.UserID == "")
				this.UserID := g_SF.Memory.ReadUserID()
			if (this.UserHash == "")
				this.UserHash := g_SF.Memory.ReadUserHash()
			if (this.Platform == "")
				this.Platform := g_SF.Memory.ReadPlatform()
			if (this.GameVersion == "")
				this.GameVersion := g_SF.Memory.ReadBaseGameVersion()
			
			for k,v in this.CurrentCD
			{
				if (!this.Settings[k])
					continue
				if (this.CurrentCD[k] <= A_TickCount)
				{
					; If it's not claimable - check if it can be claimed.
					if (!this.Claimable[k])
						this.CallCheckClaimable(k)
					; If it now is claimable - claim it.
					if (this.Claimable[k])
					{
						this.UpdateMainStatus("Claiming " . (this.Names[k]))
						this.Claim(k)
						this.CurrentCD[k] := A_TickCount + this.SafetyDelay
						this.Claimable[k] := false
					}
				}
			}
		}
		this.UpdateMainStatus("Idle.")
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
		if (CDP_key == "Platinum")
		{
			params := this.GetBoilerplate()
			response := g_ServerCalls.ServerCall("getdailyloginrewards",params)
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
			params := this.GetBoilerplate()
			response := g_ServerCalls.ServerCall("trialsrefreshdata",params)
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
			params := this.GetBoilerplate()
			g_ServerCalls.ServerCall("revealalacarteoffers",params)
			response := g_ServerCalls.ServerCall("getalacarteoffers",params)
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
			params := this.GetBoilerplate()
			response := g_ServerCalls.ServerCall("getcompletiondata",params)
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
			params := this.GetBoilerplate()
			extraParams := params . "&return_all_items_live=1&return_all_items_ever=0&show_hard_currency=1&prioritize_item_category=recommend"
			response := g_ServerCalls.ServerCall("getshop",extraParams)
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
					params := this.GetBoilerplate()
					extraParams := params . "&dialog=" . v . "&ui_type=standard"
					response := g_ServerCalls.ServerCall("getdynamicdialog",extraParams)
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
	
	Claim(CDP_key)
	{
		params := this.GetBoilerplate()
		if (CDP_key == "Platinum")
		{
			extraParams := "&is_boost=0" . params
			response := g_ServerCalls.ServerCall("claimdailyloginreward",extraParams)
			if (IsObject(response) && response.success)
			{
				if (response.daily_login_details.premium_active)
				{
					extraParams := "&is_boost=1" . params
					response := g_ServerCalls.ServerCall("claimdailyloginreward",extraParams)
				}
				this.Claimed[CDP_key] += 1
			}
		}
		else if (CDP_key == "Trials")
		{
			extraParams := "&campaign_id=" . (this.TrialsCampaignID) . params
			response := g_ServerCalls.ServerCall("trialsclaimrewards",extraParams)
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
				extraParams := "&offer_id=" . v . params
				response := g_ServerCalls.ServerCall("PurchaseALaCarteOffer",extraParams)
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
			extraParams := "&collection_quest_id=-1" . params
			response := g_ServerCalls.ServerCall("claimcollectionquestrewards",extraParams)
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
				extraParams := "&premium_item_id=" . v . params
				response := g_ServerCalls.ServerCall("claimsalebonus",extraParams)
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
				extraParams := "&code=" . v . params
				response := g_ServerCalls.ServerCall("redeemcoupon",extraParams)
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
	}
	
	; =======================
	; ===== TIMER STUFF =====
	; =======================
	
	; Adds timed functions (typically to be started when briv gem farm is started)
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer := ObjBindMethod(this, "MainLoop")
		this.TimerFunctions[fncToCallOnTimer] := this.MainLoopCD
		fncToCallOnTimer := ObjBindMethod(this, "UpdateSharedSettings")
		this.TimerFunctions[fncToCallOnTimer] := 1234
	}

	; Starts the saved timed functions (typically to be started when briv gem farm is started)
	StartTimedFunctions()
	{
		this.Running := true
		this.UpdateMainStatus("Idle.")
		this.UserID := g_SF.Memory.ReadUserID()
		this.UserHash := g_SF.Memory.ReadUserHash()
		this.Platform := g_SF.Memory.ReadPlatform()
		this.GameVersion := g_SF.Memory.ReadBaseGameVersion()
		for k,v in this.TimerFunctions
			SetTimer, %k%, %v%, 0
		for k,v in this.CurrentCD
			this.CurrentCD[k] := A_TickCount + (this.StartingCD * this.StaggeredChecks[k])
		this.UpdateGUI()
	}

	; Stops the saved timed functions (typically to be stopped when briv gem farm is stopped)
	StopTimedFunctions()
	{
		this.Running := false
		this.UpdateMainStatus(this.WaitingMessage)
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
	
	UpdateMainStatus(status)
	{
		GuiControl, ICScriptHub:Text, g_CDP_StatusText, % status
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
	
		GuiControl, ICScriptHub:, g_CDP_PlatinumTimer, % this.ProduceGUITimerMessage("Platinum")
		GuiControl, ICScriptHub:, g_CDP_TrialsTimer, % this.ProduceGUITimerMessage("Trials")
		GuiControl, ICScriptHub:, g_CDP_FreeOfferTimer, % this.ProduceGUITimerMessage("FreeOffer")
		GuiControl, ICScriptHub:, g_CDP_GuideQuestsTimer, % this.ProduceGUITimerMessage("GuideQuests")
		GuiControl, ICScriptHub:, g_CDP_BonusChestsTimer, % this.ProduceGUITimerMessage("BonusChests")
		GuiControl, ICScriptHub:, g_CDP_CelebrationsTimer, % this.ProduceGUITimerMessage("Celebrations")
		GuiControl, ICScriptHub:, g_CDP_PlatinumDaysCount, % this.ProduceGUIClaimedMessage("Platinum")
		GuiControl, ICScriptHub:, g_CDP_TrialsRewardsCount, % this.ProduceGUIClaimedMessage("Trials")
		GuiControl, ICScriptHub:, g_CDP_FreeOffersCount, % this.ProduceGUIClaimedMessage("FreeOffer")
		GuiControl, ICScriptHub:, g_CDP_GuideQuestsCount, % this.ProduceGUIClaimedMessage("GuideQuests")
		GuiControl, ICScriptHub:, g_CDP_BonusChestsCount, % this.ProduceGUIClaimedMessage("BonusChests")
		GuiControl, ICScriptHub:, g_CDP_CelebrationRewardsCount, % this.ProduceGUIClaimedMessage("Celebrations")
		
		GuiControl, ICScriptHub:, g_CDP_TrialsStatusHeader, % (this.TrialsPresetStatuses[1][this.TrialsStatus[1]]) . ":"
		GuiControl, ICScriptHub:, g_CDP_TrialsStatus, % (this.TrialsStatus[1] == 1 ? this.TrialsPresetStatuses[2][this.TrialsStatus[2]] : (this.FmtSecs(this.CeilMillisecondsToNearestMainLoopCDSeconds(this.TrialsStatus[2])) . (this.TrialsStatus[1] == 2 ? " (est)" : "")))
		GuiControl, ICScriptHub:, g_CDP_DailyBoostHeader, % "Daily Boost" . (this.DailyBoostExpires > 0 ? " Expires" : "") . ":"
		GuiControl, ICScriptHub:, g_CDP_DailyBoostExpires, % (this.DailyBoostExpires > 0 ? this.FmtSecs(this.CeilMillisecondsToNearestMainLoopCDSeconds(this.DailyBoostExpires)) : (this.DailyBoostExpires == 0 ? "Inactive" : ""))
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
	
	GetBoilerplate()
	{
		return "&user_id=" . (this.UserID) . "&hash=" . (this.UserHash) . "&instance_id=" . (this.InstanceID) . "&language_id=1&timestamp=0&request_id=0&network_id=" . (this.Platform) . "&mobile_client_version=" . (this.GameVersion) . "&instance_key=1&offline_v2_build=1&localization_aware=true"
	}

	RandInt(min,max)
	{
		r := min
		Random,r,min,max
		return r
	}
	
}
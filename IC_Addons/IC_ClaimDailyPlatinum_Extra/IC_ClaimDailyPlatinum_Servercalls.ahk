
#include %A_LineFile%\..\..\IC_Core\IC_SharedFunctions_Class.ahk
global g_SF := new IC_SharedFunctions_Class
global g_UserSettings := SH_SharedFunctions.LoadObjectFromJSON( A_LineFile . "\..\..\..\Settings.json" )
class IC_BrivGemFarmRun_ClaimDailyPlatinum_Coms_Class ; Activated/shared by cdp servercall overrides
{
    Claimed := ""
    Claimable := ""
    CurrentCD := ""
    TrialsCampaignID := ""
    UnclaimedGuideQuests := ""
    DailyBoostExpires := ""
    FreeWeeklyRerolls := ""
    TrialsStatus := ""
}

class IC_ClaimDailyPlatinum_Servercalls_Overrides
{
	ServerCall(callIdent,params)
	{
		params .= this.dummyData . "&user_id=" . this.userID . "&hash=" . this.userHash . "&instance_id=" . this.instanceID
		return base.ServerCall(callIdent,params)
	}

    LaunchCalls()
    {
        base.LaunchCalls()
        if (A_Args[1] != "") ; all claim calls are done via file, not args.
            return
        this.ReportClaims()
    }
}

class IC_ClaimDailyPlatinum_Servercalls
{
    ; ==============
    ; informative only
    ; this.SHSharedData := := new IC_BrivGemFarmRun_ClaimDailyPlatinum_Coms_Class
    ; this.SHSharedData.Claimed
    ; this.SHSharedData.Claimable
    ; this.SHSharedData.CurrentCD
    ; this.SHSharedData.TrialsCampaignID := 0
    ; this.SHSharedData.FreeWeeklyRerolls
    ; this.Claimed := {"Platinum":0,"Trials":0,"FreeOffer":0,"GuideQuests":0,"BonusChests":0,"Celebrations":0}
    ; this.Claimable := {"Platinum":false,"Trials":false,"FreeOffer":false,"GuideQuests":false,"BonusChests":false,"Celebrations":false}
    ; this.CurrentCD := {"Platinum":0,"Trials":0,"FreeOffer":0,"GuideQuests":0,"BonusChests":0,"Celebrations":0}
    ; this.TrialsCampaignID := 0
    ; this.FreeWeeklyRerolls
    ; this.FreeOfferIDs := []
    ; this.CelebrationCodes := []
    ; this.TiamatHP := [40,75,130,200,290,430,610,860,1200,1600]
	; this.MainLoopCD := 60000 ; in milliseconds = 1 minute.
    ; this.StartingCD := 60000 ; in milliseconds = 1 minute.
	; this.SafetyDelay := 30000 ; in milliseconds = 30 seconds.
	; NoTimerDelay := 28800000 ; in milliseconds = 8 hours.
	; NoTimerDelayRNG := 1800000 ; in milliseconds = 30 minutes.
    ; ==============


    InitClaimPremium() ; declare class variables here since they are not copied by updatesclass
    {
        if (A_Args[1] != "") ; all claim calls are done via file, not args.
            return
        this.FreeOfferIDs := []
	    this.CelebrationCodes := []
	    this.TiamatHP := [40,75,130,200,290,430,610,860,1200,1600]
        ; The timer for MainLoop:
	    this.MainLoopCD := 60000 ; in milliseconds = 1 minute.
    	; The starting cooldown for each type:
        this.StartingCD := 60000 ; in milliseconds = 1 minute.
	    ; The delay between when the server says a timer resets and when to check (for safety):
	    this.SafetyDelay := 30000 ; in milliseconds = 30 seconds.
        this.TrialsCampaignID := 5
        this.BonusChestIDs := []
        this.FreeOfferIDs := []
        this.NoTimerDelay := 28800000 ; in milliseconds = 8 hours.
        this.NoTimerDelayRNG := 1800000 ; in milliseconds = 30 minutes.
        SHSharedData := new IC_BrivGemFarmRun_ClaimDailyPlatinum_Coms_Class
        guid := ComObjCreate("Scriptlet.TypeLib").Guid
        ObjRegisterActive(SHSharedData, guid)
        this.SHSharedData := SHSharedData
        this.WriteObjectToJSON(A_LineFile . "\..\LastGUID_ClaimDailyPremium.json", guid)
        try {
            ScriptHubComs := ComObjActive(this.LoadObjectFromJSON(A_LineFile . "\..\..\IC_BrivGemFarm_Performance\LastGUID_BrivGemFarmComponent.json"))
        }
        if(IsObject(ScriptHubComs))
            ScriptHubComs.ResetCDPComponentComs() ; tell script to load coms and set trials campaign ID / Free Offers
        this.TrialsCampaignID := this.SHSharedData.TrialsCampaignID == "" ? this.TrialsCampaignID : this.SHSharedData.TrialsCampaignID
        this.FreeOfferIDs := this.SHSharedData.FreeOfferIDs == "" ? this.FreeOfferIDs : g_SF.ComObjectCopy(this.SHSharedData.FreeOfferIDs)
        this.BonusChestIDs := this.SHSharedData.BonusChestIDs == "" ? this.BonusChestIDs : g_SF.ComObjectCopy(this.SHSharedData.BonusChestIDs)
        ScriptHubComs := ""
        ; The amount of times each type has been claimed:
        this.Claimed := {"Platinum":0,"Trials":0,"FreeOffer":0,"GuideQuests":0,"BonusChests":0,"Celebrations":0}
        ; The flags to tell the timers to pause if the script is waiting for the game to go offline.
        this.Claimable := {"Platinum":false,"Trials":false,"FreeOffer":false,"GuideQuests":false,"BonusChests":false,"Celebrations":false}
        ; The current cooldown for each type:
        this.CurrentCD := {"Platinum":0,"Trials":0,"FreeOffer":0,"GuideQuests":0,"BonusChests":0,"Celebrations":0}
    }

    Claim(CDP_key)
    {
        if (CDP_key == "Platinum")
        {
            params := "&is_boost=0"
            response := g_BrivServerCall.ServerCall("claimdailyloginreward", params)
            if (IsObject(response) && response.success)
            {
                if (response.daily_login_details.premium_active)
                {
                    params := "&is_boost=1"
                    response := g_BrivServerCall.ServerCall("claimdailyloginreward", params)
                }
                this.claimed[CDP_key] += 1
            }
        }
        else if (CDP_key == "Trials")
        {
            params := "&campaign_id=" . this.SHSharedData.TrialsCampaignID
            response := g_BrivServerCall.ServerCall("trialsclaimrewards", params)
            this.TrialsCampaignID := 0
            if (!IsObject(response) || !response.success)
            {
                ; server call failed
                this.TrialsStatus := [1,1]
                return
            }
            this.claimed[CDP_key] += 1
            this.TrialsStatus := [1,3]
        }
        else if (CDP_key == "FreeOffer")
        {
            for k,v in this.FreeOfferIDs
            {
                params := "&offer_id=" . v
                response := g_BrivServerCall.ServerCall("PurchaseALaCarteOffer", params)
                if (!IsObject(response) || !response.success)
                {
                    ; server call failed
                    this.FreeOfferIDs := []
                    return
                }
            }
            this.claimed[CDP_key] += g_SF.ArrSize(this.FreeOfferIDs)
            this.FreeOfferIDs := []
        }
        else if (CDP_key == "GuideQuests")
        {
            params := "&collection_quest_id=-1"
            response := g_BrivServerCall.ServerCall("claimcollectionquestrewards", params)
            if (IsObject(response) && response.success && response.awarded_items.success)
            {
                CDP_numGuideQuestsClaimed := g_SF.ArrSize(response.awarded_items.rewards_claimed_quest_ids)
                if (CDP_numGuideQuestsClaimed > 0 )
                {
                    this.claimed[CDP_key] += CDP_numGuideQuestsClaimed
                    this.UnclaimedGuideQuests := 0
                }
            }
        }
        else if (CDP_key == "BonusChests")
        {
            for k,v in this.BonusChestIDs
            {
                params := "&premium_item_id=" . v
                response := g_BrivServerCall.ServerCall("claimsalebonus", params)
                if (!IsObject(response) || !response.success)
                {
                    ; server call failed
                    this.BonusChestIDs := []
                    return
                }
            }
            this.claimed[CDP_key] += g_SF.ArrSize(this.BonusChestIDs)
            this.BonusChestIDs := []
        }
        else if (CDP_key == "Celebrations")
        {
            for k,v in this.CelebrationCodes
            {
                params := "&code=" . v
                response := g_BrivServerCall.ServerCall("redeemcoupon", params)
                if (!IsObject(response) || !response.success)
                {
                    ; server call failed
                    this.CelebrationCodes := []
                    return
                }
            }
            this.claimed[CDP_key] += g_SF.ArrSize(this.CelebrationCodes)
            this.CelebrationCodes := []
        }
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
            response := g_BrivServerCall.ServerCall("getdailyloginrewards", "")
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
            response := g_BrivServerCall.ServerCall("trialsrefreshdata", "")
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
                CDP_trialsCampaignsSize := g_SF.ArrSize(CDP_trialsCampaigns)
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
            this.FreeWeeklyRerolls := -1
            g_BrivServerCall.ServerCall("revealalacarteoffers", "")
            response := g_BrivServerCall.ServerCall("getalacarteoffers", "")
            if (IsObject(response) && response.success)
            {
                for k,v in response.offers.offers
                {
                    if (v.type != "free" || v.cost > 0)
                        continue
                    if (!v.purchased)
                        this.FreeOfferIDs.Push(v.offer_id)
                }
                this.FreeWeeklyRerolls := (response.offers.reroll_cost == 0 ? response.offers.rerolls_remaining : 0)
                if (g_SF.ArrSize(this.FreeOfferIDs) > 0)
                    return [true, 0]
                return [false, A_TickCount + (response.offers.time_remaining * 1000) + this.SafetyDelay]
            }
        }
        else if (CDP_key == "GuideQuests")
        {
            response := g_BrivServerCall.ServerCall("getcompletiondata", "")
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
            response := g_BrivServerCall.ServerCall("getshop", params)
            if (IsObject(response) && response.success)
            {
                for k,v in response.package_deals
                    if (v.bonus_status == "0" && g_SF.ArrSize(v.bonus_item) > 0)
                        this.BonusChestIDs.Push(v.item_id)
                if (g_SF.ArrSize(this.BonusChestIDs) > 0)
                    return [true, 0]
            }
            return [false, A_TickCount + this.CalcNoTimerDelay()]
        }
        else if (CDP_key == "Celebrations")
        {
            global g_SF
            this.CelebrationCodes := []
            g_SF.Memory.OpenProcessReader()
            wrlLoc := g_SF.Memory.GetWebRequestLogLocation()
            if (wrlLoc == "")
                return [false, A_TickCount + this.CalcNoTimerDelay()]
            webRequestLog := ""
            FileRead, webRequestLog, %wrlLoc%
            CDP_nextClaimSeconds := 9999999
            if (InStr(webRequestLog, """dialog"":"))
            {
                currMatches := this.GetAllRegexMatches(webRequestLog, """dialog"": ?""([^""]+)""")
                for k,v in currMatches
                {
                    params := "&dialog=" . v . "&ui_type=standard"
                    response := g_BrivServerCall.ServerCall("getdynamicdialog", params)
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
            if (g_SF.ArrSize(this.CelebrationCodes) > 0)
                return [true, 0]
            if (CDP_nextClaimSeconds < 9999999)
                return [false, A_TickCount + (CDP_nextClaimSeconds * 1000) + this.SafetyDelay]
            else
                return [false, A_TickCount + this.CalcNoTimerDelay()]
        }
        return [false, A_TickCount + this.StartingCD]
    }

    ReportClaims()
    {
        Critical, On
        if (IsObject(this.SHSharedData)) 
        {

            this.SHSharedData.Claimed := this.Claimed
            this.SHSharedData.Claimable := this.Claimable
            this.SHSharedData.CurrentCD := this.CurrentCD
            this.SHSharedData.TrialsCampaignID := 0
            this.SHSharedData.UnclaimedGuideQuests := this.UnclaimedGuideQuests
            this.SHSharedData.DailyBoostExpires := this.DailyBoostExpires
            this.SHSharedData.FreeWeeklyRerolls := this.FreeWeeklyRerolls
            this.SHSharedData.TrialsStatus := this.TrialsStatus
            this.SHSharedData.FreeOfferIDs := this.FreeOfferIDs
            this.SHSharedData.BonusChestIDs := this.BonusChestIDs
        }
        try
        {
            ScriptHubComs := ComObjActive(this.LoadObjectFromJSON(A_LineFile . "\..\..\IC_BrivGemFarm_Performance\LastGUID_BrivGemFarmComponent.json"))
        }
        if (IsObject(ScriptHubComs)) {
            try {
                ScriptHubComs.UpdateCDPComponent()
            }
        }
        Critical, Off
        ScriptHubComs := ""
    }

	; ======================
	; ===== MISC STUFF =====
	; ======================
	CalcNoTimerDelay()
	{
		return this.NoTimerDelay + this.RandInt(-this.NoTimerDelayRNG, this.NoTimerDelayRNG)
	}

	RandInt(min,max)
	{
		r := min
		Random,r,min,max
		return r
	}

	GetAllRegexMatches(haystack,needle)
	{
		matches := []
		while n := RegExMatch(haystack,"O)" needle,match,n?n+1:1)
		{
			index := matches.length()+1
			loop % match.count()
				matches.push(match.value(a_index))
		}
		return matches
	}
}
SH_UpdateClass.UpdateClassFunctions(g_BrivServerCall, IC_ClaimDailyPlatinum_Servercalls_Overrides)
SH_UpdateClass.AddClassFunctions(g_BrivServerCall, IC_ClaimDailyPlatinum_Servercalls)
g_BrivServerCall.InitClaimPremium()


        
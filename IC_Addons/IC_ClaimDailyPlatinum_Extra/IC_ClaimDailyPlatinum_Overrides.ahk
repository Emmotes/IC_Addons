class IC_ClaimDailyPlatinum_SharedData_Added_Class ; Added to g_SharedData in BGF_Run
{
    CDP_UpdateSettingsFromFile(fileName := "")
    {
        if (fileName == "")
            fileName := IC_ClaimDailyPlatinum_Functions.SettingsPath
        settings := g_SF.LoadObjectFromJSON(fileName)
        if (!IsObject(settings))
            return false
		for k,v in settings
			g_BrivUserSettingsFromAddons[ "CDP_" k ] := v
    }
}

class IC_BrivGemFarmRun_ClaimDailyPlatinum_SharedData_Class ; Updates IC_BrivGemFarm_Coms which updates g_BrivFarmComsObj
{
    ResetCDPComponentComs()
    { ; called from CDP servercalls
    
        static ResetComsLock := False
        if(ResetComsLock)
            return
        ResetComsLock := True
        try
        {
            ServerCallGuid := g_SF.LoadObjectFromJSON(A_LineFile . "\..\LastGUID_ClaimDailyPremium.json")
            try{
                g_ClaimDailyPlatinum.SharedData := ComObjActive(ServerCallGuid)
                g_ClaimDailyPlatinum.SharedData.TrialsCampaignID := g_ClaimDailyPlatinum.TrialsCampaignID
            }
        }
        ResetComsLock := False
    }

    UpdateCDPComponent()
    {
        Critical, On
        claimedValue := g_SF.ComObjectCopy(g_ClaimDailyPlatinum.SharedData.Claimed)
        if(claimedValue != "") ; should not be empty, should always be an object with items in it.
        {
            g_ClaimDailyPlatinum.Claimed := g_ClaimDailyPlatinum.SharedData.Claimed == "" ? g_ClaimDailyPlatinum.Claimed : g_SF.ComObjectCopy(g_ClaimDailyPlatinum.SharedData.Claimed)
            g_ClaimDailyPlatinum.Claimable := g_ClaimDailyPlatinum.SharedData.Claimable == "" ? g_ClaimDailyPlatinum.Claimable : g_SF.ComObjectCopy(g_ClaimDailyPlatinum.SharedData.Claimable)
            g_ClaimDailyPlatinum.CurrentCD := g_ClaimDailyPlatinum.SharedData.CurrentCD == "" ? g_ClaimDailyPlatinum.CurrentCD : g_SF.ComObjectCopy(g_ClaimDailyPlatinum.SharedData.CurrentCD)
            g_ClaimDailyPlatinum.TrialsCampaignID := g_ClaimDailyPlatinum.SharedData.TrialsCampaignID == "" ? g_ClaimDailyPlatinum.TrialsCampaignID : g_ClaimDailyPlatinum.SharedData.TrialsCampaignID
            g_ClaimDailyPlatinum.UnclaimedGuideQuests := g_ClaimDailyPlatinum.SharedData.UnclaimedGuideQuests == "" ? g_ClaimDailyPlatinum.UnclaimedGuideQuests : g_ClaimDailyPlatinum.SharedData.UnclaimedGuideQuests
            g_ClaimDailyPlatinum.DailyBoostExpires := g_ClaimDailyPlatinum.SharedData.DailyBoostExpires == "" ? g_ClaimDailyPlatinum.DailyBoostExpires : g_ClaimDailyPlatinum.SharedData.DailyBoostExpires
            g_ClaimDailyPlatinum.FreeWeeklyRerolls := g_ClaimDailyPlatinum.SharedData.FreeWeeklyRerolls == "" ? g_ClaimDailyPlatinum.FreeWeeklyRerolls : g_ClaimDailyPlatinum.SharedData.FreeWeeklyRerolls
            g_ClaimDailyPlatinum.TrialsStatus := g_ClaimDailyPlatinum.SharedData.TrialsStatus == "" ? g_ClaimDailyPlatinum.TrialsStatus : g_SF.ComObjectCopy(g_ClaimDailyPlatinum.SharedData.TrialsStatus)
        }
        g_ClaimDailyPlatinum.HasComsUpdated := A_TickCount - this.MainLoopCD
        Critical, Off
    }
}
class IC_DMFishingMinigame_Functions
{
	static SettingsPath := A_LineFile . "\..\DMFishingMinigame_Settings.json"
	static DefaultCoords := {"c_compX":-90,"c_compY":180,"c_skipX":-127,"c_skipY":-77,"c_restX":122,"c_restY":-141}

	TickFrequency := -1
	PreviousInstanceId := ""

    ReadDMSpecialGuest()
    {
        if (this.IsGameClosed())
			return
		
		currInstanceId := g_SF.Memory.ReadInstanceID()
		if (this.PreviousInstanceId == "" || currInstanceId == "" || this.PreviousInstanceId != currInstanceId)
		{
        	g_SF.Memory.OpenProcessReader()
			this.PreviousInstanceId := g_SF.Memory.ReadInstanceID()
		}

        if (!IsObject(g_SF.Memory.GameManager.game.gameInstances.StatHandler.DSpec1SlotId)) {
            g_SF.Memory.GameManager.game.gameInstances.StatHandler.DSpec1SlotId := New GameObjectStructure(g_SF.Memory.GameManager.game.gameInstances.StatHandler,"Int", [0x280])
            g_SF.Memory.GameManager.game.gameInstances.ResetCollections()
        }

        return g_SF.Memory.GameManager.game.gameInstances[g_SF.Memory.GameInstance].StatHandler.DSpec1SlotId.Read()
    }

	; =======================================
	; ===== RESTART ADVENTURE FUNCTIONS =====
	; =======================================

	RestartAdventure(SanityChecked := false)
	{
		if (!SanityChecked && !this.SanityCheckCoordinates())
		{
			MsgBox, % "Custom Coordinates aren't viable. Fix them."
			return "Custom Coordinates aren't viable. Fix them."
		}
		; Step 1: Press R to open the complete adventure dialog.
		IC_DMFishingMinigame_Component.UpdateMainStatus("Opening Complete Adventure dialog.")
		openedCompAdv := this.OpenCompleteAdventure()
		; Step 2: Click the Complete button.
		completeStatusMsg := "Completing the adventure."
		IC_DMFishingMinigame_Component.UpdateMainStatus(completeStatusMsg)
		clickedComplete := this.ClickCompleteAdventure(completeStatusMsg)
		if (!clickedComplete)
		{
			MsgBox, % "Failed to click the Complete button in time."
			return "Failed to click the Complete button in time."
		}
		; Step 3: Alternate clicking the Skip button and the Restart button.
		skipRestartStatusMsg := "Alternating Skip and Restart buttons."
		IC_DMFishingMinigame_Component.UpdateMainStatus(skipRestartStatusMsg)
		clickedRestart := this.AlternateSkipAndRestart(skipRestartStatusMsg)
		if (!clickedRestart)
		{
			MsgBox, % "Failed to click Restart in time."
			return "Failed to click Restart in time."
		}
		; Step 4: Disable Autoprogress.
		g_SF.ToggleAutoProgress(0, false, true)
		return "success"
	}

	SanityCheckCoordinates()
	{
		if (!g_DMFishingMinigame.Settings["customCoords"])
			return true

		gameWidth := g_DMFishingMinigame.GameWidth
		gameHeight := g_DMFishingMinigame.GameHeight
		for k,v in ["comp", "skip", "rest"]
		{
			currCoords := this.GetCoordinates("c_" v)
			if (currCoords == "")
				return false
			x := currCoords[1]
			y := currCoords[2]
			if (!IC_DMFishingMinigame_Component.IsNumber(x) || x <= 0 || x > gameWidth)
				return false
			if (!IC_DMFishingMinigame_Component.IsNumber(y) || y <= 0 || y > gameHeight)
				return false
		}
		return true
	}

	OpenCompleteAdventure()
	{
		g_SF.DirectedInput(,, "{r}" )
		Sleep, 1000
		return true
	}
	
	ClickCompleteAdventure(DMFM_status, DMFM_timeout := 10000)
	{
		local compCoords := this.GetCoordinates("c_comp")
		local startTime := this.GetTickCount()
		local elapsed := 0
		loop
		{
			if (!g_DMFishingMinigame.Running)
				return true
			this.ClickTheMouse(compCoords[1], compCoords[2])
			Sleep, 500
			if (g_SF.Memory.ReadCurrentZone() == -1)
				return true
			elapsed := this.GetTickCount() - startTime
			if (elapsed >= DMFM_timeout)
				break
			IC_DMFishingMinigame_Component.UpdateMainStatus(DMFM_status . " Timeout: " . Round((DMFM_timeout - elapsed)/1000, 3) . "s.")
		}
		return false
	}

	AlternateSkipAndRestart(DMFM_status, DMFM_timeout := 30000)
	{
		local skipCoords := this.GetCoordinates("c_skip")
		local restCoords := this.GetCoordinates("c_rest")
		local startTime := this.GetTickCount()
		local elapsed := 0
		loop
		{
			if (!g_DMFishingMinigame.Running)
				return true
			this.ClickTheMouse(skipCoords[1], skipCoords[2])
			Sleep, 50
			this.ClickTheMouse(restCoords[1], restCoords[2])
			Sleep, 500
			if (g_SF.Memory.ReadCurrentZone() >= 1)
				return true
			elapsed := this.GetTickCount() - startTime
			if (elapsed >= DMFM_timeout)
				break
			IC_DMFishingMinigame_Component.UpdateMainStatus(DMFM_status . " Timeout: " . Round((DMFM_timeout - elapsed)/1000, 3) . "s.")
		}
		return false
	}
	
	; ===========================
	; ===== MOUSE FUNCTIONS =====
	; ===========================
	
	ClickTheMouse(xClick,yClick)
	{
		if (!g_DMFishingMinigame.Running)
			return
		hWnd := g_SF.hWnd
		WinActivate, ahk_id %hWnd%
		Sleep, 40
		MouseMove, %xClick%, %yClick%
		Sleep, 10
		MouseClick, Left, %xClick%, %yClick%, 1, 0, D
		Sleep, 80
		MouseClick, Left, %xClick%, %yClick%, 1, 0, U
	}
	
	; =================================
	; ===== MISC HELPER FUNCTIONS =====
	; =================================

	GetCoordinates(coordType)
	{
		local width := 0
		local height := 0
		local offsetX := 0
		local offsetY := 0
		local actualX := 0
		local actualY := 0
		if (g_DMFishingMinigame.Settings["customCoords"])
		{
			offsetX := g_DMFishingMinigame.Settings[coordType "X"]
			offsetY := g_DMFishingMinigame.Settings[coordType "Y"]
		}
		else
		{
			if (InStr(coordType, "comp") || InStr(coordType, "rest"))
				width := g_DMFishingMinigame.GameWidthHalf
			else
				width := g_DMFishingMinigame.GameWidth
			if (InStr(coordType, "comp"))
				height := g_DMFishingMinigame.GameHeightHalf
			else
				height := g_DMFishingMinigame.GameHeight
			offsetX := this.DefaultCoords[coordType "X"]
			offsetY := this.DefaultCoords[coordType "Y"]
		}
		actualX := width + offsetX
		actualY := height + offsetY
		return [actualX, actualY]
	}
	
	GetTickCount()
	{
		if (this.TickFrequency < 0)
		{
			DllCall("QueryPerformanceFrequency", "Int64*", freq)
			this.TickFrequency := freq / 1000
		}
		DllCall("QueryPerformanceCounter", "Int64*", tick)
		return tick / this.TickFrequency
	}
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "" AND Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
			return true
		return false
	}
	
}
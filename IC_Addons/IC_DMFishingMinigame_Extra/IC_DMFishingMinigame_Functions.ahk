class IC_DMFishingMinigame_Functions
{
	static SettingsPath := A_LineFile . "\..\DMFishingMinigame_Settings.json"

	TickFrequency := -1

    ReadDMSpecialGuest()
    {
        if (this.IsGameClosed())
			return

        if (!IsObject(g_SF.Memory.GameManager.game.gameInstances.StatHandler.DSpec1SlotId)) {
            g_SF.Memory.GameManager.game.gameInstances.StatHandler.DSpec1SlotId := New GameObjectStructure(g_SF.Memory.GameManager.game.gameInstances.StatHandler,"Int", [0x280])
            g_SF.Memory.GameManager.game.gameInstances.ResetCollections()
        }

        return g_SF.Memory.GameManager.game.gameInstances[g_SF.Memory.GameInstance].StatHandler.DSpec1SlotId.Read()
    }

	; =======================================
	; ===== RESTART ADVENTURE FUNCTIONS =====
	; =======================================

	RestartAdventure()
	{
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

	OpenCompleteAdventure()
	{
		g_SF.DirectedInput(,, "{r}" )
		Sleep, 1000
		return true
	}
	
	ClickCompleteAdventure(DMFM_status, DMFM_timeout := 10000)
	{
		local width := g_DMFishingMinigame.GameWidthHalf
		local height := g_DMFishingMinigame.GameHeightHalf
		local actualX := width + g_DMFishingMinigame.Settings["compX"]
		local actualY := height + g_DMFishingMinigame.Settings["compY"]
		local startTime := this.GetTickCount()
		local elapsed := 0
		loop
		{
			if (!g_DMFishingMinigame.Running)
				return true
			this.ClickTheMouse(actualX, actualY)
			Sleep, 500
			if (g_SF.Memory.ReadCurrentZone() == -1)
				return true
			elapsed := this.GetTickCount() - startTime
			if (elapsed >= DMFM_timeout)
				break
			IC_DMFishingMinigame_Component.UpdateMainStatus(DMFM_status . " " . Round((DMFM_timeout - elapsed)/1000, 3) . "s")
		}
		return false
	}

	AlternateSkipAndRestart(DMFM_status, DMFM_timeout := 30000)
	{
		local width := g_DMFishingMinigame.GameWidth
		local widthHalf := g_DMFishingMinigame.GameWidthHalf
		local height := g_DMFishingMinigame.GameHeight
		local skipX := width + g_DMFishingMinigame.Settings["skipX"]
		local skipY := height + g_DMFishingMinigame.Settings["skipY"]
		local restX := widthHalf + g_DMFishingMinigame.Settings["restX"]
		local restY := height + g_DMFishingMinigame.Settings["restY"]
		local startTime := this.GetTickCount()
		local elapsed := 0
		loop
		{
			if (!g_DMFishingMinigame.Running)
				return true
			this.ClickTheMouse(skipX, skipY)
			Sleep, 50
			this.ClickTheMouse(restX, restY)
			Sleep, 500
			if (g_SF.Memory.ReadCurrentZone() >= 1)
				return true
			elapsed := this.GetTickCount() - startTime
			if (elapsed >= DMFM_timeout)
				break
			IC_DMFishingMinigame_Component.UpdateMainStatus(DMFM_status . " " . Round((DMFM_timeout - elapsed)/1000, 3) . "s")
		}
		return false
	}
	
	; ===========================
	; ===== MOUSE FUNCTIONS =====
	; ===========================
	
	ClickTheMouse(xClick,yClick)
	{
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
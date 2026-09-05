#include %A_LineFile%\..\FindText.ahk

class IC_DMFishingMinigame_Functions
{
	static SettingsPath := A_LineFile . "\..\DMFishingMinigame_Settings.json"
	static TextComp := "|<comp>*176$82.zzzzzzzzzzzzzzzzzzzzzzzzzzzzkTzzzzzwDzzzzw1zzzzzzszzzzzVrzzzzzzbzwzzyTzzzzzzyTznzzlzyTgwzHtwTDtz7zUQU0k3bUMC1wzwMk0336QNnlblzXn77ASNXbDCD7yDAQwlta0QwVwTcwlnn7aMDnkzswnX7DAQNnzDDzk30QQwk3b0Q41zkT3VVl0QD3kQ7zzzzzzyTzzzzzzzzzzzzlzzzzzzzzzzzzz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"
	static TextSkip := "|<skip>*172$44.zzzzzzzzzzzzzzzwDXzjzzw0kzlzzy0CDwTzzXvXzzzzszszzzzy3y88MVzUDX760Dy0sVlUVzsC0wMQTzVUD67XzwM3lVswy68QMQTU3X7627s0sklU3z0w6081zzzzzy7zzzzzzVzzzzzzsTzzzzzzzzzzzzzzzs"
	static TextRest := "|<rest>*183$90.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk0zzzzzzzzzzzzzs07zzzzzzzzzzzzs03zzzzzDzzzzyTsS3zzzzyDzzzzsTsTVzzzzwDzzzzsTsTVzzzzwDzzzzsTsTVw7y0w7s3sMMTsT3s1w0M1s1s0E3sS3k0s0M1k0w0E3s07VksTQDnkw7sTs0DXssDwDzkwDsTs0TX0s1wDw0wDsTsQDU1w0QDk0wDsTsQDUDzUQDUswDsTsQDVzzwQDVswDsTsS7UttsQDVkwDsTsS7k0s0S1U0wDs3sT3s0k0y0k087w3kD1zjzDz1yzzzy3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"

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
		useOCR := g_DMFishingMinigame.Settings["coordsType"] == "FindText"
		if (useOCR)
			WinGetPos, pX, pY, pW, pH, % "ahk_id " g_SF.hwnd

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
		if (useOCR)
			clickedComplete := this.ClickCompleteAdventureOCR(completeStatusMsg, pX, pY, pW, pH)
		else
			clickedComplete := this.ClickCompleteAdventure(completeStatusMsg)
		if (!clickedComplete)
		{
			MsgBox, % "Failed to click the Complete button in time."
			return "Failed to click the Complete button in time."
		}
		; Step 3: Alternate clicking the Skip button and the Restart button.
		skipRestartStatusMsg := usingOCR ? "Clicking Skip and Restart buttons." : "Alternating Skip and Restart buttons."
		IC_DMFishingMinigame_Component.UpdateMainStatus(skipRestartStatusMsg)
		if (useOCR)
			clickedRestart := this.AlternateSkipAndRestartOCR(skipRestartStatusMsg, pX, pY, pW, pH)
		else
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
		if (g_DMFishingMinigame.Settings["coordsType"] != "Custom")
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
		g_SF.DirectedInput(,, "{r}")
		Sleep, 200
		return true
	}
	
	ClickCompleteAdventure(DMFM_status, DMFM_timeout := 15000)
	{
		local compCoords := this.GetCoordinates("c_comp")
		if (compCoords == "")
			return false
		local triedReopenComplete := false
		local startTime := this.GetTickCount()
		local elapsed := 0
		loop
		{
			if (!g_DMFishingMinigame.Running)
				return true
			this.ClickTheMouse(compCoords[1], compCoords[2])
			Sleep, 200
			if (g_SF.Memory.ReadCurrentZone() == -1)
				return true
			elapsed := this.GetTickCount() - startTime
			if (!triedReopenComplete && elapsed*2 >= DMFM_timeout)
			{
				this.OpenCompleteAdventure()
				triedReopenComplete := true
			}
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
		if (skipCoords == "" || restCoords == "")
			return false
		local startTime := this.GetTickCount()
		local elapsed := 0
		loop
		{
			if (!g_DMFishingMinigame.Running)
				return true
			this.ClickTheMouse(skipCoords[1], skipCoords[2])
			Sleep, 50
			this.ClickTheMouse(restCoords[1], restCoords[2])
			Sleep, 200
			if (g_SF.Memory.ReadCurrentZone() >= 1)
				return true
			elapsed := this.GetTickCount() - startTime
			if (elapsed >= DMFM_timeout)
				break
			IC_DMFishingMinigame_Component.UpdateMainStatus(DMFM_status . " Timeout: " . Round((DMFM_timeout - elapsed)/1000, 3) . "s.")
		}
		return false
	}

	ClickCompleteAdventureOCR(DMFM_status, pX, pY, pW, pH, DMFM_timeout := 20000)
	{
		local startTime := this.GetTickCount()
		local elapsed := 0
		loop
		{
			if (!g_DMFishingMinigame.Running)
				return true
			ocrResult := this.FindTextOCR(pX, pY, pW, pH, g_SF.hwnd, this.TextComp, 1)
			if (ocrResult)
			{
				compCoords := this.ConvertScreenToClientAndCentre(ocrResult[1])
				this.ClickTheMouse(compCoords[1], compCoords[2])
			}
			Sleep, 200
			if (g_SF.Memory.ReadCurrentZone() == -1)
				return true
			elapsed := this.GetTickCount() - startTime
			if (elapsed >= DMFM_timeout)
				break
			IC_DMFishingMinigame_Component.UpdateMainStatus(DMFM_status . " Timeout: " . Round((DMFM_timeout - elapsed)/1000, 3) . "s.")
		}
		return false
	}

	AlternateSkipAndRestartOCR(DMFM_status, pX, pY, pW, pH, DMFM_timeout := 30000)
	{
		local startTime := this.GetTickCount()
		local elapsed := 0
		loop
		{
			if (!g_DMFishingMinigame.Running)
				return true
			ocrResult := this.FindTextOCR(pX, pY, pW, pH, g_SF.hwnd, this.TextRest, 1)
			if (ocrResult)
			{
				compCoords := this.ConvertScreenToClientAndCentre(ocrResult[1])
				this.ClickTheMouse(compCoords[1], compCoords[2])
				Sleep, 50
			}
			ocrResult := this.FindTextOCR(pX, pY, pW, pH, g_SF.hwnd, this.TextSkip, 0)
			if (ocrResult)
			{
				compCoords := this.ConvertScreenToClientAndCentre(ocrResult[1])
				this.ClickTheMouse(compCoords[1], compCoords[2])
			}
			Sleep, 200
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
		local offsetX := 0
		local offsetY := 0
		local actualX := 0
		local actualY := 0
		if (g_DMFishingMinigame.Settings["coordsType"] == "Custom")
			return [g_DMFishingMinigame.Settings[coordType "X"], g_DMFishingMinigame.Settings[coordType "Y"]]

		local width := g_DMFishingMinigame.GameWidth
		local height := g_DMFishingMinigame.GameHeight
		switch (coordType)
		{
			case "c_comp":
				return [Round(width * 0.5, 0) - 88, Round(height * 0.5, 0) + 180]
			case "c_skip":
				return [Round(width * 0.95, 0) - 50, Round(height * 0.95, 0) - 32]
			case "c_rest":
				return [Round(width * 0.5, 0) + 122, Round(height * 0.75, 0) + 57]
		}
		return
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
		if(g_SF.Memory.ReadCurrentZone() == "" AND Not WinExist("ahk_exe " . g_userSettings["ExeName"]))
			return true
		return false
	}

	FindTextOCR(pX, pY, pW, pH, hwnd, textToFind, scrnShot := 1)
	{
		; FindText tutorial: https://www.autohotkey.com/boards/viewtopic.php?t=102806
		if (this.IsGameClosed())
			return ""
		WinActivate, ahk_id %hwnd%
		WinWaitActive, ahk_id %hwnd%,,3
		if (ErrorLevel)
			return ""
		return FindText(rX, rY, pX, pY+Round(pH*0.5,0), pX+pW, pY+pH, 0.05, 0.05, textToFind, scrnShot, 0)
	}

	ConvertScreenToClientAndCentre(found)
	{
		FindText().ScreenToClient(rX, rY, found[1], found[2], g_SF.hwnd)
		return [rX + Round(found[3]*0.5,0), rY + Round(found[4]*0.5,0)]
	}
	
}
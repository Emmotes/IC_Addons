class IC_DMFishingMinigame_GUI_Control
{
	/*
	This code is basically shamelessly copied from ImpEGamer's Level Up addon.
	*/
	controlId := ""
	hidden := ""
	disabled := ""

	__new(controlId, controlType := "", options := "", text := "")
	{
        global
        this.controlID := controlID
		if controlType in GroupBox
			GUIFunctions.UseThemeTextColor("HeaderTextColor", 700)
        else if controlType in ComboBox,DropDownList,Edit,ListBox
            GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        else if controlType in ListView
            GUIFunctions.UseThemeTextColor("TableTextColor")
		else
			GUIFunctions.UseThemeTextColor("DefaultTextColor")
        options .= " v" . controlID
		if (InStr(options, "Hidden"))
			this.hidden := true
		if (InStr(options, "Disabled"))
			this.disabled := true
        Gui, ICScriptHub:Add, %controlType%, %options%, % text
        if controlType in ListView
            GUIFunctions.UseThemeListViewBackgroundColor(controlID)
        GUIFunctions.UseThemeTextColor("DefaultTextColor")
	}

    Show()
    {
		if (!this.hidden)
			return
        controlId := this.controlID
        GuiControl, ICScriptHub:Show, %controlId%
        this.Hidden := false
    }

    Hide()
    {
		if (this.hidden)
			return
        controlId := this.controlID
        GuiControl, ICScriptHub:Hide, %controlId%
        this.Hidden := true
    }

	Enable()
	{
		if (!this.disabled)
			return
		controlId := this.controlId
		GuiControl, ICScriptHub:Enable, %controlId%
		this.disabled := false
	}

	Disable()
	{
		if (this.disabled)
			return
		controlId := this.controlId
		GuiControl, ICScriptHub:Disable, %controlId%
		this.disabled := true
	}

}
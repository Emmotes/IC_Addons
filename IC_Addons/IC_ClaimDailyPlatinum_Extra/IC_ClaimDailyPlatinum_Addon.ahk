#include %A_LineFile%\..\IC_ClaimDailyPlatinum_Functions.ahk
#include %A_LineFile%\..\IC_ClaimDailyPlatinum_Overrides.ahk
#include *i %A_LineFile%\..\..\..\SharedFunctions\SH_UpdateClass.ahk
SH_UpdateClass.UpdateClassFunctions(g_SharedData, IC_ClaimDailyPlatinum_SharedData_Class)

g_SharedData.CDP_UpdateSettingsFromFile()
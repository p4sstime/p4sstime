// This file relates to all convars and will contain the functions for them

Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbPlyIsDead[client] = false;
	RemoveShotty(client);
	if(TF2_GetPlayerClass(client)==TFClass_DemoMan){QueryClientConVar(client, "m_filter", FilterCheck, false);}

	return Plugin_Handled;
}

Action OnChangeClass(int client, const char[] strCommand, int args)
{
	char sChosenClass[12];
	if(arrbPlyIsDead[client] == true && bSwitchDuringRespawn.BoolValue)
	{
		GetCmdArg(1, sChosenClass, sizeof(sChosenClass));
		PrintCenterText(client, "Class when spawned will be %s.", sChosenClass);
		TFClassType class = TF2_GetClass(sChosenClass);
		if (class != TFClass_Unknown) SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", class);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (condition == TFCond_PasstimeInterception && bStealBlurryOverlay.BoolValue)
	{
		ClientCommand(client, "r_screenoverlay \"\"");
	}
	if (condition == TFCond_Charging && TF2_GetPlayerClass(client)==TFClass_DemoMan)
	{
		CreateTimer(0.1, MultiCheck, client);
	}
}

Action Event_PlayerResup(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveShotty(client);

	return Plugin_Handled;
}

Action Command_PasstimeSuicide(int client, int args)
{
	SDKHooks_TakeDamage(client, client, client, 500.0);
	ReplyToCommand(client, "[PASS] Committed suicide");
	return Plugin_Handled;
}

Action Command_PasstimeJackPickupHud(int client, int args)
{
	int value = 0;
	if(GetCmdArgIntEx(1, value))
	{
		if(value == 1)
			arrbJackAcqSettings[client].bPlyHudTextSetting = true;
		else if(value == 0)
			arrbJackAcqSettings[client].bPlyHudTextSetting = false;
		if(value == 1 || value == 0)
		{
			SetCookieBool(client, cookieJACKPickupHud, arrbJackAcqSettings[client].bPlyHudTextSetting);
			ReplyToCommand(client, "[PASS] JACK pickup HUD text: %s", arrbJackAcqSettings[client].bPlyHudTextSetting ? "ON" : "OFF");
		}
	}
	else
		ReplyToCommand(client, "[PASS] Invalid argument");
	return Plugin_Handled;
}

Action Command_PasstimeJackPickupChat(int client, int args)
{
	int value = 0;
	if(GetCmdArgIntEx(1, value))
	{
		if(value == 1)
			arrbJackAcqSettings[client].bPlyChatPrintSetting = true;
		if(value == 0)
			arrbJackAcqSettings[client].bPlyChatPrintSetting = false;
		if(value == 1 || value == 0)
		{
			SetCookieBool(client, cookieJACKPickupChat, arrbJackAcqSettings[client].bPlyChatPrintSetting);
			ReplyToCommand(client, "[PASS] JACK pickup chat text: %s", arrbJackAcqSettings[client].bPlyChatPrintSetting ? "ON" : "OFF");
		}
	}
	else
		ReplyToCommand(client, "[PASS] Invalid argument");
	return Plugin_Handled;
}

Action Command_PasstimeJackPickupSound(int client, int args)
{
	int value = 0;
	if(GetCmdArgIntEx(1, value))
	{
		if(value == 1)
			arrbJackAcqSettings[client].bPlySoundSetting = true;
		if(value == 0)
			arrbJackAcqSettings[client].bPlySoundSetting = false;
		if(value == 1 || value == 0)
		{
			SetCookieBool(client, cookieJACKPickupSound, arrbJackAcqSettings[client].bPlySoundSetting);
			ReplyToCommand(client, "[PASS] JACK pickup sound: %s", arrbJackAcqSettings[client].bPlySoundSetting ? "ON" : "OFF");
		}
	}
	else
		ReplyToCommand(client, "[PASS] Invalid argument");
	return Plugin_Handled;
}

void RemoveShotty(int client)
{
	if (bEquipStockWeapons.BoolValue)
	{
		TFClassType class = TF2_GetPlayerClass(client);
		int iWep;
		if (class == TFClass_DemoMan || class == TFClass_Soldier) iWep = GetPlayerWeaponSlot(client, 1);
		else if (class == TFClass_Medic) iWep = GetPlayerWeaponSlot(client, 0);

		if (iWep >= 0)
		{
			char classname[64];
			GetEntityClassname(iWep, classname, sizeof(classname));

			if (StrEqual(classname, "tf_weapon_shotgun_soldier") || StrEqual(classname, "tf_weapon_pipebomblauncher"))
			{
				PrintToChat(client, "\x07ff0000 [PASS] Shotgun/Stickies equipped");
				TF2_RemoveWeaponSlot(client, 1);
			}

			if (StrEqual(classname, "tf_weapon_syringegun_medic"))
			{
				PrintToChat(client, "\x07ff0000 [PASS] Syringe Gun equipped");
				TF2_RemoveWeaponSlot(client, 0);
			}
		}
	}
}
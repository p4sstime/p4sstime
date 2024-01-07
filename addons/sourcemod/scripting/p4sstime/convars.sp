// This file relates to all convars and will contain the functions for them

Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbPlyIsDead[client] = false;
	RemoveShotty(client);
	if(TF2_GetPlayerClass(client)==TFClass_DemoMan){QueryClientConVar(client, "m_filter", FilterCheck, 0);}

	return Plugin_Handled;
}

Action OnChangeClass(int client, const char[] strCommand, int args)
{
	if(arrbPlyIsDead[client] == true && bSwitchDuringRespawn.BoolValue)
	{
		PrintCenterText(client, "You can't change class yet.");
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
		QueryClientConVar(client, "m_filter", FilterCheck, 1);
	}
}

Action Event_PlayerResup(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveShotty(client);

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
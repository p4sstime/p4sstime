// This file relates to the caber regen mechanic and will contain the functions for them; taken from https://forums.alliedmods.net/showthread.php?p=2725055 and modified to work for us
Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) 
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (victim == 0 || attacker != victim || !IsClientInGame(victim) || GetEventInt(event, "custom") != TF_CUSTOM_STICKBOMB_EXPLOSION || GetConVarFloat(fCaberTimer)==0)
		return Plugin_Handled;

	tCaberRegen[victim] = CreateTimer(GetConVarFloat(fCaberTimer), Timer_RefreshStickBomb, GetClientUserId(victim));
	return Plugin_Handled;
}

KillCaberRegenTimer(client)
{
	Handle timer = tCaberRegen[client];
	if (timer != INVALID_HANDLE)
	{
		KillTimer(timer);
		tCaberRegen[client] = INVALID_HANDLE;
	}
}

Action Timer_RefreshStickBomb(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
		return Plugin_Handled;
	
	RefreshStickBomb(client);
	tCaberRegen[client] = INVALID_HANDLE;
	return Plugin_Handled;
}

RefreshStickBomb(client, bool doWeaponCheck=true)
{
	int stickbomb = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (stickbomb <= MaxClients || !IsValidEdict(stickbomb))
		return;
	
	if (doWeaponCheck)
	{
		char netclass[64];
		GetEntityNetClass(stickbomb, netclass, sizeof(netclass));
		if (!!strcmp(netclass, STICKBOMB_CLASS))
			return;
	}
	
	ClientCommand(client, "playgamesound Player.PickupWeapon");
	SetEntProp(stickbomb, Prop_Send, "m_bBroken", 0);
	SetEntProp(stickbomb, Prop_Send, "m_iDetonated", 0);
}

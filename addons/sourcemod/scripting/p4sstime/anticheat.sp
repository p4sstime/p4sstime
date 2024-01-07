// This file relates to all anticheat features and will contain the functions for them
Action TurnBindRight(int client, const char[] strCommand, int args)
{   
	if(TF2_GetPlayerClass(client)==TFClass_DemoMan) 
	{
		SetLogInfo(client);
		LogToGame("\"%N<%i><%s><%s>\" used \"+right\" as Demoman (position \"%.0f %.0f %.0f\")",
		user1, GetClientUserId(user1), user1steamid, user1team,
		user1position[0], user1position[1], user1position[2]);
	}
	return Plugin_Handled;
}

Action TurnBindLeft(int client, const char[] strCommand, int args)
{   
	if(TF2_GetPlayerClass(client)==TFClass_DemoMan) 
	{
		SetLogInfo(client);
		LogToGame("\"%N<%i><%s><%s>\" used \"+left\" as Demoman (position \"%.0f %.0f %.0f\")",
		user1, GetClientUserId(user1), user1steamid, user1team,
		user1position[0], user1position[1], user1position[2]);
	}
	return Plugin_Handled;
}

void FilterCheck(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any value)
{
	if(!StrEqual(cvarValue, "0") && !value)
	{
		SetLogInfo(client);
		LogToGame("\"%N<%i><%s><%s>\" spawned as Demoman with m_filter on",
		user1, GetClientUserId(user1), user1steamid, user1team);
	}
	else if(!StrEqual(cvarValue, "0") && value)
	{
		SetLogInfo(client);
		LogToGame("\"%N<%i><%s><%s>\" charged as Demoman with m_filter on", 
		user1, GetClientUserId(user1), user1steamid, user1team);
	}
}

Action TimedFilterCheck(Handle timer, any client)
{
	QueryClientConVar(client, "m_filter", FilterCheck, true);
	return Plugin_Handled;
}
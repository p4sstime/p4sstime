Action Command_MatchEndStatsMenu(int client, int args)
{
	if (IsValidClient(client)) mMatchEndStatsMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

Action Timer_DisplayMatchEndStatsMenu(Handle timer)
{
	for (int x = 1; x < MaxClients + 1; x++)
	{
		if (!IsValidClient(x)) continue;
		mMatchEndStatsMenu.Display(x, 30);
	}
	return Plugin_Handled;
}

public int MatchEndStatsMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action){
		case MenuAction_Display:
		{
		int selfIndex = param1;
		int redTeam[16], bluTeam[16];
		int redCursor, bluCursor = 0;
		mMatchEndStatsMenu.AddItem("SelfStats", "You");
		for (int x = 1; x < MaxClients + 1; x++)
		{
			if (!IsValidClient(x)) continue;

			if (TF2_GetClientTeam(x) == TFTeam_Red)
			{
				redTeam[redCursor] = x;
				redCursor++;
			}

			else if (TF2_GetClientTeam(x) == TFTeam_Blue) {
				bluTeam[bluCursor] = x;
				bluCursor++;
			}
		}
		for (int x = 1; x < MaxClients + 1; x++)
		{
			if (!IsValidClient(x)) continue;

			if (TF2_GetClientTeam(x) == TFTeam_Red)
			{
				for (int i = 0; i < bluCursor; i++)
				{
					char playerName[MAX_NAME_LENGTH];
				  	GetClientName(bluTeam[i], playerName, sizeof(playerName));
					mMatchEndStatsMenu
				   	PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				}

				for (int i = 0; i < redCursor; i++)
				{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(redTeam[i], playerName, sizeof(playerName));
				PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
				}
			}

			else if (TF2_GetClientTeam(x) == TFTeam_Blue || TF2_GetClientTeam(x) == TFTeam_Spectator) 
				{
					for (int i = 0; i < redCursor; i++)
					{
			   			char playerName[MAX_NAME_LENGTH];
			   			GetClientName(redTeam[i], playerName, sizeof(playerName));
						PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
					}

					for (int i = 0; i < bluCursor; i++)
					{
						char playerName[MAX_NAME_LENGTH];
						GetClientName(bluTeam[i], playerName, sizeof(playerName));
						PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
					}
				}
			}
		}
		case MenuAction_Select:
		{
		   char info[32];
		   mMatchEndStatsMenu.GetItem(param2, info, sizeof(info));
		   if(StrEqual(info, "DisplayMoreTF"))
			  ShowMOTDPanel(param1, "more.tf match statistics", moreurl);
		}
	}
	return 0;
}
Action Command_PasstimeSimpleChatPrint(int client, int args)
{
	int value = 0;
	char status[64];
	if(GetCmdArgIntEx(1, value))
	{
		if(value == 1)
			arrbJackAcqSettings[client].bPlySimpleChatPrintSetting = true;
		if(value == 0)
			arrbJackAcqSettings[client].bPlySimpleChatPrintSetting = false;
	}
	Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Simple end of round stats: %s", arrbJackAcqSettings[client].bPlySimpleChatPrintSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
	PrintToChat(client, status);
	return Plugin_Handled;
}

Action Command_PasstimeToggleChatPrint(int client, int args)
{
	int value = 0;
	char status[64];
	if(GetCmdArgIntEx(1, value))
	{
		if(value == 1)
			arrbJackAcqSettings[client].bPlyToggleChatPrintSetting = true;
		if(value == 0)
			arrbJackAcqSettings[client].bPlyToggleChatPrintSetting = false;
	}
	Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Toggle end of round chat summary: %s", arrbJackAcqSettings[client].bPlyToggleChatPrintSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
	PrintToChat(client, status);
	return Plugin_Handled;
}

Action Timer_ShowMoreTF(Handle timer, any client)
{
	if (!IsValidClient(client))
		return Plugin_Stop;
	
	char num[3];
	Handle Kv = CreateKeyValues("data");
	IntToString(MOTDPANEL_TYPE_URL, num, sizeof(num));
	KvSetString(Kv, "title", "MoreTF");
	KvSetString(Kv, "type", num);
	KvSetString(Kv, "msg", moreurl);
	KvSetNum(Kv, "customsvr", 1);
	ShowVGUIPanel(client, "info", Kv);
	CloseHandle(Kv);

	return Plugin_Stop;
}

// this is really fucking sloppy but shrug
Action Timer_DisplayStats(Handle timer)
{
	int redTeam[16], bluTeam[16];
	int redCursor, bluCursor = 0;
	
	for (int x = 1; x < MaxClients + 1; x++)
	{
		if (!IsValidClient(x)) continue;

		PrintToConsole(x, "////////////////////////////////////////////////////////////////////////");
		PrintToConsole(x, "//                                        //                          //");
		PrintToConsole(x, "//               PASS Stats               //    Plugin Version: %s    //", VERSION);
		PrintToConsole(x, "//           Thanks for playing!          //            %s            //", __DATE__);
		PrintToConsole(x, "//                                        //                          //");
		PrintToConsole(x, "////////////////////////////////////////////////////////////////////////");
		PrintToConsole(x, "//                                                                    //");

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
				if(arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B G %d,\x073bc48f A %d,\x07ffff00 SV %d,\x07ff00ff I %d,\x07ff8000 ST %d"
						, playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
						, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				else if(!arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d"
						, playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
						, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				PrintToConsole(x, "//   BLU | %N", i); // have this be red so your team shows up first?
				PrintToConsole(x, "//   %d goals, %d assists, %d saves, %d intercepts, %d steals         //", arriPlyRoundPassStats[bluTeam[i]].iPlyScores
					, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
					, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				PrintToConsole(x, "//   %d Panaceas, %d win strats, %d handoffs, %d first grabs          //", arriPlyRoundPassStats[bluTeam[i]].iPlyPanaceas
					, arriPlyRoundPassStats[bluTeam[i]].iPlyWinStrats, arriPlyRoundPassStats[bluTeam[i]].iPlyHandoffs, arriPlyRoundPassStats[bluTeam[i]].iPlyFirstGrabs);
				PrintToConsole(x, "//   %d catapults, %d blocks, %d steal2saves                          //", arriPlyRoundPassStats[bluTeam[i]].iPlyCatapults
					, arriPlyRoundPassStats[bluTeam[i]].iPlyBlocks, arriPlyRoundPassStats[bluTeam[i]].iPlySteal2Saves);
				PrintToConsole(x, "//                                                                    //");
			}

			for (int i = 0; i < redCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(redTeam[i], playerName, sizeof(playerName));
				if(arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B G %d,\x073bc48f A %d,\x07ffff00 SV %d,\x07ff00ff I %d,\x07ff8000 ST %d"
						, playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
						, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				else if(!arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d"
						, playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
						, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				PrintToConsole(x, "//   RED | %N", i);
				PrintToConsole(x, "//   %d goals, %d assists, %d saves, %d intercepts, %d steals         //", arriPlyRoundPassStats[redTeam[i]].iPlyScores
					, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves
					, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
				PrintToConsole(x, "//   %d Panaceas, %d win strats, %d handoffs, %d first grabs          //", arriPlyRoundPassStats[redTeam[i]].iPlyPanaceas
					, arriPlyRoundPassStats[redTeam[i]].iPlyWinStrats, arriPlyRoundPassStats[redTeam[i]].iPlyHandoffs, arriPlyRoundPassStats[redTeam[i]].iPlyFirstGrabs);
				PrintToConsole(x, "//   %d catapults, %d blocks, %d steal2saves                          //", arriPlyRoundPassStats[redTeam[i]].iPlyCatapults
					, arriPlyRoundPassStats[redTeam[i]].iPlyBlocks, arriPlyRoundPassStats[redTeam[i]].iPlySteal2Saves);
				PrintToConsole(x, "//                                                                    //");
			}
		}

		else if (TF2_GetClientTeam(x) == TFTeam_Blue || TF2_GetClientTeam(x) == TFTeam_Spectator) {
			for (int i = 0; i < redCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(redTeam[i], playerName, sizeof(playerName));
				if(arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B G %d,\x073bc48f A %d,\x07ffff00 SV %d,\x07ff00ff I %d,\x07ff8000 ST %d"
						, playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
						, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				else if(!arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d"
						, playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
						, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				PrintToConsole(x, "//   RED | %N", i);
				PrintToConsole(x, "//   %d goals, %d assists, %d saves, %d intercepts, %d steals         //", arriPlyRoundPassStats[redTeam[i]].iPlyScores
					, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves
					, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
				PrintToConsole(x, "//   %d Panaceas, %d win strats, %d handoffs, %d first grabs          //", arriPlyRoundPassStats[redTeam[i]].iPlyPanaceas
					, arriPlyRoundPassStats[redTeam[i]].iPlyWinStrats, arriPlyRoundPassStats[redTeam[i]].iPlyHandoffs, arriPlyRoundPassStats[redTeam[i]].iPlyFirstGrabs);
				PrintToConsole(x, "//   %d catapults, %d blocks, %d steal2saves                          //", arriPlyRoundPassStats[redTeam[i]].iPlyCatapults
					, arriPlyRoundPassStats[redTeam[i]].iPlyBlocks, arriPlyRoundPassStats[redTeam[i]].iPlySteal2Saves);
				PrintToConsole(x, "//                                                                    //");
			}

			for (int i = 0; i < bluCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(bluTeam[i], playerName, sizeof(playerName));
				if(arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B G %d,\x073bc48f A %d,\x07ffff00 SV %d,\x07ff00ff I %d,\x07ff8000 ST %d"
						, playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
						, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				else if(!arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d"
						, playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
						, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				PrintToConsole(x, "//   BLU | %N", i);
				PrintToConsole(x, "//   %d goals, %d assists, %d saves, %d intercepts, %d steals         //", arriPlyRoundPassStats[bluTeam[i]].iPlyScores
					, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves
					, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				PrintToConsole(x, "//   %d Panaceas, %d win strats, %d handoffs, %d first grabs          //", arriPlyRoundPassStats[bluTeam[i]].iPlyPanaceas
					, arriPlyRoundPassStats[bluTeam[i]].iPlyWinStrats, arriPlyRoundPassStats[bluTeam[i]].iPlyHandoffs, arriPlyRoundPassStats[bluTeam[i]].iPlyFirstGrabs);
				PrintToConsole(x, "//   %d catapults, %d blocks, %d steal2saves                          //", arriPlyRoundPassStats[bluTeam[i]].iPlyCatapults
					, arriPlyRoundPassStats[bluTeam[i]].iPlyBlocks, arriPlyRoundPassStats[bluTeam[i]].iPlySteal2Saves);
				PrintToConsole(x, "//                                                                    //");
			}
		}
	}

	// clear stats
	for (int i = 0; i < MaxClients + 1; i++)
	{
		PrintToConsole(i, "////////////////////////////////////////////////////////////////////////");
		arriPlyRoundPassStats[i].iPlyScores = 0, arriPlyRoundPassStats[i].iPlyAssists = 0, arriPlyRoundPassStats[i].iPlySaves = 0, arriPlyRoundPassStats[i].iPlyIntercepts = 0, arriPlyRoundPassStats[i].iPlySteals = 0
		, arriPlyRoundPassStats[i].iPlyPanaceas = 0, arriPlyRoundPassStats[i].iPlyWinStrats = 0, arriPlyRoundPassStats[i].iPlyHandoffs = 0, arriPlyRoundPassStats[i].iPlyFirstGrabs = 0,
		arriPlyRoundPassStats[i].iPlyCatapults = 0, arriPlyRoundPassStats[i].iPlyBlocks = 0, arriPlyRoundPassStats[i].iPlySteal2Saves = 0;
	}

	return Plugin_Stop;
}
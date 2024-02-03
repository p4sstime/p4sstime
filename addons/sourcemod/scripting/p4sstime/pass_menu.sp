// This file relates to all menu features for player-specific settings and will contain the functions for them
public OnClientCookiesCached(int client)
{
	char sValue[8];
	GetClientCookie(client, cookieJACKPickupHud, sValue, sizeof(sValue));
	arrbJackAcqSettings[client].bPlyHudTextSetting = (StringToInt(sValue) > 0);
	GetClientCookie(client, cookieJACKPickupChat, sValue, sizeof(sValue));
	arrbJackAcqSettings[client].bPlyChatPrintSetting = (StringToInt(sValue) > 0);
	GetClientCookie(client, cookieJACKPickupSound, sValue, sizeof(sValue));
	arrbJackAcqSettings[client].bPlySoundSetting	= (StringToInt(sValue) > 0);
	GetClientCookie(client, cookieSimpleChatPrint, sValue, sizeof(sValue));
	arrbJackAcqSettings[client].bPlySimpleChatPrintSetting	= (StringToInt(sValue) > 0);
	GetClientCookie(client, cookieToggleChatPrint, sValue, sizeof(sValue));
	arrbJackAcqSettings[client].bPlyToggleChatPrintSetting	= (StringToInt(sValue) > 0);
}  

Action Command_PassMenu(int client, int args)
{
	if (IsValidClient(client)) mPassMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

int PassMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char status[64];
		mPassMenu.GetItem(param2, info, sizeof(info));
		if (StrEqual(info, "jackpickuphud"))
		{
			arrbJackAcqSettings[param1].bPlyHudTextSetting = !arrbJackAcqSettings[param1].bPlyHudTextSetting;
			mPassMenu.Display(param1, MENU_TIME_FOREVER);
			if (arrbJackAcqSettings[param1].bPlyHudTextSetting) 
				SetClientCookie(param1, cookieJACKPickupHud, "1");
			else
				SetClientCookie(param1, cookieJACKPickupHud, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Hud text: %s", arrbJackAcqSettings[param1].bPlyHudTextSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
		if (StrEqual(info, "jackpickupchat"))
		{
			arrbJackAcqSettings[param1].bPlyChatPrintSetting = !arrbJackAcqSettings[param1].bPlyChatPrintSetting;
			mPassMenu.Display(param1, MENU_TIME_FOREVER);
			if (arrbJackAcqSettings[param1].bPlyChatPrintSetting) 
				SetClientCookie(param1, cookieJACKPickupChat, "1");
			else
				SetClientCookie(param1, cookieJACKPickupChat, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Chat text: %s", arrbJackAcqSettings[param1].bPlyChatPrintSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
		if (StrEqual(info, "jackpickupsound"))
		{
			arrbJackAcqSettings[param1].bPlySoundSetting = !arrbJackAcqSettings[param1].bPlySoundSetting;
			mPassMenu.Display(param1, MENU_TIME_FOREVER);
			if (arrbJackAcqSettings[param1].bPlySoundSetting) 
				SetClientCookie(param1, cookieJACKPickupSound, "1");
			else
				SetClientCookie(param1, cookieJACKPickupSound, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Sound notification: %s", arrbJackAcqSettings[param1].bPlySoundSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
		if(StrEqual(info, "simpleprint"))
		{
			arrbJackAcqSettings[param1].bPlySimpleChatPrintSetting = !arrbJackAcqSettings[param1].bPlySimpleChatPrintSetting;
			mPassMenu.Display(param1, MENU_TIME_FOREVER);
			if (arrbJackAcqSettings[param1].bPlySimpleChatPrintSetting) 
				SetClientCookie(param1, cookieSimpleChatPrint, "1");
			else
				SetClientCookie(param1, cookieSimpleChatPrint, "0");
			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Simple round summary stats: %s", arrbJackAcqSettings[param1].bPlySimpleChatPrintSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
		if(StrEqual(info, "toggleprint"))
		{
			arrbJackAcqSettings[param1].bPlyToggleChatPrintSetting = !arrbJackAcqSettings[param1].bPlyToggleChatPrintSetting;
			mPassMenu.Display(param1, MENU_TIME_FOREVER);
			if (arrbJackAcqSettings[param1].bPlyToggleChatPrintSetting) 
				SetClientCookie(param1, cookieToggleChatPrint, "1");
			else
				SetClientCookie(param1, cookieToggleChatPrint, "0");
			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Toggle round chat summary: %s", arrbJackAcqSettings[param1].bPlyToggleChatPrintSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
	}
	return 0; // just do this to get rid of warning
}
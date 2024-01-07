// This file relates to all menu features for player-specific settings and will contain the functions for them
public OnClientCookiesCached(int client)
{
	char sValue[8];
	GetClientCookie(client, cookieBallHudHud, sValue, sizeof(sValue));
	arrbJackAcqSettings[client].bPlyHudTextSetting = (StringToInt(sValue) > 0);
	GetClientCookie(client, cookieBallHudChat, sValue, sizeof(sValue));
	arrbJackAcqSettings[client].bPlyChatPrintSetting = (StringToInt(sValue) > 0);
	GetClientCookie(client, cookieBallHudSound, sValue, sizeof(sValue));
	arrbJackAcqSettings[client].bPlySoundSetting	= (StringToInt(sValue) > 0);
}  

Action Command_BallHud(int client, int args)
{
	if (IsValidClient(client)) mBallHudMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

int BallHudMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char status[64];
		mBallHudMenu.GetItem(param2, info, sizeof(info));
		if (StrEqual(info, "hudtext"))
		{
			arrbJackAcqSettings[param1].bPlyHudTextSetting = !arrbJackAcqSettings[param1].bPlyHudTextSetting;
			mBallHudMenu.Display(param1, MENU_TIME_FOREVER);
			if (arrbJackAcqSettings[param1].bPlyHudTextSetting) 
				SetClientCookie(param1, cookieBallHudHud, "1");
			else
				SetClientCookie(param1, cookieBallHudHud, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Hud text: %s", arrbJackAcqSettings[param1].bPlyHudTextSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
		if (StrEqual(info, "chattext"))
		{
			arrbJackAcqSettings[param1].bPlyChatPrintSetting = !arrbJackAcqSettings[param1].bPlyChatPrintSetting;
			mBallHudMenu.Display(param1, MENU_TIME_FOREVER);
			if (arrbJackAcqSettings[param1].bPlyChatPrintSetting) 
				SetClientCookie(param1, cookieBallHudChat, "1");
			else
				SetClientCookie(param1, cookieBallHudChat, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Chat text: %s", arrbJackAcqSettings[param1].bPlyChatPrintSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
		if (StrEqual(info, "sound"))
		{
			arrbJackAcqSettings[param1].bPlySoundSetting = !arrbJackAcqSettings[param1].bPlySoundSetting;
			mBallHudMenu.Display(param1, MENU_TIME_FOREVER);
			if (arrbJackAcqSettings[param1].bPlySoundSetting) 
				SetClientCookie(param1, cookieBallHudSound, "1");
			else
				SetClientCookie(param1, cookieBallHudSound, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Sound notification: %s", arrbJackAcqSettings[param1].bPlySoundSetting ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
	}
	return 0; // just do this to get rid of warning
}
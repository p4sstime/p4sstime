#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <sdktools>
#include <dhooks>
#include <clientprefs>

#include "passtime-fixes/dhooks.sp"

#pragma semicolon 1	   // required for logs.tf

enum struct BallHudSettings
{
	bool hudText;
	bool chat;
	bool sound;
}

enum struct Statistics
{
	int scores;
	int assists;
	int saves;
	int interceptions;
	int steals;
}

BallHudSettings playerBallHudSettings[MAXPLAYERS + 1];
Statistics		playerStatistics[MAXPLAYERS + 1];

float			bluGoal[3], redGoal[3];

ConVar			stockEnable, respawnEnable, clearHud, collisionDisable, statsEnable, statsDelay, saveRadius, trikzEnable, trikzProjCollide, practiceMode, trikzProjDev;

int				plyGrab;
int				plyDirecter;
int				firstGrab;
int  			ball;
int  			handoffCheck;
int  			trikzProjCollideCurVal;
int  			trikzProjCollideSave = 2;
Menu			ballHudMenu;
bool			deadPlayers[MAXPLAYERS + 1];
bool			inAir;
bool			panaceaCheck = false;
bool			plyTakenDirectHit[MAXPLAYERS + 1];
Handle  		g_ballhudHud = INVALID_HANDLE;
Handle  		g_ballhudChat = INVALID_HANDLE;
Handle  		g_ballhudSound = INVALID_HANDLE;

public Plugin myinfo =
{
	name		= "Passtime Fixes",
	author		= "czarchasm, Dr. Underscore (James), EasyE",
	description = "A mashup of fixes and features for Competitive 4v4 PASS Time.",
	version		= "1.4.0",
	url			= "https://github.com/czarchasm00/passtime-fixes"
};

public void OnPluginStart()
{
	GameData gamedata = new GameData("passtime-fixes");
	if (gamedata)
	{
		DHooks_Initialize(gamedata);
		delete gamedata;
	}

	g_ballhudHud = RegClientCookie("ballhudHudSetting", "Passtime Fixes' sm_ballhud HUD Setting Value", CookieAccess_Public);
	g_ballhudChat = RegClientCookie("ballhudChatSetting", "Passtime Fixes' sm_ballhud Chat Setting Value", CookieAccess_Public);
	g_ballhudSound = RegClientCookie("ballhudSoundSetting", "Passtime Fixes' sm_ballhud Sounds Setting Value", CookieAccess_Public);

	RegConsoleCmd("sm_ballhud", Command_BallHud);

	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("post_inventory_application", Event_PlayerResup, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("pass_get", Event_PassGet, EventHookMode_Post);
	HookEvent("pass_free", Event_PassFree, EventHookMode_Post);
	HookEvent("pass_ball_stolen", Event_PassStolen, EventHookMode_Post);
	HookEvent("pass_score", Event_PassScorePre, EventHookMode_Pre);
	HookEvent("pass_score", Event_PassScorePost, EventHookMode_Post);
	HookEvent("pass_pass_caught", Event_PassCaughtPre, EventHookMode_Pre);
	HookEvent("pass_pass_caught", Event_PassCaughtPost, EventHookMode_Post);
	HookEvent("rocket_jump", Event_RJ, EventHookMode_Post);
	HookEvent("rocket_jump_landed", Event_RJLand, EventHookMode_Post);
	HookEvent("sticky_jump", Event_SJ, EventHookMode_Post);
	HookEvent("sticky_jump_landed", Event_SJLand, EventHookMode_Post);
	HookEvent("teamplay_round_win", Event_TeamWin, EventHookMode_Post);
	HookEntityOutput("trigger_catapult", "OnCatapulted", Hook_OnCatapult);
	HookEntityOutput("info_passtime_ball_spawn", "OnSpawnBall", Hook_OnSpawnBall);
	AddCommandListener(OnChangeClass, "joinclass");

	stockEnable		 = CreateConVar("sm_pt_whitelist", "0", "Toggles ability to equip shotgun, stickies, and needles; this is needed as whitelists can't normally block stock weapons", FCVAR_NOTIFY);
	respawnEnable	 = CreateConVar("sm_pt_respawn", "0", "Toggles class switch ability while dead to instantly respawn", FCVAR_NOTIFY);
	clearHud		 = CreateConVar("sm_pt_hud", "1", "Toggles the blurry screen overlay after intercepting or stealing", FCVAR_NOTIFY);
	collisionDisable = CreateConVar("sm_pt_collision_disable", "1", "Toggles whether the jack will collide with dropped ammo packs or weapons", FCVAR_NOTIFY);
	statsEnable		 = CreateConVar("sm_pt_stats", "0", "Toggles printing of passtime events to chat both during and after games; automatically set to 1 if a map name starts with 'pa'; does not stop logging", FCVAR_NOTIFY);
	statsDelay		 = CreateConVar("sm_pt_stats_delay", "7.5", "Set the delay between round end and the stats being displayed in chat", FCVAR_NOTIFY);
	saveRadius		 = CreateConVar("sm_pt_stats_save_radius", "200", "Set the radius in hammer units from the goal that an intercept is considered a save", FCVAR_NOTIFY);
	trikzEnable		 = CreateConVar("sm_pt_trikz", "0", "Set 'trikz' mode. 1 adds friendly knockback for airshots, 2 adds friendly knockback for splash damage, 3 adds friendly knockback for everywhere", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	trikzProjCollide = CreateConVar("sm_pt_trikz_projcollide", "2", "Manually set team projectile collision behavior when trikz is on. 2 always collides, 1 will cause your projectiles to phase through if you are too close (default game behavior), 0 will cause them to never collide.", 0, true, 0.0, true, 2.0);
	practiceMode	 = CreateConVar("sm_pt_practice", "0", "Toggle practice mode. When the round timer reaches 5 minutes, add 5 minutes to the timer.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	trikzProjDev = CreateConVar("sm_pt_trikz_projcollide_dev", "0", "DONOTUSE; This command is used solely by the plugin to change values. Changing this manually may cause issues.", FCVAR_HIDDEN, true, 0.0, true, 2.0);

	HookConVarChange(trikzEnable, Hook_OnTrikzChange);
	HookConVarChange(trikzProjCollide, Hook_OnProjCollideChange);
	HookConVarChange(trikzProjDev, Hook_OnProjCollideDev);
	HookConVarChange(practiceMode, Hook_OnPracticeModeChange);

	ballHudMenu = new Menu(BallHudMenuHandler);
	ballHudMenu.SetTitle("Jack Notifications");
	ballHudMenu.AddItem("hudtext", "Toggle HUD notification");
	ballHudMenu.AddItem("chattext", "Toggle chat notification");
	ballHudMenu.AddItem("sound", "Toggle sound notification");

	char mapPrefix[3];
	GetCurrentMap(mapPrefix, sizeof(mapPrefix));
	statsEnable.BoolValue = StrEqual("pa", mapPrefix);

	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			OnClientPutInServer(client);
		}
	}
	for (new i = MaxClients; i > 0; --i)
	{
		if (!AreClientCookiesCached(i))
		{
			continue;
		}
		OnClientCookiesCached(i);
	}
}

public void OnMapStart() // getgoallocations
{
	int goal1 = FindEntityByClassname(-1, "func_passtime_goal");
	int goal2 = FindEntityByClassname(goal1, "func_passtime_goal");
	int team1 = GetEntProp(goal1, Prop_Send, "m_iTeamNum");
	if (team1 == 2)
	{
		GetEntPropVector(goal1, Prop_Send, "m_vecOrigin", bluGoal);
		GetEntPropVector(goal2, Prop_Send, "m_vecOrigin", redGoal);
	}
	else {
		GetEntPropVector(goal2, Prop_Send, "m_vecOrigin", bluGoal);
		GetEntPropVector(goal1, Prop_Send, "m_vecOrigin", redGoal);
	}
}

public bool IsValidClient(int client)
{
	if (client > 4096) client = EntRefToEntIndex(client);
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (IsFakeClient(client)) return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	return true;
}

/*
https://sourcemod.dev/#/sdkhooks/typeset.SDKHookCB for parameters

OnTakeDamage -> When a player is damaged, you can change parameters here like modifying damage
OnTakeDamagePost -> After a player has been damaged, cannot change parameters
OnTakeDamageAlive -> After player has been damaged, but before damage bonuses e.g. crits are applied, can also change parameters here
OnTakeDamageAlivePost -> After player has been damaged, period. Cannot change parameters here
*/
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, Event_OnTakeDamage);
}

// following classnames are taken from here: https://developer.valvesoftware.com/w/index.php?title=Category:Point_Entities&pagefrom=Prop+glass+futbol#mw-pages
public void OnEntityCreated(int entity, const char[] classname)
{
	DHooks_OnEntityCreated(entity, classname);
	if (StrEqual(classname, "tf_projectile_rocket") || StrEqual(classname, "tf_projectile_pipe"))
		SDKHook(entity, SDKHook_Touch, OnProjectileTouch);
}

public void OnProjectileTouch(int entity, int other) // direct hit detector, taken from MGEMod
{
	plyDirecter = other;
	if (other > 0 && other <= MaxClients)
	{
		plyTakenDirectHit[plyDirecter] = true;
	}
}

public void Hook_OnProjCollideChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (newValue[0] == '0')
		trikzProjCollideSave = 0;
	if (newValue[0] == '1')
		trikzProjCollideSave = 1;
	if (newValue[0] == '2')
		trikzProjCollideSave = 2;
}

public void Hook_OnProjCollideDev(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(FindConVar("sm_projectiles_ignore_teammates") != null) 
		SetConVarInt(FindConVar("sm_projectiles_ignore_teammates"), 0);
	if (newValue[0] == '0')
		trikzProjCollideCurVal = 0;
	if (newValue[0] == '1')
		trikzProjCollideCurVal = 1;
	if (newValue[0] == '2')
		trikzProjCollideCurVal = 2;
}

public int ProjCollideValue()
{
	return trikzProjCollideCurVal;
}

public void Hook_OnTrikzChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (newValue[0] == '0')
		SetConVarInt(FindConVar("mp_friendlyfire"), 0);
	if (newValue[0] == '1' || newValue[0] == '2' || newValue[0] == '3')
		SetConVarInt(FindConVar("mp_friendlyfire"), 1);
}

public OnClientCookiesCached(int client)
{
	char sValue[8];
	GetClientCookie(client, g_ballhudHud, sValue, sizeof(sValue));
	playerBallHudSettings[client].hudText = (StringToInt(sValue) > 0);
	GetClientCookie(client, g_ballhudChat, sValue, sizeof(sValue));
	playerBallHudSettings[client].chat = (StringToInt(sValue) > 0);
	GetClientCookie(client, g_ballhudSound, sValue, sizeof(sValue));
	playerBallHudSettings[client].sound	= (StringToInt(sValue) > 0);
}  

public Action Command_BallHud(int client, int args)
{
	if (IsValidClient(client)) ballHudMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int BallHudMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char status[64];
		ballHudMenu.GetItem(param2, info, sizeof(info));
		if (StrEqual(info, "hudtext"))
		{
			playerBallHudSettings[param1].hudText = !playerBallHudSettings[param1].hudText;
			ballHudMenu.Display(param1, MENU_TIME_FOREVER);
			if (playerBallHudSettings[param1].hudText) 
				SetClientCookie(param1, g_ballhudHud, "1");
			else
				SetClientCookie(param1, g_ballhudHud, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Hud text: %s", playerBallHudSettings[param1].hudText ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
		if (StrEqual(info, "chattext"))
		{
			playerBallHudSettings[param1].chat = !playerBallHudSettings[param1].chat;
			ballHudMenu.Display(param1, MENU_TIME_FOREVER);
			if (playerBallHudSettings[param1].chat) 
				SetClientCookie(param1, g_ballhudChat, "1");
			else
				SetClientCookie(param1, g_ballhudChat, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Chat text: %s", playerBallHudSettings[param1].chat ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
		if (StrEqual(info, "sound"))
		{
			playerBallHudSettings[param1].sound = !playerBallHudSettings[param1].sound;
			ballHudMenu.Display(param1, MENU_TIME_FOREVER);
			if (playerBallHudSettings[param1].sound) 
				SetClientCookie(param1, g_ballhudSound, "1");
			else
				SetClientCookie(param1, g_ballhudSound, "0");

			Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Sound notification: %s", playerBallHudSettings[param1].sound ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
			PrintToChat(param1, status);
		}
	}
	return 0; // just do this to get rid of warning
}

/*-------------------------------------------------- Player Events --------------------------------------------------*/
public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	deadPlayers[client] = false;
	RemoveShotty(client);

	return Plugin_Handled;
}

public Action Event_PlayerResup(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveShotty(client);

	return Plugin_Handled;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask) // taken from mgemod; just going to use this instead of isvalidclient for the below function
{
	return entity > MaxClients || !entity;
}

public float DistanceAboveGround(int victim) // taken from mgemod
{
	float vStart[3];
	float vEnd[3];
	float vAngles[3] =  { 90.0, 0.0, 0.0 };
	GetClientAbsOrigin(victim, vStart);
	Handle trace = TR_TraceRayFilterEx(vStart, vAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceEntityFilterPlayer);

	float distance = -1.0;
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vEnd, trace);
		distance = GetVectorDistance(vStart, vEnd, false);
	} else {
		LogError("trace error. victim %N(%d)", victim, victim);
	}

	delete trace;
	return distance;
}

public Action Event_RJ(Event event, const char[] name, bool dontBroadcast)
{
	inAir = true;
	return Plugin_Handled;
}

public Action Event_RJLand(Event event, const char[] name, bool dontBroadcast)
{
	inAir = false;
	return Plugin_Handled;
}

public Action Event_SJ(Event event, const char[] name, bool dontBroadcast)
{
	inAir = true;
	return Plugin_Handled;
}

public Action Event_SJLand(Event event, const char[] name, bool dontBroadcast)
{
	inAir = false;
	return Plugin_Handled;
}

public Action OnChangeClass(int client, const char[] strCommand, int args)
{
	if(deadPlayers[client] == true && respawnEnable.BoolValue)
	{
		PrintCenterText(client, "You can't change class yet.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Event_OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	char victimName[MAX_NAME_LENGTH], attackerName[MAX_NAME_LENGTH];
	char steamid_victim[16];
	char team_victim[12];
	GetClientName(victim, victimName, sizeof(victimName));
	GetClientAuthId(victim, AuthId_Steam3, steamid_victim, sizeof(steamid_victim));
	if (victim != attacker && !(GetEntityFlags(victim) & FL_ONGROUND) && DistanceAboveGround(victim) > 200 && plyTakenDirectHit[victim] && GetEntProp(victim, Prop_Send, "m_bHasPasstimeBall") == 1 && TF2_GetClientTeam(victim) != TF2_GetClientTeam(attacker))
	{
		char steamid_attacker[16];
		char team_attacker[12];
		GetClientName(attacker, attackerName, sizeof(attackerName));
		GetClientAuthId(attacker, AuthId_Steam3, steamid_attacker, sizeof(steamid_attacker));
		if (statsEnable.BoolValue)
			PrintToChatAll("\x0700ffff[PASS] %s \x07ffff00airshot \x0700ffffball carrier %s!", attackerName, victimName);
		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_carrier_airshot\" against \"%N<%i><%s><%s>\"", attacker, GetClientUserId(attacker), steamid_attacker, team_attacker, victim, GetClientUserId(victim), steamid_victim, team_victim);
	}
	if (trikzEnable.IntValue == 0 || attacker <= 0 || !IsClientInGame(attacker) || !IsValidClient(victim)) // should not damage
	{
		SetConVarInt(trikzProjDev, 0); // reset
		return Plugin_Continue;	// end function early if attacker or victim is not legit player in game
	}
	if (trikzEnable.IntValue == 1 && TF2_GetClientTeam(victim) == TF2_GetClientTeam(attacker) && victim != attacker && !(GetEntityFlags(victim) & FL_ONGROUND) && plyTakenDirectHit[victim])
	{
		SetConVarInt(trikzProjDev, trikzProjCollideSave);
		TF2_AddCondition(victim, TFCond_PasstimeInterception, 0.05 , 0);
		if (DistanceAboveGround(victim) > 200)
		{
			char steamid_attacker[16];
			char team_attacker[12];
			GetClientName(attacker, attackerName, sizeof(attackerName));
			GetClientAuthId(attacker, AuthId_Steam3, steamid_attacker, sizeof(steamid_attacker));
			if (statsEnable.BoolValue)
				PrintToChatAll("\x0700ffff[PASS] %s \x07ffff00airshot \x0700ffff%s!", attackerName, victimName);
			LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_friendly_airshot\" against \"%N<%i><%s><%s>\"", attacker, GetClientUserId(attacker), steamid_attacker, team_attacker, victim, GetClientUserId(victim), steamid_victim, team_victim);
		}
		plyTakenDirectHit[victim] = false;
		return Plugin_Changed;
	}
	else if (trikzEnable.IntValue == 1 && TF2_GetClientTeam(victim) == TF2_GetClientTeam(attacker) && victim != attacker) // should not damage
	{
		SetConVarInt(trikzProjDev, 0); // never collide
		damage = 0.0;
		return Plugin_Changed;
	}
	if (trikzEnable.IntValue == 2 && TF2_GetClientTeam(victim) == TF2_GetClientTeam(attacker) && victim != attacker && !(GetEntityFlags(victim) & FL_ONGROUND))
	{
		SetConVarInt(trikzProjDev, trikzProjCollideSave);
		TF2_AddCondition(victim, TFCond_PasstimeInterception, 0.05 , 0);
		return Plugin_Changed;
	}
	else if (trikzEnable.IntValue == 2 && TF2_GetClientTeam(victim) == TF2_GetClientTeam(attacker) && victim != attacker) // should not damage
	{	
		SetConVarInt(trikzProjDev, 0); // never collide
		damage = 0.0;
		return Plugin_Changed;
	}
	if (trikzEnable.IntValue == 3 && TF2_GetClientTeam(victim) == TF2_GetClientTeam(attacker) && victim != attacker)
	{
		SetConVarInt(trikzProjDev, trikzProjCollideSave);
		TF2_AddCondition(victim, TFCond_PasstimeInterception, 0.05 , 0);
		return Plugin_Changed;
	}
	return Plugin_Continue;	
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (condition == TFCond_PasstimeInterception && clearHud.BoolValue)
	{
		ClientCommand(client, "r_screenoverlay \"\"");
	}
}

// the below function is dr underscore's fix. thanks!
public TF2_OnConditionRemoved(client, TFCond condition)
{
	if (condition == TFCond_Ubercharged)
		TF2_RemoveCondition(client, TFCond_UberchargeFading);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	deadPlayers[client] = true;

	return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
	deadPlayers[client] = false;

	playerStatistics[client].scores		   = 0;
	playerStatistics[client].assists	   = 0;
	playerStatistics[client].saves		   = 0;
	playerStatistics[client].interceptions = 0;
	playerStatistics[client].steals		   = 0;
}

/*-------------------------------------------------- PASS Events --------------------------------------------------*/
public void Hook_OnSpawnBall(const char[] name, int caller, int activator, float delay)
{
	ball = FindEntityByClassname(-1, "passtime_ball");
	if (collisionDisable.BoolValue) SetEntityCollisionGroup(ball, 4);
	firstGrab = 1;
}

public Action Event_PassFree(Event event, const char[] name, bool dontBroadcast)
{
	int owner = event.GetInt("owner");
	if (playerBallHudSettings[owner].hudText)
	{
		SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
		ShowHudText(owner, 1, "");
	}

	return Plugin_Handled;
}

public Action Event_PassGet(Event event, const char[] name, bool dontBroadcast) // passget prehook occurs AFTER ball throw
{
	plyGrab = event.GetInt("owner");

	// log formatting
	char steamid[16];
	char team[12];

	GetClientAuthId(plyGrab, AuthId_Steam3, steamid, sizeof(steamid));

	if (GetClientTeam(plyGrab) == 2)
	{
		team = "Red";
	}
	else if (GetClientTeam(plyGrab) == 3) {
		team = "Blue";
	}
	else {	  // players shouldn't ever be able to grab the ball in spec but if they get manually spawned, maybe...
		team = "Spectator";
	}
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_get\" (firstcontact \"%i\")", plyGrab, GetClientUserId(plyGrab), steamid, team, firstGrab);
		// ex: "TOMATO TERROR<19><[U:1:160108865]><Blue>" triggered "pass_get" (firstcontact "0")
	if (firstGrab == 1 && inAir)
	{
		panaceaCheck = true;
	}
	else
	{
		panaceaCheck = false;
	}
	firstGrab = 0;

	if (playerBallHudSettings[plyGrab].hudText)
	{
		SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
		ShowHudText(plyGrab, 1, "YOU HAVE THE JACK");
	}

	if (playerBallHudSettings[plyGrab].chat)
	{
		PrintToChat(plyGrab, "\x07ffff00[PASS]\x0700ff00 YOU HAVE THE JACK!!!");
	}

	if (playerBallHudSettings[plyGrab].sound)
	{
		ClientCommand(plyGrab, "playgamesound Passtime.BallSmack");
	}

	if (GetEntityFlags(plyGrab) & FL_ONGROUND != FL_ONGROUND)
	{ 
		inAir = true;
	}

	return Plugin_Handled;
}

public Action Event_PassCaughtPre(Handle event, const char[] name, bool dontBroadcast)
{
	int	thrower	= GetEventInt(event, "passer");
	int	catcher	= GetEventInt(event, "catcher");
	char throwerName[MAX_NAME_LENGTH], catcherName[MAX_NAME_LENGTH];
	GetClientName(thrower, throwerName, sizeof(throwerName));
	GetClientName(catcher, catcherName, sizeof(catcherName));
	if (TF2_GetClientTeam(thrower) == TFTeam_Spectator || TF2_GetClientTeam(catcher) == TFTeam_Spectator) return Plugin_Stop;
	int passTarget = GetEntProp(catcher, Prop_Send, "m_bIsTargetedForPasstimePass");
	if (TF2_GetClientTeam(thrower) == TF2_GetClientTeam(catcher) && passTarget == 0 && !(GetEntityFlags(catcher) & FL_ONGROUND) && DistanceAboveGround(catcher) > 200) // if on same team and catcher is not locked onto for a pass, also 200 units above ground at least (to ignore just normal non-lock passes)
	{
		if (statsEnable.BoolValue)
			PrintToChatAll("\x0700ffff[PASS] %s \x07ffff00handed off \x0700ffffto %s!", throwerName, catcherName);
		handoffCheck = 1;
	}
	return Plugin_Continue;
}

public Action Event_PassCaughtPost(Handle event, const char[] name, bool dontBroadcast)
{
	int	thrower	= GetEventInt(event, "passer");
	int	catcher	= GetEventInt(event, "catcher");
	float dist = GetEventFloat(event, "dist");
	float duration = GetEventFloat(event, "duration");
	int intercept = true;
	plyGrab = catcher;

	if (TF2_GetClientTeam(thrower) == TFTeam_Spectator || TF2_GetClientTeam(catcher) == TFTeam_Spectator) return Plugin_Handled;

	if (GetClientTeam(thrower) == GetClientTeam(catcher))
	{
		intercept = false;
	}

	// log formatting
	char steamid_thrower[16];
	char steamid_catcher[16];
	char team_thrower[12];
	char team_catcher[12];
	char throwerName[MAX_NAME_LENGTH], catcherName[MAX_NAME_LENGTH];

	GetClientName(thrower, throwerName, sizeof(throwerName));
	GetClientName(catcher, catcherName, sizeof(catcherName));
	GetClientAuthId(thrower, AuthId_Steam3, steamid_thrower, sizeof(steamid_thrower));
	GetClientAuthId(catcher, AuthId_Steam3, steamid_catcher, sizeof(steamid_catcher));

	if (GetClientTeam(thrower) == 2)
	{
		team_thrower = "Red";
	}
	else if (GetClientTeam(thrower) == 3) {
		team_thrower = "Blue";
	}
	else {
		team_thrower = "Spectator";
	}

	if (GetClientTeam(catcher) == 2)
	{
		team_catcher = "Red";
	}
	else if (GetClientTeam(catcher) == 3) {
		team_catcher = "Blue";
	}
	else {	  // if a player throws the ball then goes spec they can trigger this event as a spectator
		team_catcher = "Spectator";
	}
	
	if (InGoalieZone(catcher) && statsEnable.BoolValue)
	{
		PrintToChatAll("\x0700ffff[PASS] %s \x07ffff00blocked \x0700ffff%s from scoring!", catcherName, throwerName);
		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_pass_caught\" against \"%N<%i><%s><%s>\" (save \"1\") (dist \"%.3f\") (duration \"%.3f\")", catcher, GetClientUserId(catcher), steamid_catcher, team_catcher, thrower, GetClientUserId(thrower), steamid_thrower, team_thrower, dist, duration); // only do this for logs.tf; no need to put a variable on saves cuz if this if statement prints its always a save
		playerStatistics[catcher].saves++;
	}
	else if (statsEnable.BoolValue) 
	{
		if (intercept)
			PrintToChatAll("\x0700ffff[PASS] %s \x07ff00ffintercepted \x0700ffff%s!", catcherName, throwerName);
		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_pass_caught\" against \"%N<%i><%s><%s>\" (interception \"%i\") (handoff \"%i\") (dist \"%.3f\") (duration \"%.3f\")", catcher, GetClientUserId(catcher), steamid_catcher, team_catcher, thrower, GetClientUserId(thrower), steamid_thrower, team_thrower, intercept, handoffCheck, dist, duration);
		playerStatistics[catcher].interceptions++;
	}
	panaceaCheck = false;

	return Plugin_Handled;
}

public Action Event_PassStolen(Event event, const char[] name, bool dontBroadcast)
{
	int victim = event.GetInt("victim");
	int thief  = event.GetInt("attacker");
	plyGrab = thief;

	// log formatting
	char steamid_thief[16];
	char steamid_victim[16];
	char team_thief[12];
	char team_victim[12];

	GetClientAuthId(thief, AuthId_Steam3, steamid_thief, sizeof(steamid_thief));
	GetClientAuthId(victim, AuthId_Steam3, steamid_victim, sizeof(steamid_victim));

	if (GetClientTeam(thief) == 2)
	{
		team_thief = "Red";
	}
	else if (GetClientTeam(thief) == 3) {
		team_thief = "Blue";
	}
	else {
		team_thief = "Spectator";
	}

	if (GetClientTeam(victim) == 2)
	{
		team_victim = "Red";
	}
	else if (GetClientTeam(victim) == 3) {
		team_victim = "Blue";
	}
	else {
		team_victim = "Spectator";
	}

	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_ball_stolen\" against \"%N<%i><%s><%s>\"", thief, GetClientUserId(thief), steamid_thief, team_thief, victim, GetClientUserId(victim), steamid_victim, team_victim);
	panaceaCheck = false;

	if (playerBallHudSettings[victim].hudText)
	{
		SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
		ShowHudText(victim, 1, "");
	}
	if (statsEnable.BoolValue)
	{
		char thiefName[MAX_NAME_LENGTH], victimName[MAX_NAME_LENGTH];
		GetClientName(thief, thiefName, sizeof(thiefName));
		GetClientName(victim, victimName, sizeof(victimName));
		PrintToChatAll("\x0700ffff[PASS] %s\x07ff8000 stole from\x0700ffff %s!", thiefName, victimName);
		playerStatistics[thief].steals++;
	}
	return Plugin_Handled;
}

public Action Event_PassScorePre(Event event, const char[] name, bool dontBroadcast)
{
	int	 scorer	  = event.GetInt("scorer");
	int	 points	  = event.GetInt("points");
	int	 assistor = event.GetInt("assister");

	// log formatting
	char steamid_scorer[16];
	char team_scorer[12];

	GetClientAuthId(scorer, AuthId_Steam3, steamid_scorer, sizeof(steamid_scorer));

	if (GetClientTeam(scorer) == 2)
	{
		team_scorer = "Red";
	}
	else if (GetClientTeam(scorer) == 3) {
		team_scorer = "Blue";
	}
	else {
		team_scorer = "Spectator";
	}

	if(TF2_GetPlayerClass(scorer) == TFClass_Medic){
		panaceaCheck = false;
	}

	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_score\" (points \"%i\") (panacea \"%d\")", scorer, GetClientUserId(scorer), steamid_scorer, team_scorer, points, panaceaCheck);

	if (assistor > 0)
	{
		char steamid_assistor[16];
		char team_assistor[12];

		GetClientAuthId(assistor, AuthId_Steam3, steamid_assistor, sizeof(steamid_assistor));

		if (GetClientTeam(assistor) == 2)
		{
			team_assistor = "Red";
		}
		else if (GetClientTeam(assistor) == 3) {
			team_assistor = "Blue";
		}
		else {
			team_assistor = "Spectator";
		}

		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_score_assist\"", assistor, GetClientUserId(assistor), steamid_assistor, team_assistor);
		playerStatistics[assistor].assists++;

	}
	return Plugin_Continue;
}

public Action Event_PassScorePost(Event event, const char[] name, bool dontBroadcast)
{
	if (!statsEnable.BoolValue) return Plugin_Handled;

	int client = event.GetInt("scorer");
	int	assistor = event.GetInt("assister");
	if (!IsValidClient(client)) return Plugin_Handled;
	char playerName[MAX_NAME_LENGTH], assistorName[MAX_NAME_LENGTH];
	GetClientName(client, playerName, sizeof(playerName));
	if (GetEntityFlags(client) & FL_ONGROUND == FL_ONGROUND)
	{ 
		inAir = false;
	}
	if (panaceaCheck && TF2_GetPlayerClass(client) != TFClass_Medic && statsEnable.BoolValue)
	{
		PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a \x074df74dPanacea!", playerName);
	}
	else if (assistor > 0 && statsEnable.BoolValue)
	{
		GetClientName(assistor, assistorName, sizeof(assistorName));
		PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a goal \x0700ffffassisted by %s!", playerName, assistorName);
	}
	else if(statsEnable.BoolValue)
	{
		PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a goal!", playerName);
	}
	playerStatistics[client].scores++;

	return Plugin_Handled;
}

public bool InGoalieZone(int client)
{
	int	  team = GetClientTeam(client);
	float position[3];
	GetClientAbsOrigin(client, position);

	if (team == view_as<int>(TFTeam_Blue))
	{
		float distance = GetVectorDistance(position, bluGoal, false);
		if (distance < saveRadius.FloatValue) return true;
	}

	if (team == view_as<int>(TFTeam_Red))
	{
		float distance = GetVectorDistance(position, redGoal, false);
		if (distance < saveRadius.FloatValue) return true;
	}
	return false;
}

public void Hook_OnCatapult(const char[] output, int caller, int activator, float delay)
{
	char steamid[16];
	char team[12];
	char plyName[MAX_NAME_LENGTH];
	if(activator == ball && firstGrab == 0 && IsClientConnected(plyGrab))
	{
		GetClientName(plyGrab, plyName, sizeof(plyName));
		GetClientAuthId(plyGrab, AuthId_Steam3, steamid, sizeof(steamid));

		if (GetClientTeam(plyGrab) == 2)
		{
			team = "Red";
		}
		else if (GetClientTeam(plyGrab) == 3) 
		{
			team = "Blue";
		}
		else // players shouldn't ever be able to grab the ball in spec but if they get manually spawned, maybe...
		{	  
			team = "Spectator";
		}
		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_trigger_catapult\" with the jack (catapult \"1\")", plyGrab, GetClientUserId(plyGrab), steamid, team);
		if (statsEnable.BoolValue)
			PrintToChatAll("\x0700ffff[PASS] %s \x07ff3434catapulted \x0700ffffthe jack!", plyName);
	}
}

/*-------------------------------------------------- Game Events --------------------------------------------------*/
public void Hook_OnPracticeModeChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (practiceMode.BoolValue)
	{
		int entityTimer = FindEntityByClassname(-1, "team_round_timer");
		SetVariantInt(300);
		AcceptEntityInput(entityTimer, "AddTime");
		CreateTimer(300.0, AddFiveMinutes, TIMER_REPEAT); // 5 minutes
	}
}

Action AddFiveMinutes(Handle timer)
{
	if (practiceMode.BoolValue)
	{
		int entityTimer = FindEntityByClassname(-1, "team_round_timer");
		SetVariantInt(300);
		AcceptEntityInput(entityTimer, "AddTime");
		return Plugin_Continue;
	}
	else return Plugin_Stop;
}

public Action Event_TeamWin(Event event, const char[] name, bool dontBroadcast)
{
	if (!statsEnable.BoolValue) return Plugin_Handled;
	CreateTimer(statsDelay.FloatValue, Timer_DisplayStats);
	return Plugin_Handled;
}

// this is really fucking sloppy but shrug
public Action Timer_DisplayStats(Handle timer)
{
	int redTeam[16], bluTeam[16];
	int redCursor, bluCursor = 0;
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
				PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, playerStatistics[bluTeam[i]].scores, playerStatistics[bluTeam[i]].assists, playerStatistics[bluTeam[i]].saves, playerStatistics[bluTeam[i]].interceptions, playerStatistics[bluTeam[i]].steals);
			}

			for (int i = 0; i < redCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(redTeam[i], playerName, sizeof(playerName));
				PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, playerStatistics[redTeam[i]].scores, playerStatistics[redTeam[i]].assists, playerStatistics[redTeam[i]].saves, playerStatistics[redTeam[i]].interceptions, playerStatistics[redTeam[i]].steals);
			}
		}

		else if (TF2_GetClientTeam(x) == TFTeam_Blue || TF2_GetClientTeam(x) == TFTeam_Spectator) {
			for (int i = 0; i < redCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(redTeam[i], playerName, sizeof(playerName));
				PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, playerStatistics[redTeam[i]].scores, playerStatistics[redTeam[i]].assists, playerStatistics[redTeam[i]].saves, playerStatistics[redTeam[i]].interceptions, playerStatistics[redTeam[i]].steals);
			}

			for (int i = 0; i < bluCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(bluTeam[i], playerName, sizeof(playerName));
				PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, playerStatistics[bluTeam[i]].scores, playerStatistics[bluTeam[i]].assists, playerStatistics[bluTeam[i]].saves, playerStatistics[bluTeam[i]].interceptions, playerStatistics[bluTeam[i]].steals);
			}
		}
	}

	// clear stats
	for (int i = 0; i < MaxClients + 1; i++)
	{
		playerStatistics[i].scores = 0, playerStatistics[i].assists = 0, playerStatistics[i].saves = 0, playerStatistics[i].interceptions = 0, playerStatistics[i].steals = 0;
	}

	return Plugin_Stop;
}

public void RemoveShotty(int client)
{
	if (stockEnable.BoolValue)
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


/*
some data that will be useful later
https://lmaobox.net/lua/TF2_props/

*/
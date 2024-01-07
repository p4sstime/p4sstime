#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <sdktools>
//#include <dhooks>
#include <clientprefs>

//#include "p4sstime-fixes/dhooks.sp"

#pragma semicolon 1	   // required for logs.tf

enum struct enubPlyJackSettings
{
	bool bPlyHudTextSetting;
	bool bPlyChatPrintSetting;
	bool bPlySoundSetting;
}

enum struct enuiPlyRoundStats
{
	int iPlyScores;
	int iPlyAssists;
	int iPlySaves;
	int iPlyIntercepts;
	int iPlySteals;
}

enubPlyJackSettings arrbJackAcqSettings[MAXPLAYERS + 1];
enuiPlyRoundStats	arriPlyRoundPassStats[MAXPLAYERS + 1];

float			fBluGoalPos[3], fRedGoalPos[3];

ConVar			bEquipStockWeapons, bSwitchDuringRespawn, bStealBlurryOverlay, bDroppedItemsCollision, bPrintStats, fStatsPrintDelay, saveRadius, /*trikzEnable, trikzProjCollide, trikzProjDev*/bPracticeMode;

int				iPlyWhoGotJack;
// int				plyDirecter;
int				ibFirstGrabCheck;
int  			eiJack;
int  			eiPassTarget;
//int  			trikzProjCollideCurVal;
//int  			trikzProjCollideSave = 2;
Menu			mBallHudMenu;
bool			arrbPlyIsDead[MAXPLAYERS + 1];
bool			arrbBlastJumpStatus[MAXPLAYERS + 1]; // true if blast jumping, false if has landed
bool			arrbPanaceaCheck[MAXPLAYERS + 1];
// bool			plyTakenDirectHit[MAXPLAYERS + 1];
Handle  		cookieBallHudHud = INVALID_HANDLE;
Handle  		cookieBallHudChat = INVALID_HANDLE;
Handle  		cookieBallHudSound = INVALID_HANDLE;

public Plugin myinfo =
{
	name		= "4v4 PASS Time Extension",
	author		= "blake++, Dr. Underscore, EasyE, sappho (MGEMod), muddy",
	description = "The main plugin for 4v4 Competitive PASS Time.",
	version		= "1.5.1",
	url			= "https://github.com/blakeplusplus/p4sstime"
};

public void OnPluginStart()
{
	/*GameData gamedata = new GameData("passtime-fixes");
	if (gamedata)
	{
		DHooks_Initialize(gamedata);
		delete gamedata;
	}*/

	cookieBallHudHud = RegClientCookie("ballhudHudSetting", "Passtime Fixes' sm_ballhud HUD Setting Value", CookieAccess_Public);
	cookieBallHudChat = RegClientCookie("ballhudChatSetting", "Passtime Fixes' sm_ballhud Chat Setting Value", CookieAccess_Public);
	cookieBallHudSound = RegClientCookie("ballhudSoundSetting", "Passtime Fixes' sm_ballhud Sounds Setting Value", CookieAccess_Public);

	RegConsoleCmd("sm_ballhud", Command_BallHud);

	// player_askedforball is NOT a real event; https://discord.com/channels/335290997317697536/335290997317697536/1180394803020693565 sourcemod discord server
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("post_inventory_application", Event_PlayerResup);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("pass_get", Event_PassGet);
	HookEvent("pass_free", Event_PassFree);
	HookEvent("pass_ball_stolen", Event_PassStolen);
	HookEvent("pass_score", Event_PassScore);
	HookEvent("pass_pass_caught", Event_PassCaught);
	HookEvent("pass_ball_blocked", Event_PassBallBlocked);
	HookEvent("rocket_jump", Event_RJ);
	HookEvent("rocket_jump_landed", Event_RJLand);
	HookEvent("sticky_jump", Event_SJ);
	HookEvent("sticky_jump_landed", Event_SJLand);
	HookEvent("teamplay_round_win", Event_TeamWin);
	HookEntityOutput("trigger_catapult", "OnCatapulted", Hook_OnCatapult);
	HookEntityOutput("info_passtime_ball_spawn", "OnSpawnBall", Hook_OnSpawnBall);
	AddCommandListener(OnChangeClass, "joinclass");

	bEquipStockWeapons		 = CreateConVar("sm_pt_whitelist", "0", "If 1, disable ability to equip shotgun, stickies, and needles; this is needed as whitelists can't normally block stock weapons.", FCVAR_NOTIFY);
	bSwitchDuringRespawn	 = CreateConVar("sm_pt_respawn", "0", "If 1, disable class switch ability while dead to instantly respawn.", FCVAR_NOTIFY);
	bStealBlurryOverlay		 = CreateConVar("sm_pt_hud", "1", "If 1, disable blurry screen overlay after intercepting or stealing.", FCVAR_NOTIFY);
	bDroppedItemsCollision = CreateConVar("sm_pt_drop_collision", "1", "If 1, disables the jack colliding with dropped ammo packs or weapons.", FCVAR_NOTIFY);
	bPrintStats		 = CreateConVar("sm_pt_stats", "0", "If 1, enables printing of passtime events to chat both during and after games. Does not affect logging.", FCVAR_NOTIFY);
	fStatsPrintDelay		 = CreateConVar("sm_pt_stats_delay", "7.5", "Set the delay between round end and the stats being displayed in chat.", FCVAR_NOTIFY);
	saveRadius		 = CreateConVar("sm_pt_save_radius", "200", "Set the radius in hammer units from the goal that an intercept is considered a save.", FCVAR_NOTIFY);
	//trikzEnable	 = CreateConVar("sm_pt_trikz", "0", "Set 'trikz' mode. 1 adds friendly knockback for airshots, 2 adds friendly knockback for splash damage, 3 adds friendly knockback for everywhere", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	//trikzProjCollide = CreateConVar("sm_pt_trikz_projcollide", "2", "Manually set team projectile collision behavior when trikz is on. 2 always collides, 1 will cause your projectiles to phase through if you are too close (default game behavior), 0 will cause them to never collide.", 0, true, 0.0, true, 2.0);
	bPracticeMode	 = CreateConVar("sm_pt_practice", "0", "If 1, enables practice mode. When the round timer reaches 5 minutes, add 5 minutes to the timer.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	//trikzProjDev = CreateConVar("sm_pt_trikz_projcollide_dev", "0", "DONOTUSE; This command is used solely by the plugin to change values. Changing this manually may cause issues.", FCVAR_HIDDEN, true, 0.0, true, 2.0);

	//HookConVarChange(trikzEnable, Hook_OnTrikzChange);
	//HookConVarChange(trikzProjCollide, Hook_OnProjCollideChange);
	//HookConVarChange(trikzProjDev, Hook_OnProjCollideDev);
	HookConVarChange(bPracticeMode, Hook_OnPracticeModeChange);

	mBallHudMenu = new Menu(BallHudMenuHandler);
	mBallHudMenu.SetTitle("Jack Notifications");
	mBallHudMenu.AddItem("hudtext", "Toggle HUD notification");
	mBallHudMenu.AddItem("chattext", "Toggle chat notification");
	mBallHudMenu.AddItem("sound", "Toggle sound notification");

	char mapPrefix[3];
	GetCurrentMap(mapPrefix, sizeof(mapPrefix));
	bPrintStats.BoolValue = StrEqual("pa", mapPrefix);

	/*for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			OnClientPutInServer(client);
		}
	}*/
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
		GetEntPropVector(goal1, Prop_Send, "m_vecOrigin", fBluGoalPos);
		GetEntPropVector(goal2, Prop_Send, "m_vecOrigin", fRedGoalPos);
	}
	else {
		GetEntPropVector(goal2, Prop_Send, "m_vecOrigin", fBluGoalPos);
		GetEntPropVector(goal1, Prop_Send, "m_vecOrigin", fRedGoalPos);
	}
}

bool IsValidClient(int client)
{
	if (client > 4096) client = EntRefToEntIndex(client);
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (IsFakeClient(client)) return false; // comment this to test with bots per easye
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
/*public OnClientPutInServer(client)
{
	//SDKHook(client, SDKHook_OnTakeDamage, Event_OnTakeDamage);
}

// following classnames are taken from here: https://developer.valvesoftware.com/w/index.php?title=Category:Point_Entities&pagefrom=Prop+glass+futbol#mw-pages
public void OnEntityCreated(int entity, const char[] classname)
{
	//DHooks_OnEntityCreated(entity, classname);
	if (StrEqual(classname, "tf_projectile_rocket") || StrEqual(classname, "tf_projectile_pipe"))
		SDKHook(entity, SDKHook_Touch, OnProjectileTouch);
}

void OnProjectileTouch(int entity, int other) // direct hit detector, taken from MGEMod
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
}*/

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

/*-------------------------------------------------- Player Events --------------------------------------------------*/
Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbPlyIsDead[client] = false;
	RemoveShotty(client);

	return Plugin_Handled;
}

Action Event_PlayerResup(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveShotty(client);

	return Plugin_Handled;
}

bool TraceEntityFilterPlayer(int entity, int contentsMask) // taken from mgemod; just going to use this instead of isvalidclient for the below function
{
	return entity > MaxClients || !entity;
}

float DistanceAboveGround(int victim) // taken from mgemod
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

Action Event_RJ(Event event, const char[] name, bool dontBroadcast) // rj and sj not fired when lifted up by another player
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbBlastJumpStatus[client] = true;
	return Plugin_Handled;
}

Action Event_RJLand(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbBlastJumpStatus[client] = false;
	return Plugin_Handled;
}

Action Event_SJ(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbBlastJumpStatus[client] = true;
	return Plugin_Handled;
}

Action Event_SJLand(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbBlastJumpStatus[client] = false;
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

/*Action Event_OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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
		if (bPrintStats.BoolValue)
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
			if (bPrintStats.BoolValue)
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
}*/

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (condition == TFCond_PasstimeInterception && bStealBlurryOverlay.BoolValue)
	{
		ClientCommand(client, "r_screenoverlay \"\"");
	}
}

// the below function is dr underscore's fix. thanks!
public void TF2_OnConditionRemoved(client, TFCond condition)
{
	if (condition == TFCond_Ubercharged)
		TF2_RemoveCondition(client, TFCond_UberchargeFading);
}

Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbPlyIsDead[client] = true;

	return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
	arrbPlyIsDead[client] = false;

	arriPlyRoundPassStats[client].iPlyScores		   = 0;
	arriPlyRoundPassStats[client].iPlyAssists	   = 0;
	arriPlyRoundPassStats[client].iPlySaves		   = 0;
	arriPlyRoundPassStats[client].iPlyIntercepts = 0;
	arriPlyRoundPassStats[client].iPlySteals		   = 0;
}

/*-------------------------------------------------- PASS Events --------------------------------------------------*/
void Hook_OnSpawnBall(const char[] name, int caller, int activator, float delay)
{
	eiJack = FindEntityByClassname(-1, "passtime_ball");
	if (bDroppedItemsCollision.BoolValue) SetEntityCollisionGroup(eiJack, 4);
	ibFirstGrabCheck = 1;
}

Action Event_PassFree(Event event, const char[] name, bool dontBroadcast)
{
	int owner = event.GetInt("owner");

	// log formatting
	char steamid[16];
	char team[12];
	float position[3];
	GetClientAbsOrigin(owner, position);
	GetClientAuthId(owner, AuthId_Steam3, steamid, sizeof(steamid));
	if (GetClientTeam(owner) == 2)
	{
		team = "Red";
	}
	else if (GetClientTeam(owner) == 3) {
		team = "Blue";
	}
	else {	  // players shouldn't ever be able to grab the ball in spec but if they get manually spawned, maybe...
		team = "Spectator";
	}
	if (arrbJackAcqSettings[owner].bPlyHudTextSetting)
	{
		SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
		ShowHudText(owner, 1, "");
	}
	eiPassTarget = EntRefToEntIndex(GetEntPropEnt(owner, Prop_Send, "m_hPasstimeeiPassTarget"));
	if (!(arrbBlastJumpStatus[owner]))
		arrbPanaceaCheck[owner] = false;
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_free\" (position \"%.0f %.0f %.0f\")",
		owner, GetClientUserId(owner), steamid, team,
		position[0], position[1], position[2]);
	return Plugin_Handled;
}

Action Event_PassBallBlocked(Event event, const char[] name, bool dontBroadcast) // When an enemy player blocks a thrown ball without picking it up, via uber or rocket/sticky jumpers
{
	int thrower = event.GetInt("owner");
	int blocker = event.GetInt("blocker");

	// log formatting
	char steamid_thrower[16];
	char steamid_blocker[16];
	char team_thrower[12];
	char team_blocker[12];
	float thrower_position[3], blocker_position[3];

	GetClientAbsOrigin(thrower, thrower_position);
	GetClientAbsOrigin(blocker, blocker_position);
	GetClientAuthId(thrower, AuthId_Steam3, steamid_thrower, sizeof(steamid_thrower));
	GetClientAuthId(blocker, AuthId_Steam3, steamid_blocker, sizeof(steamid_blocker));

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

	if (GetClientTeam(blocker) == 2)
	{
		team_blocker = "Red";
	}
	else if (GetClientTeam(blocker) == 3) {
		team_blocker = "Blue";
	}
	else {	  // if a player throws the ball then goes spec they can trigger this event as a spectator
		team_blocker = "Spectator";
	}
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_ball_blocked\" against \"%N<%i><%s><%s>\" (thrower_position \"%.0f %.0f %.0f\") (blocker_position \"%.0f %.0f %.0f\")",
		blocker, GetClientUserId(blocker), steamid_blocker, team_blocker,
		thrower, GetClientUserId(thrower), steamid_thrower, team_thrower,
		thrower_position[0], thrower_position[1], thrower_position[2], 
		blocker_position[0], blocker_position[1], blocker_position[2]);
	return Plugin_Handled;
}

Action Event_PassGet(Event event, const char[] name, bool dontBroadcast) // passget prehook occurs AFTER ball throw, this is posthook tho
{
	iPlyWhoGotJack = event.GetInt("owner");

	// log formatting
	char steamid[16];
	char team[12];
	float position[3];

	GetClientAuthId(iPlyWhoGotJack, AuthId_Steam3, steamid, sizeof(steamid));
	GetClientAbsOrigin(iPlyWhoGotJack, position);

	if (GetClientTeam(iPlyWhoGotJack) == 2)
	{
		team = "Red";
	}
	else if (GetClientTeam(iPlyWhoGotJack) == 3) {
		team = "Blue";
	}
	else {	  // players shouldn't ever be able to grab the ball in spec but if they get manually spawned, maybe...
		team = "Spectator";
	}
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_get\" (firstcontact \"%i\") (position \"%.0f %.0f %.0f\")",
		iPlyWhoGotJack, GetClientUserId(iPlyWhoGotJack), steamid, team, ibFirstGrabCheck,
		position[0], position[1], position[2]);
		// ex: "TOMATO TERROR<19><[U:1:160108865]><Blue>" triggered "pass_get" (firstcontact "0")
	if (ibFirstGrabCheck == 1 && arrbBlastJumpStatus[iPlyWhoGotJack])
	{
		arrbPanaceaCheck[iPlyWhoGotJack] = true;
	}
	else
	{
		arrbPanaceaCheck[iPlyWhoGotJack] = false;
	}
	ibFirstGrabCheck = 0;

	if (arrbJackAcqSettings[iPlyWhoGotJack].bPlyHudTextSetting)
	{
		SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
		ShowHudText(iPlyWhoGotJack, 1, "YOU HAVE THE JACK");
	}

	if (arrbJackAcqSettings[iPlyWhoGotJack].bPlyChatPrintSetting)
	{
		PrintToChat(iPlyWhoGotJack, "\x07ffff00[PASS]\x0700ff00 YOU HAVE THE JACK!!!");
	}

	if (arrbJackAcqSettings[iPlyWhoGotJack].bPlySoundSetting)
	{
		ClientCommand(iPlyWhoGotJack, "playgamesound Passtime.BallSmack");
	}

	

	return Plugin_Handled;
}

Action Event_PassCaught(Handle event, const char[] name, bool dontBroadcast)
{
	int	thrower	= GetEventInt(event, "passer");
	int	catcher	= GetEventInt(event, "catcher");
	float dist = GetEventFloat(event, "dist");
	float duration = GetEventFloat(event, "duration");
	int intercept = false;
	int bSave = false;
	int ibHandoffCheck = false;
	iPlyWhoGotJack = catcher;
	char steamid_thrower[16];
	char steamid_catcher[16];
	char team_thrower[12];
	char team_catcher[12];
	char throwerName[MAX_NAME_LENGTH], catcherName[MAX_NAME_LENGTH];
	float thrower_position[3], catcher_position[3];

	GetClientName(thrower, throwerName, sizeof(throwerName));
	GetClientName(catcher, catcherName, sizeof(catcherName));
	GetClientAuthId(thrower, AuthId_Steam3, steamid_thrower, sizeof(steamid_thrower));
	GetClientAuthId(catcher, AuthId_Steam3, steamid_catcher, sizeof(steamid_catcher));
	GetClientAbsOrigin(thrower, thrower_position);
	GetClientAbsOrigin(catcher, catcher_position);


	if (TF2_GetClientTeam(thrower) == TFTeam_Spectator || TF2_GetClientTeam(catcher) == TFTeam_Spectator) return Plugin_Handled;

	if (GetClientTeam(thrower) != GetClientTeam(catcher))
	{
		intercept = true;
		if(InGoalieZone(catcher))
		{
			bSave = true;
			arriPlyRoundPassStats[catcher].iPlySaves++;
			if(bPrintStats.BoolValue)
				PrintToChatAll("\x0700ffff[PASS] %s \x07ffff00blocked \x0700ffff%s from scoring!", catcherName, throwerName);
		}
		else
		{
			arriPlyRoundPassStats[catcher].iPlyIntercepts++;
			if(bPrintStats.BoolValue)
				PrintToChatAll("\x0700ffff[PASS] %s \x07ff00ffintercepted \x0700ffff%s!", catcherName, throwerName);
		}
	}

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
	ibHandoffCheck = false;
	GetClientName(thrower, throwerName, sizeof(throwerName));
	GetClientName(catcher, catcherName, sizeof(catcherName));
	if (TF2_GetClientTeam(thrower) == TF2_GetClientTeam(catcher) && eiPassTarget != catcher && !(GetEntityFlags(catcher) & FL_ONGROUND) && DistanceAboveGround(catcher) > 200) // if on same team and catcher is not locked onto for a pass, also 200 units above ground at least (to ignore just normal non-lock passes)
	{
		if (bPrintStats.BoolValue)
			PrintToChatAll("\x0700ffff[PASS] %s \x07ffff00handed off \x0700ffffto %s!", throwerName, catcherName);
		ibHandoffCheck = true;
		eiPassTarget = 0;
	}
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_pass_caught\" against \"%N<%i><%s><%s>\" (interception \"%i\") (save \"%i\") (handoff \"%i\") (dist \"%.3f\") (duration \"%.3f\") (thrower_position \"%.0f %.0f %.0f\") (catcher_position \"%.0f %.0f %.0f\")",
		catcher, GetClientUserId(catcher), steamid_catcher, team_catcher,
		thrower, GetClientUserId(thrower), steamid_thrower, team_thrower,
		intercept, bSave, ibHandoffCheck, dist, duration,
		thrower_position[0], thrower_position[1], thrower_position[2],
		catcher_position[0], catcher_position[1], catcher_position[2]);
	arrbPanaceaCheck[thrower] = false;
	arrbPanaceaCheck[catcher] = false;
	
	return Plugin_Handled;
}

Action Event_PassStolen(Event event, const char[] name, bool dontBroadcast)
{
	int victim = event.GetInt("victim");
	int thief  = event.GetInt("attacker");
	iPlyWhoGotJack = thief;

	// log formatting
	char steamid_thief[16];
	char steamid_victim[16];
	char team_thief[12];
	char team_victim[12];
	float victim_position[3], thief_position[3];

	GetClientAbsOrigin(thief, thief_position);
	GetClientAbsOrigin(victim, victim_position);
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

	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_ball_stolen\" against \"%N<%i><%s><%s>\" (thief_position \"%.0f %.0f %.0f\") (victim_position \"%.0f %.0f %.0f\")",
		thief, GetClientUserId(thief), steamid_thief, team_thief,
		victim, GetClientUserId(victim), steamid_victim, team_victim,
		thief_position[0], thief_position[1], thief_position[2],
		victim_position[0], victim_position[1], victim_position[2]);
	arrbPanaceaCheck[victim] = false;
	arrbPanaceaCheck[thief] = false;

	if (arrbJackAcqSettings[victim].bPlyHudTextSetting)
	{
		SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
		ShowHudText(victim, 1, "");
	}
	if (bPrintStats.BoolValue)
	{
		char thiefName[MAX_NAME_LENGTH], victimName[MAX_NAME_LENGTH];
		GetClientName(thief, thiefName, sizeof(thiefName));
		GetClientName(victim, victimName, sizeof(victimName));
		PrintToChatAll("\x0700ffff[PASS] %s\x07ff8000 stole from\x0700ffff %s!", thiefName, victimName);
		arriPlyRoundPassStats[thief].iPlySteals++;
	}
	return Plugin_Handled;
}

Action Event_PassScore(Event event, const char[] name, bool dontBroadcast)
{
	int	scorer = event.GetInt("scorer");
	int	points = event.GetInt("points");
	int assistor = event.GetInt("assister");

	// log formatting
	char steamid_scorer[16];
	char team_scorer[12];
	float scorer_position[3], assistor_position[3];
	char playerName[MAX_NAME_LENGTH], assistorName[MAX_NAME_LENGTH];

	GetClientAbsOrigin(scorer, scorer_position);

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

	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_score\" (points \"%i\") (panacea \"%d\") (position \"%.0f %.0f %.0f\")", 
		scorer, GetClientUserId(scorer), steamid_scorer, team_scorer, points, arrbPanaceaCheck[scorer],
		scorer_position[0], scorer_position[1], scorer_position[2]);

	if (assistor > 0)
	{
		char steamid_assistor[16];
		char team_assistor[12];

		GetClientAbsOrigin(assistor, assistor_position);
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

		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_score_assist\" (position \"%.0f %.0f %.0f\")", 
			assistor, GetClientUserId(assistor), steamid_assistor, team_assistor,
			assistor_position[0], assistor_position[1], assistor_position[2]);
		arriPlyRoundPassStats[assistor].iPlyAssists++;
	}
	GetClientName(scorer, playerName, sizeof(playerName));
	if (arrbPanaceaCheck[scorer] && TF2_GetPlayerClass(scorer) != TFClass_Medic && bPrintStats.BoolValue)
	{
		PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a \x074df74dPanacea!", playerName);
	}
	else if (assistor > 0 && bPrintStats.BoolValue)
	{
		GetClientName(assistor, assistorName, sizeof(assistorName));
		PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a goal \x0700ffffassisted by %s!", playerName, assistorName);
	}
	else if(bPrintStats.BoolValue)
	{
		PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a goal!", playerName);
	}
	arriPlyRoundPassStats[scorer].iPlyScores++;

	return Plugin_Handled;
}

bool InGoalieZone(int client)
{
	int	  team = GetClientTeam(client);
	float position[3];
	GetClientAbsOrigin(client, position);

	if (team == view_as<int>(TFTeam_Blue))
	{
		float distance = GetVectorDistance(position, fBluGoalPos, false);
		if (distance < saveRadius.FloatValue) return true;
	}

	if (team == view_as<int>(TFTeam_Red))
	{
		float distance = GetVectorDistance(position, fRedGoalPos, false);
		if (distance < saveRadius.FloatValue) return true;
	}
	return false;
}

void Hook_OnCatapult(const char[] output, int caller, int activator, float delay)
{
	char steamid[16];
	char team[12];
	char plyName[MAX_NAME_LENGTH];
	float position[3];
	if(activator == eiJack && ibFirstGrabCheck == 0 && IsClientConnected(iPlyWhoGotJack))
	{
		GetClientName(iPlyWhoGotJack, plyName, sizeof(plyName));
		GetClientAuthId(iPlyWhoGotJack, AuthId_Steam3, steamid, sizeof(steamid));
		GetClientAbsOrigin(iPlyWhoGotJack, position);
		if (GetClientTeam(iPlyWhoGotJack) == 2)
		{
			team = "Red";
		}
		else if (GetClientTeam(iPlyWhoGotJack) == 3) 
		{
			team = "Blue";
		}
		else // players shouldn't ever be able to grab the ball in spec but if they get manually spawned, maybe...
		{	  
			team = "Spectator";
		}
		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_trigger_catapult\" with the jack (position \"%.0f %.0f %.0f\")", 
			iPlyWhoGotJack, GetClientUserId(iPlyWhoGotJack), steamid, team,
			position[0], position[1], position[2]);
	}
}

/*-------------------------------------------------- Game Events --------------------------------------------------*/
void Hook_OnPracticeModeChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (bPracticeMode.BoolValue)
	{
		int entityTimer = FindEntityByClassname(-1, "team_round_timer");
		SetVariantInt(300);
		AcceptEntityInput(entityTimer, "AddTime");
		CreateTimer(300.0, AddFiveMinutes, _, TIMER_REPEAT); // 5 minutes
	}
}

Action AddFiveMinutes(Handle timer)
{
	if (bPracticeMode.BoolValue)
	{
		int entityTimer = FindEntityByClassname(-1, "team_round_timer");
		SetVariantInt(300);
		AcceptEntityInput(entityTimer, "AddTime");
		return Plugin_Continue;
	}
	else return Plugin_Stop;
}

Action Event_TeamWin(Event event, const char[] name, bool dontBroadcast)
{
	if (!bPrintStats.BoolValue) return Plugin_Handled;
	CreateTimer(fStatsPrintDelay.FloatValue, Timer_DisplayStats);
	return Plugin_Handled;
}

// this is really fucking sloppy but shrug
Action Timer_DisplayStats(Handle timer)
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
				PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
			}

			for (int i = 0; i < redCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(redTeam[i], playerName, sizeof(playerName));
				PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
			}
		}

		else if (TF2_GetClientTeam(x) == TFTeam_Blue || TF2_GetClientTeam(x) == TFTeam_Spectator) {
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

	// clear stats
	for (int i = 0; i < MaxClients + 1; i++)
	{
		arriPlyRoundPassStats[i].iPlyScores = 0, arriPlyRoundPassStats[i].iPlyAssists = 0, arriPlyRoundPassStats[i].iPlySaves = 0, arriPlyRoundPassStats[i].iPlyIntercepts = 0, arriPlyRoundPassStats[i].iPlySteals = 0;
	}

	return Plugin_Stop;
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


/*
some data that will be useful later
https://lmaobox.net/lua/TF2_props/
*/
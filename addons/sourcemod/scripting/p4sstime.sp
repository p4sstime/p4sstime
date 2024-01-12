#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <sdktools>
//#include <dhooks>
#include <clientprefs>

#pragma semicolon 1	   // required for logs.tf

#define STICKBOMB_CLASS "CTFStickBomb" // required(?) for caber regen

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

ConVar			bEquipStockWeapons, bSwitchDuringRespawn, bStealBlurryOverlay, bDroppedItemsCollision, bPrintStats, fStatsPrintDelay, /*trikzEnable, trikzProjCollide, trikzProjDev*/bPracticeMode, fCaberTimer;

int				iPlyWhoGotJack;
// int				plyDirecter;
int				ibFirstGrabCheck;
int  			eiJack;
int  			eiPassTarget;
int				ibBallSpawnLocation = 0;
//int  			trikzProjCollideCurVal;
//int  			trikzProjCollideSave = 2;
Menu			mBallHudMenu;
bool			arrbPlyIsDead[MAXPLAYERS + 1];
bool			arrbBlastJumpStatus[MAXPLAYERS + 1]; // true if blast jumping, false if has landed
bool			arrbPanaceaCheck[MAXPLAYERS + 1];
// bool			plyTakenDirectHit[MAXPLAYERS + 1];
Handle 			tCaberRegen[MAXPLAYERS + 1];
Handle  		cookieBallHudHud = INVALID_HANDLE;
Handle  		cookieBallHudChat = INVALID_HANDLE;
Handle  		cookieBallHudSound = INVALID_HANDLE;

int user1;
char user1steamid[16];
char user1team[12];
float user1position[3];
int user2;
char user2steamid[16];
char user2team[12];
float user2position[3];

public Plugin myinfo =
{
	name		= "4v4 PASS Time Extension",
	author		= "blake++",
	description = "The main plugin for 4v4 Competitive PASS Time.",
	version		= "2.0.0",
	url			= "https://github.com/blakeplusplus/p4sstime"
};

public void OnPluginStart()
{
	/*GameData gamedata = new GameData("passtime");
	if (gamedata)
	{
		DHooks_Initialize(gamedata);
		delete gamedata;
	}*/

	cookieBallHudHud = RegClientCookie("ballhudHudSetting", "p4sstime's sm_ballhud HUD Setting Value", CookieAccess_Public);
	cookieBallHudChat = RegClientCookie("ballhudChatSetting", "p4sstime's sm_ballhud Chat Setting Value", CookieAccess_Public);
	cookieBallHudSound = RegClientCookie("ballhudSoundSetting", "p4sstime's sm_ballhud Sounds Setting Value", CookieAccess_Public);

	RegConsoleCmd("sm_ballhud", Command_BallHud);

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("post_inventory_application", Event_PlayerResup);
	HookEvent("player_hurt", Event_PlayerHurt);
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
	HookEvent("stats_resetround", Event_RoundReset);
	HookEntityOutput("trigger_catapult", "OnCatapulted", Hook_OnCatapult);
	HookEntityOutput("info_passtime_ball_spawn", "OnSpawnBall", Hook_OnSpawnBall);
	AddCommandListener(OnChangeClass, "joinclass");

	bEquipStockWeapons		= CreateConVar("sm_pt_whitelist", "0", "If 1, disable ability to equip shotgun, stickies, and needles; this is needed as whitelists can't normally block stock weapons.", FCVAR_NOTIFY);
	bSwitchDuringRespawn	= CreateConVar("sm_pt_respawn", "0", "If 1, disable class switch ability while dead to instantly respawn.", FCVAR_NOTIFY);
	bStealBlurryOverlay		= CreateConVar("sm_pt_hud", "1", "If 1, disable blurry screen overlay after intercepting or stealing.", FCVAR_NOTIFY);
	bDroppedItemsCollision 	= CreateConVar("sm_pt_drop_collision", "1", "If 1, disables the jack colliding with dropped ammo packs or weapons.", FCVAR_NOTIFY);
	bPrintStats		 		= CreateConVar("sm_pt_stats", "0", "If 1, enables printing of passtime events to chat both during and after games. Does not affect logging.", FCVAR_NOTIFY);
	fStatsPrintDelay		= CreateConVar("sm_pt_stats_delay", "7.5", "Set the delay between round end and the stats being displayed in chat.", FCVAR_NOTIFY);
	bPracticeMode	 		= CreateConVar("sm_pt_practice", "0", "If 1, enables practice mode. When the round timer reaches 5 minutes, add 5 minutes to the timer.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	fCaberTimer 			= CreateConVar("sm_pt_caber_rechargetime", "20", "Set how long it takes for caber to recharge. If 0, recharging is disabled.", FCVAR_NOTIFY);

	//trikzEnable	 = CreateConVar("sm_pt_trikz", "0", "Set 'trikz' mode. 1 adds friendly knockback for airshots, 2 adds friendly knockback for splash damage, 3 adds friendly knockback for everywhere", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	//trikzProjCollide = CreateConVar("sm_pt_trikz_projcollide", "2", "Manually set team projectile collision behavior when trikz is on. 2 always collides, 1 will cause your projectiles to phase through if you are too close (default game behavior), 0 will cause them to never collide.", 0, true, 0.0, true, 2.0);
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

//#include <p4sstime/trikz.sp>
#include <p4sstime/logs.sp>
#include <p4sstime/pass_menu.sp>
#include <p4sstime/practice.sp>
#include <p4sstime/anticheat.sp>
#include <p4sstime/caber_regen.sp>
#include <p4sstime/convars.sp>

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

Action Event_RoundReset(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 0; i < MaxClients + 1; i++) // clear stats
	{
		arriPlyRoundPassStats[i].iPlyScores = 0, arriPlyRoundPassStats[i].iPlyAssists = 0, arriPlyRoundPassStats[i].iPlySaves = 0, arriPlyRoundPassStats[i].iPlyIntercepts = 0, arriPlyRoundPassStats[i].iPlySteals = 0;
	}
	if(GetConVarInt(bPracticeMode) == 1)
	{
		SetConVarInt(bPracticeMode, 0);
		PrintToChatAll("\x0700ffff[PASS] Game started; practice mode disabled.");
	}
	return Plugin_Handled;
}

Action Event_TeamWin(Event event, const char[] name, bool dontBroadcast)
{
	if (!bPrintStats.BoolValue) return Plugin_Handled;
	CreateTimer(fStatsPrintDelay.FloatValue, Timer_DisplayStats);
	return Plugin_Handled;
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

/*-------------------------------------------------- Player Events --------------------------------------------------*/

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

Action Event_RJ(Event event, const char[] name, bool dontBroadcast)
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

// the below function is dr underscore's fix. thanks!
public void TF2_OnConditionRemoved(client, TFCond condition)
{
	if (condition == TFCond_Ubercharged)
		TF2_RemoveCondition(client, TFCond_UberchargeFading);
}

Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	arrbPlyIsDead[client] = true;
	KillCaberRegenTimer(client);

	return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
	arrbPlyIsDead[client] = false;
	KillCaberRegenTimer(client);

	arriPlyRoundPassStats[client].iPlyScores		   = 0;
	arriPlyRoundPassStats[client].iPlyAssists	   = 0;
	arriPlyRoundPassStats[client].iPlySaves		   = 0;
	arriPlyRoundPassStats[client].iPlyIntercepts = 0;
	arriPlyRoundPassStats[client].iPlySteals		   = 0;
}

/*-------------------------------------------------- PASS Events --------------------------------------------------*/
void Hook_OnSpawnBall(const char[] name, int caller, int activator, float delay)
{
	char strName[15];
	eiJack = FindEntityByClassname(-1, "passtime_ball");
	if (bDroppedItemsCollision.BoolValue) SetEntityCollisionGroup(eiJack, 4);
	GetEntPropString(caller, Prop_Send, "m_iName", strName, sizeof(strName));
	ibFirstGrabCheck = true;
}

Action CheckBallLocation(Handle timer)
{
	if(ibBallSpawnLocation == 0)
		LogToGame("passtime_ball spawned upper.");
	else
		LogToGame("passtime_ball spawned lower.");
	return Plugin_Stop;
}

Action Event_PassFree(Event event, const char[] name, bool dontBroadcast)
{
	int owner = event.GetInt("owner");
	if (arrbJackAcqSettings[owner].bPlyHudTextSetting)
	{
		SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
		ShowHudText(owner, 1, "");
	}
	eiPassTarget = EntRefToEntIndex(GetEntPropEnt(owner, Prop_Send, "m_hPasstimePassTarget"));
	if (!(arrbBlastJumpStatus[owner]))
		arrbPanaceaCheck[owner] = false;
	SetLogInfo(owner);
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_free\" (position \"%.0f %.0f %.0f\")",
		user1, GetClientUserId(user1), user1steamid, user1team,
		user1position[0], user1position[1], user1position[2]);
	return Plugin_Handled;
}

Action Event_PassBallBlocked(Event event, const char[] name, bool dontBroadcast) // When an enemy player blocks a thrown ball without picking it up, via uber or rocket/sticky jumpers
{
	int blocker = event.GetInt("blocker");
	int thrower = event.GetInt("owner");
	
	SetLogInfo(blocker, thrower);
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_ball_blocked\" against \"%N<%i><%s><%s>\" (thrower_position \"%.0f %.0f %.0f\") (blocker_position \"%.0f %.0f %.0f\")",
		user1, GetClientUserId(user1), user1steamid, user1team,
		user2, GetClientUserId(user2), user2steamid, user2team,
		user1position[0], user1position[1], user1position[2], 
		user2position[0], user2position[1], user2position[2]);
	user2 = 0;
	return Plugin_Handled;
}

Action Event_PassGet(Event event, const char[] name, bool dontBroadcast)
{
	iPlyWhoGotJack = event.GetInt("owner");

	SetLogInfo(iPlyWhoGotJack);
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_get\" (firstcontact \"%i\") (position \"%.0f %.0f %.0f\")",
		user1, GetClientUserId(user1), user1steamid, user1team, ibFirstGrabCheck,
		user1position[0], user1position[1], user1position[2]);
	if (ibFirstGrabCheck && arrbBlastJumpStatus[iPlyWhoGotJack])
	{
		arrbPanaceaCheck[iPlyWhoGotJack] = true;
	}
	else
	{
		arrbPanaceaCheck[iPlyWhoGotJack] = false;
	}
	ibFirstGrabCheck = false;

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

	char throwerName[MAX_NAME_LENGTH], catcherName[MAX_NAME_LENGTH];
	GetClientName(thrower, throwerName, sizeof(throwerName));
	GetClientName(catcher, catcherName, sizeof(catcherName));

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

	if (TF2_GetClientTeam(thrower) == TF2_GetClientTeam(catcher) && eiPassTarget != catcher && !(GetEntityFlags(catcher) & FL_ONGROUND) && DistanceAboveGround(catcher) > 200) // if on same team and catcher is not locked onto for a pass, also 200 units above ground at least (to ignore just normal non-lock passes)
	{
		if (bPrintStats.BoolValue)
			PrintToChatAll("\x0700ffff[PASS] %s \x07ffff00handed off \x0700ffffto %s!", throwerName, catcherName);
		ibHandoffCheck = true;
		eiPassTarget = 0;
	}
	SetLogInfo(catcher, thrower);
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_pass_caught\" against \"%N<%i><%s><%s>\" (interception \"%i\") (save \"%i\") (handoff \"%i\") (dist \"%.3f\") (duration \"%.3f\") (thrower_position \"%.0f %.0f %.0f\") (catcher_position \"%.0f %.0f %.0f\")",
		user1, GetClientUserId(user1), user1steamid, user1team,
		user2, GetClientUserId(user2), user2steamid, user2team,
		intercept, bSave, ibHandoffCheck, dist, duration,
		user1position[0], user1position[1], user1position[2], 
		user2position[0], user2position[1], user2position[2]);
	user2 = 0;
	arrbPanaceaCheck[thrower] = false;
	arrbPanaceaCheck[catcher] = false;

	return Plugin_Handled;
}

Action Event_PassStolen(Event event, const char[] name, bool dontBroadcast)
{
	int thief  = event.GetInt("attacker");
	int victim = event.GetInt("victim");
	iPlyWhoGotJack = thief;

	SetLogInfo(thief, victim);
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_ball_stolen\" against \"%N<%i><%s><%s>\" (thief_position \"%.0f %.0f %.0f\") (victim_position \"%.0f %.0f %.0f\")",
		user1, GetClientUserId(user1), user1steamid, user1team,
		user2, GetClientUserId(user2), user2steamid, user2team,
		user1position[0], user1position[1], user1position[2], 
		user2position[0], user2position[1], user2position[2]);
	user2 = 0;
	arrbPanaceaCheck[thief] = false;
	arrbPanaceaCheck[victim] = false;

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
	int assistant = event.GetInt("assister");
	char playerName[MAX_NAME_LENGTH], assistantName[MAX_NAME_LENGTH];
	GetClientName(scorer, playerName, sizeof(playerName));

	SetLogInfo(scorer);
	LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_score\" (points \"%i\") (panacea \"%d\") (position \"%.0f %.0f %.0f\")", 
		user1, GetClientUserId(user1), user1steamid, user1team,
		points, arrbPanaceaCheck[scorer],
		user1position[0], user1position[1], user1position[2]);
	arriPlyRoundPassStats[scorer].iPlyScores++;

	if (arrbPanaceaCheck[scorer] && TF2_GetPlayerClass(scorer) != TFClass_Medic && bPrintStats.BoolValue)
	{
		PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a \x074df74dPanacea!", playerName);
	}
	else if(bPrintStats.BoolValue)
	{
		PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a goal!", playerName);
	}

	if (assistant > 0)
	{
		GetClientName(assistant, assistantName, sizeof(assistantName));
		SetLogInfo(assistant);
		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_score_assist\" (position \"%.0f %.0f %.0f\")", 
			user1, GetClientUserId(user1), user1steamid, user1team,
			user1position[0], user1position[1], user1position[2]);
		arriPlyRoundPassStats[assistant].iPlyAssists++;
		if(bPrintStats.BoolValue)
		{
			PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a goal \x0700ffffassisted by %s!", playerName, assistantName);
		}
	}

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
		if (distance < 200) return true;
	}

	if (team == view_as<int>(TFTeam_Red))
	{
		float distance = GetVectorDistance(position, fRedGoalPos, false);
		if (distance < 200) return true;
	}
	return false;
}

void Hook_OnCatapult(const char[] output, int caller, int activator, float delay)
{
	GetEntPropString(caller, Prop_Send, "m_iName", strName, sizeof(strName));
	if(activator == eiJack && !ibFirstGrabCheck && IsClientConnected(iPlyWhoGotJack) && strName != "catapult1") // ONLY WORKS FOR ARENA2 ATM
	{
		SetLogInfo(iPlyWhoGotJack);
		LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_trigger_catapult\" with the jack (position \"%.0f %.0f %.0f\")", 
			user1, GetClientUserId(user1), user1steamid, user1team,
			user1position[0], user1position[1], user1position[2]);
	}
	else if(activator == eiJack && ibFirstGrabCheck) // if the ball hasn't been grabbed
	{
		ibBallSpawnLocation = 1; // spawned lower
	}
}

/*-------------------------------------------------- Game Events --------------------------------------------------*/



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
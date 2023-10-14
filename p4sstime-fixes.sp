#include <sourcemod>
#include <tf2_stocks>
#include <sdktools>

#pragma semicolon 1 // required for logs.tf

#define NAME_SIZE 25

bool deadPlayers[MAXPLAYERS + 1];
//0 = hud text, 1 = chat, 2 = sound
bool ballHudEnabled[MAXPLAYERS + 1][3];
//playerArray: 0 = scores, saves = 1, 2 = interceptions, 3 = steals
int playerArray[MAXPLAYERS][4];
float bluGoal[3], redGoal[3];

ConVar stockEnable, respawnEnable, clearHud, collisionDisable, statsEnable, statsDelay, saveRadius;

int firstGrab;
Menu ballHudMenu;

public Plugin myinfo =
{
    name = "4v4 Competitive PASStime Fixes",
    author = "czarchasm, Dr. Underscore (James), EasyE",
    description = "A mashup of fixes for 4v4 PASStime.",
    version = "1.2",
    url = "https://github.com/czarchasm00/p4sstime-fixes"
};

public void OnPluginStart() {
    RegConsoleCmd("sm_ballhud", Command_BallHud);

    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("post_inventory_application", Event_PlayerResup, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("pass_get", Event_PassGet, EventHookMode_Post);
    HookEvent("pass_free", Event_PassFree, EventHookMode_Post);
    HookEvent("pass_ball_stolen", Event_PassStolen, EventHookMode_Post);
    HookEvent("pass_score", Event_PassScore, EventHookMode_Post);
    HookEvent("pass_pass_caught", Event_PassCaught, EventHookMode_Post);
    HookEvent("teamplay_round_win", Event_TeamWin, EventHookMode_Post);
    HookEntityOutput("info_passtime_ball_spawn", "OnSpawnBall", Hook_OnSpawnBall);
    AddCommandListener(OnChangeClass, "joinclass");

// for logs
    HookEvent("pass_pass_caught", catchBallEvent, EventHookMode_Pre);
    HookEvent("pass_get", passGrabEvent);
    HookEvent("pass_ball_stolen", passStealEvent);
    HookEvent("pass_score", passScoreEvent, EventHookMode_Pre);
// end

    stockEnable = CreateConVar("sm_passtime_whitelist", "0", "Enables/Disables passtime stock weapon locking");
    respawnEnable = CreateConVar("sm_passtime_respawn", "0", "Enables/disables fixed respawn time");
    clearHud = CreateConVar("sm_passtime_hud", "1", "Enables/Disables blocking the blur effect after intercepting or stealing the ball");
    collisionDisable = CreateConVar("sm_passtime_collision_disable", "0", "Enables/Disables the passtime jack from colliding with ammopacks or weapons");
    statsEnable = CreateConVar("sm_passtime_stats", "1", "Enables passtime stats");
    statsDelay = CreateConVar("sm_passtime_stats_delay", "7.5", "Delay for passtime stats to be displayed after a game is won");
    saveRadius = CreateConVar("sm_passtime_stats_save_radius", "200", "The Radius in hammer units from the goal that an intercept is considered a save");

    ballHudMenu = new Menu(BallHudMenuHandler);
    ballHudMenu.SetTitle("Jack Notifications");
    ballHudMenu.AddItem("hudtext", "Toggle HUD notification");
    ballHudMenu.AddItem("chattext", "Toggle chat notification");
    ballHudMenu.AddItem("sound", "Toggle sound notification");

    char mapPrefix[3];
    GetCurrentMap(mapPrefix, sizeof(mapPrefix));
    statsEnable.BoolValue = StrEqual("pa", mapPrefix);
}

public void OnMapStart() {
    GetGoalLocations();
}

public void OnClientDisconnect(int client) {
    deadPlayers[client] = false;
    ballHudEnabled[client][0] = false;
    ballHudEnabled[client][1] = false;
    ballHudEnabled[client][2] = false;
    playerArray[client][0] = 0, playerArray[client][1] = 0, playerArray[client][2] = 0, playerArray[client][3] = 0;
}

public void TF2_OnConditionAdded(int client, TFCond condition) {
    if (condition == TFCond_PasstimeInterception && clearHud.BoolValue) {
        ClientCommand(client, "r_screenoverlay \"\"");
    }
}

// the below function is dr underscore's fix. thanks!
public TF2_OnConditionRemoved(client, TFCond:condition)
{
    if (condition == TFCond_Ubercharged)
        TF2_RemoveCondition(client, TFCond_UberchargeFading);
}

public Action Command_BallHud(int client, int args) {
    if (IsValidClient(client)) ballHudMenu.Display(client, MENU_TIME_FOREVER);
    return Plugin_Handled;
}

public int BallHudMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[32];
        char status[64];
        ballHudMenu.GetItem(param2, info, sizeof(info));
        if (StrEqual(info, "hudtext")) {
            ballHudEnabled[param1][0] = !ballHudEnabled[param1][0];
            ballHudMenu.Display(param1, MENU_TIME_FOREVER);

            Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Hud text: %s", ballHudEnabled[param1][0] ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
            PrintToChat(param1, status);
        }
        if (StrEqual(info, "chattext")) {
            ballHudEnabled[param1][1] = !ballHudEnabled[param1][1];
            ballHudMenu.Display(param1, MENU_TIME_FOREVER);

            Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Chat text: %s", ballHudEnabled[param1][1] ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
            PrintToChat(param1, status);

        }
        if (StrEqual(info, "sound")) {
            ballHudEnabled[param1][2] = !ballHudEnabled[param1][2];
            ballHudMenu.Display(param1, MENU_TIME_FOREVER);

            Format(status, sizeof(status), "\x0700ffff[PASS]\x01 Sound notification: %s", ballHudEnabled[param1][2] ? "\x0700ff00Enabled" : "\x07ff0000Disabled");
            PrintToChat(param1, status);
        }
    }
}

/* ---EVENTS--- */

public Action Event_PassFree(Event event, const char[] name, bool dontBroadcast) {
    int owner = event.GetInt("owner");
    if (ballHudEnabled[owner][0]) {
        SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
        ShowHudText(owner, 1, "");
    }
}

public Action Event_PassGet(Event event, const char[] name, bool dontBroadcast) {
    int owner = event.GetInt("owner");
    if (ballHudEnabled[owner][0]) {
        SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
        ShowHudText(owner, 1, "YOU HAVE THE JACK");
    }

    if (ballHudEnabled[owner][1]) {
        PrintToChat(owner, "\x07ffff00[PASS]\x0700ff00 YOU HAVE THE JACK!!!");
    }

    if (ballHudEnabled[owner][2]) {
        ClientCommand(owner, "playgamesound Passtime.BallSmack");
    }
}

public Action Event_PassCaught(Event event, const char[] name, bool dontBroadcast) {
    if (!statsEnable.BoolValue) return Plugin_Handled;

    int passer = event.GetInt("passer");
    int catcher = event.GetInt("catcher");
    if (TF2_GetClientTeam(passer) == TF2_GetClientTeam(catcher)) return Plugin_Handled;
    if (TF2_GetClientTeam(passer) == TFTeam_Spectator || TF2_GetClientTeam(catcher) == TFTeam_Spectator) return Plugin_Handled;

    char passerName[NAME_SIZE], catcherName[NAME_SIZE];
    GetClientName(passer, passerName, sizeof(passerName));
    GetClientName(catcher, catcherName, sizeof(catcherName));
    if (InGoalieZone(catcher)) {
        PrintToChatAll("\x0700ffff[PASS] %s \x07ffff00 blocked \x0700ffff%s!", catcherName, passerName);
        playerArray[catcher][1]++;
    }
    else {
        PrintToChatAll("\x0700ffff[PASS] %s \x07ff00ffintercepted \x0700ffff%s!", catcherName, passerName);
        playerArray[catcher][2]++;
    }

    return Plugin_Handled;
}

public Action Event_PassStolen(Event event, const char[] name, bool dontBroadcast) {
    int victim = event.GetInt("victim");
    int thief = event.GetInt("attacker");
    if (ballHudEnabled[victim][0]) {
        SetHudTextParams(-1.0, 0.22, 3.0, 240, 0, 240, 255);
        ShowHudText(victim, 1, "");
    }
    if (statsEnable.BoolValue){
        char thiefName[NAME_SIZE], victimName[NAME_SIZE];
        GetClientName(thief, thiefName, sizeof(thiefName));
        GetClientName(victim, victimName, sizeof(victimName));
        PrintToChatAll("\x0700ffff[PASS] %s\x07ff8000 stole from\x0700ffff %s!", thiefName, victimName);
        playerArray[thief][3]++;
    }
    return Plugin_Handled;
}

public Action Event_PassScore(Event event, const char[] name, bool dontBroadcast) {
    if (!statsEnable.BoolValue) return Plugin_Handled;

    int client = event.GetInt("scorer");
    if (!IsValidClient(client)) return Plugin_Handled;
    char playerName[NAME_SIZE];
    GetClientName(client, playerName, sizeof(playerName));
    PrintToChatAll("\x0700ffff[PASS] %s\x073BC43B scored a goal!", playerName);
    playerArray[client][0]++;
    return Plugin_Handled;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    deadPlayers[client] = true;
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    deadPlayers[client] = false;
    RemoveShotty(client);
}

public Action Event_PlayerResup(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    RemoveShotty(client);
}

public Action Event_TeamWin(Event event, const char[] name, bool dontBroadcast) {
    if (!statsEnable.BoolValue) return Plugin_Handled;
    CreateTimer(statsDelay.FloatValue, Timer_DisplayStats);
    return Plugin_Handled;
}

public Action OnChangeClass(int client, const char[] strCommand, int args) {
    if(deadPlayers[client] == true && respawnEnable.BoolValue) {
        PrintCenterText(client, "You cant change class yet.");
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public void Hook_OnSpawnBall(const char[] name, int caller, int activator, float delay) {
    int ball = FindEntityByClassname(-1, "passtime_ball");
    if(collisionDisable.BoolValue) SetEntityCollisionGroup(ball, 4);
    firstGrab = 1;
}

//this is really fucking sloppy but shrug
public Action Timer_DisplayStats(Handle timer) {
    int redTeam[16], bluTeam[16];
    int redCursor, bluCursor = 0;
    for (int x=1; x < MaxClients+1; x++) {
        if (!IsValidClient(x)) continue;

        if (TF2_GetClientTeam(x) == TFTeam_Red) {
            redTeam[redCursor] = x;
            redCursor++;
        }

        else if (TF2_GetClientTeam(x) == TFTeam_Blue) {
            bluTeam[bluCursor] = x;
            bluCursor++;
        }
    }
    for (int x=1; x < MaxClients+1; x++) {
        if (!IsValidClient(x)) continue;

        if (TF2_GetClientTeam(x) == TFTeam_Red) {
            for (int i=0; i < bluCursor; i++) {
                char playerName[NAME_SIZE];
                GetClientName(bluTeam[i], playerName, sizeof(playerName));
                PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, playerArray[bluTeam[i]][0], playerArray[bluTeam[i]][1], playerArray[bluTeam[i]][2], playerArray[bluTeam[i]][3]);
            }

            for (int i=0; i < redCursor; i++) {
                char playerName[NAME_SIZE];
                GetClientName(redTeam[i], playerName, sizeof(playerName));
                PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, playerArray[redTeam[i]][0], playerArray[redTeam[i]][1], playerArray[redTeam[i]][2], playerArray[redTeam[i]][3]);
            }
        }

        else if (TF2_GetClientTeam(x) == TFTeam_Blue|| TF2_GetClientTeam(x) == TFTeam_Spectator) {
            for (int i=0; i < redCursor; i++) {
                                 char playerName[NAME_SIZE];
                                 GetClientName(redTeam[i], playerName, sizeof(playerName));
                                 PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, playerArray[redTeam[i]][0], playerArray[redTeam[i]][1], playerArray[redTeam[i]][2], playerArray[redTeam[i]][3]);
                         }

            for (int i=0; i < bluCursor; i++) {
                char playerName[NAME_SIZE];
                GetClientName(bluTeam[i], playerName, sizeof(playerName));
                PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, playerArray[bluTeam[i]][0], playerArray[bluTeam[i]][1], playerArray[bluTeam[i]][2], playerArray[bluTeam[i]][3]);
            }

        }
    }

    //clear stats
    for (int i=0; i < MaxClients+1;i++) {
        playerArray[i][0] = 0, playerArray[i][1] = 0, playerArray[i][2] = 0, playerArray[i][3] = 0;
    }

}

/* ---FUNCTIONS--- */

public void RemoveShotty(int client) {
    if(stockEnable.BoolValue) {
        TFClassType class = TF2_GetPlayerClass(client);
        int iWep;
        if (class == TFClass_DemoMan || class == TFClass_Soldier) iWep = GetPlayerWeaponSlot(client, 1);
        else if (class == TFClass_Medic) iWep = GetPlayerWeaponSlot(client, 0);

        if(iWep >= 0) {
            char classname[64];
            GetEntityClassname(iWep, classname, sizeof(classname));

            if (StrEqual(classname, "tf_weapon_shotgun_soldier") || StrEqual(classname, "tf_weapon_pipebomblauncher")) {
                PrintToChat(client, "\x07ff0000 [PASS] Shotgun/Stickies equipped");
                TF2_RemoveWeaponSlot(client, 1);
            }

            if (StrEqual(classname, "tf_weapon_syringegun_medic")) {
                PrintToChat(client, "\x07ff0000 [PASS] Syringe Gun equipped");
                TF2_RemoveWeaponSlot(client, 0);
            }

        }
    }
}

public bool InGoalieZone(int client) {
    int team = GetClientTeam(client);
    float position[3];
    GetClientAbsOrigin(client, position);

    if (team == view_as<int>(TFTeam_Blue)) {
        float distance = GetVectorDistance(position, bluGoal, false);
        if (distance < saveRadius.FloatValue) return true;
    }

    if (team == view_as<int>(TFTeam_Red)) {
        float distance = GetVectorDistance(position, redGoal, false);
        if (distance < saveRadius.FloatValue) return true;
    }

    return false;
}

public void GetGoalLocations() {
    int goal1 = FindEntityByClassname(-1, "func_passtime_goal");
    int goal2 = FindEntityByClassname(goal1, "func_passtime_goal");
    int team1 = GetEntProp(goal1, Prop_Send, "m_iTeamNum");
    if (team1 == 2) {
        GetEntPropVector(goal1, Prop_Send, "m_vecOrigin", bluGoal);
        GetEntPropVector(goal2, Prop_Send, "m_vecOrigin", redGoal);
    }
    else {
        GetEntPropVector(goal2, Prop_Send, "m_vecOrigin", bluGoal);
        GetEntPropVector(goal1, Prop_Send, "m_vecOrigin", redGoal);
    }
}

public bool IsValidClient(int client) {
    if (client > 4096) client = EntRefToEntIndex(client);
    if (client < 1 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    if (IsFakeClient(client)) return false;
    if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
    return true;
}

// muddy's log functions are below this

public Action passGrabEvent(Handle event, const char[] name, bool dontBreadcast) {
    int ply = GetEventInt(event, "owner");

    //log formatting
    char steamid[16];
    char team[12];

    GetClientAuthId(ply, AuthId_Steam3, steamid, sizeof(steamid));

    if(GetClientTeam(ply) == 2) {
        team = "Red";
    } else if(GetClientTeam(ply) == 3) {
        team = "Blue";
    } else { //players shouldn't ever be able to grab the ball in spec but if they get manually spawned, maybe...
        team = "Spectator";
    }
    LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_get\" (firstcontact \"%i\")", ply, GetClientUserId(ply), steamid, team, firstGrab);
    firstGrab = 0;

    return Plugin_Continue;
}

public Action passStealEvent(Handle event, const char[] name, bool dontBreadcast) {
    int stealer = GetEventInt(event, "attacker");
    int carrier = GetEventInt(event, "victim");

    //log formatting
    char steamid_stealer[16];
    char steamid_carrier[16];
    char team_stealer[12];
    char team_carrier[12];

    GetClientAuthId(stealer, AuthId_Steam3, steamid_stealer, sizeof(steamid_stealer));
    GetClientAuthId(carrier, AuthId_Steam3, steamid_carrier, sizeof(steamid_carrier));

    if(GetClientTeam(stealer) == 2) {
        team_stealer = "Red";
    } else if(GetClientTeam(stealer) == 3) {
        team_stealer = "Blue";
    } else {
        team_stealer = "Spectator";
    }

    if(GetClientTeam(carrier) == 2) {
        team_carrier = "Red";
    } else if(GetClientTeam(carrier) == 3) {
        team_carrier = "Blue";
    } else {
        team_carrier = "Spectator";
    }

    LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_ball_stolen\" against \"%N<%i><%s><%s>\"", stealer, GetClientUserId(stealer), steamid_stealer, team_stealer, carrier, GetClientUserId(carrier), steamid_carrier, team_carrier);

    return Plugin_Continue;
}


public Action passScoreEvent(Event event, const char[] name, bool dontBroadcast) {
    int scorer = GetEventInt(event, "scorer");
    int points = GetEventInt(event, "points");
    int assistor = GetEventInt(event, "assister");

    //log formatting
    char steamid_scorer[16];
    char team_scorer[12];

    GetClientAuthId(scorer, AuthId_Steam3, steamid_scorer, sizeof(steamid_scorer));

    if(GetClientTeam(scorer) == 2) {
        team_scorer = "Red";
    } else if(GetClientTeam(scorer) == 3) {
        team_scorer = "Blue";
    } else {
        team_scorer = "Spectator";
    }

    LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_score\" (points \"%i\")", scorer, GetClientUserId(scorer), steamid_scorer, team_scorer, points);

    if(assistor > 0) {
        char steamid_assistor[16];
        char team_assistor[12];

        GetClientAuthId(assistor, AuthId_Steam3, steamid_assistor, sizeof(steamid_assistor));

        if(GetClientTeam(assistor) == 2) {
            team_assistor = "Red";
        } else if(GetClientTeam(assistor) == 3) {
            team_assistor = "Blue";
        } else {
            team_assistor = "Spectator";
        }

        LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_score_assist\"", assistor, GetClientUserId(assistor), steamid_assistor, team_assistor);
    }
    return Plugin_Changed;
}

public Action catchBallEvent(Handle event, const char[] name, bool dontBroadcast) {
    int thrower = GetEventInt(event, "passer");
    int catcher = GetEventInt(event, "catcher");
    float dist = GetEventFloat(event, "dist");
    float duration = GetEventFloat(event, "duration");

    int intercept = true;

    if(GetClientTeam(thrower) == GetClientTeam(catcher)) {
        intercept = false;
    }

    //log formatting
    char steamid_thrower[16];
    char steamid_catcher[16];
    char team_thrower[12];
    char team_catcher[12];

    GetClientAuthId(thrower, AuthId_Steam3, steamid_thrower, sizeof(steamid_thrower));
    GetClientAuthId(catcher, AuthId_Steam3, steamid_catcher, sizeof(steamid_catcher));

    if(GetClientTeam(thrower) == 2) {
        team_thrower = "Red";
    } else if(GetClientTeam(thrower) == 3) {
        team_thrower = "Blue";
    } else {
        team_thrower = "Spectator";
    }

    if(GetClientTeam(catcher) == 2) {
        team_catcher = "Red";
    } else if(GetClientTeam(catcher) == 3) {
        team_catcher = "Blue";
    } else { //if a player throws the ball then goes spec they can trigger this event as a spectator
        team_catcher = "Spectator";
    }
    LogToGame("\"%N<%i><%s><%s>\" triggered \"pass_pass_caught\" against \"%N<%i><%s><%s>\" (interception \"%i\") (dist \"%.3f\") (duration \"%.3f\")", catcher, GetClientUserId(catcher), steamid_catcher, team_catcher, thrower, GetClientUserId(thrower), steamid_thrower, team_thrower, intercept, dist, duration);

    return Plugin_Continue;
}

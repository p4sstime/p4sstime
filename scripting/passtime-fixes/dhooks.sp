#pragma newdecls required
#pragma semicolon 1

static ArrayList g_dynamicHookIds;

static DynamicHook g_dhook_CBaseProjectile_CanCollideWithTeammates;

void DHooks_Initialize(GameData gamedata)
{
	g_dynamicHookIds = new ArrayList();
	
	g_dhook_CBaseProjectile_CanCollideWithTeammates = DHooks_AddDynamicHook(gamedata, "CBaseProjectile::CanCollideWithTeammates");
}

void DHooks_OnEntityCreated(int entity, const char[] classname)
{
	if (!strncmp(classname, "tf_projectile_", 14))
	{						
		// Fixes projectiles sometimes not colliding with teammates
		DHooks_HookEntity(g_dhook_CBaseProjectile_CanCollideWithTeammates, Hook_Post, entity, DHookCallback_CBaseProjectile_CanCollideWithTeammates_Post);
		}
}

static DynamicHook DHooks_AddDynamicHook(GameData gamedata, const char[] name)
{
	DynamicHook hook = DynamicHook.FromConf(gamedata, name);
	if (!hook)
	{
		LogError("Failed to create hook setup handle: %s", name);
	}
	
	return hook;
}

static void DHooks_HookEntity(DynamicHook hook, HookMode mode, int entity, DHookCallback callback)
{
	if (hook)
	{
		int hookid = hook.HookEntity(mode, entity, callback, DHookRemovalCB_OnHookRemoved);
		if (hookid != INVALID_HOOK_ID)
		{
			g_dynamicHookIds.Push(hookid);
		}
	}
}

public void DHookRemovalCB_OnHookRemoved(int hookid)
{
	int index = g_dynamicHookIds.FindValue(hookid);
	if (index != -1)
	{
		g_dynamicHookIds.Erase(index);
	}
}

static MRESReturn DHookCallback_CBaseProjectile_CanCollideWithTeammates_Post(int entity, DHookReturn ret)
{
	if (!IsFriendlyFireEnabled())
		return MRES_Ignored;
	
	if (trikzProjCollideCheck()) // Always make projectiles collide with teammates
		ret.Value = true;
	if (!trikzProjCollideCheck()) // Normal game behavior (if too close, phases through)
		return MRES_Ignored;

	
	return MRES_Supercede;
}

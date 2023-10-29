#pragma newdecls required
#pragma semicolon 1

Handle g_hook_CBaseProjectile_CanCollideWithTeammates;

void DHooks_Initialize(GameData gamedata)
{
	g_dynamicHookIds = new ArrayList();
	
	g_dhook_CBaseProjectile_CanCollideWithTeammates = DHooks_AddDynamicHook(gamedata, "CBaseProjectile::CanCollideWithTeammates");
}

void DHooks_OnEntityCreated(int entity, const char[] classname)
{
	if (strncmp(classname, "tf_projectile_", 14) != 0 && ProjCollideValue() != 1) // if 1, just use default tf2 behavior
	{						
		// Fixes projectiles sometimes not colliding with teammates
		DHookToggleEntityListener(ListenType_Created, WhenEntityCreated, true);
	}
}

static MRESReturn Hook_CBaseProjectile_CanCollideWithTeammates(int self, Handle ret) {
    if (ProjCollideValue() == 0) // never collide projectiles with teammates
	{
		ret.Value = false;
		return MRES_Supercede;
	}
	if (ProjCollideValue() == 2) // Always make projectiles collide with teammates
	{
		ret.Value = true;
		return MRES_Supercede;
	}
	return MRES_Ignored;
}
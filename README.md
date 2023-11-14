# p4sstime

Competitive 4v4 PASS Time plugins and configs.

[Join the 4v4 PASS Time Discord today!](https://discord.com/invite/Vrk3Etg)

## Plugin Features

- Uploads PASS Time specific data to logs.tf for (hopefully) eventual display by logs.tf
- Fixes "uber bug" where medics who use ubercharge are not able to pick up the ball without respawning
- Prints chat messages for the following PASS Time events:
    - Scoring (with assists)
    - Saving/blocking
    - Intercepting
    - Stealing
    - Panaceas
    - Catapults (optional)
    - Handoffs
- Adds a mode to easily practice PASS Time bombs
- Every command and its effect below

### Commands

> [!IMPORTANT]
> First value before forward slash is default.

```
CLIENT
sm_ballhud               cmd    # Open menu to toggle hud text, chat text, or sound notifications when picking up the ball

SERVER
sm_pt_whitelist          0/1    # If 1, disables ability to equip shotgun, stickies, and needles; this is needed as whitelists can't normally block stock weapons.
sm_pt_respawn            0/1    # If 1, disables ability to switch classes while dead to instantly respawn.
sm_pt_hud                1/0    # If 1, disables the blurry screen overlay after intercepting or stealing.
sm_pt_drop_collision     1/0    # If 1, disables the jack colliding with dropped ammo packs or weapons.
sm_pt_stats              0/1    # If 1, enables printing of passtime events to chat both during and after games. If map begins with "pa", stats is enabled automatically. Does not affect logging.
sm_pt_stats_delay        7.5    # Set the delay between round end and the stats being displayed in chat.
sm_pt_save_radius        200    # Set the radius in hammer units from the goal that an intercept is considered a save.
sm_pt_practice           0/1    # If 1, enables practice mode. When the round timer reaches 5 minutes, add 5 minutes to the timer.
sm_pt_catapultprint      0/1    # If 1, enables catapult events printing to chat; temporary cvar until I have a better system for this
```

## Maps

[pass_arena2](https://tf2maps.net/downloads/pass_arena2.16840/)\
[pass_stadium](https://tf2maps.net/downloads/pass_stadium.15102/)\
[pass_stonework](https://tf2maps.net/downloads/pass_stonework.15974/)\
[pass_ufo](https://tf2maps.net/downloads/pass_ufo.16796/)\
[pass_park](https://tf2maps.net/downloads/park.16805/)

[4v4 PASS Time Map Archive](http://laxson.site.nfoservers.com/server/maps/)

## Credits

Contains work from:

[eaasye](https://github.com/eaasye/passtime/tree/master/addons/sourcemod/plugins)\
[drunderscore](https://github.com/drunderscore/SourcemodPlugins/blob/master/fix_uber_wearoff_condition.sp)\
[muddy](https://github.com/SirBlockles/pass-tweaks/blob/main/passtweaks.sp)\
[MGEMod](https://github.com/sapphonie/MGEMod/blob/master/addons/sourcemod/scripting/mge.sp#L546-L562); Direct hit detector\
Huge shoutout to the AlliedModders Discord for being the most helpful source of info ever.\
Thanks to those in The Dunking Dojo and those in the Official 4v4 PASS Time Discord for being my guinea pigs.

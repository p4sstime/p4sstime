# p4sstime

Competitive 4v4 PASS Time plugins, configs, and more.

[Join the 4v4 PASS Time Discord today!](https://discord.com/invite/Vrk3Etg)

## Plugin Features

- Uploads PASS Time specific data to logs.tf for display by [more.tf](https://more.tf)
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
sm_pt_practice           0/1    # If 1, enables practice mode. When the round timer reaches 5 minutes, add 5 minutes to the timer.
```

### Logs Example

Here are examples of each of the logs that the plugin will produce.
```
L 12/02/2023 - 00:05:32: "blake++<2><[U:1:95447021]><Red>" triggered "pass_get" (firstcontact "0") (position "531 -1486 392")
L 12/02/2023 - 00:05:38: "blake++<2><[U:1:95447021]><Red>" triggered "pass_free" (position "-733 -539 33")
L 12/02/2023 - 00:11:02: "blake++<5><[U:1:95447021]><Blue>" triggered "pass_score" (points "1") (panacea "0") (position "-8 1141 0")
L 12/02/2023 - 00:11:02: "jollypresents94<4><[U:1:177956067]><Blue>" triggered "pass_score_assist" (position "-41 -786 0")
L 12/02/2023 - 00:07:30: "jollypresents94<4><[U:1:177956067]><Red>" triggered "pass_pass_caught" against "blake++<2><[U:1:95447021]><Red>" (interception "0") (save "0") (handoff "0") (dist "55.343") (duration "0.780") (thrower_position "156 617 0") (catcher_position "-257 1200 0")
L 12/02/2023 - 00:10:20: "blake++<5><[U:1:95447021]><Blue>" triggered "pass_ball_stolen" against "jollypresents94<4><[U:1:177956067]><Red>" (thief_position "337 -502 0") (victim_position "385 -492 0")
L 12/02/2023 - 00:00:05: "blake++<2><[U:1:95447021]><Red>" triggered "pass_trigger_catapult" with the jack (position "-593 -1012 0")
L 12/02/2023 - 00:12:00: "blake++<5><[U:1:95447021]><Red>" triggered "pass_ball_blocked" against "jollypresents94<4><[U:1:177956067]><Blue>" (thrower_position "348 870 0") (blocker_position "210 799 475")
```

## Maps

[pass_arena2](https://tf2maps.net/downloads/pass_arena2.16840/)\
[pass_stadium](https://tf2maps.net/downloads/pass_stadium.15102/)\
[pass_stonework](https://tf2maps.net/downloads/pass_stonework.15974/)\
[pass_ufo](https://tf2maps.net/downloads/pass_ufo.16796/)\
[pass_park](https://tf2maps.net/downloads/park.16805/)

[4v4 PASS Time Map Archive](http://laxson.site.nfoservers.com/server/maps/)

## For Mappers

Certain entities and properties need to be named certain things for them to work with the plugin's logging capabilities.

- All map catapults need to have a classname of `trigger_catapult` and an output named `OnCatapulted`.
- All ball spawners need to have a classname of `info_passtime_ball_spawn` and an output named `OnSpawnBall`.

When in doubt, mirror arena2's names and outputs, as they are the standard I'll be using.

## Recommended Plugins

[JumpQOL](https://github.com/chrb22/jumpqol/) - Fixes a lot of issues with blastjumping mechanics in TF2

## Credits

Contains work from:

[eaasye](https://github.com/eaasye/passtime/tree/master/addons/sourcemod/plugins)\
[drunderscore](https://github.com/drunderscore/SourcemodPlugins/blob/master/fix_uber_wearoff_condition.sp)\
[muddy](https://github.com/SirBlockles/pass-tweaks/blob/main/passtweaks.sp)\
[MGEMod](https://github.com/sapphonie/MGEMod/blob/master/addons/sourcemod/scripting/mge.sp#L546-L562); Direct hit detector\
Huge shoutout to the AlliedModders Discord for being the most helpful source of info ever.\
Thanks to those in The Dunking Dojo and those in the Official 4v4 PASS Time Discord for being my guinea pigs.

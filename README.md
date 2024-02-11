# p4sstime

Competitive 4v4 PASS Time plugins, configs, and more.

[Join the 4v4 PASS Time Discord today!](https://discord.com/invite/Vrk3Etg)

## Plugin Features

- Uploads PASS Time specific data to logs.tf for display by [more.tf](https://more.tf) using in-game commands
- Fixes "uber bug" where medics who use Ubercharge are not able to pick up the ball without respawning
- Simple PASS Time specific anticheat
- Prints chat messages for the following PASS Time events:
    - Scoring (with assists)
    - Saving/blocking
    - Intercepting
    - Stealing
    - Panaceas
    - Win strats
    - Handoffs
    - Etc
- Prints end of round statistics in chat (optional) and in console
- Every command and its effect below

### Commands

> [!IMPORTANT]
> First value before forward slash is default.

```
CHAT
/more, .more - Open most recent log in more.tf in-game.
/pass, .pass, /p4ss, .p4ss - Open up the client settings menu.

CLIENT
sm_pt_menu               cmd    # Open menu to change plugin-specific client settings (shown below).
sm_pt_suicide            cmd    # Commit suicide; good for a type of bomb called a deathbomb.
sm_pt_jackpickup_hud     0/1    # If 1, show HUD message when you pick up the JACK.
sm_pt_jackpickup_chat    0/1    # If 1, show chat message when you pick up the JACK.
sm_pt_jackpickup_sound   0/1    # If 1, play sound when you pick up the JACK.
sm_pt_simplechatprint    0/1    # If 1, simplify end of round chat summaries.
sm_pt_togglechatprint    1/0    # Toggle printing of end of round chat summaries.

SERVER
sm_pt_stock_blocklist                       0/1    # If 1, disable ability to equip shotgun, stickies, and needles; this is needed as allowlists can't normally block stock weapons.
sm_pt_block_instant_respawn                 0/1    # If 1, disable class switch ability while dead to instantly respawn.
sm_pt_disable_intercept_blur                1/0    # If 1, disable blurry screen overlay after intercepting or stealing.
sm_pt_disable_jack_drop_item_collision      1/0    # If 1, disables the jack colliding with dropped ammo packs or weapons.
sm_pt_print_events                          0/1    # If 1, enables printing of passtime events to chat both during and after games. Does not affect logging.
sm_pt_practice                              0/1    # If 1, enables practice mode. When the round timer reaches 5 minutes, add 5 minutes to the timer.
```

### Logs Example

Here are examples of each of the logs that the plugin will produce.
```
L 02/10/2024 - 16:15:43: "blake++<2><[U:1:95447021]><Red>" triggered "pass_get" (firstcontact "1") (position "16 34 446")
L 02/10/2024 - 16:15:44: "blake++<2><[U:1:95447021]><Red>" triggered "pass_free" (position "46 -591 468")
L 02/10/2024 - 16:16:04: "blake++<2><[U:1:95447021]><Red>" triggered "pass_score" (points "1") (panacea "0") (win strat "0") (dist "302") (position "46 -1328 14")
L 02/10/2024 - 16:41:46: "Morbidly_Obese_Dog<3><[U:1:1095402112><Red>" triggered "pass_score_assist" (position "-607 667 0")
L 02/10/2024 - 16:41:44: "blake++<2><[U:1:95447021]><Red>" triggered "pass_pass_caught" against "Morbidly_Obese_Dog<3><[U:1:1095402112><Red>" (interception "0") (save "0") (handoff "0") (dist "75.688") (duration "1.184") (thrower_position "-0 -263 159") (catcher_position "-607 667 0")
L 02/10/2024 - 16:43:36: "Morbidly_Obese_Dog<3><[U:1:1095402112><Red>" triggered "pass_ball_stolen" against "blake++<2><[U:1:95447021]><Blue>" (steal defense "0") (thief_position "201 -538 0") (victim_position "170 -485 0")
L 02/10/2024 - 16:44:14: "blake++<2><[U:1:95447021]><Blue>" triggered "pass_ball_blocked" against "Morbidly_Obese_Dog<3><[U:1:1095402112><Red>" (thrower_position "-14 -1303 0") (blocker_position "-27 -918 0")

L 02/10/2024 - 16:15:59: passtime_ball spawned from the upper spawnpoint.
L 02/10/2024 - 16:15:59: passtime_ball spawned from the lower spawnpoint.
L 02/10/2024 - 16:15:59: passtime_ball spawned from the right spawnpoint.
L 02/10/2024 - 16:15:59: passtime_ball spawned from the left spawnpoint.

L 02/10/2024 - 16:26:13: "blake++<2><[U:1:95447021]><Red>" triggered "red_catapult1" with the jack (position "-711 -1258 0")
L 02/10/2024 - 16:26:13: "blake++<2><[U:1:95447021]><Red>" triggered "red_catapult2" with the jack (position "-711 -1258 0")
L 02/10/2024 - 16:26:13: "blake++<2><[U:1:95447021]><Red>" triggered "blu_catapult1" with the jack (position "-711 -1258 0")
L 02/10/2024 - 16:26:13: "blake++<2><[U:1:95447021]><Red>" triggered "blu_catapult2" with the jack (position "-711 -1258 0")
```

## Maps

_Exer's_\
[pass_arena2](https://tf2maps.net/downloads/pass_arena2.16840)\
[pass_stadium](https://tf2maps.net/downloads/pass_stadium.15102)\
[pass_stonework](https://tf2maps.net/downloads/pass_stonework.15974)\
pass_colosseum2\
pass_greenhouse

_Yo Yo Bobby Joe's_\
[pass_park](https://tf2maps.net/downloads/park.16805)\
[pass_skyline](https://tf2maps.net/downloads/skyline.17153)\
[pass_aquarium](https://tf2maps.net/downloads/aquarium.17211/)

_DropKnock's_\
[pass_ufo](https://tf2maps.net/downloads/pass_ufo.16796)\
[pass_ruin](https://tf2maps.net/downloads/pass_ruin.14697)

## For Mappers

Certain entities and properties need to be named certain things for them to work with the plugin's logging capabilities.

Below are the requirements for having your map work with the plugin. The reason for changing these is that it allows me to log more things like which spawn the jack spawns from.

### Entity Names:
**Right/Left based off of RED spawn**
```
Top info_passtime_ball_spawn name: "passtime_ball_spawn1"
Bottom info_passtime_ball_spawn name: "passtime_ball_spawn2"
Right info_passtime_ball_spawn name: "passtime_ball_spawn3"
Left info_passtime_ball_spawn name: "passtime_ball_spawn4"
```
```
Top spawn trigger_catapult name: "spawn_catapult1"
Bottom spawn trigger_catapult name: "spawn_catapult2"
Right spawn trigger_catapult name: "spawn_catapult3"
Left spawn trigger_catapult name: "spawn_catapult4"
```
```
RED Right trigger_catapult name: "red_catapult1"
RED Left trigger_catapult name: "red_catapult2"
```
```
RED Right/Main func_respawnroom name: "red_respawnroom1"
RED Left func_respawnroom name: "red_respawnroom2"
```
```
RED Right/Main info_player_teamspawn name: "red_respawnpoint1"
RED Left info_player_teamspawn name: "red_respawnpoint2"
```
**Right/Left based off of BLU spawn**
```
BLU Right trigger_catapult name: "blu_catapult1"
BLU Left trigger_catapult name: "blu_catapult2"
```
```
BLU Right/Main func_respawnroom name: "blu_respawnroom1"
BLU Left func_respawnroom name: "blu_respawnroom2"
```
```
BLU Right/Main info_player_teamspawn name: "blu_respawnpoint1"
BLU Left info_player_teamspawn name: "blu_respawnpoint2"
```

- All map catapults need to have a classname of trigger_catapult and an output named OnCatapulted.
- All ball spawners need to have a classname of info_passtime_ball_spawn and an output named OnSpawnBall.

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

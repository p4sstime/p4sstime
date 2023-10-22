# passtime-fixes

A mashup of fixes for 4v4 PASStime.

[Join the Official 4v4 PASS Time Discord today!](https://discord.com/invite/Vrk3Etg)

[Check out the 4v4 PASS Time settings repository here.](https://github.com/eaasye/passtime)

## Plugin Features

- Uploads passtime-specific data to logs.tf for (hopefully) eventual display by logs.tf

- Fixes "uber bug" where medics who use ubercharge are not able to pick up the ball without respawning

- Prints chat messages for the following:
	- Scoring
	- Intercepting
	- Stealing
	- Panaceas
	- Catapults
	- Ball airshots
	- Handoffs

- Adds a custom variant of 4v4 PASS Time called PASS Time Trikz where friendly knockback (no damage) is added and can be controlled to be based on airshots only, damage in air only, or everywhere (beta)

- Adds a mode to easily practice PASS Time bombs

### Commands

> [!IMPORTANT]
> First value before forward slash is default.

```
CLIENT
sm_ballhud                     cmd    # Open menu to toggle hud text, chat text, or sound notifications when picking up the ball

SERVER
sm_passtime_whitelist          0/1    # Toggles ability to equip shotgun, stickies, and needles
sm_passtime_respawn            0/1    # Toggles class switch ability while dead to instantly respawn
sm_passtime_hud                1/0    # Toggles the blurry screen overlay after intercepting or stealing
sm_passtime_disable_collisions 1/0    # Toggles whether the jack will collide with dropped ammo packs or weapons
sm_passtime_stats              0/1    # Toggles printing of players' total scores, saves, intercepts, and steals to chat after a game is over; automatically set to 1 if a map name starts with "pa"
sm_passtime_stats_delay        7.5    # Set the delay between round end and the stats being displayed in chat
sm_passtime_stats_save_radius  200    # Set the radius in hammer units from the goal that an intercept is considered a save
sm_passtime_trikz			  0/1/2/3 # Set 'trikz' mode. 1 adds friendly knockback for airshots, 2 adds friendly knockback for splash damage, 3 adds friendly knockback for everywhere
sm_passtime_practice		   0/1	  # Toggle practice mode. If 1, then when the round timer reaches 5 minutes, add 5 minutes to the timer.
```

## TODO
Need to Test:
-splash damage still doing damage on teammates trikz 1/2; trying with damage 0 to fix; need to check if enemies still get damage by the rocket splash; seems to work? need 2 others
-do friendly player airshots count towards airshot counter on logs.tf
-test like literally everything again due to restructuring

Fix rocket player collide on mp_friendlyfire; should've fixed it; test
Fix handoff does not even get triggered; test 3
Fix ball airshots not triggering; test 3
Fix panacea check does not account for if you are on the ground when the goal is scored
Remove forced whitelist stuff? Waiting on EasyE reply

- [ ] Track distance for scores; add to logs and chat msg thing
- [ ] Track ball carrier airshots; send as logs and chatmsg; (if player carrying ball gets airshot, it's a ball carrier airshot)
- [ ] Talk with EasyE about putting his plugins on his repo in a deprecated folder; also his whitelist is not updated; we use his as CFG and whitelist repo, use mine as the plugin. link to each other.
- [ ] Communicate with logs.tf owner to have PASS stats display on logs (need to talk to Arie or Underscore to see if they can get in contact?)

## Eventual Additions

- [ ] sm_ballhud settings do not save

The below unique bombs may require special map triggers that have not been added yet. Purely conceptual.

### Easy:
- Track mega-high bombs; send as logs and chat msg (if player reaches z level of 3000, it's a mega-high bomb) [Example](https://www.youtube.com/watch?v=WWJ2iuPBGTM); use map entities (using code would be unnecessarily taxing)
- Track pull bombs; send as logs and chat msg; (if ball gets splashed within half of a second of spawning, and it's caught in the air/hits side surf and then player scores while in the air, it's a pull bomb) [Example](https://youtu.be/2CgDMvSvXAc?t=228)
- Track push bombs; send as logs and chat msg; (if ball gets splashed from front or back leaf within half a second of spawning, and it's caught in the air then player scores while in the air, it's a push bomb)
- Track deathbombs; send as logs and chat msg; (if ball goes into goal and player who last had it died already in the air, it's a deathbomb)
	- Use inAir and onPlayerDeath?
- Track Stadium water syncs; go from in-air (off surf) to in water to hit certain height (using map entities just from water would make this super easy lol)
- Track Griff bombs; send as logs and chat msg; (if loops are made around arena ramps at least once then score, it's a griff bomb)
  	- Needs map entities first to fire outputs we can hook onto, then count
- Track Goblin/Gorblin bombs; send as logs and chat msg; (goblin has ball go through holes, gorblin has you go through holes with ball); use map entities

### Medium:
- Track splash defense; send as logs and chat msg?
	- Use the same radius; if ball goes neutral within radius of goal due to splash, it's splash defense; making this consistent is the hard part i think

### Impossible:
For these, I just don't know how I would track them. Could be easily possible

- Lobs (maybe somehow hook onto ball throw and see where viewangles are to determine lob?)
- Demo instadets
- Dribbledet
- [Pretty much every other bomb not listed already](https://www.youtube.com/watch?v=TGivc75TSQI)

## Credits

Contains work from:

[eaasye](https://github.com/eaasye/passtime/tree/master/addons/sourcemod/plugins)

[drunderscore](https://github.com/drunderscore/SourcemodPlugins/blob/master/fix_uber_wearoff_condition.sp)

[muddy](https://github.com/SirBlockles/pass-tweaks/blob/main/passtweaks.sp)

[MGEMod](https://github.com/sapphonie/MGEMod/blob/master/addons/sourcemod/scripting/mge.sp#L546-L562); Direct hit detector

Huge shoutout to the AlliedModders Discord for being the most helpful source of info ever.

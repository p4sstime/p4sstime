# p4sstime-fixes

A mashup of fixes for 4v4 PASStime.

[Join the Official 4v4 PASS Time Discord today!](https://discord.com/invite/Vrk3Etg)

## Plugin Features

- Uploads passtime-specific data to logs.tf for (hopefully) eventual display by logs.tf

- Fixes "uber bug" where medics who use ubercharge are not able to pick up the ball without respawning

- Prints chat messages for the following:
	- Scoring
	- Intercepting
	- Stealing
	- Panaceas
	- Catapults

### Commands

> [!IMPORTANT]
> First value before forward slash is default.

```
CLIENT
sm_ballhud                     cmd    # Open menu to toggle hud text, chat text, or sound notifications when picking up the ball

SERVER
sm_passtime_whitelist          0/1    # Disables shotgun, stickies, and needles
sm_passtime_respawn            0/1    # Prevents switches classes while dead to instantly respawn
sm_passtime_hud                1/0    # Disables the blurry screen overlay after intercepting or stealing
sm_passtime_disable_collisions 0/1    # Prevents the jack from colliding with dropped ammo packs or weapons
sm_passtime_stats              0/1    # Prints players total scores, saves, intercepts, and steals to chat after a game is over; automatically set to 1 if a map name starts with "pa"
sm_passtime_stats_delay        7.5    # Change the delay between a team winning and the stats being displayed in chat
```

## TODO

- [ ] Communicate with logs.tf owner to have PASS stats display on logs (in progress, waiting on reply)
- [ ] Rename pre and post functions to make more sense and reorganize them based on that for easier work
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
	- Use the same radius; if ball goes neutral within radius of goal due to splash, it's splash defense
- Track ball airshots; send as logs and chatmsg; (if ball gets shot while in the air, it's a ball airshot)
  	- Somehow hook onto projectiles and see if they hit ball while it's midair; use FL_ONGROUND?

### Hard:
- Track ball carrier airshots; send as logs and chatmsg; (if player carrying ball gets airshot, it's a ball carrier airshot); look at [substats2.sp](https://github.com/F2/F2s-sourcemod-plugins/blob/master/supstats2/supstats2.sp)
- Track handoffs; send as logs and chat msg? [Ramp Handoff Example](https://www.youtube.com/watch?v=vL9x8PUDE2Q) [Air Handoff Example](https://www.youtube.com/watch?v=x7fKfVuBEjc)

### Impossible:
For these, I just don't know how I would track them. Could be easily possible

- Demo instadets
- Dribbledet
- [Pretty much every other bomb not listed already](https://www.youtube.com/watch?v=TGivc75TSQI)

## Credits

Contains work from:

[eaasye](https://github.com/eaasye/passtime/tree/master/addons/sourcemod/plugins)

[drunderscore](https://github.com/drunderscore/SourcemodPlugins/blob/master/fix_uber_wearoff_condition.sp)

[muddy](https://github.com/SirBlockles/pass-tweaks/blob/main/passtweaks.sp)

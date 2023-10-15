# p4sstime-fixes

A mashup of fixes for 4v4 PASStime.

[Join the Official 4v4 PASS Time Discord today!](https://discord.com/invite/Vrk3Etg)

## Plugin Features

- Uploads passtime-specific data to logs.tf for (hopefully) eventual display by logs.tf

- Fixes "uber bug" where medics who use ubercharge are not able to pick up the ball without respawning

- Prints chat messages upon a player scoring, intercepting, or stealing during game

- Recognizes unique bombs like Panaceas

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
- [ ] Track Griff bombs; send as logs and chat msg; (if ball pass takes ??? distance, it's a griff bomb (it's like griff going in loops in arena))
- [ ] Track deathbombs; send as logs and chat msg; (if ball goes into goal neutral and player who last had it is dead, it's a deathbomb)
- [ ] Track goal defenses; send as logs and chat msg; (if ball is intercepted within ??? hammer units of goal, it's a defense)
- [ ] Track ball carrier airshots; send as logs and chatmsg; (if player carrying ball gets airshot, it's a ball carrier airshot)
- [ ] Track ball airshots; send as logs and chatmsg; (if ball gets shot while in the air, it's a ball airshot)
- [ ] Track pull bombs; send as logs and chat msg; (if ball gets splashed within half of a second of spawning, and someone picks it up within ???, it's a pull bomb?)
- [ ] Track catapults; send as logs and chat msg?
- [ ] Track handoffs; send as logs and chat msg?
- [ ] Track splash defense; send as logs and chat msg?

## Credits

Contains work from:

[eaasye](https://github.com/eaasye/passtime/tree/master/addons/sourcemod/plugins)

[drunderscore](https://github.com/drunderscore/SourcemodPlugins/blob/master/fix_uber_wearoff_condition.sp)

[muddy](https://github.com/SirBlockles/pass-tweaks/blob/main/passtweaks.sp)

# p4sstime-fixes

A mashup of fixes for 4v4 PASStime.

[Join the Official 4v4 PASS Time Discord today!](https://discord.com/invite/Vrk3Etg)

## Plugin Features

- Uploads passtime-specific data to logs.tf for (hopefully) eventual display by logs.tf

- Fixes "uber bug" where medics who use ubercharge are not able to pick up the ball without respawning

- Prints chat messages upon a player scoring, intercepting, or stealing during game

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

- [ ] Communicate with logs.tf owner to have PASS stats display on logs

## Credits

Contains work from:

[eaasye](https://github.com/eaasye/passtime/tree/master/addons/sourcemod/plugins)

[drunderscore](https://github.com/drunderscore/SourcemodPlugins/blob/master/fix_uber_wearoff_condition.sp)

[muddy](https://github.com/SirBlockles/pass-tweaks/blob/main/passtweaks.sp)

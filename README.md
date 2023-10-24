# passtime-fixes

A mashup of fixes and features for Competitive 4v4 PASS Time.

[Join the Official 4v4 PASS Time Discord today!](https://discord.com/invite/Vrk3Etg)

[Check out the 4v4 PASS Time settings repository here.](https://github.com/eaasye/passtime)

## Plugin Features

- Uploads PASS Time specific data to logs.tf for (hopefully) eventual display by logs.tf

- Fixes "uber bug" where medics who use ubercharge are not able to pick up the ball without respawning

- Prints chat messages for the following PASS Time events:
    - Scoring (with assists)
    - Saving/blocking
    - Intercepting
    - Stealing
    - Panaceas
    - Catapults
    - Ball carrier airshots
    - Handoffs

- Adds a custom variant of 4v4 PASS Time called PASS Time Trikz where friendly knockback (no damage) is added and can be controlled to be based on airshots only, damage in air only, or everywhere

- Adds a mode to easily practice PASS Time bombs

- Every command and its effect below

### Commands

> [!IMPORTANT]
> First value before forward slash is default.

```
CLIENT
sm_ballhud               cmd    # Open menu to toggle hud text, chat text, or sound notifications when picking up the ball

SERVER
sm_pt_whitelist          0/1    # Toggles ability to equip stock shotgun, stickies, and needles; this is needed as whitelists can't normally block stock weapons
sm_pt_respawn            0/1    # Toggles class switch ability while dead to instantly respawn
sm_pt_hud                1/0    # Toggles the blurry screen overlay after intercepting or stealing
sm_pt_disable_collisions 1/0    # Toggles whether the jack will collide with dropped ammo packs or weapons
sm_pt_stats              0/1    # Toggles printing of passtime events to chat both during and after games; automatically set to 1 if a map name starts with 'pa'; does not stop logging
sm_pt_stats_delay        7.5    # Set the delay between round end and the stats being displayed in chat
sm_pt_stats_save_radius  200    # Set the radius in hammer units from the goal that an intercept is considered a save
sm_pt_trikz            0/1/2/3  # Set 'trikz' mode. 1 adds friendly knockback for airshots, 2 adds friendly knockback for splash damage, 3 adds friendly knockback for everywhere
sm_pt_trikz_projcollide 0/1/2   # Set team projectile collision behavior. 2 always collides, 1 will cause your projectiles to phase through if you are too close (default game behavior), 0 will cause them to never collide.
sm_pt_practice           0/1    # Toggle practice mode. If 1, then when the round timer reaches 5 minutes, add 5 minutes to the timer.
```

## TODO
Need to Test:
- retest trikz totally; projcollide is not setting to the right values, its going to 0 and staying there

- retest projcollide on its own since we switched to pre

- need to retest practice mode since i changed it from only activating when OnHook5Minutes is called to anytime the cvar is changed. basically it should instantly add 5 minutes to the timer, then create a timer that adds another 5 to the timer for 5 minutes. let it repeat another time, thene turn it off and make sure game ends when it should.

- Make sure everything still goes to logs as expected; Do saves, friendly airshots, ball carrier airshots, handoffs send to logs.tf? Do friendly player airshots count towards airshot counter on logs.tf?

- [ ] Send a pull request to EasyE passtime repo about putting his plugins on his repo in a deprecated folder; also his whitelist is not updated; we use his as CFG and whitelist repo, use mine as the plugin. link to each other.
- [ ] Communicate with logs.tf owner to have PASS stats display on logs (need to talk to Arie or Underscore to see if they can get in contact?)

## Eventual Additions

- [ ] Track distance for scores; add to logs and chat msg thing (dhooks somehow?); pass_free is an event that triggers whenever the ball is thrown
- [ ] Spec hud that shows you who has ball, pass targets, etc

The below unique bombs may require special map triggers that have not been added yet. Purely conceptual.

### Easy:
- Track mega-high bombs; send as logs and chat msg (if player reaches z level of 3000, it's a mega-high bomb) [Example](https://www.youtube.com/watch?v=WWJ2iuPBGTM); use map entities (using code would be unnecessarily taxing)
- Track pull bombs; send as logs and chat msg; (if ball gets splashed within half of a second of spawning, and it's caught in the air/hits side surf and then player scores while in the air, it's a pull bomb) [Example](https://youtu.be/2CgDMvSvXAc?t=228)
- Track push bombs; send as logs and chat msg; (if ball gets splashed from front or back leaf within half a second of spawning, and it's caught in the air then player scores while in the air, it's a push bomb)
- Track deathbombs; send as logs and chat msg; (if ball goes into goal and player who last had it killbinded already in the air, it's a deathbomb)
    - Use inAir and onPlayerDeath?
- Track Stadium water syncs; go from in-air (off surf) to in water to hit certain height (using map entities just from water would make this super easy lol)
- Track Griff bombs; send as logs and chat msg; (if loops are made around arena ramps at least once then score, it's a griff bomb)
    - Needs map entities first to fire outputs we can hook onto, then count
- Track Goblin/Gorblin bombs; send as logs and chat msg; (goblin has ball go through holes, gorblin has you go through holes with ball); use map entities

### Hard:
- Track splash defense; send as logs and chat msg?
    - Use the same radius; if ball goes neutral within radius of goal due to splash, it's splash defense

### Impossible:
For these, I just don't know how I would track them. Could be easily possible, I just don't have knowledge.

- Ball airshots ([AlliedMods says](https://discord.com/channels/335290997317697536/335290997317697536/1165720293684301866): SDKHooks cannot detect since ball uses collision hull, for proper accuracy you'd need a detour on the entity method that gets called on a collision, not home to check its name (extension called passfilter does that?). alternatively can do a trace hull iterator with entity bounds each frame to find entities inside)
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

[Fixed Friendly Fire](https://github.com/Mikusch/friendlyfire); Remove distance-based projectile blocking on teammates when mp_friendlyfire 1

Huge shoutout to the AlliedModders Discord for being the most helpful source of info ever.

# p4sstime-fixes
A mashup of fixes for 4v4 PASStime.

## Plugin Features

Disables shotgun, stickies, and needles via sm_passtime_whitelist 1/0 (def. 0)

Prevents switches classes while dead to instantly respawn via sm_passtime_respawn 1/0 (def. 0)

Disables the blurry screenoverlay after intercepting or stealing via sm_passtime_hud 1/0 (def. 1)

Prevents the jack from colliding with dropped ammo packs or weapons via sm_passtime_disable_collisions 1/0 (def. 0)

Turn on hud text, chat text, or sound notifcations when picking up the ball via sm_ballhud

Prints chat messages upon a player scoring, intercepting, or stealing

Prints players total scores, saves, intercepts, and steals to chat after a game is over via sm_passtime_stats 1/0 (def. 0)

Change the delay between a team winning and the stats being displayed in chat via sm_passtime_stats_delay (def. 7.5)

sm_passtime_stats will be automatically set to 1 if the map name begins with "pa"

Fixes "uber bug" where medics who use ubercharge are not able to pick up the ball after without respawning

## Credits

Contains work from:
[eaasye](https://github.com/eaasye/passtime/tree/master/addons/sourcemod/plugins)
[drunderscore](https://github.com/drunderscore/SourcemodPlugins/blob/master/fix_uber_wearoff_condition.sp)

## Notes

https://sourcemod.dev/#/sdkhooks/typeset.SDKHookCB for parameters
OnTakeDamage -> When a player is damaged, you can change parameters here like modifying damage
OnTakeDamagePost -> After a player has been damaged, cannot change parameters
OnTakeDamageAlive -> After player has been damaged, but before damage bonuses e.g. crits are applied, can also change parameters here
OnTakeDamageAlivePost -> After player has been damaged, period. Cannot change parameters here

player_askedforball is NOT a real event; https://discord.com/channels/335290997317697536/335290997317697536/1180394803020693565 sourcemod discord server

passget prehook occurs AFTER ball throw

tf2 ent props - https://lmaobox.net/lua/TF2_props/

rj and sj events are not fired when lifted up by another player
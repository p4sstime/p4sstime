# Client Mods

These are a small collection of PASS Time specific modifications clients can do to their game that they can use in pugs/tournaments.

## Removing the PASS Time Power Meter from your HUD

![PASS Time Power Meter Example](https://i.imgur.com/LbQj0Ur.jpeg)

This hud element is really intrusive, but luckily for us, we can remove it. All we have to do is modify `hudpasstimeballstatus.res` in `/resource/ui`.

Click on the following case that applies to you.\
I am using:
[Custom HUD & File Exists](#custom-hud--file-exists-pt-powermeter-remover)
[Custom HUD & File Not Found](#custom-hud--file-not-found-pt-powermeter-remover)
[Default HUD](#default-hud-pt-powermeter-remover)

## Removing or Modifying PASS Time HUD Labels

Sometimes the PASS Time ball HUD text for events can be intrusive or even useless (for example, +CRIT does not apply to 4v4 PASS Time). Thankfully, we can also modify these elements.
![PASS Time Event Hud Text Example](https://i.imgur.com/c9YAXXG.png)
Go to your `custom` folder and open the HUD folder. Then go to `resource/ui/` and create a file named `hudpasstimeballstatus.res`.

[Custom HUD & File Exists](#custom-hud--file-exists-pt-hudeventlabels)
[Custom HUD & File Not Found](#custom-hud--file-not-found-pt-hudeventlabels)
[Default HUD](#default-hud-pt-hudeventlabels)

## Custom PASS Time Reticles

Not a fan of the default PASS Time ball reticle?
![PASS Time Ball Reticle Example](https://i.imgur.com/sWvgo0R.png)
As long as you're in a server with sv_pure set to 0, you can use these. Otherwise, it'll just go back to the default crosshair.

Simply place one of the folders inside the `passtime-crosshairs` archive into your `custom` folder.

The crosshairs are originally created by slamborghini and can be found in the Official 4v4 PASS Time Discord. I just wanted to archive them in another place.

# END OF FILE

### Custom HUD & File Exists (pt-powermeter-remover)

Go to your `custom` folder and open the HUD folder. Then go to `resource/ui/` and open up `hudpasstimeballstatus.res`. CTRL + F for `BallPowerCluster`.

Should look something like this:
```
"BallPowerCluster"
    {
        "ControlName"                                "EditablePanel"
        "fieldName"                                    "BallPowerCluster"
        "xpos"                                        "0"
        "ypos"                                        "0"
        "zpos"                                        "5"
        "wide"                                        "f0"
        "tall"                                        "f0"
        "visible"                                    "1"
        "enabled"                                    "1"

        ...
```
Change the `wide` value from `f0` to `0`.
Click save and now you can run `hud_reloadscheme` in console (if that doesn't work just restart your game). The meter should now be removed!

### Custom HUD & File Not Found (pt-powermeter-remover)

Go to your `custom` folder and open the HUD folder. Then go to `resource/ui/` and create a file named `hudpasstimeballstatus.res`. Paste in the following code and hit save.

```
"Resource/UI/HudPasstimeBallStatus.res"
{
	"BallPowerCluster"
	{
		"ControlName"								"EditablePanel"
		"fieldName"									"BallPowerCluster"
		"xpos"										"0"
		"ypos"										"0"
		"zpos"										"5"
		"wide"										"0"
		"tall"										"f0"
		"visible"									"1"
		"enabled"									"1"
	}
}
```

### Default HUD (pt-powermeter-remover)

Download the `pt-powermeter-remover` archive and put the folder inside into `YOUR_STEAM_LIBRARY\steamapps\common\Team Fortress 2\tf\custom`.

### Custom HUD & File Exists (pt-hudeventlabels)

### Custom HUD & File Not Found (pt-hudeventlabels)

### Default HUD (pt-hudeventlabels)
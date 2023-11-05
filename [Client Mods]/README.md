# pt-powermeter-remover
## Removing the PASS Time Power Meter from your HUD

https://i.imgur.com/LbQj0Ur.jpeg

This hud element is really intrusive, but luckily for us, we can remove it.

## If you're using a custom HUD...

Go to your custom folder where you put the HUD and open the HUD folder. Then go to resource/ui/ and open up hudpasstimeballstatus.res. CTRL + F for "BallPowerCluster".

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
Change the "wide" value to "0".
Done! Click save and now you can run hud_reloadscheme in console (if that doesn't work just restart your game), and you will be able to see the changes!

## If you're using a custom HUD that doesn't have the file...

Go to your custom folder and create a folder called and open the HUD folder. Then go to resource/ui/ and create a file named hudpasstimeballstatus.res. Paste in the following code and hit save.

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

## If you're using the default HUD...

Download the "passtime-powermeter-remover" folder and put it in "D:\SteamLibrary\steamapps\common\Team Fortress 2\tf\custom".

---

# passtime_crosshairs
## Custom PASS Time Reticles

Not a fan of the default PASS Time ball reticle?
https://i.imgur.com/iyfqqyG.png
As long as you're in a server with sv_pure set to 0, you can use these. Otherwise, it'll just go back to the default crosshair.

Simply place one of the folders inside the "passtime-crosshairs" folder into your custom folder.

The crosshairs are originally created by slamborghini and can be found in the Official 4v4 PASS Time Discord. I just wanted to archive them in another place.
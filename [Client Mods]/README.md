# Client Mods

These are a small collection of PASS Time specific modifications clients can do to their game that they can use in pugs/tournaments.

## Removing the PASS Time Power Meter from your HUD

![PASS Time Power Meter Example](https://i.imgur.com/LbQj0Ur.jpeg)

This hud element is really intrusive, but luckily for us, we can remove it.

If you have a custom HUD, go to your `custom` folder and open the HUD folder. Then go to `resource/ui/` and look for a file named `hudpasstimeballstatus.res`. If the file exists, [click here](#custom-hud--file-exists-removing-power-meter).

If you are using the default HUD or a custom HUD that does not have the file, simply download the `pt-hudmod` archive and put the folder inside into `YOUR_STEAM_LIBRARY\steamapps\common\Team Fortress 2\tf\custom\`.

## Removing or Modifying PASS Time HUD Labels

Sometimes the PASS Time ball HUD text for events can be intrusive or even useless (for example, +CRIT does not apply to 4v4 PASS Time). Thankfully, we can also modify these elements (although it's a bit more difficult than removing the power meter).
![PASS Time Event Hud Text Example](https://i.imgur.com/c9YAXXG.png)
If you have a custom HUD, go to your `custom` folder and open the HUD folder. Then go to `resource/ui/` and look for a file named `hudpasstimeballstatus.res`. If the file exists, [click here](#custom-hud--file-exists-changing-labels).

Otherwise, [click here](#custom-hud--file-not-found-or-default-hud-changing-labels).

## Custom PASS Time Reticles

Not a fan of the default PASS Time ball reticle?
![PASS Time Ball Reticle Example](https://i.imgur.com/sWvgo0R.png)
As long as you're in a server with sv_pure set to 0, you can use these. Otherwise, it'll just go back to the default crosshair.

Simply place one of the folders inside the `passtime-crosshairs` archive into your `custom` folder.

The crosshairs are originally created by slamborghini and can be found in the Official 4v4 PASS Time Discord. I just wanted to archive them in another place.

# END OF FILE
<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

### Custom HUD & File Exists (Removing Power Meter)

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

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

### Custom HUD & File Exists (Changing Labels)

Open up the `hudpasstimeballstatus.res` file and CTRL + F for the text you want. As shown in the example before, the +CRIT message is `EventBonusLabel`, the event name (RED SCORE) is `EventTitleLabel`, and the person who caused the event is `EventDetailLabel`.

To remove, for any `Event____Label`:\
Change the `tall` value to `0`.

If you wish to change the positioning of any elements, [use this reference document](https://github.com/rbjaxter/budhud/wiki/Element-Positioning).\
If you wish to change the font to a different one, [follow this guide](#change-the-font-for-pass-time-hud-labels-changing-labels).\
If you wish to add a totally new font that isn't installed in your HUD, [follow this guide](https://github.com/rbjaxter/budhud/wiki/Adding---Replacing-Custom-Fonts#guide).

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

### Custom HUD & File Not Found OR Default HUD (Changing Labels)

Download the `pt-hudmod` archive and put the folder inside into `YOUR_STEAM_LIBRARY\steamapps\common\Team Fortress 2\tf\custom\`. Open up the `hudpasstimeballstatus.res` file and CTRL + F for the text you want. As shown in the example before, the +CRIT message is `EventBonusLabel`, the event name (RED SCORE) is `EventTitleLabel`, and the person who caused the event is `EventDetailLabel`.

To remove, for any `Event____Label`:\
Change the `tall` value to `0`.

If you wish to change the positioning of any elements, [use this reference document](https://github.com/rbjaxter/budhud/wiki/Element-Positioning).\
If you wish to change the font to a different one, [follow this guide](#change-the-font-for-pass-time-hud-labels-changing-labels).\
If you wish to add a totally new font that isn't installed in your HUD, [follow this guide](https://github.com/rbjaxter/budhud/wiki/Adding---Replacing-Custom-Fonts#guide).

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

### Change the Font for PASS Time HUD Labels (Changing Labels)

Only follow this guide if your HUD has this font installed.
> [!WARNING]  
> This is a general guide. HUDs vary in the way they do things. Worst case scenario, follow the guide on adding fonts to get a better idea, or ask in the [HUDS.TF Discord server](http://huds.tf).

In your `resource` folder in your HUD, there is a file named `clientscheme.res`. If it contains a lot of lines that start with `#base`, that means that the file we're looking for, `fonts_scheme.res` is somewhere else. Follow the path it says (usually inside of a folder called `scheme`) and open that file. If there is no `#base` line that points to a `fonts_scheme.res`, it means that the fonts are in the `clientscheme.res` file somewhere.

Fonts are structured like so:
![HUD Font File Code Example](https://i.imgur.com/kTTPtpB.png)
HUDs will usually structure their fonts where they have the name of the font (ex. `m0refont`) and then a number at the end to signify the size, along with optional flags for attributes (ex. `m0refont22Shadow`).\
See what font you are currently using for the label you'd like to change the font on (look at the `font` field), and use that as a reference point. If I'm using `m0refont12` and I want to go bigger, I might use `m0refont20`, provided that it exists in my `fonts_scheme.res`/`client_scheme.res`.\
> [!NOTE]  
> If you change to a bigger or smaller font, you may have to modify the label's values for `tall` or its positioning. Use `vgui_cache_res_files 0` and `hud_reloadscheme` to test this out while running TF2. If the font does not change, it may require a game restart in between font changes.

> [!IMPORTANT]  
> After you are satisfied with your customization, be sure to turn `vgui_cache_res_files 1` or you **will** have worse performance.

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

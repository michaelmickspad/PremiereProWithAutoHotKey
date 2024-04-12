# Premiere Pro with AutoHotKey

# WARNING: THIS PROJECT IS CURRENTLY IN AN ALPHA STATE!
This program will work with basic functionality, but only a selection of the funtions are available (but they are the most important ones), and this will require you to manually write your own hotkeys. There is a template provided for how to do that, but I'm currently working on adding a way to not have to worry about doing that.

## Overview (Please Read)

This is my own version of the Premiere Pro editing help scripts originally created by Taran Van Hemert.

Many of his implementations are perfectly fine and functional, but to the average user (or even many power users), sifting through a large amount of code that was primarily written for one person's specific setup can be difficult, and making an easier to use and configure version of what Taran had built is what this project aims to achieve.

The aim of this project is to allow easier automation of certain tasks within the video editing process when using Premiere Pro for people who aren't as willing to deal with manually editing code by including ways to instantly and much more easily configure the automation scripts to work based on the user's specific setup, such as uploading a keybinding file or giving the ability to set hotkeys for presets from a gui rather than directly writing the code.

However, this aim is a goal that I will be working on bit by bit towards rather than dedicating my life to, so for now, the primary use case is to allow more transparancy and easy adjustments of Taran Van Hemert's original Premiere scripts.

Many of his original functions are re-written to follow better coding standards and practices while also adding in some features that I personally think are useful to make the code more configurable and adaptable.

At the current moment, there are no plans to implement his AfterEffects or Photoshop scripts because I am one person coding this as a fun side project and I don't understand how AfterEffects works AT ALL, but never say never.

If you want an idea of how these functions are used in practice, check out his original set of tutorials, and then watch mine to get an idea of how these are used and how to configure it to your own use cases

* [Taran's Repository](https://github.com/TaranVH/2nd-keyboard/tree/master)
* [Taran's Original Tutorials (INSERT LINK)]()
* [My Tutorial (COMING EVENTUALLY, USE THIS README AND REACH OUT IF STUFF IS UNCLEAR)]()


## Getting Started

### Required Dependencies

* Adobe Premiere Pro on either Windows 10 or Windows 11
* [AutoHotKey](https://www.autohotkey.com/download/) (Scripts are built on AHK v1.1)

### Optional Dependencies
* Python
    * This is optional because all of the scripts are available for you to run, but the .exe is being offered as an alternative if you don't wish to install Python

### How to Run This Program

* Downloading This Program
    * At the top of the GitHub page, click on the drop down button "<> Code" and click "Download ZIP"
    * Extract the zip into wherever you want to keep the program
        * The .zip file MUST be extracted, otherwise the setup program will appear as if it's running as intended with no errors, but won't actually do anything in regards to actually setting it up

* Create your configuration file
    * Run "Setup.exe" and follow the on screen instructions to build your config file
        * This may pop up with a windows defender warning, I don't know why that pops up (I think it may be because I am using part of the Windows API to read the display scaling that's already set, so if that removes the warning, I will change that to be a manual entry in the future, but for now, just click through to ignore the warning)
        * If you have Python installed and would like to run this in script form, the script to run is "UserConfiguration.py" in the Setup_Scripts folder
    * Once you run through the questions, you should see the file "PremiereWithAHKConfig.ini" appear inside the "config" folder
        * Do not worry about any of the other files in this folder, many of them are placeholders for future ideas I want to implement
        * If you have ever looked at a .kys file and were curious what the numbers in them corresponded to, "virtualkeys.json" has that information if you are a video editor who has had issues you need to manually adjust within the .kys file

* Once you have your config file, Start creating your hotkeys in "UserHotkeys.ahk"
    * Check the section below on Setting Hotkeys for more information on this step
    * There is one hotkey already set in "PremiereProWithAutoHotKey.ahk" which is CTRL + ` (The key to the left of the "1" key on the keyboard), and it's set to close this program. If you would like to remove or change this, please update or remove it from "PremiereProWithAutoHotKey.ahk". It technically doesn't need to be there as you can also close the program by right clicking the icon in the bottom right and closing it from there, but I don't feel comfortable shipping this code without an emergency close hotkey.

* Once you have your hotkeys set up, double click on "PremiereProWithAutoHotKey.ahk" to run the program
    * You can also create a shortcut to that script and place it anywhere (I highly recommend you do this because removing that script from it's place in the folders will break the program)


## Setting Hotkeys Overview
When building out your own hotkeys in "UserHotkeys.ahk", you can call a variety of functions to do automated tasks in Premiere

To call one of these functions, use the following syntax:
```autohotkey
INSERT_HOTKEY_HERE::
    ; NAME_OF_HOTKEY
    FUNCTION_NAME(FUNCTION_PARAMETERS)
Return
```
For an actual example, this hotkey is activated with "CTRL + j" and adds an effect called "shakeScreen20" to the clip below the cursor

```autohotkey
^j::
    ; CTRL + j - shakeScreen20 Preset
    preset("shakeScreen20")
Return
```

When making the hotkeys it is important to note the modifier keys:
- ^ means CTRL
- \+ means SHIFT
- !  means ALT

And when using keys that are not the standard alphanumeric keys (such as the numpad, arrow keys, function keys, etc.) you need to use specific names to use them and surround that name with these brackets: { }

A list of these keys can be found [here.](https://www.autohotkey.com/docs/v1/KeyList.htm)

If you want a more thorough idea of how to set up your hotkeys, check the file "UserHotkeysEXAMPLE.ahk" in the Example Files folder.

### Essential Functions
The following is a list of functions and exaplanations for what they do that are contained in the Essential_Functions.ahk script

* preset("EFFECT_NAME")
    * Adds a custom effect to the clip your mouse is hovering over
    * The effect you want to use MUST be in an effects folder, whether official or one you make doesn't really matter, but you cannot have a custom effect outside of a folder or else the mouse will not line up properly

* prFocus("PANEL_NAME")
    * Brings a specific panel into focus
    * You options for the panel name are as follows:
        * "timeline"
        * "effects"
        * "effect controls"
        * "program"
            * Program Monitor
        * "source"
            * Source Monitor
        * "project"
            * Opens the primary bin for your active project

* searchForEffect("EFFECT_NAME")
    * Opens the search box and looks for the specified effect name
    * Since preset() already does this AND adds the effect to your clip, I would recommend using this in situations where you may have multiple functions like "CROP20", "CROP30", "CROP40", etc. and you set a hotkey to search "CROP" to get all of them easily rather than to look for one specific effect, but that's up to you

* effectsPanelFindBox()
    * Opens the effects panel and places your cursor inide the search box, allowing you to type in the box instantly

* marker()
    * Stops playing any video and places a marker at the playhead
    * While Premiere technically already has a keyboard shortcut for this, this is more reliable since it forces a stop on the timeline

### Audio Functions
The following is a list of functions and exaplanations for what they do that are contained in the Audio_Functions.ahk script

* addGain(AMOUNT)
    * Adds gain to whatever audio clip is currently selected, input must be an integer value

* insertSFX("SOUND_EFFECT_NAME")
    * CURRENTLY UNFINISHED, DO NOT USE
    * Inserts the specified sound effect to the timeline

* audioMonoMaker("TRACK")
    * CURRENTLY UNFINISHED, DO NOT USE
    * Converts the selected audio clip to Mono
    * Input for track must be "right" or "left", not specifying will default to the left Audio Track

### Extended Functions
The following is a list of functions and exaplanations for what they do that are contained in the Extended_Functions.ahk script

In order to use the extended functions, additional setup is required to be performed, as of right now, these are a not high priority to fix, but they will be implemented down the line.

* instantVFX("EFFECT_NAME")
    * CURRENTLY UNFINISHED, DO NOT USE

* clickTransformIcon()
    * CURRENTLY UNFINISHED, DO NOT USE

* cropClick()
    * CURRENTLY UNFINISHED, DO NOT USE

### Taran Functions
The Taran_Functions.ahk script contains functions from Taran's original scripts that I wanted to keep included in case anyone got specific use out of them, but as of right now, they are low priority to implement, and if I decide to implement any of them, they will likely move to one of the other scripts.

I would only recommend looking deeper into these functions if you have previous familiarity with AutoHotKey and Premiere, I have done minor formatting adjustments on the functions, but not much work beyond that.

## How Do I Update?
I'm going to be honest with you here, chief... I am learning as I'm going, so updates are going to be a baby bit messy until I learn how to fully deal with them.

The best thing to do if you want the newest version of this project when updates are made is to redownload the code, and copy anything from your old version's config folder into the new one. I'm going to try my best to eventually make a way to just hit a button and update the program and keep all of your changes, but for the time being, "hold onto your config files" is genuinely the best advice I can give. This is meant to help you edit videos easier, but it's also a project being done in my spare time by a person who's only ever contributed to other projects, never headed their own before.

## Authors

**Mickspad**
- [Youtube](https://www.youtube.com/mickspad)
- [Twitter](https://www.Twitter.com/mickspad)


## Version History

* Version 0.1
    - Initial release
    - Included basic scripts for creating your configuration file from a premiere pro .kys file
    - Included functionality for preset() and associated other functions
    - Wrote the README
    - Included placeholders for future ideas regarding GUI and automated hotkey generation
    - Included executable for the initial version of the setup process

## License

Yes.

## Acknowledgments

This project would not have been possible without the amazing work done by Taran Van Hemert with his original scripts which were the basis for this entire project.

I also would like to thank the following people for being willing to help me through testing the functionality:
* Eight Faye - [Twitter](https://twitter.com/Eight_Faye)
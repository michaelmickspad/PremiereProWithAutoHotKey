# Premiere Pro with AutoHotKey

README is incomplete, will remove this message when there is a functional version of the project available on github, in its current state, the repo is still being set up

## Overview (Please Read)

This is my own version of the Premiere Pro editing help scripts originally created by Taran Van Hemert. He is a fantastic video editor, but his code is... he's a great video editor.

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

### Dependencies

* Adobe Premiere Pro on either Windows 10 or Windows 11
* [AutoHotKey](https://www.autohotkey.com/download/) (Scripts are built on AHK v1.1)
* Python (Anaconda is recommended)
    * I plan on making  this optional eventually by providing a standalone .exe file, but for the time being, it only works when you have Python installed

### Installing

* Create your configuration file
    * If you are a developer and want to be developer-y:
        * On the command line, run "InitialSetup.py" and follow the proper input arguments to create your config file
    * If you are not a developer or just want an easy setup:
        * Run "UserConfiguration.py" and follow the on screen instructions to build your config file
        * At the current moment, this exists solely as a script, so you need python installed to run it, but running it only required double clicking on it in the file browser. I do plan on providing a standalone executable at some point in the future, but that point is not now, so sorry but please install Python and run the script.
        * This will automatically run "InitialSetup.py" after answering the specific questions, so don't worry about running the setup script afterwards
    * If you hate yourself and absolutely REFUSE to use Python
        * Use the DEFAULT_CONFIG_TEMPLATE.ini file as a way to manually type out each of your keyboard shortcuts for each of your premiere commands (Don't actually do this)

* Once you have your config file, create your own Hotkeys in UserHotKeys.ahk
ADD MORE LATER

### Executing Program

* How to run the program
* Step-by-step bullets
```
code blocks for commands
```

## Functions Overview
When building out your own uses in "____.ahk" using the template, you can call a variety of functions

To call one of these functions, use the following syntax:
```autohotkey
INSERT_HOTKEY_HERE::
    ; NAME_OF_HOTKEY
    FUNCTION_NAME(FUNCTION_PARAMETERS)
Return
```
For an actual example, this hotkey is activated with "CTRL + j" and adds an effect called "shakeScreen20" to the clip

```autohotkey
^j::
    ; CTRL + j - shakeScreen20 Preset
    preset("shakeScreen20")
Return
```
You can use "UserHotkeysExample.ahk" if you want a more thorough idea for how I set up mine

## Essential Functions
The following is a list of functions and exaplanations for what they do that are contained in the Essential_Functions.ahk script

- preset("EFFECT_NAME")
    - Adds a custom effect to the clip your mouse is hovering over
    - The effect you want to use MUST be in an effects folder, whether official or one you make doesn't really matter, but you cannot have a custom effect outside of a folder or else the mouse will not line up properly

- prFocus("PANEL_NAME")
    - Brings a specific panel into focus
    - You options for the panel name are as follows:
        - "timeline"
        - "effects"
        - "effect controls"
        - "program"
            - Program Monitor
        - "source"
            - Source Monitor
        - "project"
            - Opens the primary bin for your active project

- searchForEffect("EFFECT_NAME")
    - Opens the search box and looks for the specified effect name
    - Since preset() already does this AND adds the effect to your clip, I would recommend using this in situations where you may have multiple functions like "CROP20", "CROP30", "CROP40", etc. and you set a hotkey to search "CROP" to get all of them easily rather than to look for one specific effect, but that's up to you

- effectsPanelFindBox()
    - Opens the effects panel and places your cursor inide the search box, allowing you to type in the box instantly

- marker()
    - Stops playing any video and places a marker at the playhead
    - While Premiere technically already has a keyboard shortcut for this, this is more reliable since it forces a stop on the timeline

- INSERT_NEXT_FUNCTION HERE

## Audio Functions
The following is a list of functions and exaplanations for what they do that are contained in the Audio_Functions.ahk script

(If you have no use for any of these, do not include this script in UserHotkeys.ahk)

- INSERT_NEXT_FUNCTION HERE

## Extended Functions
The following is a list of functions and exaplanations for what they do that are contained in the Extended_Functions.ahk script

(If you have no use for any of these, do not include this script in UserHotkeys.ahk)

- INSERT_NEXT_FUNCTION HERE

## Help

THIS SECTION WILL BE ADDED LATER

## Authors

**Mickspad**
- [Youtube](https://www.youtube.com/mickspad)
- [Twitter](https://www.Twitter.com/mickspad)


## Version History

* Version 0.1
    - Initial release

## License

Yes.

## List of Issues That Irked Me With Taran's Code And Caused Me To Make This Project
Taran, if you're reading this, I'm sorry... I know you are a video editor and not a coder, but these things were issues that made the code so much more diffult to parse and included some very problematic practices

- Use of whitespace tabs instead of multiple spaces (terrible for formatting and adjustability, and options exist to replace your tab button in coding text editors with multiple spaces)
- Use of "goto"
- Use of "goto" to jump to a line specified by single line function call
- Use of "goto" to jump to end a function instead of stopping function with "Return"
- Use of "goto" to break for loops rather than having a boolean flag in a while loop
- Use of "goto" with a single line function call that starts a single line above a closing brace
- Use of "goto" to simulate CONDITIONAL RECURSION
- Using variables before assigning them because AutoHotKey will default them rather than crash
- Lack of indenting for functions (meaning functions are not collapsible in text editor)
- Duplicate indenting of if statements
- Indenting the backets to be in line with the code of the function instead of in line with the function name
- Inconsistent indenting meaning it was MUCH more difficult to figure out where loops and if statements ended
- Inconsistent useage of brackets after if statements (sometimes there's brackets, sometimes it's just indents)
- Comments that go on beyond 200 characters on a single line instead of making them a new line (likely written with word wrapping enabled)
- Not using variables for user defined keyboard inputs in function, so multiple instances of the same key would need to be changed if user had different Premiere keyboard shortcuts
- Comments saying "uncomment next line if debugging" (perfectly fine for personal use, but probably not the best thing to hand off to other people if they have no coding experience) 
- Commented out code with notes that read "No longer in use" left in code instead of cleaning it up
- Long chains of if-else statements when switch statements would be both easier to read and easier to adjust
- Manually writing code when functions have already been written to do achieve the same effect (sometimes not replaced, sometimes replaced but with original version commented out and left in code)
- Numerous instances of dead code with comments saying "Don't use this" that have remained in the code base for 6+ years
- Temporary lines used for debugging that were left in code commented out and not labeled as such
- No leading space at the start of comments squishing the wording against the comment tag
- Notes indicating that strings are not variables
- Useage of single = for comparison (since AutoHotKey technically allows that for some reason)
- Useage of global variables for items that can be confined to local scope

In conclusion: See me after class, young man.

## Acknowledgments

THIS SECTION WILL BE ADDED LATER
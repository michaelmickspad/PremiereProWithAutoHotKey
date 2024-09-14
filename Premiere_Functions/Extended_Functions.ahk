#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force ; Only one version of this script may run at a time
#MaxHotkeysPerInterval, 2000
#WinActivateForce

/*
 * DESCRIPTION:
 *
 * This file is split off from the essential functions because theses ones all contain
 * optional elements. I feel confident in not allowing the user to use the script at all
 * unless all the required keybinds are set for each function in the essential functions
 * list, but for these functions, there is more wiggle room for if the user even has a
 * keybind set in premiere for the command. (I don't want to block the user from using the
 * preset function just because they don't have a keybind for changing a clip on the
 * timeline to be highlighted yellow)
 *
 * These functions also help to cover specific edge cases or section off functions that
 * require external software. At the current moment, I have soft plans to implement all
 * of the functions from Taran's scripts if possible, but this is where some of the more
 * difficult ones will be stored that still do seem possible.
 *
 * This will also contain my own functions that are completely separate from Taran's
 * scripts
 *
 * While the global hotkey values are set in a similar way to the essential ones, they
 * should never be used by "SendInput", and should only be activated by "checkAndSendKey"
 * which does a check and displays an error message if the user doesn't have the key set
 */

; Global Variables
global CONFIG_FILEPATH := "%A_WorkingDir%\..\config\PremiereWithAHKConfig.ini"
global POPULATED_EXTENDED_GLOBALS := False

; Custom Keybinds for Script Functions (all are optional)
global TL_CLIP_VIOLET = "NOT SET"
global TL_CLIP_IRIS = "NOT SET"
global TL_CLIP_CARIBBEAN = "NOT SET"
global TL_CLIP_CERULEAN = "NOT SET"
global TL_CLIP_LAVENDER = "NOT SET"
global TL_CLIP_FOREST = "NOT SET"
global TL_CLIP_ROSE = "NOT SET"
global TL_CLIP_MANGO = "NOT SET"
global TL_CLIP_PURPLE = "NOT SET"
global TL_CLIP_BLUE = "NOT SET"
global TL_CLIP_TEAL = "NOT SET"
global TL_CLIP_MAGENTA = "NOT SET"
global TL_CLIP_TAN = "NOT SET"
global TL_CLIP_GREEN = "NOT SET"
global TL_CLIP_BROWN = "NOT SET"
global TL_CLIP_YELLOW = "NOT SET"
global DIRECT_MANIP_PROG_MON = "NOT SET"

populateExtendedGlobals()
{
    ; Before we can populate the globals for this script specifically, we need to make
    ; sure the essential ones are populated
    if (POPULATED_ESSENTIAL_GLOBALS == False)
    {
        populateEssentialGlobals()
    }

    ; Grabs the data set by the python script from the configuration file and adjusts the
    ; values of the global variables of the script accordingly
    ; Outputs to a temporary variable first because ini file reading to global can be
    ; iffy at times
    ; Also all of the keys in the config are the command names in the .kys file

    IniRead, clipVioletCmd,    %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.0, NOT SET
    IniRead, clipIrisCmd,      %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.1, NOT SET
    IniRead, clipCaribbeanCmd, %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.2, NOT SET
    IniRead, clipCeruleanCmd,  %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.3, NOT SET
    IniRead, clipLavenderCmd,  %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.4, NOT SET
    IniRead, clipForestCmd,    %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.5, NOT SET
    IniRead, clipRoseCmd,      %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.6, NOT SET
    IniRead, clipMangoCmd,     %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.7, NOT SET
    IniRead, clipPurpleCmd,    %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.8, NOT SET
    IniRead, clipBlueCmd,      %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.9, NOT SET
    IniRead, clipTealCmd,      %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.10, NOT SET
    IniRead, clipMagentaCmd,   %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.11, NOT SET
    IniRead, clipTanCmd,       %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.12, NOT SET
    IniRead, clipGreenCmd,     %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.13, NOT SET
    IniRead, clipBrownCmd,     %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.14, NOT SET
    IniRead, clipYellowCmd,    %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.edit.label.15, NOT SET
    IniRead, actDirManipProgMonCmd, %CONFIG_FILEPATH%, Premiere_Keybinds, cmdPLACEHOLDER, NOT SET


    ; Set the global variables (again, we do this separately because reading a config file
    ; directly into a global variable can have some issues, I would NOT be doing it this
    ; way if setting the globals directly was perfectly viable)
    TL_CLIP_VIOLET := clipVioletCmd
    TL_CLIP_IRIS := clipIrisCmd
    TL_CLIP_CARIBBEAN := clipCaribbeanCmd
    TL_CLIP_CERULEAN := clipCeruleanCmd
    TL_CLIP_LAVENDER := clipLavenderCmd
    TL_CLIP_FOREST := clipForestCmd
    TL_CLIP_ROSE := clipRoseCmd
    TL_CLIP_MANGO := clipMangoCmd
    TL_CLIP_PURPLE := clipPurpleCmd
    TL_CLIP_BLUE := clipBlueCmd
    TL_CLIP_TEAL := clipTealCmd
    TL_CLIP_MAGENTA := clipMagentaCmd
    TL_CLIP_TAN := clipTanCmd
    TL_CLIP_GREEN := clipGreenCmd
    TL_CLIP_BROWN := clipBrownCmd
    TL_CLIP_YELLOW := clipYellowCmd
    DIRECT_MANIP_PROG_MON := actDirManipProgMonCmd

    POPULATED_EXTENDED_GLOBALS := True
}

instantVFX(effectName)
{
    ;TODO: Implement
}

; TODO: REQUIRES IMAGESEARCH FUNCTIONALITY
cropClick()
{
    ; WARNING: This function REQUIRES screenshots using imageSearch
    ; Please ensure that you have the required screenshots available
    
    ; Clicks on the crop transform button in order to select the crop itself
    ; This allows you to get the handles on the program monitor much quicker and easier

    ; This is automatically called by preset() if you have this function enabled

    ; Do not run unless the values for the Display Scaling is updated
    if (POPULATED_ESSENTIAL_GLOBALS == False)
    {
        populateEssentialGlobals()
    }

    CoordMode, Pixel, Screen
    CoordMode, Mouse, Screen

    ; Temporarily blocks the mouse and keyboard inputs while the function is running
    BlockInput, MouseMove
    BlockInput, On

    MouseGetPos, xPosCursor, yPosCursor

    ;TODO: THIS IS A SCREEN VALUE, UPDATE THIS TO BE USER DEFINED
    effectControlsX := 10
    effectControlsY := 200

    ;TODO: Implement the rest of this function

}



changeClipColor(clipColor)
{
    ; This function allows the user to use the name of the color when setting up their
    ; hotkeys rather than a "SendInput" that's hardcoded to their specific shortcut

    if (POPULATED_EXTENDED_GLOBALS == False)
    {
        populateExtendedGlobals()
    }

    Switch clipColor {
        Case "violet", "Violet", "VIOLET", "1":
            changeClipColorConfirm(TL_CLIP_VIOLET, clipColor)
            return
        Case "iris", "Iris", "IRIS", "2":
            changeClipColorConfirm(TL_CLIP_IRIS, clipColor)
            return
        Case "caribbean", "Carribbean", "CARRIBBEAN", "3":
            changeClipColorConfirm(TL_CLIP_CARIBBEAN, clipColor)
            return
        Case "lavender", "Lavender", "LAVENDER", "4":
            changeClipColorConfirm(TL_CLIP_LAVENDER, clipColor)
            return
        Case "purple", "Purple", "PURPLE", "9":
            changeClipColorConfirm(TL_CLIP_PURPLE, clipColor)
            return
        Case "cerulean", "Cerulean", "CERULEAN", "5":
            changeClipColorConfirm(TL_CLIP_CERULEAN, clipColor)
            return
        Case "rose", "Rose", "ROSE", "7":
            changeClipColorConfirm(TL_CLIP_ROSE, clipColor)
            return
        Case "mango", "Mango", "MANGO", "8":
            changeClipColorConfirm(TL_CLIP_MANGO, clipColor)
            return
        Case "blue", "Blue", "BLUE", "10":
            changeClipColorConfirm(TL_CLIP_BLUE, clipColor)
            return
        Case "forest", "Forest", "FOREST", "6":
            changeClipColorConfirm(TL_CLIP_FOREST, clipColor)
            return
        Case "teal", "Teal", "TEAL", "11":
            changeClipColorConfirm(TL_CLIP_TEAL, clipColor)
            return
        Case "magenta", "Magenta", "MAGENTA", "12":
            changeClipColorConfirm(TL_CLIP_MAGENTA, clipColor)
            return
        Case "tan", "Tan", "TAN", "13":
            changeClipColorConfirm(TL_CLIP_TAN, clipColor)
            return
        Case "green", "Green", "GREEN", "14":
            MsgBox, TESTING TESTING
            changeClipColorConfirm(TL_CLIP_GREEN, clipColor)
            return
        Case "brown", "Brown", "BROWN", "15":
            changeClipColorConfirm(TL_CLIP_BROWN, clipColor)
            return
        Case "yellow", "Yellow", "YELLOW", "16":
            changeClipColorConfirm(TL_CLIP_YELLOW, clipColor)
            return
        Default: 
            errorMsg1 := "Your spelling may be incorrect for the selected color, please "
            errorMsg2 := "keep in mind that if you set custom colors, this will not work. "
            errorMsg3 := "You can make it work by entering the default name of whatever "
            errorMsg4 := "color you changed or the number (starting with 1) that the color "
            errorMsg5 := "appears in the Label Color list inside Preferences"
            errorMsg := errorMsg1 . errorMsg2 . errorMsg3 . errorMsg4 . errorMsg5
            MsgBox % errorMsg
            return
    }
    return
}

changeClipColorConfirm(checkKey, clipColor)
{
    ; This is a version of checkAndSendKey that is specific to changeClipColor
    ; as it has a more unique error message to display
    if (checkKey == "NOT SET")
    {
        MsgBox, No Premiere Keyboard shortcut set for changing clip color to %clipColor%
        return False ; Failed to send the keybind
    }
    else
    {
        SendInput % checkKey
        return True ; Sent the keybind
    }
}

closeTitler()
{
    ; This allows the Titler window to be closed with a keyboard shortcut
    ; The titler is an older tool within Adobe Premiere Pro that is considered depricated
    ; but it is engrained into many workflows despite the newer options

    ; TODO: Decide if this should be implemented or not
}

clickTransformIcon()
{
    passCheck := checkAndSendKey(DIRECT_MANIP_PROG_MON, "Activate Direct Manipulation in Program Monitor")
    if !passCheck
    {
        return False ; Failed the check, emergency stop function
    }
    Sleep 5

    ; TODO: Implement the rest of this function because it seems useful
    ; This is based on clickTransformIcon2 in Taran's Script
}
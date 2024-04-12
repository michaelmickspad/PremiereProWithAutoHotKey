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
 * This file is split off from the essential functions because they generally require
 * more setup than the other scripts. Anything in the essential functions script I feel
 * confident having everything just error out if the user doesn't have stuff set up, but
 * for these functions, it's entirely possible that the user just doesn't have certain
 * things set up.
 *
 * These functions also help to cover specific edge cases or sectiuon off functions that
 * require external software. At the current moment, I have soft plans to implement all
 * of the functions from Taran's scripts if possible, but this is where some of the more
 * difficult ones will be stored that still do seem possible.
 *
 * This will also contain my own functions that are completely separate from Taran's
 * scripts
 *
 */

; Global Variables
global CONFIG_FILEPATH := "%A_WorkingDir%\..\config\PremiereWithAHKConfig.ini"
global POPULATED_EXTENDED_GLOBALS := False

; Required Custom Keybinds for Script Functions
global PLACEHOLDER_REQUIRED_HOTKEY

populateExtendedGlobals()
{
    ; Grabs the data set by the python script from the configuration file and adjusts the
    ; values of the global variables of the script accordingly
    ; Outputs to a temporary variable first because ini file reading to global can be
    ; iffy at times
    ; Also all of the keys in the config are the command names in the .kys file

    IniRead, removeInOutCmd,  %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.clear.inandout
    ;TODO: Add in the rest of the function

    missingCommandName := ""

    ; Added Error Checking
    Switch "ERROR"
    {
        case removeInOutCmd: missingCommandName := "Remove In and Out Points"
    }

    ; If missingCommandName is set, that means the user doesn't have a required shortcut
    ; for this function, and we shouldn't attempt to continue
    if (missingCommandName != "")
    {
        ; I hate some of the janky BS in AutoHotKey
        ; I just want to concatenate a string! WHY IS THIS SO DIFFICULT?!?!?
        ; A PERIOD SHOULD NOT BE A CONCATENATION OPERATOR
        errorMsg1 := "ERROR: No command specified for " missingCommandName " Command"
        errorMsg2 := " which is required to run this command.`n`nPlease run the setup"
        errorMsg3 := " script and specify your Premiere Pro keybindings.`n`nPress OK to"
        errorMsg4 := " close the automation program."
        errorMsg := errorMsg1 . errorMsg2 . errorMsg3 . errorMsg4
        MsgBox % errorMsg
        ExitApp
    }

    ; Everything has been validated, set the global variables
    PLACEHOLDER_REQUIRED_HOTKEY := removeInOutCmd

    POPULATED_EXTENDED_GLOBALS := True
}

instantVFX(effectName)
{
    ;TODO: Implement
}

clickTransformIcon()
{
    ; Marked as Obsolete in the original script, but it is being used in InstantVFX
    ; TODO: Implement
}

;TODO: Move this function to another script for ImageSearch based functions since they
; require a lot more setup than the other functions
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

    ; TODO: Make an AHK Script that adds specific points on the screen to the config file
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


ChangeClipColor(clipColor){
    ; This function allows the user to use the name of the color when setting up their
    ; hotkeys
    ;TODO: Update this to run with variables, and also add in a dedicated check function
    ; that's separate from the other check functions since this is highly specific
    Switch clipColor {
        Case "violet": SendInput, ^!+1 
            return
        Case "lavender": SendInput, ^!+2 
            return
        Case "purple": SendInput, ^!+3 
            return
        Case "yellow": SendInput, ^!+4
            return
        Case "rose": SendInput, ^!+5 
            return
        Case "mango": SendInput, ^!+6
            return
        Case "blue": SendInput, ^!+7 
            return
        Default: 
            MsgBox, Check the code because the spelling of the color may be off
            return
    }
    return
}

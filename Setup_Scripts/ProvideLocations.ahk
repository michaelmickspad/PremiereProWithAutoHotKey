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
 * CURRENTLY UNUSED - STILL BEING BUILT
 *
 * This is a setup script for the select parts of the script where it's functionally
 * impossible to determine where on the screen certain items are since they can be
 * anywhere based on how the user has their computer set up
 *
 * I'm trying to limit the number of these that exist, but there are some that just
 * can't be helped, so this script runs entirely in Auto-Execution and asks the user to
 * specify where things are on their screen through step by step instructions and saving
 * that information into the script configuration file
 *
 * I know I had "translate window to screen" and vice versa functions in my old script
 * but those are stuck on my old work computer and I don't remember how I made them
 * and I don't even know if they would work considering Premiere runs across multiple
 * windows
 */

;-----------------------------------------------------------------------------------------
; AUTO-EXECUTION
;-----------------------------------------------------------------------------------------

global CONFIG_FILEPATH := "%A_WorkingDir%\..\config\PremiereWithAHKConfig.ini"
global X_POSITION := -1
global Y_POSITION := -1
global POSITION_PROVIDED := False

initialExplanation()


giveUserInstructions("Test")
waitForNextInput("confirm.button.x", "confirm.button.y")


; Ending
endMsg1 := "Thank you for running the script, be sure to run the other configuration tool"
endMsg2 := " to upload your own premiere keybindings before running the full script."
endMsg := endMsg1 . endMsg2
MsgBox % endMsg

ExitApp ; END OF AUTO-EXECUTION SECTION


;-----------------------------------------------------------------------------------------
; HOTKEYS
;-----------------------------------------------------------------------------------------

^`::
    ; CTRL + ` - Emergency Exit
    ExitApp
Return

^j::
    ; CTRL + j - Provide Position
    CoordMode, Mouse, Screen
    MouseGetPos, mouseXPos, mouseYPos, activeWindow
    X_POSITION := mouseXPos
    Y_POSITION := mouseYPos
    POSITION_PROVIDED := True
Return

;-----------------------------------------------------------------------------------------
; FUNCTIONS
;-----------------------------------------------------------------------------------------

initialExplanation()
{
    ; AGAIN, I HATE this stupid crap with string concatenation
    ; I genuinely love some of the janky BS you can get away with in AHK, but not *this*
    ; I just want to be able to do msg += "text" like you can in any other language
    msg1 := "Welcome to the Premiere with AutoHotKey screen configurator!`n`n"
    msg2 := "I wanted to try to put everything in the configurator in the Python script "
    msg3 := "but it seems that that's more difficult, so here we are.`n`n"
    msg4 := "Some parts of this script rely on specific screen positions that are unable "
    msg5 := "to be determined automatically, so we're going to walk through and specify "
    msg6 := "those locations now. This may be somewhat annoying, but unless you change "
    msg7 := "your display settings, you should only have to do this once.`n`n"
    msg8 := "DO NOT HAVE ANY OTHER AUTOHOTKEY SCRIPTS RUNNING WHILE RUNNING THIS`n`n"
    msg9 := "Please open Premiere and then click OK to continue"
    msg := msg1 . msg2 . msg3 . msg4 . msg5 . msg6 . msg7 . msg8 . msg9
    MsgBox % msg
}

giveUserInstructions(itemToProvide)
{
    msg1 := "Please hover your mouse over "
    msg2 := " and press:`n`n"
    msg3 := "CTRL + ""J""" ; WHY CAN'T YOU JUST BE NORMAL?!?!?!? USE A BACKSLASH!!!!
    msg := msg1 . itemToProvide . msg2 . msg3
    MsgBox % msg
}

waitForNextInput(xVarName, yVarName)
{
    ; This is a TERRIBLE solution, but fuck it, it works and I'm mad enough to not
    ; exactly care
    ; I REALLY wanted to have all configuration in python, and all automation in AHK
    ; but the inclusion of screen based pixel values destroyed any chance of that
    ; There ARE ways to be able to do this exact setup in python, but they require
    ; additional packages, and I'm trying my hardest to make this work easily for
    ; video editors and not developers

    ; Time limit of 2 minutes before it will stop for safety
    ; This isn't actually 2 minutes, this is more like 3-4, but it's a fair amount of time
    emergencyBreak := 0
    while (emergencyBreak < 12000 && not POSITION_PROVIDED)
    {
        Sleep 10
        emergencyBreak++
    }

    if (POSITION_PROVIDED)
    {
        ; Put the global values into the config file
        IniWrite, %X_POSITION%, %CONFIG_FILEPATH%, Screen_Locations, %xVarName%
        IniWrite, %Y_POSITION%, %CONFIG_FILEPATH%, Screen_Locations, %yVarName%
        ; Reset Global Values
        X_POSITION := -1
        Y_POSITION := -1
        POSITION_PROVIDED := False
    }
    else
    {
        ; We timed out, don't let this script run forever on someone's computer
        msg := "Position setup timeout, Exiting for safety"
        MsgBox % msg
        ExitApp
    }
}
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
 * This is the main script for the Premiere Pro With AutoHotKey automation program
 *
 * Functionality will be stored in other scripts, and this one exists to tie the rest
 * of them together so this can be started by running a single script.
 *
 * I would highly recommend making a shortcut to this file if you want to launch this
 * program from anywhere on your computer, but before you do that, make sure you've run
 * the setup process to configure this program to your machine.
 *
 */

; Using A_ScriptDir everywhere is inconsistent, so declaring the locations of a few items
; is much more manageable (and one of the few times the janky BS of AHK is appreciated)
global TOP_DIR := A_ScriptDir
global CONFIG_FILEPATH := "config\PremiereWithAHKConfig.ini"

; Function Scripts
#Include %A_ScriptDir%\Premiere_Functions\Essential_Functions.ahk
#Include %A_ScriptDir%\Premiere_Functions\Extended_Functions.ahk
#Include %A_ScriptDir%\Premiere_Functions\Audio_Functions.ahk
;#Include %A_ScriptDir%\Premiere_Functions\Taran_Functions.ahk

; Checking to make sure that there is a configuration file
if !FileExist(CONFIG_FILEPATH)
{
    MsgBox, Please run the first time setup process to generate a configuration file
    ExitApp
}


; Some of the "mods" for Premiere Pro need to be run as a separate process so it doesn't
; interfere with the primary script, but whether or not they run is determined through
; a toggle flag within the config file
; WARNING: THESE MODS ARE RUNNING AS A SEPARATE PROCESS AND THEREFORE WILL NOT STOP IF
; "ExitApp" IS INVOKED (This generally shouldn't be a problem for what these mods do, but
; it's worth warning about, and this warning should be in the README when it gets updated)
IniRead, ppModDeleteExistingKeyframes, %CONFIG_FILEPATH%, PPWAHK_Configs, yesDeleteKeyframes, 0
if (ppModDeleteExistingKeyframes == 1)
{
    Run %A_ScriptDir%\Premiere_Functions\PPMOD_YesDeleteExistingKeyframes.ahk
}


; While #Include's TYPICALLY go at the very top of the script, the Hotkey script actually
; has to be included at the end because setting hotkeys ends the auto-execution section
#Include %A_ScriptDir%\config\GeneratedHotkeys.ahk

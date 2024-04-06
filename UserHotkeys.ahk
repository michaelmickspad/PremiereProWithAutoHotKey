#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force ; Only one version of this script may run at a time
#MaxHotkeysPerInterval, 2000
#WinActivateForce

; Function Scripts Being Used
#Include %A_ScriptDir%\Premiere_Functions\Essential_Functions.ahk

; Potential Includes
;#Include %A_ScriptDir%\Extended_Functions.ahk

/*
 * DESCRIPTION:
 *
 * This file will be where all of the user defined keybaord shortcuts will be placed.
 * At the current moment, it only has one shortcut that's being used to test each of
 * the functions, but my eventual hope is to automate the process of writing any code
 * in this file and just allowing users to use a GUI to specify what they want to have
 * happen and then have the code be written into this file for them.
 */


^`::
    ; CTRL + ` - Emergency Exit Automation Script
    ExitApp
Return

^j::
    ; CTRL + j - Debugging Test
    ;debugTest()
    preset("BLUR 10")
Return
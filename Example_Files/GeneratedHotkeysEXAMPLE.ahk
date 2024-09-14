; DO NOT MANUALLY EDIT THIS SCRIPT UNLESS YOU KNOW WHAT YOU ARE DOING
; THIS IS MEANT TO BE ADJUSTED THROUGH AN AUTOMATED PROCESS AND EDITING THIS SCRIPT
; MANUALLY WILL BREAK THE AUTOMATIC WRITER

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force ; Only one version of this script may run at a time
#MaxHotkeysPerInterval, 2000
#WinActivateForce

; Function Scripts
#Include %A_ScriptDir%\Premiere_Functions\Essential_Functions.ahk

/*
 * DESCRIPTION:
 *
 * This script will hold all the user's hotkeys
 * It is not meant to be written manually, but rather written by the "AHKScriptWriter.py"
 * python script, which will parse the hotkeys stored in the "userMadeHotkeys.json"
 * file and convert them into code that can be understood by AutoHotKey
 *
 */

#IfWinActive ahk_exe Adobe Premiere Pro.exe
Numpad3::
    ; Numpad3
    preset("BLUR 10")
Return

#IfWinActive ahk_exe Adobe Premiere Pro.exe
XButton1::
    ; XButton1
    deleteSingleClipAtCursor()
Return

#IfWinActive
^`::
    ; CTRL + `
    ExitApp
Return

#IfWinActive ahk_exe Adobe Premiere Pro.exe
^j::
    ; CTRL + j
    addGain("5")
Return


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
 * This file is where you can write your own custom keybaord shortcuts.
 * This is SEPARATE from the automatically generated ones through the gui, any shortcuts
 * placed here will have to be managed yourself manually, so if you accidentally generate
 * a hotkey using the GUI and you add one here, that is an issue you will have to keep in
 * mind and resolve yourself as this file is not tracked by the GUI at all. Please only
 * use this page if you are more familiar with AutoHotKey.
 *
 * If you are not as familiar with AutoHotKey, please use the GUI to create your keyboard
 * shortcuts.
 *
 * This file is included by PremiereProWithAutoHotKey.ahk, so please activate the program
 * by using that script and only use this file to add your own hotkeys and functions.
 */

;TODO: Add some example hotkeys in here once the GUI is up and running
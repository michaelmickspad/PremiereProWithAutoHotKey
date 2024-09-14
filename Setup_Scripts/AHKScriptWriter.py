'''
Description:
Writes the AutoHotKey Script based on information it takes in from another file
Not sure what that other file will be exactly, but all in due time
'''

import sys
import os
import json

# This list gets used to know when to not write parameters into the code even if the user
# has specified one in the gui
ahkFunctionsWithoutParameters = [
    'effectsPanelFindBox',
    'deleteSingleClipAtCursor'
]

def WriteTheScript(topDir):
    '''
    Writes the .ahk file for the user based on the inputs in the scriptFunctions
    dictionary
    '''
    scriptLines = []
    # We need to start by using the UserHotkeyTemplate.txt file to get the parts of the
    # script that are meant for setup, and separate functions will be used to add the
    # content where it needs to be added

    configDir = os.path.join(topDir, 'config')
    templateFile = os.path.join(configDir, 'GenHotkeyTemplate.txt')

    with open(templateFile, 'r') as template:
        for line in template:
            line = line.rstrip('\n')
            if line == '[[[INSERT_USER_FUNCTIONS_HERE]]]':
                hotkeyLines = WriteHotkeys(configDir)
                scriptLines.extend(hotkeyLines)
            else:
                # Not a marker, meaning it's part of the template and needs to be included
                scriptLines.append(line)
    
    # Now that we have our written out script in a list, we need to output it to an actual
    # file
    outputFilepath = os.path.join(configDir, 'GeneratedHotkeys.ahk')
    with open(outputFilepath, 'w') as outFile:
        for line in scriptLines:
            outFile.write('{}\n'.format(line))


def WriteHotkeys(configDirIn):
    '''
    Translates the hotkeys in the dictionary into something useable by ahk
    Returns a list of lines to be added to the GeneratedHotKeys.ahk script
    '''
    scriptLinesToAdd = []
    userMadeHotkeysJSON = os.path.join(configDirIn, 'userMadeHotkeys.json')

    userHotkeys = []
    with open(userMadeHotkeysJSON) as jFile:
        userHotkeys = json.loads(jFile.read())

    for hotkey in userHotkeys:

        # Universal Hotkeys are hotkeys that will work outside of Premiere
        # If the hotkey isn't universal, it needs this tag above it
        progRestrictionText = "#IfWinActive ahk_exe Adobe Premiere Pro.exe"
        hotkeyLine = ''
        if hotkey['ctrl']:
            hotkeyLine = hotkeyLine + '^'
        if hotkey['shift']:
            hotkeyLine = hotkeyLine + '+'
        if hotkey['alt']:
            hotkeyLine = hotkeyLine + '!'
        hotkeyLine = hotkeyLine + hotkey['hotkey']
        humanReadableHotkey = TranslateHotkey(hotkeyLine)
        hotkeyLine = hotkeyLine + '::'
        #descLine = '    ; {}\n    ; {}'.format(humanReadableHotkey, hotkey['description'])
        descLine = '    ; {}'.format(humanReadableHotkey)

        # The actual function may vary depending on what's in the JSON
        if hotkey['custom_code']:
            # This function has custom code, which is saved in a subdirectory inside
            # of the config directory and denoted by the ID
            custCodeFile = 'CustomCode{}.txt'.format(hotkey['id'])
            custCodeFile = os.path.join(configDirIn, 'CustomFunctions', custCodeFile)
            with open(custCodeFile, 'r') as custCode:
                custCodeString = custCode.read()
                custCodeString = custCodeString.strip()
                custCodeString = custCodeString.split('\n')
                firstLine = True # Flag that removes the starting newline character
                funcLines = ''
                for line in custCodeString:
                    if firstLine:
                        firstLine = False
                        funcLines = '{}    {}'.format(funcLines, line)
                    else:
                        funcLines = '{}\n    {}'.format(funcLines, line)
        elif hotkey['function']:
            if hotkey['function'] == 'ExitApp':
                # ExitApp does not need () afterwards since it's a built in ahk command
                funcLines = '    {}'.format(hotkey['function'])
                # ExitApp is a universal command, so it can run outside of Premiere
                progRestrictionText = "#IfWinActive" # Any program
            elif hotkey['parameter'] and hotkey['function'] not in ahkFunctionsWithoutParameters:
                funcLines = '    {}("{}")'.format(hotkey['function'], hotkey['parameter'])
            else:
                funcLines = '    {}()'.format(hotkey['function'])
        else:
            # There was no custom code and no function set
            funcLines = '    MsgBox, No functionality set for hotkey'

        scriptLinesToAdd.append(progRestrictionText)
        scriptLinesToAdd.append(hotkeyLine)
        scriptLinesToAdd.append(descLine)
        scriptLinesToAdd.append(funcLines)
        scriptLinesToAdd.append('Return')
        scriptLinesToAdd.append('') # Empty line for better spacing

    return scriptLinesToAdd

def TranslateHotkey(hotkey):
    '''
    Takes the AHK syntax of the hotkey and translates it into something more human
    readable for the description in the generated hotkeys
    '''
    # Need to do the + first since we're adding +'s into this
    if '+' in hotkey:
        hotkey = hotkey.replace('+', 'SHIFT + ')
    if '!' in hotkey:
        hotkey = hotkey.replace('!', 'ALT + ')
    if '^' in hotkey:
        hotkey = hotkey.replace('^', 'CTRL + ')
    return hotkey


# Main Function
if __name__ == '__main__':
    #args = ParseArguments()
    retCode = WriteTheScript()
    sys.exit(retCode)
'''
Description:
Writes the AutoHotKey Script based on information it takes in from another file
Not sure what that other file will be exactly, but all in due time
'''

import sys
import os
import json

def WriteTheScript():
    '''
    Writes the .ahk file for the user based on the inputs in the scriptFunctions
    dictionary
    '''
    scriptLines = []
    # We need to start by using the UserHotkeyTemplate.txt file to get the parts of the
    # script that are meant for setup, and separate functions will be used to add the
    # content where it needs to be added

    topDir = os.path.abspath(__file__)
    topDir = os.path.dirname(topDir) # Setup_Scripts
    topDir = os.path.dirname(topDir) # PremiereProWithAutoHotKey
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
        hotkeyLine = hotkey['hotkey'] + '::'
        humanReadableHotkey = TranslateHotkey(hotkey['hotkey'])
        descLine = '    ; {}\n    ; {}'.format(humanReadableHotkey, hotkey['description'])
        
        # The actual function may vary depending on what's in the JSON
        if "function" in hotkey:
            funcLine = '    {}("{}")'.format(hotkey['function'], hotkey['parameter'])
        elif "AHKCmd" in hotkey:
            funcLine = '    {}'.format(hotkey['AHKCmd'])
        else:
            # If there is an error, let the user know that it was happening
            funcLine = '    MsgBox, There was an error with importing hotkeys from config'

        scriptLinesToAdd.append(hotkeyLine)
        scriptLinesToAdd.append(descLine)
        scriptLinesToAdd.append(funcLine)
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
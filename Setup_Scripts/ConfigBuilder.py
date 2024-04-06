'''
Description:
__
'''

import argparse
import configparser
import json
import sys
import os
import xml.etree.ElementTree as ET

def ParseArguments(inputArguments=None):
    '''
    This function parses all the input arguments
    '''
    parser = argparse.ArgumentParser(
        prog = 'ConfigBuilder.py',
        description = 'Prompts the user to give information about their configuration ' \
                    + 'for both Windows and Premiere'
    )
    
    # Required Arguments
    parser.add_argument(
        'premiereKeybindFile',
        action = 'store',
        help = 'Path to the exported premiere keybindings'
    )

    # Optional Arguments
    parser.add_argument(
        '--displayScaling',
        action = 'store',
        help = 'Specify the display scaling option in Windows. Default is 100',
        default = 100
    )
    
    try:
        if inputArguments:
            arguments = parser.parse_args(inputArguments)
        else:
            arguments = parser.parse_args()
    except argparse.ArgumentError as exc:
        print(exc.message, '\n', exc.argument_name)
        print('\nExecute \'{} -h\' for more information'.format(parser.prog))
        sys.exit(1)

    return arguments

def BuildIniFile(keybindDictionary, sectionNameIn, iniFilePath, freshStart=False):
    '''
    Builds the .ini file from the parsed Premiere keybindings so that AutoHotKey can
    use the values as global variables

    freshStart means that we need to remove whatever was in that section before,
    otherwise we append the sections
    '''
    ahkConfig = configparser.ConfigParser()
    ahkConfig.read(iniFilePath)

    if freshStart:
        ahkConfig.remove_section(sectionNameIn)

    if not ahkConfig.has_section(sectionNameIn):
        ahkConfig.add_section(sectionNameIn)

    for keybind in keybindDictionary:
        # Format is used to stringify any number values
        keybindValue = '{}'.format(keybindDictionary[keybind])
        ahkConfig.set(sectionNameIn, keybind, keybindValue)
    
    # Write the .ini configuration file
    with open(iniFilePath, 'w') as configFile:
        ahkConfig.write(configFile)

def ParseKeybindsFromKysFile(kysFileIn):
    '''
    Takes the input of a .kys file exported from Premiere after setting keybindings
    and builds a dictionary of values to that will later be used to build the config
    file for the AutoHotKey script so commands are executed using the user's preferred
    keybinds

    Return values:
        Return Code
        Keyboard Shortcut Dictionary
    '''

    keybindDictionary = {}

    # Load the data for how Premiere stores keybindings
    virtualKeys = GetVirtualKeys()

    if not kysFileIn.endswith('.kys'):
        print('ERROR: File must be a .kys file exported from Premiere Pro')
        return 1, None # Failure

    tree = ET.parse(kysFileIn)
    root = tree.getroot()
    shortcutsBranch = root.find('shortcuts')
    contextBranches = shortcutsBranch.findall('*')
    # Remove branches that aren't context branches (Don't know how to specify to only
    # check part of a tag in the findall, so this is fine enough)
    contextBranches = [x for x in contextBranches if 'context' in x.tag]
    # This is probably stupid, but I've never done XML parsing before so cut me some slack
    # This is only meant to run whenever you change your keybinds in premiere, so... not
    # a ton of times after initial setup, if I cared about efficiency, I wouldn't be 
    # using Python for this, it's FINE
    itemList = []
    for contextBranch in contextBranches:
        # Find all of the actual keybaord shortcuts from the context branch
        subItemList = [x for x in contextBranch if 'item' in x.tag]
        subItemList = [x for x in subItemList if 'itemcount' not in x.tag]
        # Add the keyboard shortcuts to the overall item list
        itemList.extend(subItemList)

    for item in itemList:
        keybindDictionary = AddParsedKeybindToDictionary(item, keybindDictionary, virtualKeys)
    
    return 0, keybindDictionary # Success

def AddParsedKeybindToDictionary(keybindElement, keybindDictionaryIn, virtualKeysIn):
    '''
    Parses the found keybind element from the .kys file and parses it into a command
    that AutoHotKey uses before putting the command into the keybindDictionary to
    later build the configuration file

    Return Values:
        Keyboard Shortcut Dictionary (Reference)
    '''
    cmdName = keybindElement.find('commandname').text
    hotkeyCommand = ''
    
    # AutoHotKey uses +, !, and ^ to refer to shift, alt, and control
    # so if those are active, we need to add them to the start of the command
    if keybindElement.find('modifier.shift').text == 'true':
        hotkeyCommand += '+'
    if keybindElement.find('modifier.alt').text == 'true':
        hotkeyCommand += '!'
    if keybindElement.find('modifier.ctrl').text == 'true':
        hotkeyCommand += '^'
    # We don't need escape characters for any of these because the only one that can
    # be set to a hotkey is the +, and only on the Numpad, which has it's own syntax

    # Get the actual key that needs to be pressed and add that to the command
    virtualKeyCode = keybindElement.find('virtualkey').text

    # Premiere accepts keyboard shortcuts for an "=" on the Numpad, but AutoHotKey
    # does not (that's documented at least), so if we hit that specific case, just
    # end immediately
    if virtualKeyCode == '3221225533':
        print('\nWARNING: User has a keybind set to the "=" on the numpad')
        print('AutoHotKey does not consider that a known valid keyboard input.')
        print('The script can still be used without issue, but any shortcuts set to ')
        print('this key are unable to be performed by AutoHotKey, so errors may occur')
        print('stating that a keybind is not set if the command required uses this')
        print('keybind.\n\n')
        return keybindDictionaryIn

    keyboardInput = virtualKeysIn[virtualKeyCode]
    hotkeyCommand += keyboardInput

    # Add the command to the dictionary of keybindings (while selecting the most complex
    # option available when there is a clash)
    if cmdName in keybindDictionaryIn:
        if len(keybindDictionaryIn[cmdName]) > len(hotkeyCommand):
            hotkeyCommand = keybindDictionaryIn[cmdName]

    keybindDictionaryIn[cmdName] = hotkeyCommand

    return keybindDictionaryIn

def GetVirtualKeys():
    '''
    Turns the stored JSON file into an dictionary that's easier to work with in Python

    The JSON file holds definitions for how Adobe stores each key in the .kys file,
    I don't fully understand *why* Adobe does it this way, but they do, and this allows
    the .kys file to be translated into commands that can be understood by AutoHotKey

    "But why are you using JSON when you can just store the python dictionary in plain
    text and use pickle to save and load it?" Because JSON is more widely used and I've
    seen multiple forum posts of people asking "is there a list of what each virtualkey
    corresponds to?" while working on this project and now we have one... also I didn't
    think about using pickle until it was already built in JSON and I'm not redoing it.
    '''

    # Get the stored JSON file
    jsonFile = os.path.abspath(__file__)
    jsonFile = os.path.dirname(jsonFile)
    jsonFile = os.path.dirname(jsonFile) # PremiereProWithAutoHotKey
    jsonFile = os.path.join(jsonFile, 'config')
    jsonFile = os.path.join(jsonFile, 'virtualkeys.json')

    # Put the data from the JSON file into a dictionary
    virtualKeys = {}
    with open(jsonFile) as jFile:
        virtualKeysJson = json.loads(jFile.read())
    
    # Reformat the JSON dictionary into one that is easier to work with in other
    # parts of the script
    for vk in virtualKeysJson:
        # Format is used to stringify any number values
        virtualKeys['{}'.format(vk["virtualkey"])] = '{}'.format(vk["key"])

    return virtualKeys

# Main Function
if __name__ == '__main__':
    
    args = ParseArguments()

    # Determine the location of the configuration file
    configFilePath = os.path.abspath(__file__)
    configFilePath = os.path.dirname(configFilePath)
    configFilePath = os.path.dirname(configFilePath) # PremiereProWithAutoHotKey
    configFilePath = os.path.join(configFilePath, 'config')
    configFilePath = os.path.join(configFilePath, 'PremiereWithAHKConfig.ini')

    # Load the data from the input arguments for windows configurations
    windowsConfigs = {}
    windowsConfigs["display scaling"] = args.displayScaling
    BuildIniFile(windowsConfigs, 'Windows_Configs', configFilePath, freshStart=True)

    # Parse through the user's .kys file for premiere commands
    retCode, keybinds = ParseKeybindsFromKysFile(args.premiereKeybindFile)
    
    # If we didn't run into an issue above, build the configuration file so AutoHotKey
    # can understand the inputs from the user
    if retCode == 0:
        BuildIniFile(keybinds, 'Premiere_Keybinds', configFilePath, freshStart=True)
    else:
        print('Failed')
        # Find some way to display this information to the user other than print

    sys.exit(retCode)
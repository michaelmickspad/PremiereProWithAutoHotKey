'''
Description:

Runs the user through a series of questions to help build the configuration file
for the Premiere with AutoHotKey scripts
'''

from tkinter import Tk
from tkinter.filedialog import askopenfilename
import os
import sys
import ConfigBuilder
import ctypes

def AskUserQuestions():
    '''
    Main form where the questions are answered
    '''
    # Values determined through questioning
    userAnswers = {}

    msg = 'Welcome to the Premiere Pro AutoHotKey Automation Tool Configurator\n' \
        + 'This project was built by Michael Mickspad with heavy inspiration and code ' \
        + 'from Taran Van Hemert\n\n'
    print(msg)

    prompt = 'Is this your first time running this configurator on this computer? (Y/N): '
    userAnswers['First Time Setup'] = PromptUserBoolean(prompt)

    # I don't know what ctypes is completely, but this line accurately grabs the display
    # scaling of the main monitor
    displayScaling = ctypes.windll.shcore.GetScaleFactorForDevice(0)
    badDisplayMsg = '\nUnfortunately this script only works for values of 100% and 150%' \
                  + ' resolution scaling,\nfuture additions may change this, but for' \
                  + ' now, please adjust your resolution scaling\nif you wish to run' \
                  + ' this tool.\n'
    if displayScaling not in [100, 150]:
        print(badDisplayMsg)

    prompt = 'Your current windows scaling is detected as {}%. '.format(displayScaling) \
           + 'Is this correct? (Y/N): '
    correctScaling = PromptUserBoolean(prompt)
    if not correctScaling:
        prompt = 'Please Enter your Windows Display Scaling Value: '
        badOptionMsg = '\nPRESS CTRL+"C" OR CLOSE THIS WINDOW TO EXIT'
        displayScaling = PromptUserInt(prompt)
        if displayScaling not in [100, 150]:
            print(badDisplayMsg)
            print(badOptionMsg)
            input()
            sys.exit(1)
    userAnswers['Display Scaling'] = displayScaling


    prompt = 'Please specify your Premiere keyboard shortcuts\n' \
           + 'This is generally stored in your Documents folder under\n' \
           + '"Adobe" > "Premiere Pro" > "[VERSION]" > "Profile-[USERNAME]" > "Win"\n' \
           + 'but this can be different based on if you are using the Creative Cloud.\n' \
           + 'The file will have a .kys extension\n'
    userAnswers['Premiere Keyfile'] = PromptUserFileUpload(prompt, 'kys')

    return userAnswers


def PromptUserBoolean(prompt):
    '''
    Tasks the user with answering yes or no questions and returns the value of their
    answer.
    '''
    print() # Better Formatting
    userResponse = False # Pre-declaring variable
    invalidMsg = '\nInvalid Input, please answer with either Y or N'
    queryAnswered = False
    lastAnswerBad = False
    while not queryAnswered:
        if lastAnswerBad:
            print(invalidMsg)
            lastAnswerBad = False # Reset Flag
        userAnswer = input(prompt)
        # Using startswith in case user enters "yes"
        if userAnswer.lower().strip().startswith('y'):
            queryAnswered = True
            userResponse = True
        # Using startswith in case user enters "no"
        elif userAnswer.lower().strip().startswith('n'):
            queryAnswered = True
            userResponse = False
        else:
            lastAnswerBad = True

    return userResponse

def PromptUserInt(prompt):
    '''
    Tasks the user with entering a numerical integer value for a question and returns it

    Answers that are considered bad for reasons other than being an invalid input will
    be handled outside of this function
    '''
    print() # Better formatting
    invalidMsg = '\nInvalid Input, please enter a numerical integer value'
    queryAnswered = False
    lastAnswerBad = False
    while not queryAnswered:
        if lastAnswerBad:
            print(invalidMsg)
            lastAnswerBad = False # Reset Flag
        userAnswer = input(prompt)
        try:
            userAnswer = int(userAnswer)
        except ValueError:
            lastAnswerBad = True

        if not lastAnswerBad:
            return userAnswer

def PromptUserFileUpload(prompt, expectedFileExtension):
    '''
    Tasks the user with selecting a file to upload and returns the file they select.

    Will check to make sure that the file extensions match, but any checking beyond that
    will have to be done outside of this function
    '''
    print() # Better formatting
    invalidMsg = '\nInvalid File Selected, file must have a ' \
               + '\".{}\" extension\n'.format(expectedFileExtension)
    queryAnswered = False
    lastAnswerBad = False
    print(prompt)
    while not queryAnswered:
        if lastAnswerBad:
            print(invalidMsg)
        input('Pres ENTER to open the file browser...')
        Tk().withdraw() # Don't want a full gui, just the file selection dialog
        fileSelected = askopenfilename()
        fileSelected = os.path.abspath(fileSelected)
        if fileSelected.endswith('.{}'.format(expectedFileExtension)):
            queryAnswered = True
            print() # Better spacing
        else:
            lastAnswerBad = True
    
    return fileSelected


def BuildConfig(configOptionsIn):
    '''
    Calls the setup script to build the AHK Configuration file using the information
    collected from the user.
    '''
    configInputArgs = []
    configInputArgs.append(configOptionsIn['Premiere Keyfile'])
    # The key and value need to be separate
    configInputArgs.append('--displayScaling')
    configInputArgs.append('{}'.format(configOptionsIn['Display Scaling'])) # Stringify

    try:
        retCode = ConfigBuilder.Main(configInputArgs)
    except Exception:
        retCode = 1
    
    if retCode == 0:
        print('You should now see a shiny new config file in your output directory')
    else:
        print('There was an error with parsing the following file:\n')
        print(configOptionsIn['Premiere Keyfile'])
        print('Please check to ensure the .kys file is a valid Premiere Pro key file')


# Main Function
if __name__ == '__main__':

    configOptions = AskUserQuestions()
    BuildConfig(configOptions)

    input("\nPress ENTER To Close...")
    sys.exit(0)
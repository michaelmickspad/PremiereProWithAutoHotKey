'''
Description:

Runs the user through a series of questions to help build the configuration file
for the Premiere with AutoHotKey scripts
'''

from tkinter import Tk
from tkinter.filedialog import askopenfilename
import os
import sys

def AskUserQuestions():
    '''
    Main form where the questions are answered
    '''
    # Values determined through questioning
    #TODO: Switch the single variables to the userAnswers dictionary
    userAnswers = {} # Currently Unused

    firstTimeSetup = True
    displayScaling = -1
    premiereKeyfile = ''

    msg = 'Welcome to the Premiere Pro AutoHotKey Automation Tool Configurator\n' \
        + 'This project was built by Michael Mickspad with heavy inspiration and code ' \
        + 'from Taran Van Hemert\n\n'
    print(msg)

    prompt = 'Is this your first time running this configurator on this computer? (Y/N): '
    firstTimeSetup = PromptUserBoolean(prompt)

    prompt = 'Please Enter your Windows Display Scaling Value: '
    badOptionMsg = '\nUnfortunately this script only works for values of 100% and 150% ' \
                 + 'resolution scaling,\nfuture additions may change this, but for ' \
                 + 'now, please adjust your resolution scaling\nif you wish to run ' \
                 + 'this tool.' \
                 + '\nPRESS CTRL+"C" OR CLOSE THIS WINDOW TO EXIT'
    displayScaling = PromptUserInt(prompt)
    if displayScaling not in [100, 150]:
        print(badOptionMsg)
        input()
        sys.exit(1)

    prompt = 'Please specify your Premiere keyboard shortcuts\n' \
           + 'This is generally stored in your Documents folder under\n' \
           + '"Adobe" > "Premiere Pro" > "[VERSION]" > "Profile-[USERNAME]" > "Win"\n' \
           + 'but this can be different based on if you are using the Creative Cloud.\n' \
           + 'The file will have a .kys extension\n'
    premiereKeyfile = PromptUserFileUpload(prompt, 'kys')

    return firstTimeSetup, displayScaling, premiereKeyfile



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
    invalidMsg = '\nInvalid File Selected, file must have a \".{}\" extension\n'.format(expectedFileExtension)
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


def BuildConfig(windowsConfigs, premiereKeyFileIn):
    '''
    Calls the setup script to build the AHK Configuration file using the information
    collected from the user.

    This function SUCKS, use if for now but just find a better way to do this later
    '''

    setupScript = os.path.abspath(__file__)
    setupScript = os.path.dirname(setupScript)
    setupScript = os.path.join(setupScript, 'ConfigBuilder.py') # File name subject to change

    pythonPath = sys.executable

    runCommand = '{} "{}" "{}"'.format(pythonPath, setupScript, premiereKeyFileIn)
    runCommand += ' --displayScaling {}'.format(windowsConfigs['display scaling'])

    retCode = os.system(runCommand)
    if retCode == 0:
        print('You should now see a shiny new config file in your output directory')
    else:
        print(premiereKeyFileIn)
        print('What the hell happened?')
    
    return retCode

# Main Function
if __name__ == '__main__':

    windowsConfigs = {}
    _, windowsConfigs['display scaling'], premiereKeyfile = AskUserQuestions()
    BuildConfig(windowsConfigs, premiereKeyfile)

    input("\nPress ENTER To Close...")
    sys.exit(0)
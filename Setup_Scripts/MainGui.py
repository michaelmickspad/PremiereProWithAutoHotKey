import configparser
import tkinter as tk
from tkinter import *
from tkinter import messagebox
from tkinter import ttk
from tkinter.messagebox import *
from tkinter.filedialog import *
from tkinter.filedialog import askopenfilename
import os
import json
import sys
import webbrowser

# Non-system imports
import AHKScriptWriter
import FirstTimeSetupGui

# This is a global variable so it's easier to add to as more functions get implemented
# and are considered "valid" for the dropdown option selection
validFunctions = [
    'preset',
    'searchForEffect',
    'deleteSingleClipAtCursor',
    'marker',
    'effectsPanelFindBox',
    'addGain',
    'changeClipColor',
    'ExitApp'
]

githubUrl = 'https://github.com/michaelmickspad/PremiereProWithAutoHotKey/tree/main'

# Global Functions that are best left out of the objects
def openUrl(url):
    webbrowser.open_new(url)

def RunFirstTimeSetup(topdirIn):
    # I want to have a separate gui that does the first time setup process like a
    # startup wizard, but that's quickly becomming way more work than I want to put in
    # and I already have the command line walkthrough working, so for the time being,
    # that's what's getting called until I decide to go back to the first time setup
    # gui (or someone offers a code contribution)
    firstTimeSetupExe = os.path.join(topdirIn, 'FirstTimeSetup.exe')
    os.system(firstTimeSetupExe)

def CheckForConflicts(ctrl, shift, alt, keybind, iniFilePath):
    '''
    This checks to see if there are any conflicts with keybinds set in Premiere
    This function gets called before officially saving a hotkey so the user has a chance
    to cancel the save

    Returns true if there is a conflict and false if there is no conflict
    '''
    ahkConfig = configparser.ConfigParser()
    ahkConfig.read(iniFilePath)
    hotkeyVal = ''
    if ctrl:
        hotkeyVal = hotkeyVal + '^'
    if shift:
        hotkeyVal = hotkeyVal + '+'
    if alt:
        hotkeyVal = hotkeyVal + '!'
    hotkeyVal = hotkeyVal + keybind
    premiereKeybinds = ahkConfig['Premiere_Keybinds']
    # Run through each of the saved Premiere shortcuts and see if there are any conflicts
    # This isn't the most efficient way of doing this, but on the small scale that this
    # program is working with, it's instantaneous from the user's perspective
    for keybind in premiereKeybinds.values():
        if hotkeyVal.lower() == keybind.lower():
            return True # Conflict
    return False # No Conflict

class Hotkey:
    def __init__(
            self,
            id = -1,
            ctrl = False,
            shift = False,
            alt = False,
            keybind = '',
            func = '',
            funcParam = '',
            customCode = False
        ):
        self.id = id
        self.ctrl = ctrl
        self.shift = shift
        self.alt = alt
        self.keybind = keybind
        self.func = func
        self.funcParam = funcParam
        self.customCode = customCode

    def ExportToDict(self):
        '''
        The .json file is in a list format, so this takes all the values of the hotkey
        and repackages it into a dictionary so it can be added to the list to put back
        into the .json file
        '''
        exportDict = dict()
        exportDict['id'] = int(self.id)
        exportDict['ctrl'] = self.ctrl
        exportDict['shift'] = self.shift
        exportDict['alt'] = self.alt
        if self.keybind.strip():
            exportDict['hotkey'] = self.keybind
        else:
            exportDict['hotkey'] = "\{End\}" # Default invalid keybinds to end key
        if self.func and self.func.strip() in validFunctions:
            exportDict['function'] = self.func.strip()
        else:
            exportDict['function'] = False
        if self.funcParam:
            exportDict['parameter'] = self.funcParam.strip()
        else:
            exportDict['parameter'] = False
        exportDict['custom_code'] = self.customCode
        return exportDict

    def ExportToList(self):
        '''
        Takes all of the data stored within the object and adjusts it to a format where
        the viewTable will read and display it in a user friendly manner
        '''
        ctrlDisplay = '✓'
        shiftDisplay = '✓'
        altDisplay = '✓'
        custDisplay = '✓'
        funcDisplay = self.func
        funcParamDisplay = self.funcParam

        if not self.ctrl:
            ctrlDisplay = ' '
        if not self.shift:
            shiftDisplay = ' '
        if not self.alt:
            altDisplay = ' '
        if not self.customCode:
            custDisplay = ' '
        if not self.func:
            funcDisplay = 'N/A'
        if not self.funcParam:
            funcParamDisplay = 'N/A'

        outList = [self.id,
                   ctrlDisplay,
                   shiftDisplay,
                   altDisplay,
                   self.keybind,
                   funcDisplay,
                   funcParamDisplay,
                   custDisplay]
        return outList

    def DebugPrint(self):
        print('PRINTING DEBUG OUTPUT')
        print('ID: {}'.format(self.id))
        print('Ctrl: {}'.format(self.ctrl))
        print('Shift: {}'.format(self.shift))
        print('Alt: {}'.format(self.alt))
        print('Hotkey: {}'.format(self.keybind))
        print('Function: {}'.format(self.func))
        print('Parameter: {}'.format(self.funcParam))
        print('Custom Code: {}'.format(self.customCode))
        print('END OF PRINTING DEBUG OUTPUT')

class WelcomeWindow:
    '''
    Mini README Page that appears when the user first starts up the program that has
    links to the github page and brief reminders, while also giving the user a button
    to run first time setup
    '''
    def __init__(
            self,
            configFile,
            mainWindow
        ):
        self.configFile = configFile
        self.mainWindow = mainWindow

        self.root = tk.Tk()
        self.root.resizable(width=0, height=0)
        self.root.attributes('-topmost', True)
        self.frame = tk.Frame(self.root)
        self.root.title('Welcome')

        self.welcomeLabel = Label(self.root, text='Welcome')
        self.check_dontShowAgain_state = BooleanVar()
        self.check_dontShowAgain = Checkbutton(self.root,
                                               variable=self.check_dontShowAgain_state,
                                               text='Do not show this message again')
        #self.label_dontShowAgain = Label(text='Do not show this message again')
        self.welcomeLabel.grid(row=0, column=0)
        self.check_dontShowAgain.grid(row=1, column=0)

        self.root.protocol('WM_DELETE_WINDOW', lambda: self.closeWelcomePage())
    
    def closeWelcomePage(self):
        '''
        Checks the value of the checkbox and determines if the welcome page should be
        shown again and saves that value to the config file
        '''
        print('PLACEHOLDER - updateConfigWelcome')
        self.root.destroy()

class CustomCodeEntryWindow():
    '''
    Allows the user to enter their own code for a hotkey via a text editor, but in a way
    that can actually be tracked and saved when re-writing the AHK scripts

    This class is a heavily modified version of the recreation of Notepad using
    TKinter by Mirnal Verma

    This lacks a lot of the creature comforts of other IDE's but if people are going to
    complain about that, they can use their IDE and then just copy and paste, it's made
    for if the user wants to go a little bit more complicated than the rest of the gui
    can provide, if they want to go beyond this, they could just write their own
    AutoHotKey script and use the provided functions
    '''
    def __init__(
            self,
            mainWindow,
            idNumIn,
            topDirectory
        ):
        self.mainWindow = mainWindow
        self.idNum = idNumIn
        self.customCode = ''
        self.topDirectory = topDirectory
        self.customCodeFile = ''

        # Checks to see if there is any custom code already written
        self.customCodeFile = os.path.join(self.topDirectory, 'config', 'CustomFunctions')
        self.customCodeFile = os.path.join(self.customCodeFile, 'CustomCode{}.txt'.format(self.idNum))

        if os.path.exists(self.customCodeFile):
            with open(self.customCodeFile, 'r') as custFile:
                self.customCode = custFile.read()

        # Overall Page Configuration
        self.root = tk.Tk()
        self.root.title('Custom Code Entry')
        self.root.protocol('WM_DELETE_WINDOW', lambda: self.CloseCustomCodePage())
        self.textInputArea = Text(self.root, wrap='none')

        # Scrollbars
        self.yScrollBar = Scrollbar(self.textInputArea, orient=VERTICAL)
        self.xScrollBar = Scrollbar(self.textInputArea, orient=HORIZONTAL)

        # Control Buttons
        self.saveButton = Button(self.root, text = 'Save', padx=5, pady=2, width=15, justify='center')

        # Set Width and Height
        # TODO: Change the default window size
        self.winWidth = 500
        self.winHeight = 500
        screenWidth = self.root.winfo_screenwidth()
        screenHeight = self.root.winfo_screenheight()
        leftPos = int(screenWidth / 2) - int(self.winWidth / 2)
        topPos = int(screenHeight / 2) - int(self.winHeight / 2)
        self.root.geometry('{}x{}+{}+{}'.format(self.winWidth, self.winHeight, leftPos, topPos))

        # Make the text area auto resizable
        self.root.grid_rowconfigure(0, weight=1)
        self.root.grid_columnconfigure(0, weight=1)

        # Add controls
        self.textInputArea.grid(sticky= N + E + S + W,
                                column=0,
                                row=0,
                                columnspan=3,
                                padx=2,
                                pady=2)

        self.yScrollBar.pack(side=RIGHT,fill=Y)
        self.xScrollBar.pack(side=BOTTOM,fill=X)

        # Scrollbar will adjust automatically according to the content
        self.yScrollBar.config(command=self.textInputArea.yview)
        self.textInputArea.config(yscrollcommand=self.yScrollBar.set)
        self.xScrollBar.config(command=self.textInputArea.xview)
        self.textInputArea.config(xscrollcommand=self.xScrollBar.set)

        # Add the buttons to the bottom
        self.saveButton.config(command=lambda: self.SaveCustomCode())
        self.saveButton.grid(row=1, column=0, padx=5, pady=2, sticky=W)

        # Add in whatever code was saved previously
        self.textInputArea.insert(END, self.customCode)
    
    def SaveCustomCode(self):
        '''
        Saves the custom code to a persistent file
        '''
        self.customCode = self.textInputArea.get("1.0", END)
        with open(self.customCodeFile, 'w') as custFile:
            custFile.write(self.customCode)
    
    def CloseCustomCodePage(self):
        '''
        Checks for any unsaved changes before the page is closed
        '''
        closePage = True
        if self.customCode != self.textInputArea.get("1.0",END):
            closePage = False
            msg = 'You have unsaved changes, still quit?'
            if messagebox.askokcancel('Quit', msg):
                closePage = True
        if closePage:
            self.root.destroy()

class MainWindow:
    def __init__(
            self,
            hotkeyList,
            hotkeyJsonFile,
            configFilePath,
            topDirectory
        ):
        self.hotkeyList = hotkeyList
        self.hotkeyJsonFile = hotkeyJsonFile
        self.configFile = configFilePath
        self.topDirectory = topDirectory

        self.root = tk.Tk()
        self.root.resizable(width=0, height=0)
        self.frame = tk.Frame(self.root)
        self.frame_buttons = tk.Frame(self.frame)

        # Overall Page Configurations
        self.root.title('Premiere Pro With AutoHotKey')
        self.root.protocol('WM_DELETE_WINDOW', lambda: self.SaveAndClose())

        # Create the dropdown menubar options
        self.menubar = Menu(self.root)
        self.root.config(menu=self.menubar)
        self.fileMenu = Menu(self.menubar)
        self.menubar.add_cascade(label='File', menu=self.fileMenu)
        self.fileMenu.add_command(label='Run Automation Program',
                                  command=lambda: self.SaveAndRunFullProgram())
        self.fileMenu.add_command(label='Update Premiere Hotkeys',
                                  command=lambda: self.UpdatePremiereHotkeys())
        self.fileMenu.add_command(label='Change Premiere Hotkey File',
                                  command=lambda: self.ChangeKysFile())
        self.fileMenu.add_separator()
        self.fileMenu.add_command(label='Run First Time Setup',
                                  #command=lambda: FirstTimeSetupGui.FirstTimeSetupWindow(self.root))
                                  command=lambda: RunFirstTimeSetup(self.topDirectory))
        self.fileMenu.add_separator()
        self.fileMenu.add_command(label='Github Page',
                                  command=lambda: openUrl(githubUrl))
        self.fileMenu.add_separator()
        self.fileMenu.add_command(label='Exit',
                                  command=lambda: self.root.destroy())

        # Create the elements for viewing the hotkeys
        self.viewTable = ttk.Treeview(self.frame,
                                      columns=(1,2,3,4,5,6,7,8),
                                      show='headings')
        self.viewTable.column(1, anchor='center', width=30)
        self.viewTable.heading(1, text='ID')
        self.viewTable.column(2, anchor='center', width=35)
        self.viewTable.heading(2, text='Ctrl')
        self.viewTable.column(3, anchor='center', width=35)
        self.viewTable.heading(3, text='Shift')
        self.viewTable.column(4, anchor='center', width=35)
        self.viewTable.heading(4, text='Alt')
        self.viewTable.column(5, anchor='center', width=100)
        self.viewTable.heading(5, text='Hotkey')
        self.viewTable.column(6, anchor='center', width=100)
        self.viewTable.heading(6, text='Function')
        self.viewTable.column(7, anchor='center', width=100)
        self.viewTable.heading(7, text='Parameter')
        self.viewTable.column(8, anchor='center', width=50)
        self.viewTable.heading(8, text='Custom')

        # Populate the initial hotkeys to the list
        for hotkeyListKey in hotkeyList:
            viewTableHKFormat = hotkeyList[hotkeyListKey].ExportToList()
            self.viewTable.insert('', END, values=viewTableHKFormat)

        # Create the elements for editing hotkeys
        self.label_id = tk.Label(self.frame, text='ID:')
        self.label_idVal = tk.Label(self.frame, text='')
        self.label_shift = tk.Label(self.frame, text='Shift:')
        self.check_shift_state = BooleanVar()
        self.check_shift = tk.Checkbutton(self.frame, state='disabled', variable=self.check_shift_state)
        self.label_ctrl = tk.Label(self.frame, text='Ctrl:')
        self.check_ctrl_state = BooleanVar()
        self.check_ctrl = tk.Checkbutton(self.frame, state='disabled', variable=self.check_ctrl_state)
        self.label_alt = tk.Label(self.frame, text='Alt:')
        self.check_alt_state = BooleanVar()
        self.check_alt = tk.Checkbutton(self.frame, state='disabled', variable=self.check_alt_state)
        self.label_keybind = tk.Label(self.frame, text='Keybind:')
        self.entry_keybind = tk.Entry(self.frame, state='disabled')
        self.label_function = tk.Label(self.frame, text='Function:')
        self.combo_function = ttk.Combobox(self.frame, values=validFunctions, state='disabled')
        self.label_param = tk.Label(self.frame, text='Parameter:')
        self.entry_param = tk.Entry(self.frame, state='disabled')
        self.label_useCust = tk.Label(self.frame, text='Custom Code:')
        self.check_useCust_state = BooleanVar()
        self.check_useCust = tk.Checkbutton(self.frame, state='disabled', variable=self.check_useCust_state)
        self.button_custCode = tk.Button(self.frame, text='Write Code', state='disabled')

        self.button_addHotkey = tk.Button(self.frame_buttons, text='Add Hotkey')
        self.button_editHotkey = tk.Button(self.frame_buttons, text='Save Edits', state='disabled')
        self.button_removeHotkey = tk.Button(self.frame_buttons, text='Remove Hotkey', state='disabled')
        self.button_startAHK = tk.Button(self.frame_buttons, text='Start AHK Script')

        #=======================================================================

        # Start Placing the items into the GUI (This may need to be overhauled by pixel
        # placements instead of grid)
        self.frame.grid(row=0, column=0)
        self.viewTable.grid(row=0, column=0, rowspan=5, columnspan=2, padx=10, pady=10)

        self.label_id.grid(row=6, column=0, sticky='e')
        self.label_idVal.grid(row=6, column=1, sticky='w')
        self.label_ctrl.grid(row=7, column=0, sticky='e')
        self.check_ctrl.grid(row=7, column=1, sticky='w')
        self.label_shift.grid(row=8, column=0, sticky='e')
        self.check_shift.grid(row=8, column=1, sticky='w')
        self.label_alt.grid(row=9, column=0, sticky='e')
        self.check_alt.grid(row=9, column=1, sticky='w')
        self.label_keybind.grid(row=10, column=0, sticky='e')
        self.entry_keybind.grid(row=10, column=1, sticky='w')
        self.label_function.grid(row=11, column=0, sticky='e')
        self.combo_function.grid(row=11, column=1, sticky='w')
        self.label_param.grid(row=12, column=0, sticky='e')
        self.entry_param.grid(row=12, column=1, sticky='w')
        self.label_useCust.grid(row=13, column=0, sticky='e')
        self.check_useCust.grid(row=13, column=1, sticky='w')
        self.button_custCode.grid(row=13, column=1, sticky='w', padx=25)

        self.frame_buttons.grid(row=15, column=0, columnspan=2)
        self.button_addHotkey.grid(row=1, column=0, padx=10, pady=10)
        self.button_editHotkey.grid(row=1, column=1, padx=10, pady=10)
        self.button_removeHotkey.grid(row=1, column=2, padx=10, pady=10)
        self.button_startAHK.grid(row=1, column=3, padx=10, pady=10)

        # Set the functionality of the buttons and viewTable
        self.viewTable.bind("<<TreeviewSelect>>", self.MoveHotkeyToEditField)
        self.button_addHotkey['command'] = lambda: self.MakeNewHotkey()
        self.button_editHotkey['command'] = lambda: self.saveEditsMade()
        self.button_custCode['command'] = lambda: self.WriteCustomCode()
        self.button_removeHotkey['command'] = lambda: self.DeleteHotkey()
        self.button_startAHK['command'] = lambda: self.SaveAndRunFullProgram()

        # Check the config file and see if we should display the welcome page
        config = configparser.ConfigParser()
        showWelcomePage = False
        if os.path.exists(self.configFile):
            config.read(self.configFile)
            if not config.get('PPWAHK_Configs', 'hideWelcomePage', fallback=False):
                showWelcomePage = True
        else:
            showWelcomePage = True
        
        # TODO: Uncomment following lines after the welcomePage has been more fleshed out
        # if showWelcomePage:
        #     welcomePage = WelcomeWindow(self.configFile, self)
        #     welcomePage.root.mainloop()
        # As of right now, the welcome page is just going to be a temporary warning message
        if showWelcomePage:
            msg = 'Configuration file not found, please run the first time setup\n\n' \
                + 'If you are seeing this after running the first time setup, you may ' \
                + 'have forgotten to extract the program before running it.'
            messagebox.showwarning('First Time Setup Required', msg)


    def disableInput(self):
        # If the user is not editing a hotkey, only the "add hotkey" button should be
        # able to be pressed
        self.check_ctrl['state'] = 'disabled'
        self.check_shift['state'] = 'disabled'
        self.check_alt['state'] = 'disabled'
        self.entry_keybind['state'] = 'disabled'
        self.entry_param['state'] = 'disabled'
        self.combo_function['state'] = 'disabled'
        self.check_useCust['state'] = 'disabled'
        self.button_custCode['state'] = 'disabled'
        self.button_editHotkey['state'] = 'disabled'
        self.button_removeHotkey['state'] = 'disabled'
    
    def enableInput(self):
        # Called when the user is creating or editing a new hotkey to allow changes
        self.check_ctrl['state'] = 'normal'
        self.check_shift['state'] = 'normal'
        self.check_alt['state'] = 'normal'
        self.entry_keybind['state'] = 'normal'
        self.entry_param['state'] = 'normal'
        self.combo_function['state'] = 'normal'
        self.check_useCust['state'] = 'normal'
        self.button_custCode['state'] = 'normal'
        self.button_editHotkey['state'] = 'normal'
        self.button_removeHotkey['state'] = 'normal'
    
    def ClearEditFields(self):
        self.label_idVal['text'] = ''
        self.entry_keybind.delete(0,END)
        self.entry_param.delete(0,END)
        self.combo_function.delete(0, END)
        self.check_alt.deselect()
        self.check_ctrl.deselect()
        self.check_shift.deselect()
        self.check_useCust.deselect()
    
    def MoveHotkeyToEditField(self, a):
        self.ClearEditFields()
        self.enableInput()
        # Get the ID from the viewTable and use it as the key to get the hotkey object
        try:
            selectedViewTableItem = self.viewTable.selection()[0]
        except IndexError:
            # This occurs when a hotkey is deleted, rather than having it error out, this
            # will stop this function from running
            self.disableInput()
            return False # Stop function
        self.label_idVal['text'] = self.viewTable.item(selectedViewTableItem)['values'][0]
        idNum = '{}'.format(self.label_idVal['text'])
        hotkeyToPullFrom = self.hotkeyList[idNum]
        self.entry_keybind.insert(0, hotkeyToPullFrom.keybind)
        if hotkeyToPullFrom.func:
            self.combo_function.set(hotkeyToPullFrom.func)
        else:
            # No function set
            self.combo_function.delete(0, END)
        if hotkeyToPullFrom.funcParam:
            self.entry_param.insert(0, hotkeyToPullFrom.funcParam)
        else:
            # No function parameter set
            self.entry_param.delete(0, END)
        if hotkeyToPullFrom.alt:
            self.check_alt.select()
        if hotkeyToPullFrom.shift:
            self.check_shift.select()
        if hotkeyToPullFrom.ctrl:
            self.check_ctrl.select()
        if hotkeyToPullFrom.customCode:
            self.check_useCust.select()

    def saveEditsMade(self):
        '''
        Takes the information entered by the user in the edit fields and saves it in the
        hotkey obects
        '''
        # The user should not be able to save if there is no set hotkey
        if not self.entry_keybind.get().strip():
            messagebox.showwarning('Error', 'You must set a keybind to save the hotkey')
            return False # Just end the function
        
        # We need to check to see if the hotkey the user is trying to set is available
        conflict = CheckForConflicts(self.check_ctrl_state.get(),
                                     self.check_shift_state.get(),
                                     self.check_alt_state.get(),
                                     self.entry_keybind.get(),
                                     self.configFile)
        if conflict:
            # TODO: Probably re-write this message, it seems really wordy and confusing
            # Note: After testing, ahk hotkeys have a higher priority than premiere keybinds
            # when running in windows, so make that the focus of the new message
            msg = "The key combination you are trying to set conflicts with a keyboard " \
                + "shortcut in Premiere Pro. This can have unexpected behavior. I " \
                + "recommend picking a different key combination or updating your " \
                + "keyboard shortcuts in Premiere Pro.\n\nIf you do update your " \
                + "keyboard shortcuts in Premiere Pro, remember that you need to " \
                + "update that information within this program. You can do this by " \
                + "clicking File > Update Premiere Hotkeys\n\nHowever, the detected key" \
                + "may be a menu shortcut and this detection is a false positive. " \
                + "\n\nAre you sure you want to save this hotkey?"
            res = messagebox.askquestion('Key Combination Conflict', msg)
            if res == 'no':
                return False # Just end the function

        newHotkey = False # Default value to be overridden
        # Formatting this in case it gets converted to an int
        idNum = '{}'.format(self.label_idVal['text'])
        if not idNum in self.hotkeyList.keys():
            # This is a new hotkey that was just created
            newHotkey = True
            hotkeyToSaveTo = Hotkey(id=idNum)
        else:
            hotkeyToSaveTo = self.hotkeyList[idNum]
        
        # Update the data stored in the object
        hotkeyToSaveTo.ctrl = self.check_ctrl_state.get()
        hotkeyToSaveTo.shift = self.check_shift_state.get()
        hotkeyToSaveTo.alt = self.check_alt_state.get()
        hotkeyToSaveTo.keybind = self.entry_keybind.get()
        hotkeyToSaveTo.func = self.combo_function.get()
        hotkeyToSaveTo.funcParam = self.entry_param.get()
        hotkeyToSaveTo.customCode = self.check_useCust_state.get()

        viewTableValues = hotkeyToSaveTo.ExportToList()
        if newHotkey:
            # We need to add it to the overall hotkey list
            self.hotkeyList[idNum] = hotkeyToSaveTo
            newViewTableRow = hotkeyToSaveTo.ExportToList()
            self.viewTable.insert('', END, values=newViewTableRow)
        else:
            selectedViewTableItem = self.viewTable.selection()[0]
            self.viewTable.item(selectedViewTableItem, values=viewTableValues)

        self.ClearEditFields()
        self.disableInput()
        self.SaveAllHotkeyChangesToJSON(writeScripts=True)

    def MakeNewHotkey(self):
        '''
        Happens when the "Add Hotkey" button is pressed and allows the user to enter
        information for a new hotkey
        '''
        self.viewTable.selection_clear()
        self.ClearEditFields()
        self.enableInput()
        idNum = self.FindFirstAvailableIDNum()
        self.label_idVal['text'] = idNum

    def DeleteHotkey(self):
        # Formatting this in case it gets converted to an int
        idNum = '{}'.format(self.label_idVal['text'])
        msg = "Are you sure you want to delete this custom hotkey?"
        res = messagebox.askquestion('Are you sure?', msg)
        if res == 'yes':
            # Remove any custom code file
            custFile = os.path.join(self.topDirectory, 'config', 'customFunctions')
            custFile = os.path.join(custFile, 'CustomCode{}.txt'.format(idNum))
            if os.path.exists(custFile):
                os.remove(custFile)
            # Remove it from the overall dictionary
            del hotkeyList[idNum]
            # Remove it from the viewTable
            selectedViewTableItem = self.viewTable.selection()[0]
            self.viewTable.delete(selectedViewTableItem)
            self.ClearEditFields()
            self.disableInput()
            self.SaveAllHotkeyChangesToJSON(writeScripts=True)

    def PrintHotkeyDebug(self):
        # Formatting this in case it gets converted to an int
        idNum = '{}'.format(self.label_idVal['text'])
        hotkeyList[idNum].DebugPrint()
    
    def SaveAllHotkeyChangesToJSON(self, writeScripts=False):
        '''
        Runs through the list of all the hotkeys, converts them all to the proper JSON
        format and then updates the .json file so the ahkscript writer can run through

        WriteScripts when active will run the external AHKScriptWriter.py script to 
        then convert the .json data into a format understandable to AutoHotKey
        '''
        # TODO: Add in some error checking, I know it already exists in saveEdits, but
        # this gets called when doing the run function and closing the program
        # maybe add an extra parameter here to do the extra error checking
        listToPushToJSONFile = []
        for hotkeyKey in self.hotkeyList.keys():
            currHotkey = self.hotkeyList[hotkeyKey]
            listToPushToJSONFile.append(currHotkey.ExportToDict())
        
        # The list should be sorted by the value of the ID
        listToPushToJSONFile = sorted(listToPushToJSONFile, key=lambda x: x.get('id'))
        
        jsonString = json.dumps(listToPushToJSONFile, indent=4)
        
        with open(self.hotkeyJsonFile, 'w') as outFile:
            outFile.write(jsonString)
        
        if writeScripts:
            AHKScriptWriter.WriteTheScript(self.topDirectory)
    
    def FindFirstAvailableIDNum(self):
        '''
        Since the user can add and remove hotkeys, the ID numbers may become a jumbled
        mess, so this function helps to find the first available number
        (Future plans may include flooring all of the IDs upon startup of the gui)
        '''
        for i in range(1, 1000):
            # Stringify i
            iString = '{}'.format(i)
            # Check to see if the value already exists
            if not iString in self.hotkeyList.keys():
                return iString
        print('ERROR: HOTKEY ID ERROR')
        return False # Handle this later, but for now, induce an intentional crash

    def WriteCustomCode(self):
        '''
        Opens up a separate window that's like notepad and allows the user to save their
        custom code to a file stored in the configs directory
        '''
        idNum = '{}'.format(self.label_idVal['text'])
        custCodePage = CustomCodeEntryWindow(self, idNum, self.topDirectory)
        custCodePage.root.mainloop()
    
    def UpdatePremiereHotkeys(self):
        '''
        Calls a separate script to update the config if there have been any changes to
        the premiere .kys file
        '''
        ahkConfig = configparser.ConfigParser()
        ahkConfig.read(self.configFile)
        kysFileLoc = ahkConfig.get('PPWAHK_Configs',
                                   'kysFileLocation',
                                   fallback='NONE SET')
        
        if os.path.exists(kysFileLoc):
            # Valid File path for the .kys file
            print('PLACEHOLDER: CALL CONFIG BUILDER SCRIPT')
        else:
            # Either the file path was invalid or there is no .kys saved to the config
            # either way, prompt the user to set a new config file
            msg = "There is no .kys saved to your settings configuration. Would you " \
                  "like to set one?"
            res = messagebox.askquestion('.kys Config Error', msg)
            if res == 'yes':
                fileSelected = askopenfilename(filetypes=[("Premiere Keybinds", "*.kys")])
                fileSelected = os.path.abspath(fileSelected)
                print('PLACEHOLDER: Call Config Builder with new .kys to save to config')
    
    def ChangeKysFile(self):
        '''
        Allows the user to select the .kys file and reconfigure based on it
        '''
        fileSelected = askopenfilename(filetypes=[("Premiere Keybinds", "*.kys")])
        fileSelected = os.path.abspath(fileSelected)
        print('Call Config Builder with new .kys to save to config')
    
    def SaveAndRunFullProgram(self):
        '''
        Runs through a quick check to ensure that everything is good to go and then
        closes the gui and starts the AHK Script
        '''
        # TODO: Add in some error checking here like there is in saveEditsMade
        # to make sure that we don't overwrite anything
        self.SaveAllHotkeyChangesToJSON(writeScripts=True)
        ppwahkRunner = os.path.join(self.topDirectory, 'PremiereProWithAutoHotKey.ahk')
        self.root.destroy()
        # START is somewhat equivalent to adding "&" at the end of a linux command, it's
        # not exactly the same, but close enough for this program, it runs the script "in
        # the background" as it's own process completely separate from this script
        os.system('START {}'.format(ppwahkRunner))
        sys.exit(0)
    
    def SaveAndClose(self):
        '''
        Runs through a quick check to ensure that everything is good to go and then
        closes the gui
        '''
        # TODO: Maybe add in some error checking, but also maybe just remove this
        # function entirely and just set the close via the X button to run through
        # the other save function before closing rather than having this dedicated
        # function for that
        print('PLACEHOLDER - SaveAndClose')
        self.root.destroy()

def loadSavedHotkeys(jsonFile = False):
    '''
    Reads the .json file and parses all of the data into a python list of objects
    Defaults the input argument to False so dummy data can be used for testing purposes
    '''
    if jsonFile:
        with open(jsonFile) as jFile:
            hotkeyDictList = json.loads(jFile.read())
    else:
        # Once this gets merged into the final project, remove this mess
        # This is only to be used for testing
        hotkeyDictList = '[{"id": 1,"shift": false,"alt": false,"ctrl": false,"hotkey":' \
                       + ' "j","function": "preset","parameter": "BLUR10","custom_code"' \
                       + ': false},{"id": 2,"shift": false,"alt": true,"ctrl": true,' \
                       + '"hotkey": "Numpad0","function": false,"parameter": false,' \
                       + '"custom_code": true}]'
        hotkeyDictList = json.loads(hotkeyDictList)

    hotkeyList = {}

    for hotkeyDict in hotkeyDictList:
        # Putting this into a dictionary sorted by the id numbers to assist in both
        # finding new id numbers quickly if the user deletes hotkeys and it gets messy
        # but also to keep the 3 different data formats the hotkeys have to be stored in
        # easy to match and switch between one another
        hotkeyList['{}'.format(hotkeyDict['id'])] = Hotkey(hotkeyDict['id'],
                                                           hotkeyDict['ctrl'],
                                                           hotkeyDict['shift'],
                                                           hotkeyDict['alt'],
                                                           hotkeyDict['hotkey'],
                                                           hotkeyDict['function'],
                                                           hotkeyDict['parameter'],
                                                           hotkeyDict['custom_code'])
    return hotkeyList


if __name__ == '__main__':
    
    # Determine the location of the Top Directory (PremiereProWithAutoHotKey)
    # Gathering this data differs depending on if this is a run as a script or as an exe
    if getattr(sys, 'frozen', False):
        # Executable
        topdir = os.path.dirname(sys.executable)
    else:
        # Script
        topdir = os.path.abspath(__file__)
        topdir = os.path.dirname(topdir) # Setup_Scripts
        topdir = os.path.dirname(topdir) # Top Dir / PremiereProWithAutoHotKey
    
    # These are important file paths that need to be passed around
    hotkeyJsonFile = os.path.join(topdir, 'config', 'userMadeHotkeys.json')
    iniConfigFile = os.path.join(topdir, 'config', 'PremiereWithAHKConfig.ini')

    hotkeyList = loadSavedHotkeys(jsonFile=hotkeyJsonFile)

    program = MainWindow(hotkeyList, hotkeyJsonFile, iniConfigFile, topdir)
    program.root.mainloop()
//
//  AppDelegate.swift
//  op
//
//  Created by nogira on 30/5/2022.
//

import Cocoa

// TODO: event listener for copy/paste events occuring after a selection so there is not lag from not estimating the dispatch time well enough


// have folder where you place plugin folders containing json (which specifies the shell env, the name/relative-location of root script, the regex match for the plugin to popup on, and the icon name), icon image, and the code

/**
 type of text input, so we know what type of popup window to trigger.
 
 there are three button types to be handled:
 1. **copy-paste**: copy selection → modify text → paste text, replacing original selection
 2. **copy**: copy selection → trigger something, but don't replace original selection
 3. **paste**: paste from the clipboard (could also modify the clipboard text before pasting)
 
 all button types will appear on a selection event, though button type 3 will only appear on a long-press event, thus we need to make sure to mark non-paste buttons so we know not to incluide them in a paste-type popup
 */
enum InputType: String, Decodable {
    //          above struct & protocol are for JSON parsing
    case selection
    case pasteboard
}
enum SelectionMethod {
    case accessibility
    case keyPress
}

struct SelectionData {
    var currentSelection: String = ""
    var popupType: InputType = .selection
    var selectionMethod: SelectionMethod = .accessibility
    var prevFocusedApp: NSRunningApplication! = nil
    var mouseDownPosition: NSPoint! = nil
    var mouseUpPosition: NSPoint! = nil
}

var data = SelectionData()



class AppDelegate: NSObject, NSApplicationDelegate {

    let defaults = UserDefaults.standard
    
    let actions: [ActionConfig] = loadActions()
    
//    lazy var settingsWindowController = SettingsWindowController()
//    lazy var popupWindowController = PopupWindowController()
    var settingsWindow: NSWindow?
    var settingsViewController: SettingsViewController?
    var popupWindow: NSWindow?
    var popupViewController: PopupViewController?
    
    // store state of our status bar item so it stays in memory, and thus displays on status bar
    var statusBarItem: NSStatusItem!
    
    
    func applicationWillFinishLaunching(_ notification: Notification) {

    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        acquirePrivileges()
        
        // create status bar item
        statusBarItem = createStatusBarItem()
        
        // create popup window
        (popupWindow, popupViewController) = createPopupWindow()
        
        // create settings window
        (settingsWindow, settingsViewController) = createSettingsWindow()
    }
    
    @objc func settings() {
        print("show/hide")
        if let window: NSWindow = settingsWindow {
            if window.isVisible {
                window.orderOut(self)
            } else {
                window.orderFront(self)
                // send window to front / focus the window
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    @objc func openFolder() {
        print("open folder")
        let path: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let baseFolder: URL =  path.appendingPathComponent("nogira.op")
        let pluginsFolder: URL = baseFolder.appendingPathComponent("plugins")

        NSWorkspace.shared.selectFile(
            nil, inFileViewerRootedAtPath: pluginsFolder.path)
    }
    @objc func quit() {
        print("quit")
        NSApp.terminate(Any?.self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}


//NSPasteboard.accessibilityFocusedUIElement()

func acquirePrivileges() {
    let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
    let privOptions = [trusted: true] as CFDictionary
    let accessEnabled: Bool = AXIsProcessTrustedWithOptions(privOptions)
    print("accessEnabled: \(accessEnabled)")
}

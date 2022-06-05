//
//  AppDelegate.swift
//  op
//
//  Created by nogira on 30/5/2022.
//

import Cocoa

// TODO: event listener for copy/paste events occuring after a selection so there is not lag from not estimating the dispatch time well enough


// have folder where you place plugin folders containing json (which specifies the shell env, the name/relative-location of root script, the regex match for the plugin to popup on, and the icon name), icon image, and the code

struct Data {
    var currentSelection: String = ""
    var selectionType: String = "all"
    var selectionAquisitionMethod: String = ""
    var prevFocusedApp: NSRunningApplication! = nil
    var accessibilityFocusedElement: AnyObject! = nil
}

var data = Data()

//@main
class AppDelegate: NSObject, NSApplicationDelegate {

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
        
        addEventListeners()
        
        
        
        // create settings window
        (settingsWindow, settingsViewController) = createSettingsWindow()
//        // show window
//        settingsWindow!.makeKeyAndOrderFront(nil)
        
        
        // create popup window
        (popupWindow, popupViewController) = createPopupWindow()
//        // show window
//        popupWindow!.makeKeyAndOrderFront(nil)
        
        
        
        // create status bar item
        statusBarItem = createStatusBarItem()
        
        
        //        // for NSServices to work
        //        NSApp.servicesProvider = self
    }
    
//    @objc func handleTextSelection(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
//        if let str = pboard.string(forType: NSPasteboard.PasteboardType.string) {
//                //your logic goes here
//            print(str)
//       }
//    }
    
    @objc func show() {
        print("show")
        if let window: NSWindow = settingsWindow {
            window.orderFront(self)
        }
        // send window to front / focus the window
        NSApp.activate(ignoringOtherApps: true)
    }
    @objc func hide() {
        print("hide")
        if let window: NSWindow = settingsWindow {
            window.orderOut(self)
        }
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

func createSettingsWindow() -> (NSWindow, SettingsViewController) {
    let settingsWindow: NSWindow! = NSWindow(
        contentRect: NSMakeRect(0, 0, 300, 300),
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false
    )
    // center the window on screen
    settingsWindow.center()
    settingsWindow?.title = "Settings"
    // always open window in the active space rather than the first space it opened in
    // space is another word for desktop (e.g. i have fullscreen safari on one desktop and xcode on another desktop)
    settingsWindow?.collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
    let settingsViewController: SettingsViewController! = SettingsViewController()
    let settingsContent = settingsWindow!.contentView! as NSView
    let settingsView = settingsViewController!.view
    settingsContent.addSubview(settingsView)
    
    return (settingsWindow, settingsViewController)
}

func createPopupWindow() -> (NSWindow, PopupViewController) {
    let popupWindow: NSWindow! = NSWindow( // 10, 1000, 200, 20
        contentRect: NSMakeRect(10, 800, 94, 24),
        styleMask: .unifiedTitleAndToolbar,
        backing: .buffered,
        defer: false
    )
    // always open window in the active space rather than the first space it opened in
    // space is another word for desktop (e.g. i have fullscreen safari on one desktop and xcode on another desktop)
    popupWindow?.collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
//    popupWindow?.hidesOnDeactivate = true
    let popupViewController: PopupViewController! = PopupViewController()
    let popupContent = popupWindow!.contentView! as NSView
    let popupView = popupViewController!.view
    popupContent.addSubview(popupView)
    
    return (popupWindow, popupViewController)
}

//NSPasteboard.accessibilityFocusedUIElement()

func acquirePrivileges() {
    let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
    let privOptions = [trusted: true] as CFDictionary
    let accessEnabled: Bool = AXIsProcessTrustedWithOptions(privOptions)
    print("accessEnabled: \(accessEnabled)")
}

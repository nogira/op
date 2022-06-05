//
//  Detect Events.swift
//  op
//
//  Created by nogira on 2/6/2022.
//

import AppKit
import ApplicationServices

import Cocoa
import Quartz
import CoreGraphics
import Carbon
import Foundation
import CoreFoundation

// keep in memory to speed it up
let copyScriptObject: NSAppleScript = NSAppleScript(
    contentsOf: Bundle.main.url(forResource: "jxa", withExtension: "scpt")!,
    error: nil)!

// TODO: remove popup on keypress
// also when mouse moves too far away

// TODO: remove popup after 2 sec when move a certain distance away from the menu bar (prob use y distance since could have v long popup where have to move to side alot to get button)

// TODO: modify applescript to detect if copy/paste button is available to be pressed or greyed out
// perhaps even dump accessibility in favor of this (?)

func addEventListeners() {
    // track length of drag
    var startDragLocation: NSPoint!
    
    // detect if window moved instead of text selected
    var startFocusedWindowFrame: CGRect!
    
    // detect long press in same spot
    var timeOfMouseDown: CGFloat!
    
    NSEvent.addGlobalMonitorForEvents(
        matching: .leftMouseDown,
        handler: {
            (event : NSEvent) -> Void in
            
            // add currently focused app  so can refocus after loses focus from clicking popup window
            data.prevFocusedApp = NSWorkspace.shared.frontmostApplication!
            
            if let frame = getCurrentWindowFrame() {
                startFocusedWindowFrame = frame
            }
            
            timeOfMouseDown = event.timestamp
            
            // hide popup on click. if double click or drag it will reappear
//            let popupWindow: NSWindow? = NSApp.windows[1]
//            if let window: NSWindow = popupWindow {
//                window.orderOut(nil)
//            }
            
            startDragLocation = event.locationInWindow

//            print("hello")
            
            if event.clickCount == 2 || event.clickCount == 3 {
                handleSelection(startPos: startDragLocation, endPos: startDragLocation!)
            }
        }
    )
    NSEvent.addGlobalMonitorForEvents(
        matching: .leftMouseUp,
        handler: {
            (event : NSEvent) -> Void in
            
            // confirm this is an actual drag event adn not a random key up with no prior key down
            if startDragLocation != nil {
                
                // this `if-let-else` for endFocusedWindowFrame is need in case accessibilty privileges are not yet on
                let endFocusedWindowFrame: CGRect
                if let frame = getCurrentWindowFrame() {
                    endFocusedWindowFrame = frame
                } else {
                    return
                }
                // if window hasn't moved or resized, event may be a text selection, so proceed with event handling
                if startFocusedWindowFrame == endFocusedWindowFrame {
                    
                    let currentLocation = event.locationInWindow
                    let x0 = startDragLocation.x
                    let y0 = startDragLocation.y
                    let x1 = currentLocation.x
                    let y1 = currentLocation.y
                    // print(x0, y0, x1, y1)
                    let x_diff = abs(x0 - x1)
                    let y_diff = abs(y0 - y1)

                    if x_diff > 5 || y_diff > 5 {
                        handleSelection(startPos: startDragLocation, endPos: currentLocation)
                    } else {
                        // handle long press in same spot
                        
                        let timeOfMouseUp = event.timestamp
                        let timeDiff = timeOfMouseUp - timeOfMouseDown
                        if timeDiff > 0.40 {
                            print("this is long press")
                            
                            // TODO: paste popup instead of copy popup
                        }
                    }
                }
            }
            startDragLocation = nil
        }
    )
}

func handleSelection(startPos: NSPoint, endPos: NSPoint) {
    let pasteboard: NSPasteboard = NSPasteboard.general
    let prevPasteboard: String = pasteboard.string(forType: .string) ?? ""
    print("prev: \(prevPasteboard)")
    
    
    
    
//    let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()
//
//    let focApp = getAXAttributeValue(systemWideElement, attr: "AXFocusedApplication") as! AXUIElement
//    let focMenu = getAXAttributeValue(focApp, attr: "AXMenuBar") as! AXUIElement
//
//    let editMenuBtn = getAXElemFromChildrenOfAXElemByTitle(focMenu, title: "Edit")!
//    let editMenuBtnSubmenu = getAXAttributeValue(editMenuBtn, attr: "AXChildren") as! NSArray
//
//    let copyBtn = getAXElemFromChildrenOfAXElemByTitle(
//        editMenuBtnSubmenu[0] as! AXUIElement,
//        title: "Copy")!
//    let copyBtnSubmenu = getAXAttributeValue(copyBtn, attr: "AXChildren") as! NSArray
//
//    if copyBtnSubmenu.count == 0 {
//        print("no nested copy button")
//
//        clickAXElemBtn(copyBtn)
//    } else {
//        print("yes nested copy button")
//        let copyBtnChildCopyBtn = getAXElemFromChildrenOfAXElemByTitle(
//            copyBtnSubmenu[0] as! AXUIElement,
//            title: "Copy")!
//
//        clickAXElemBtn(copyBtnChildCopyBtn)
//    }
    
    


    
    
    
     // must delay key press to allow selection event to occur prior to the copy.
     // usleep freezes event loop so cant use. must use DispatchQueue instead
     // 0.10s delay for selection event:
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
        
        
        
        
        
        
        // removed getting selection via accessibility focus element bc applescript is superior as you can easily check if copy is available before pressing
        let result: String = getSelectionViaAppleScript()
        
        // still need ctrl-c as backup for janky apps like anki
        
        if result == "copy-success" {
            data.selectionAquisitionMethod = "applescript"
            data.selectionType = "all"
            // TODO: other is data.selectionType = "paste" for mouse hold in same spot
            data.currentSelection = pasteboard.string(forType: .string) ?? ""
            print("got via applescript")
            print("copied: \(data.currentSelection)")

            // seems i don't need a delay between the applescript copy and reseting pasteboard
            
            // reset clipboard
            pasteboard.clearContents()
            pasteboard.setString(prevPasteboard, forType: .string)
            
            openPopWindow(startPos: startPos, endPos: endPos)
            
        } else if result == "copy-failed" { // i.e. the app didnt have a copy button, so have to use cmd-c
            // tap cmd-c
            tapCmdAndKey("c")
            
            // 0.05s delay for wait for copy event:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                let selection = pasteboard.string(forType: .string) ?? ""
                // reset clipboard
                pasteboard.clearContents()
                pasteboard.setString(prevPasteboard, forType: .string)
                
                if selection != "" {
                    print("got via ctrl-c")
                    print(selection)
                    data.selectionAquisitionMethod = "ctrl-c"
                    data.selectionType = "all"
                    data.currentSelection = selection
                    openPopWindow(startPos: startPos, endPos: endPos)
                } else {
                    print("no selection")
//                    data.selectionType = "paste"
                    data.currentSelection = ""
                }
            }
        } else { // "copy-disabled", so not able to copy
            return
        }
        
    }
}

func getSelectionViaAppleScript() -> String {

    // TODO: test me (tested ctr-c/v but not applescript)
    
    // TODO: replace "set activeApp to..." with:
    //   data.prevFocusedApp.bundleIdentifier
    //   or
    //   data.prevFocusedApp.processIdentifier
    //
    // do same for the setSelection function

    var error: NSDictionary?
    let output: NSAppleEventDescriptor = copyScriptObject.executeAndReturnError(&error)
    let outputStr: String = output.stringValue ?? ""
    // when error does not equal nil, there is an error
    print("error: \(error != nil)")
    // pretty sure error is impossible bc i used a try-catch statement
    
    return outputStr
}
func setSelectionViaAppleScript(str: String) {
    
    // FIXME: might be able to get applescript injections here ..
    
    // TODO: test me
    
    let script: String = """
        tell application "System Events"
            set activeApp to name of first application process whose frontmost is true
        end tell

        tell application activeApp
            set replacementText to \(str)
            set contents of selection to replacementText
        end tell
        """
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: script) {
        scriptObject.executeAndReturnError(&error)
    }
}
func pressKeyAndCmd(_ key_num: CGKeyCode) -> Void {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: key_num, keyDown: true)!
    event.flags = CGEventFlags.maskCommand
    event.post(tap: CGEventTapLocation.cgSessionEventTap)
}
func releaseKeyAndCmd(_ key_num: CGKeyCode) -> Void {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: key_num, keyDown: false)!
    event.flags = CGEventFlags.maskCommand
    event.post(tap: CGEventTapLocation.cgSessionEventTap)
}
func tapCmdAndKey(_ key: String) -> Void {
    var keyCode: CGKeyCode
    switch key {
    case "c":
        keyCode = 8
    case "v":
        keyCode = 9
    default:
        return
    }
    pressKeyAndCmd(keyCode)
    releaseKeyAndCmd(keyCode)
}
func cmdV(str: String) {

    let pasteboard = NSPasteboard.general
    let prevPasteboard = pasteboard.string(forType: .string) ?? ""
    
    // set text to clipboard
    pasteboard.clearContents()
    pasteboard.setString(str, forType: .string)
    
    // dont need delay for past bc window gets back in focus fast enough:
//    print(NSWorkspace.shared.frontmostApplication!.bundleIdentifier)
    
    // paste text
    tapCmdAndKey("v")
    
    // 0.1s delay for paste event to finish (mainly so long for laggy electron apps, which is the primary use case for the this copy/paste part, as accessibility doesnt work on web-apps):
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        // reset clipboard
        pasteboard.setString(prevPasteboard, forType: .string)
    }
}

func openPopWindow(startPos: NSPoint, endPos: NSPoint) {
    
    
    
    let screen = NSScreen.main!
    let rect = screen.frame
    let screenHeight = rect.size.height
    let screenWidth = rect.size.width
    
    let popupWindow: NSWindow? = NSApp.windows[1]
    if let window: NSWindow = popupWindow {
        let rect = window.frame
        let windowHeight = rect.size.height
        let windowWidth = rect.size.width
        
        var xPos = endPos.x - (windowWidth / 2)
        var yPos = endPos.y + (windowHeight * 1.5)
        
        // fix window getting cut off if on edge of screen
        
        if xPos + windowWidth > screenWidth {
            xPos = screenWidth - windowWidth
        } else if xPos < 0 {
            xPos = 0
        }

        if yPos + windowHeight > screenHeight {
            yPos = screenHeight
        } else if yPos < windowHeight {
            yPos = windowHeight
        }
        
        // position window
        window.setFrameTopLeftPoint(NSPoint(x: xPos, y: yPos))
        // show window / send window to front
        window.orderFrontRegardless()
    }
}

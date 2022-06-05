//
//  handleSelection.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

// keep JXA in memory to speed it up
let copyScriptObject: NSAppleScript = NSAppleScript(
    contentsOf: Bundle.main.url(forResource: "jxa-copy-event", withExtension: "scpt")!,
    error: nil)!


func handleSelection(startPos: NSPoint, endPos: NSPoint) {
    let pasteboard: NSPasteboard = NSPasteboard.general
    let prevPasteboard: String = pasteboard.string(forType: .string) ?? ""
    print("prev: \(prevPasteboard)")

     // must delay key press to allow selection event to occur prior to the copy.
     // usleep freezes event loop so cant use. must use DispatchQueue instead
     // 0.10s delay for selection event:
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
        
        let result: String = copyViaAX()
        // applescript can do the same thing but much slower so no point using it
        
        // still need ctrl-c as backup for janky apps like anki with no edit menu
        
        if result == "copy-success" {
            data.selectionAquisitionMethod = "accessibility"
            data.selectionType = "all"
            // TODO: other is data.selectionType = "paste" for mouse hold in same spot
            
            // 0.01s delay to wait for copy event:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                data.currentSelection = pasteboard.string(forType: .string) ?? ""
                print("got via AX")
                print("copied: \(data.currentSelection)")

                // seems i don't need a delay between getting clipobard and reseting it
                
                // reset clipboard
                pasteboard.clearContents()
                pasteboard.setString(prevPasteboard, forType: .string)
                
                openPopWindow(startPos: startPos, endPos: endPos)
            }
        } else if result == "copy-failed" { // i.e. app has no copy button, so have to use cmd-c
            // tap cmd-c
            tapCmdAndKey("c")
            
            // 0.05s delay to wait for copy event:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                let selection = pasteboard.string(forType: .string) ?? ""
                // reset clipboard
                pasteboard.clearContents()
                pasteboard.setString(prevPasteboard, forType: .string)
                
                if selection != "" {
                    print("got via cmd-c")
                    print(selection)
                    data.selectionAquisitionMethod = "cmd-c"
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

func getEditSubmenuViaAX() -> AXUIElement {
    
    // FIXME: handle cases where edit submenu not present
    
    let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()
    let focApp = getAXAttributeValue(systemWideElement, attr: "AXFocusedApplication") as! AXUIElement
    let focMenu = getAXAttributeValue(focApp, attr: "AXMenuBar") as! AXUIElement
    let editMenuBtn = getAXElemFromChildrenOfAXElemByTitle(focMenu, title: "Edit")!
    let editMenuBtnChildrenArr = getAXAttributeValue(editMenuBtn, attr: "AXChildren") as! NSArray
    // only one item in the array
    let editSubmenu = editMenuBtnChildrenArr[0] as! AXUIElement
    
    return editSubmenu
}

func copyViaAX() -> String {
    
    // FIXME: handle cases where edit submenu not present
    
    let editSubmenu: AXUIElement = getEditSubmenuViaAX()
    let copyBtn = getAXElemFromChildrenOfAXElemByTitle(editSubmenu, title: "Copy")!
    let copyBtnEnabled = getAXAttributeValue(copyBtn, attr: "AXEnabled") as! Bool
    
    if copyBtnEnabled {
        let copyBtnChildrenArr = getAXAttributeValue(copyBtn, attr: "AXChildren") as! NSArray

        if copyBtnChildrenArr.count == 0 {
//            print("no nested copy button")
            clickAXElemBtn(copyBtn)
            return "copy-success"
        } else {
//            print("yes nested copy button")
            let copyBtnSubmenu = copyBtnChildrenArr[0] as! AXUIElement
            let realCopyBtn = getAXElemFromChildrenOfAXElemByTitle(
                copyBtnSubmenu,
                title: "Copy")!
            let realCopyBtnEnabled = getAXAttributeValue(realCopyBtn, attr: "AXEnabled") as! Bool
            
            if realCopyBtnEnabled {
                clickAXElemBtn(realCopyBtn)
                return "copy-success"
            } else {
                return "copy-disabled"
            }
        }
    } else {
        return "copy-disabled"
    }
}

func pasteViaAX() -> String {
    
    // FIXME: handle cases where edit submenu not present
    
    let editSubmenu: AXUIElement = getEditSubmenuViaAX()
    let copyBtn = getAXElemFromChildrenOfAXElemByTitle(editSubmenu, title: "Copy")!
    let copyBtnEnabled = getAXAttributeValue(copyBtn, attr: "AXEnabled") as! Bool
    
    if copyBtnEnabled {
        let copyBtnChildrenArr = getAXAttributeValue(copyBtn, attr: "AXChildren") as! NSArray

        if copyBtnChildrenArr.count == 0 {
//            print("no nested copy button")
            clickAXElemBtn(copyBtn)
            return "copy-success"
        } else {
//            print("yes nested copy button")
            let copyBtnSubmenu = copyBtnChildrenArr[0] as! AXUIElement
            let realCopyBtn = getAXElemFromChildrenOfAXElemByTitle(
                copyBtnSubmenu,
                title: "Copy")!
            let realCopyBtnEnabled = getAXAttributeValue(realCopyBtn, attr: "AXEnabled") as! Bool
            
            if realCopyBtnEnabled {
                clickAXElemBtn(realCopyBtn)
                return "copy-success"
            } else {
                return "copy-disabled"
            }
        }
    } else {
        return "copy-disabled"
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

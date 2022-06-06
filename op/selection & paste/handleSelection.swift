//
//  handleSelection.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

enum AXCopyResult {
    case copySuccess
    case copyDisabled
    case copyFailed
}

// TODO: have a whitelist/blacklist for apps so e.g. if you don't want it on in photoshop it doesnt need to be
// TODO: that gives me an idea. what if it could edit files in the pasteboard, so e.g. you copy an image and paste as black and white, and of course it only appear when an image is in clipboard

func handleSelection(_ viewController: PopupViewController) {
    let pasteboard: NSPasteboard = NSPasteboard.general
    let prevPasteboard: String = pasteboard.string(forType: .string) ?? ""
    print("prev: \(prevPasteboard)")

    data.popupType = .copyOrCopyPaste
    
    
     // must delay key press to allow selection event to occur prior to the copy.
     // usleep freezes event loop so cant use. must use DispatchQueue instead
     // 0.10s delay for selection event:
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
        
        
        // --------------HANDLE SPECIAL CASES---------------
        
        if let bundleID = data.prevFocusedApp.bundleIdentifier {
            print(bundleID)
            if bundleID == "com.apple.finder" {
                if let focusedElem = getFocusedElem() {
                    if let focusedElemIdentifierRef = getAXAttributeValue(
                        focusedElem, attr: "AXIdentifier") {
                        
                        let focusedElemIdentifier = focusedElemIdentifierRef as! String
                        print(focusedElemIdentifier)
                        
                        var continueWithSelection: Bool!
                        
                        switch focusedElemIdentifier {
                        // IF ANY OF THESE, IT IS SAFE TO COPY, IF NOT RETURN
                            // if its the search bar
                        case "_NS:123",
                            // if its a folder renaming text-box
                            "ShrinkToFit Text Field",
                            // if its a the "Help" search bar
                            "_SC_SEARCH_FIELD",
                            // go -> go to folder
                            "PathTextField",
                            // go -> connect to server
                            "_NS:154":
                            
                            continueWithSelection = true
                        default:
                            continueWithSelection = false
                        }
                        if continueWithSelection == false {
                            return
                        }
                    }
                }
            }
        }
        
        

        let result: AXCopyResult = copyViaAX()
        // applescript can do the same thing but much slower so no point using it
        
        print(result)
        
        // still need ctrl-c as backup for janky apps like anki with no edit menu
        
        if result == .copySuccess {
            data.selectionMethod = .accessibility
            
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
                
                showPopupWindow(viewController)
            }
        } else if result == .copyFailed { // i.e. app has no copy button, so have to use cmd-c
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
                    data.selectionMethod = .keyPress
                    data.currentSelection = selection
                    showPopupWindow(viewController)
                }
            }
        } else { // .copyDisabled , so not able to copy
            return
        }
    }
}

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

func handleSelection(startPos: NSPoint, endPos: NSPoint) {
    let pasteboard: NSPasteboard = NSPasteboard.general
    let prevPasteboard: String = pasteboard.string(forType: .string) ?? ""
    print("prev: \(prevPasteboard)")

    data.popupType = .copyOrCopyPaste
    
     // must delay key press to allow selection event to occur prior to the copy.
     // usleep freezes event loop so cant use. must use DispatchQueue instead
     // 0.10s delay for selection event:
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
        
        let result: AXCopyResult = copyViaAX()
        // applescript can do the same thing but much slower so no point using it
        
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
                
                openPopWindow(startPos: startPos, endPos: endPos)
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
                    openPopWindow(startPos: startPos, endPos: endPos)
                }
            }
        } else { // .copyDisabled , so not able to copy
            return
        }
    }
}

//
//  handlePaste.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

func pasteString(_ str: String) {
    let pasteboard = NSPasteboard.general
    let prevPasteboard = pasteboard.string(forType: .string) ?? ""
    
    // set text to clipboard
    pasteboard.clearContents()
    pasteboard.setString(str, forType: .string)
    
    let selType = data.selectionMethod
    // paste text
    switch selType {
    case .accessibility:
        // TODO: remove this delay when fixed window unfocusing from pressing popup btn
        // 0.01s delay for window to re-focus:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            pasteViaAX()
            // 0.01s delay for paste event to finish:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                // reset clipboard
                pasteboard.setString(prevPasteboard, forType: .string)
            }
        }
    case .keyPress:
        // dont need delay for paste bc window gets back in focus fast enough:
    //    print(NSWorkspace.shared.frontmostApplication!.bundleIdentifier)
        tapCmdAndKey("v")
        // 0.1s delay for paste event to finish (mainly so long for laggy electron apps, which is the primary use case for the this copy/paste part, as accessibility doesnt work on web-apps):
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // reset clipboard
            pasteboard.setString(prevPasteboard, forType: .string)
        }
    }
}

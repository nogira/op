//
//  addEventListeners.swift
//  op
//
//  Created by nogira on 2/6/2022.
//

import AppKit
import Cocoa

// TODO: remove popup on keypress
// also when mouse moves too far away

// TODO: remove popup after 2 sec when move a certain distance away from the menu bar (prob use y distance since could have v long popup where have to move to side alot to get button)

// TODO: modify applescript to detect if copy/paste button is available to be pressed or greyed out
// perhaps even dump accessibility in favor of this (?)

func addEventListeners() {
    // detect if window moved instead of text selected
    var startFocusedWindowFrame: CGRect!
    
    // detect long press in same spot
    var timeOfMouseDown: CGFloat!
    
    NSEvent.addGlobalMonitorForEvents(
        matching: .leftMouseDown,
        handler: {
            (event : NSEvent) -> Void in
            
            print("mousedown")
            
            // MARK: - hide popup
            
            // hide popup on click. if this is a new selection event, it will reappear
            hidePopupWindow()
            
            // MARK: - handle selection
            
            // add currently focused app  so can refocus after loses focus from clicking popup window
            data.prevFocusedApp = NSWorkspace.shared.frontmostApplication!
            
            if let frame = getCurrentWindowFrame() {
                startFocusedWindowFrame = frame
            }
            timeOfMouseDown = event.timestamp
            data.mouseDownPosition = event.locationInWindow
            
            if event.clickCount == 2 || event.clickCount == 3 {
                // since this is a mouse down event and window position relies on mouse up position, and mouse up position on double click is expected to be same position, we let mouse up position equal mouse down position
                data.mouseUpPosition = event.locationInWindow
                handleSelection()
            }
        }
    )
    NSEvent.addGlobalMonitorForEvents(
        matching: .leftMouseUp,
        handler: {
            (event : NSEvent) -> Void in
            
            // confirm this is an actual drag event adn not a random key up with no prior key down
            if data.mouseDownPosition != nil {
                
                // this `if-let-else` for endFocusedWindowFrame is need in case accessibilty privileges are not yet on
                let endFocusedWindowFrame: CGRect
                if let frame = getCurrentWindowFrame() {
                    endFocusedWindowFrame = frame
                } else {
                    return
                }
                // if window hasn't moved or resized, event may be a text selection, so proceed with event handling
                if startFocusedWindowFrame == endFocusedWindowFrame {
                    
                    data.mouseUpPosition = event.locationInWindow
                    let (x0, y0) = (data.mouseDownPosition.x, data.mouseDownPosition.y)
                    let (x1, y1) = (data.mouseUpPosition.x, data.mouseUpPosition.y)
                    let xDiff = abs(x0 - x1)
                    let yDiff = abs(y0 - y1)
                    
                    if xDiff > 5 || yDiff > 5 {
                        handleSelection()
                    } else {
                        // --handle long press in same spot--
                        
                        let timeOfMouseUp = event.timestamp
                        let timeDiff = timeOfMouseUp - timeOfMouseDown
                        if timeDiff > 0.40 {
                            // FIXME: it is possible to select text then hold down button with selection remaining, so the paste will paste over the selection
                            // bug or feature ???
                            
                            data.popupType = .paste
                            showPopupWindow()
                        }
                    }
                }
            }
            data.mouseDownPosition = nil
        }
    )
    
    // FIXME: not executing on keydow for some reason !!!
    
    NSEvent.addGlobalMonitorForEvents(
        matching: .keyDown,
        handler: {
            (event : NSEvent) -> Void in
            
            // MARK: - hide popup
            
            print("keydown")
    
            // hide popup on key press
            hidePopupWindow()
        }
    )
}

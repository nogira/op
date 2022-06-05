//
//  addEventListeners.swift
//  op
//
//  Created by nogira on 2/6/2022.
//

import AppKit

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
            let popupWindow: NSWindow? = NSApp.windows[1]
            if let window: NSWindow = popupWindow {
                window.orderOut(nil)
            }
            
            startDragLocation = event.locationInWindow
            
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
                            // FIXME: it is possible to select text then hold down button with selection remaining, so the paste will paste over the selection
                            // bug or feature ???
                            
                            // TODO: paste popup instead of copy popup
                            
                            data.popupType = .paste
                            openPopWindow(startPos: startDragLocation, endPos: currentLocation)
                            
                        }
                    }
                }
            }
            startDragLocation = nil
        }
    )
}

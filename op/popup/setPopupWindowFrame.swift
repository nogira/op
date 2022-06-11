//
//  setPopupWindowFrame.swift
//  op
//
//  Created by nogira on 6/6/2022.
//

import AppKit

func setPopupWindowFrame(_ view: NSView, _ padding: CGFloat) -> Void {
    let (windowWidth, windowHeight) = calculateWindowSize(view, padding)
    let (xPos, yPos) = calculateWindowPosition(windowWidth, windowHeight)
    let newWindowFrame = NSRect(x: xPos, y: yPos, width: windowWidth, height: windowHeight)
    view.window!.setFrame(newWindowFrame, display: true)
    // need to get root view size too so subviews don't get cut off
    view.setFrameSize(NSSize(width: windowWidth, height: windowHeight))
}

func calculateWindowSize(_ view: NSView, _ padding: CGFloat) -> (CGFloat, CGFloat) {
    var windowWidth: CGFloat = 0
    var windowHeight: CGFloat = 0
    
    // add left padding
    windowWidth += padding
    // add bottom padding
    windowHeight += padding

    let subviews = view.subviews
    for subview in subviews {
        windowWidth += subview.frame.width
        // add right padding
        windowWidth += padding
    }
    windowHeight += subviews[0].frame.height
    // add top padding
     windowHeight += padding
    
    return (windowWidth, windowHeight)
}

func calculateWindowPosition(_ windowWidth: CGFloat, _ windowHeight: CGFloat
    ) -> (CGFloat, CGFloat) {
//            let startPos: NSPoint = data.mouseDownPosition
    let endPos: NSPoint = data.mouseUpPosition
    
    let screen = NSScreen.main!
    let rect = screen.frame
    let screenHeight = rect.size.height
    let screenWidth = rect.size.width
    
    var xPos = endPos.x - (windowWidth / 2)
    var yPos = endPos.y + (windowHeight * 0.5)
    
    // fix window getting cut off if on edge of screen
    
    if xPos + windowWidth > screenWidth {
        xPos = screenWidth - windowWidth
    } else if xPos < 0 {
        xPos = 0
    }

    if yPos + windowHeight > screenHeight {
        yPos = screenHeight - windowHeight
    } else if yPos < windowHeight {
        yPos = 0
    }
    
    return (xPos, yPos)
}

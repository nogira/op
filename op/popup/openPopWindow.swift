//
//  openPopWindow.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

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

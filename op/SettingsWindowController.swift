//
//  WindowController.swift
//  op
//
//  Created by nogira on 30/5/2022.
//

import Cocoa

class SettingsWindowController: NSWindowController {

//    convenience init() {
//        self.init(windowNibName: "Main")
//    }
    
    override func windowWillLoad() {
        super.windowWillLoad()
        
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
//        contentViewController = ViewController()
        
        // can't place in windowWillLoad - must rely on window being loaded
        if let window = window, let screen = window.screen {
            // no titlebar, just the top left buttons
            window.styleMask.insert(NSWindow.StyleMask.unifiedTitleAndToolbar)
            window.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
            window.styleMask.insert(NSWindow.StyleMask.titled)
            window.toolbar?.isVisible = false
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            
            window.hasShadow = false
            print(window.isVisible)
            print(window.contentView!)
            
            let offsetFromLeftOfScreen: CGFloat = 5000
            let offsetFromTopOfScreen: CGFloat = 100
            let screenRect = screen.visibleFrame
            let newOriginY = screenRect.maxY - window.frame.height - offsetFromTopOfScreen
            window.setFrameOrigin(NSPoint(x: offsetFromLeftOfScreen, y: newOriginY))
        }
    }
}

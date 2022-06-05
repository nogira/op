//
//  PopupWindowController.swift
//  op
//
//  Created by nogira on 30/5/2022.
//

import Cocoa

class PopupWindowController: NSWindowController {

    convenience init() {
        self.init(windowNibName: "PopupWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        contentViewController = PopupViewController()
    }
}

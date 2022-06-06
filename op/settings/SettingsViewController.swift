//
//  ViewController.swift
//  op
//
//  Created by nogira on 30/5/2022.
//

import Cocoa

// TODO: use SwiftUI List() view for this. have a demo as diff xcode project

class SettingsViewController: NSViewController {

    override func loadView() {
        let view = NSView(frame: NSMakeRect(0,0,100,100))
        view.wantsLayer = true
        view.layer?.borderWidth = 2
        view.layer?.borderColor = NSColor.red.cgColor
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
//    override func viewWillAppear() {
//        super.viewWillAppear()
//        // configure your window properties here
//        
//        
//        
//
//    }
}


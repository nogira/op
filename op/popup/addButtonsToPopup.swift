//
//  addButtonsToPopup.swift
//  op
//
//  Created by nogira on 8/6/2022.
//

import AppKit

func addButtonsToPopup(_ viewController: PopupViewController, _ appDelegate: AppDelegate) {
    let actions: [ActionConfig] = delegate.actions
    let actionsEnabled = delegate.defaults.object(forKey: "actionsEnabled") as! [String : Bool]
    var buttons = viewController.buttons
    let view = viewController.view
    
    // ---ADD BUTTONS TO VIEW---
    

    // set background of main view, and round it's corners
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.white.cgColor
    view.layer?.cornerRadius = 5
    

    // reset buttons:
    // 1. in var store
    buttons?.removeAll()
    // 2. in subviews
    view.subviews = []
    
    var i = 0
    let isPastePopup = data.popupType == .pasteboard
    let isNotPastePopup = !isPastePopup
    for item in actions {
        let name = item.actionName
        let popupType = item.inputType
        // add if enabled
        if actionsEnabled[name] == true {
            // 1. if this is not a paste popup, free to add every button
            if isNotPastePopup ||
                // 2. if this is a paste popup, and the button is a paste button, add button, otherwise don't add button
                isPastePopup && popupType == .pasteboard {
                
                let btn: CustomNSButton!
                // if action has an icon, use it
                if item.iconFile != "" {
                    let iconURL: URL = pluginsFolder()
                        .appendingPathComponent(item.actionName)
                        .appendingPathComponent(item.iconFile)
                    let icon = resizeImage(image: NSImage(byReferencing: iconURL), w: 15, h: 15)
                    btn = CustomNSButton(image: icon, target: viewController, action: #selector(PopupViewController.handleButton(_:)))
                    
                    // TODO: find a new way to pass message from button to action. ORRR just declare a var in viewcontroller instead of explicitly passing
                    

    //                    buttons[i].setFrameSize(NSSize(width: 15, height: 15))
                } else {
                    btn = CustomNSButton(title: name, target: viewController, action: #selector(PopupViewController.handleButton(_:)))
                }
                // this is the id for #selector function to know which button was pressed
                btn.name = name
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.bezelStyle  = NSButton.BezelStyle.roundRect
                btn.isBordered = false
                btn.contentTintColor = NSColor.black
                
                buttons!.append(btn)
                
                view.addSubview(btn)
                i += 1
            }
        }
    }
}

class CustomNSButton: NSButton {
    var name: String?
}

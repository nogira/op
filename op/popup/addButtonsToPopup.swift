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
    
    let darkMode: Bool = delegate.defaults.bool(forKey: "dark mode")
    let backgroundColor = darkMode ? NSColor.black.cgColor : NSColor.white.cgColor
    let buttonColor = darkMode ? NSColor.white : NSColor.black
    
    // set background of main view, and round it's corners
    view.wantsLayer = true
    view.layer?.backgroundColor = backgroundColor
    view.layer?.cornerRadius = 5
    
    // ---ADD BUTTONS TO VIEW---
    
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
            // MARK: - decide whether to add action to popup
            // 1. if this is not a paste popup, free to add every button
            if isNotPastePopup ||
                // 2. if this is a paste popup, and the button is a paste button, add button, otherwise don't add button
                isPastePopup && popupType == .pasteboard {
                
                let btn: CustomNSButton!
                // MARK: - add icon button
                // if action has an icon, use it
                if let iconFile: String = item.iconFile {
                    let iconURL: URL = pluginsFolder()
                        .appendingPathComponent(item.actionName)
                        .appendingPathComponent(iconFile)
                    let icon = resizeImage(image: NSImage(byReferencing: iconURL), w: 15, h: 15)
                    // allow image to be recolored to white in dark mode
                    icon.isTemplate = true
                    btn = CustomImageNSButton(image: icon, target: viewController, action: #selector(PopupViewController.handleButton(_:)))
                // MARK: - add text button
                } else if let iconName = item.iconSFSymbol {
                    let icon = resizeImage(image: NSImage(systemSymbolName: iconName, accessibilityDescription: "")!, w: 15, h: 15)
                    // allow image to be recolored to white in dark mode
                    icon.isTemplate = true
                    btn = CustomImageNSButton(image: icon, target: viewController, action: #selector(PopupViewController.handleButton(_:)))
                } else {
                    btn = CustomNSButton(title: name, target: viewController, action: #selector(PopupViewController.handleButton(_:)))
                }
                // this is the id for #selector function to know which button was pressed
                btn.name = name
                
                // prevent autolayout from changing the size of the frame
                // THIS MUST BE SET BEFORE MANUALLY SETTING THE FRAME (nvm didnt work)
                btn.translatesAutoresizingMaskIntoConstraints = false

                // button styling
                btn.bezelStyle  = NSButton.BezelStyle.roundRect
                btn.isBordered = false
                btn.contentTintColor = buttonColor
                
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

class CustomImageNSButton: CustomNSButton {
    override var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        size.width += 7 // left and right padding to match padding of text
        size.height += 1 // match the 16 px height of text buttons
        return size;
    }
}


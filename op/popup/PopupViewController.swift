//
//  PopupViewController.swift
//  op
//
//  Created by nogira on 30/5/2022.
//

/*

JSON:
{
"appear on": "paste",  // options: "copy", "paste", "all"
"regex": "https://google.com",
"regex flags": "gi",
"env": "/bin/bash"
"script file": "./main.js"
}
 
 // ability to edit some of these (e.g. regex, check box for eahch of on-paste and on-copy) from settings

*/

import Cocoa



class PopupViewController: NSViewController {
    
    let padding: CGFloat = 2
    
    var buttons: [NSButton]! = []
    
    // the work item to hide popup window (gets called after 3 sec of window being visible)
    var workItem: DispatchWorkItem?
    
    
    override func loadView() {
        let view = NSView(frame: NSMakeRect(0,0,200,100))
//        view.wantsLayer = true
//        view.layer?.borderWidth = 2
//        view.layer?.borderColor = NSColor.red.cgColor
        self.view = view
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here. (this is only called once; on app start)
        
        
        
        addEventListeners(self)
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
//        addButtonsToPopup()
        
        
        // ---default buttons---
        
        // TODO: to retain order, must use dict in array instead of dict. seems dict give completely random order
        
        // reset buttons:
        // 1. in var store
        buttons = []
        // 2. in subviews
        view.subviews = []
        
        let defaultButtons: [(String, PopupType)] = [
            ("ab", .copyOrCopyPaste),
            ("AB", .copyOrCopyPaste),
            ("cut", .copyOrCopyPaste),
            ("copy", .copyOrCopyPaste),
            ("paste =", .paste),
        ]
        
        var i = 0
        let isPastePopup = data.popupType == .paste
        let isNotPastePopup = !isPastePopup
        for item in defaultButtons {
            let (title, popupType) = item
            // 1. if this is not a paste popup, free to add every button
            if isNotPastePopup ||
                // 2. if this is a paste popup, and the button is a paste button, add button, otherwise don't add button
                isPastePopup && popupType == .paste {
                
                buttons.append(NSButton(title: title, target: self, action: #selector(handleButton(_:))))
                buttons[i].translatesAutoresizingMaskIntoConstraints = false
                buttons[i].bezelStyle = NSButton.BezelStyle.smallSquare
                view.addSubview(buttons[i])
                i += 1
            }
        }
        constraintsInit()
    }
    
    override func viewDidAppear() {
        
        // CAN'T GET DIMENSIONS OF BUTTONS UNTIL LAYOUT IS COMPUTED, SO WE CALCULATE WINDOW DIMENSIONS HERE
        setPopupWindowFrame(view, padding)

        
        // remove window after 5 seconds. this is cancelable (the cancellation will get called when hidePopupWindow is called)
        workItem = DispatchWorkItem { self.hide() }
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
        }
    }
    
    func show() {
        showPopupWindow(self)
    }
    
    func hide() {
        hidePopupWindow(self)
    }
    
    func constraintsInit() {
        
        var constraintsArr: [NSLayoutConstraint] = []
        
        // initial anchor subview
        constraintsArr.append(contentsOf: [
            view.subviews[0].leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: padding),
            view.subviews[0].bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -padding),
        ])
        // the rest of the subbiews (if present)
        let numSubviews = view.subviews.count
        if numSubviews > 1 {
            let i = 1
            for idx in i...(numSubviews - 1) {
                constraintsArr.append(contentsOf: [
                    view.subviews[idx].leadingAnchor.constraint(
                        equalTo: view.subviews[idx - 1].trailingAnchor, constant: padding),
                    view.subviews[idx].bottomAnchor.constraint(
                        equalTo: view.bottomAnchor, constant: -padding),
                ])
            }
        }
        
        NSLayoutConstraint.activate(constraintsArr)
    }
    
    @objc func handleButton(_ sender: NSButton) {
        print(sender.title)
        
        // refocus previously focused app
        // TODO: this solution is a bit janky bc it visually gets unfocused then re-focused, so better solution would be to prevent unfocus in the forst place
        data.prevFocusedApp.activate()
        
        // even though i have an mouse-down event listener event that should close the popup window, it doesnt seem to close if the mouse-down is on the window itself, so must also close window from here:
        let popupWindow: NSWindow? = view.window
        if let window = popupWindow {
            window.orderOut(self)
        }
        
        // perform action on text
        switch sender.title {
        case "ab":
            let newText = data.currentSelection.lowercased()
            pasteString(newText)
        case "AB":
            let newText = data.currentSelection.uppercased()
            pasteString(newText)
        case "cut":
            tapCmdAndKey("x")
        case "copy":
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(data.currentSelection, forType: .string)
        case "paste =":
            let newText: String = NSPasteboard.general.string(forType: .string) ?? ""
            pasteString(newText)
        default:
            print("title unrecognized")
        }
  
        // reset current selection
        data.currentSelection = ""
        
        // FIXME: if user doesnt click button nothing gets reset.. but maybe thats fine bc a new event will just overwrite anyways ?
    }
}

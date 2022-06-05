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
//import AppleScriptObjC

class PopupViewController: NSViewController {
    
    let padding: CGFloat = 2
    
    var buttons: [NSButton]! = []
    
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
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
//        addButtonsToPopup()
        
        
        // ---default buttons---
        
        // TODO: to retain order, must use dict in array instead of dict
        
        // reset buttons:
        // 1. in var store
        buttons = []
        // 2. in subviews
        view.subviews = []
        
        let defaultButtons: [String: PopupType] = [
            "ab": .copyOrCopyPaste,
            "AB": .copyOrCopyPaste,
            "paste =": .paste,
        ]
        
        print(data.popupType)
        
        var i = 0
        let isNotPastePopup = data.popupType == .copyOrCopyPaste
        let isPastePopup = !isNotPastePopup
        for (title, popupType) in defaultButtons {
            // if this is a paste popup, and the button is a paste button, add button, otherwise don't add button
            if isNotPastePopup || isPastePopup && popupType == .paste {
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
        
        
        // can't get dimensions of buttons only layout is computed, so we calculate window dimensions here
        
        
        // --calculate window height and width--
        
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
        // add top padding (not needed for some reason ???)
        // windowHeight += padding

        let prevFrame: NSRect = view.window!.frame
        let newWindowSize: NSRect = NSRect(x: prevFrame.minX, y: prevFrame.minY, width: windowWidth, height: windowHeight)

        view.window?.setFrame(newWindowSize, display: true)

        // FIXME: when window first appears, it's centering relative to the cursor is off bc this function hasn't loaded yet to update the window size to be able to center based on window size
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
                print(idx)
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
        let popupWindow: NSWindow? = NSApp.windows[1]
        if let window = popupWindow {
            window.orderOut(self)
        }
        
        let fn = sender.title
        
        // perform action on text
        if  fn == "ab" {
            let newText = data.currentSelection.lowercased()
            pasteString(newText)
        } else if fn == "AB" {
            let newText = data.currentSelection.uppercased()
            pasteString(newText)
        } else if fn == "paste =" {
            let newText: String = NSPasteboard.general.string(forType: .string) ?? ""
            pasteString(newText)
        }
        // reset current selection
        data.currentSelection = ""
        
        // FIXME: if user doesnt click button nothing gets reset.. but maybe thats fine bc a new event will just overwrite anyways ?
    }
}



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

var workItem = DispatchWorkItem { hidePopupWindow() }

class PopupViewController: NSViewController {
    
    let padding: CGFloat = 2
    
    var buttons: [NSButton]! = []
    
    // the work item to hide popup window (gets called after 3 sec of window being visible)
    
    
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
        
        addEventListeners()
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
        
        let defaultButtons: [String: PopupType] = [
            "ab": .copyOrCopyPaste,
            "AB": .copyOrCopyPaste,
            "paste =": .paste,
        ]
        
        var i = 0
        let isPastePopup = data.popupType == .paste
        let isNotPastePopup = !isPastePopup
        for (title, popupType) in defaultButtons {
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
        
        // CAN'T GET DIMENSIONS OF BUTTONS ONLY LAYOUT IS COMPUTED, SO WE CALCULATE WINDOW DIMENSIONS HERE
        
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
        
    
        let (xPos, yPos) = calculateWindowPosition(windowWidth, windowHeight)

        let newWindowFrame = NSRect(x: xPos, y: yPos, width: windowWidth, height: windowHeight)

        let window = view.window!
        window.setFrame(newWindowFrame, display: true)

        // FIXME: when window first appears, it's centering relative to the cursor is off bc this function hasn't loaded yet to update the window size to be able to center based on window size
        
        
        
        // FIXME: this workItem never gets executed
        
        print("run auto-hide")
        
        // remove window after 5 seconds. this is cancelable (the cancellation will get called when hidePopupWindow is called)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
        
        workItem.isCancelled
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

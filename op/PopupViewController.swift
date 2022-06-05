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
    
    var button1: NSButton!
    var button2: NSButton!
    var button3: NSButton!
    
    override func loadView() {
        let view = NSView(frame: NSMakeRect(0,0,200,100))
//        view.wantsLayer = true
//        view.layer?.borderWidth = 2
//        view.layer?.borderColor = NSColor.red.cgColor
        self.view = view
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        button1 = NSButton(title: "ab", target: self, action: #selector(handleButton(_:)))
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.bezelStyle = NSButton.BezelStyle.smallSquare
        view.addSubview(button1)

        button2 = NSButton(title: "AB", target: self, action: #selector(handleButton(_:)))
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.bezelStyle = NSButton.BezelStyle.smallSquare
        view.addSubview(button2)
        
//        button3 = NSButton(
//            image: NSImage(
//                systemSymbolName: "square.and.arrow.up",
//                accessibilityDescription: ""
//            )!,
//            target: self,
//            action: #selector(handleButton(_:)))
        button3 = NSButton(title: "paste =", target: self, action: #selector(handleButton(_:)))
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.bezelStyle = NSButton.BezelStyle.smallSquare
        view.addSubview(button3)
        
        constraintsInit()
        
        print("view did load")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        print("view will appear")
        
        var windowWidth: CGFloat = 0
        var windowHeight: CGFloat = 0
        
        // add left padding
        windowWidth += padding
        // add bottom padding
        windowHeight += padding
        
        let subviews = self.view.subviews
        for view in subviews {
            windowWidth += view.frame.width
            // add right padding
            windowWidth += padding
        }
        
        windowHeight += subviews[0].frame.height
        // add top padding (not needed for some reason ???)
        // windowHeight += padding
        
        let prevFrame: NSRect = self.view.window!.frame
        let newWindowSize: NSRect = NSRect(x: prevFrame.minX, y: prevFrame.minY, width: windowWidth, height: windowHeight)
        
        self.view.window?.setFrame(newWindowSize, display: true)
        
        // FIXME: when window first appears, it's centering relative to the cursor is off bc this function hasn't loaded yet to update the window size to be able to center based on window size
    }
    
    func constraintsInit() {
        NSLayoutConstraint.activate([
            button1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            button1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
            button2.leadingAnchor.constraint(equalTo: button1.trailingAnchor, constant: padding),
            button2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
            button3.leadingAnchor.constraint(equalTo: button2.trailingAnchor, constant: padding),
            button3.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
        ])
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
            modifyTextInSelection(newText)
        } else if fn == "AB" {
            let newText = data.currentSelection.uppercased()
            modifyTextInSelection(newText)
        } else if fn == "paste =" {
            let newText: String = NSPasteboard.general.string(forType: .string) ?? ""
            modifyTextInSelection(newText)
        }
        // reset current selection
        data.currentSelection = ""
        
        // FIXME: if user doesnt click button nothing gets reset.. but maybe thats fine bc a new event will just overwrite anyways ?
    }
}

func modifyTextInSelection(_ str: String) {
    let selType = data.selectionAquisitionMethod
    switch selType {
    case "applescript":
        setSelectionViaAppleScript(str: str)
    case "ctrl-c":
        cmdV(str: str)
    default:
        print("no selection aquisition method found")
    }
    // reset
    data.selectionAquisitionMethod = ""
}

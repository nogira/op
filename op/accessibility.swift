//
//  accessibility.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import Cocoa

func getAllAXAttributeNames(_ elem: AXUIElement) -> CFArray {
    var attributes: CFArray?
    AXUIElementCopyAttributeNames(elem, &attributes)
    return attributes!
}

func getAXAttributeValue(_ elem: AXUIElement, attr: String) -> CFTypeRef? {
    var val: CFTypeRef?
    AXUIElementCopyAttributeValue(elem, attr as CFString, &val)
    return val
}

func getAXElemFromChildrenOfAXElemByTitle(_ AXElem: AXUIElement, title: String) -> AXUIElement? {
    let AXElemChildren = getAXAttributeValue(AXElem, attr: "AXChildren") as! NSArray
    for elem in AXElemChildren {
        let elem = elem as! AXUIElement
        let elemTitle = getAXAttributeValue(elem, attr: "AXTitle")
        // Edit
        if elemTitle as! String == title {
            return elem
        }
    }
    return nil
}

func clickAXElemBtn(_ AXElem: AXUIElement) -> Void {
    AXUIElementPerformAction(AXElem, "AXPress" as CFString)
}

func getCurrentWindowFrame() -> CGRect? {
    let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()
    if let focusedElemRef = getAXAttributeValue( systemWideElement, attr: "AXFocusedUIElement") {
        let focusedElem = focusedElemRef as! AXUIElement
        if let focusedWindowRef = getAXAttributeValue(focusedElem, attr: "AXWindow") {
            let focusedWindow = focusedWindowRef as! AXUIElement
            let focusedFrame: CFTypeRef? = getAXAttributeValue(focusedWindow, attr: "AXFrame")
            var frameRect = CGRect()
            AXValueGetValue(focusedFrame as! AXValue, AXValueType.cgRect, &frameRect)
            return frameRect
        }
    }
    return nil
}

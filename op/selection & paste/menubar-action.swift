//
//  menubar-action.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

func getEditSubmenuViaAX() -> AXUIElement {
    
    // FIXME: handle cases where edit submenu not present
    
    let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()
    let focApp = getAXAttributeValue(systemWideElement, attr: "AXFocusedApplication") as! AXUIElement
    let focMenu = getAXAttributeValue(focApp, attr: "AXMenuBar") as! AXUIElement
    let editMenuBtn = getAXElemFromChildrenOfAXElemByTitle(focMenu, title: "Edit")!
    let editMenuBtnChildrenArr = getAXAttributeValue(editMenuBtn, attr: "AXChildren") as! NSArray
    // only one item in the array
    let editSubmenu = editMenuBtnChildrenArr[0] as! AXUIElement
    
    return editSubmenu
}

func copyViaAX() -> AXCopyResult {
    
    // FIXME: handle cases where edit submenu not present
    
    let editSubmenu: AXUIElement = getEditSubmenuViaAX()
    let copyBtn = getAXElemFromChildrenOfAXElemByTitle(editSubmenu, title: "Copy")!
    let copyBtnEnabled = getAXAttributeValue(copyBtn, attr: "AXEnabled") as! Bool
    
    if copyBtnEnabled {
        let copyBtnChildrenArr = getAXAttributeValue(copyBtn, attr: "AXChildren") as! NSArray

        if copyBtnChildrenArr.count == 0 {
//            print("no nested copy button")
            clickAXElemBtn(copyBtn)
            return .copySuccess
        } else {
//            print("yes nested copy button")
            let copyBtnSubmenu = copyBtnChildrenArr[0] as! AXUIElement
            let realCopyBtn = getAXElemFromChildrenOfAXElemByTitle(
                copyBtnSubmenu,
                title: "Copy")!
            let realCopyBtnEnabled = getAXAttributeValue(realCopyBtn, attr: "AXEnabled") as! Bool
            
            if realCopyBtnEnabled {
                clickAXElemBtn(realCopyBtn)
                return .copySuccess
            } else {
                return .copyDisabled
            }
        }
    } else {
        return .copyDisabled
    }
}

func pasteViaAX() {
    
    // FIXME: handle cases where edit submenu not present
    
    let editSubmenu: AXUIElement = getEditSubmenuViaAX()
    let copyBtn = getAXElemFromChildrenOfAXElemByTitle(editSubmenu, title: "Paste")!
    let copyBtnEnabled = getAXAttributeValue(copyBtn, attr: "AXEnabled") as! Bool
    
    if copyBtnEnabled {
        let copyBtnChildrenArr = getAXAttributeValue(copyBtn, attr: "AXChildren") as! NSArray

        if copyBtnChildrenArr.count == 0 {
//            print("no nested paste button")
            clickAXElemBtn(copyBtn)
        } else {
//            print("yes nested paste button")
            let copyBtnSubmenu = copyBtnChildrenArr[0] as! AXUIElement
            let realCopyBtn = getAXElemFromChildrenOfAXElemByTitle(
                copyBtnSubmenu,
                title: "Paste")!
            let realCopyBtnEnabled = getAXAttributeValue(realCopyBtn, attr: "AXEnabled") as! Bool
            
            if realCopyBtnEnabled {
                clickAXElemBtn(realCopyBtn)
            }
        }
    }
}

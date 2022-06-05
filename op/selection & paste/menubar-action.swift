//
//  menubar-action.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

func getEditSubmenuViaAX() -> AXUIElement? {
    let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()
    if let focusedAppRef = getAXAttributeValue(systemWideElement, attr: "AXFocusedApplication") {
        let focusedApp = focusedAppRef as! AXUIElement
        if let focusedMenuRef = getAXAttributeValue(focusedApp, attr: "AXMenuBar") {
            let focusedMenu = focusedMenuRef as! AXUIElement
            if let editMenuBtn = getAXElemFromChildrenOfAXElemByTitle(focusedMenu, title: "Edit") {
                let editMenuBtnChildrenArr = getAXAttributeValue(
                    editMenuBtn, attr: "AXChildren") as! NSArray
                // only one item in the array
                let editSubmenu = editMenuBtnChildrenArr[0] as! AXUIElement
                return editSubmenu
            }
        }
    }
    return nil
}

func copyViaAX() -> AXCopyResult {
    
    // FIXME: handle cases where edit submenu not present
    
    if let editSubmenu: AXUIElement = getEditSubmenuViaAX() {
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
    return .copyFailed
}

func pasteViaAX() {
    if let editSubmenu: AXUIElement = getEditSubmenuViaAX() {
        let copyBtn = getAXElemFromChildrenOfAXElemByTitle(editSubmenu, title: "Paste")!
        let copyBtnEnabled = getAXAttributeValue(copyBtn, attr: "AXEnabled") as! Bool
        
        if copyBtnEnabled {
            let copyBtnChildrenArr = getAXAttributeValue(copyBtn, attr: "AXChildren") as! NSArray

            if copyBtnChildrenArr.count == 0 {
                clickAXElemBtn(copyBtn)
            } else {
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
}

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
                if let editMenuBtnChildrenArrRef = getAXAttributeValue(
                    editMenuBtn, attr: "AXChildren") {
                    let editMenuBtnChildrenArr = editMenuBtnChildrenArrRef as! NSArray
                    // only one item in the array
                    let editSubmenu = editMenuBtnChildrenArr[0] as! AXUIElement
                    return editSubmenu
                }
            }
        }
    }
    return nil
}

func copyViaAX() -> AXCopyResult {
    
    // FIXME: handle cases where edit submenu not present
    
    if let editSubmenu: AXUIElement = getEditSubmenuViaAX() {
        if let copyBtn = getAXElemFromChildrenOfAXElemByTitle(editSubmenu, title: "Copy", cmdChar: "C") {
//            print("FOUND COPY BUTTON")
//            print(getAllAXAttributeNames(copyBtn))
//            print(getAXAttributeValue(copyBtn, attr: "AXMenuItemCmdChar")) // -> "C"
            let copyBtnEnabled = getAXAttributeValue(
                copyBtn, attr: "AXEnabled") as! Bool
            if copyBtnEnabled {
                let copyBtnChildrenArr = getAXAttributeValue(
                    copyBtn, attr: "AXChildren") as! NSArray
                if copyBtnChildrenArr.count == 0 {
                    clickAXElemBtn(copyBtn)
                    return .copySuccess
                } else {
                    let copyBtnSubmenu = copyBtnChildrenArr[0] as! AXUIElement
                    if let realCopyBtn = getAXElemFromChildrenOfAXElemByTitle(
                        copyBtnSubmenu, title: "Copy", cmdChar: "C") {
                        
                        let realCopyBtnEnabled = getAXAttributeValue(
                            realCopyBtn, attr: "AXEnabled") as! Bool
                        if realCopyBtnEnabled {
                            clickAXElemBtn(realCopyBtn)
                            return .copySuccess
                        } else {
                            return .copyDisabled
                        }
                    }
                }
            } else {
                return .copyDisabled
            }
        }
    }
    return .copyFailed
}

func pasteViaAX() {
    if let editSubmenu: AXUIElement = getEditSubmenuViaAX() {
        if let pasteBtn = getAXElemFromChildrenOfAXElemByTitle(
            editSubmenu, title: "Paste", cmdChar: "V") {
            
            let pasteBtnEnabled = getAXAttributeValue(
                pasteBtn, attr: "AXEnabled") as! Bool
            if pasteBtnEnabled {
                let pasteBtnChildrenArr = getAXAttributeValue(
                    pasteBtn, attr: "AXChildren") as! NSArray

                if pasteBtnChildrenArr.count == 0 {
                    clickAXElemBtn(pasteBtn)
                } else {
                    let pasteBtnSubmenu = pasteBtnChildrenArr[0] as! AXUIElement
                    if let realPasteBtn = getAXElemFromChildrenOfAXElemByTitle(
                        pasteBtnSubmenu, title: "Paste", cmdChar: "V") {
                        
                        let realPasteBtnEnabled = getAXAttributeValue(
                            realPasteBtn, attr: "AXEnabled") as! Bool
                        if realPasteBtnEnabled {
                            clickAXElemBtn(realPasteBtn)
                        }
                    }
                }
            }
        }
    }
}

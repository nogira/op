//
//  hide-and-show-window.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

func showPopupWindow() {
    let popupWindow: NSWindow? = NSApp.windows[1]
    if let window: NSWindow = popupWindow {
        // show window / send window to front
        window.orderFrontRegardless()
    }
}

func hidePopupWindow() {
    
    print("hide")
    let popupWindow: NSWindow? = NSApp.windows[1]
    if let window: NSWindow = popupWindow {
        window.orderOut(nil)
        // cancel auto-hide window worker, as window is already closed
        workItem.cancel()
    }
}

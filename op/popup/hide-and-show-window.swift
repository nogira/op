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
    print("the-hide-func")
    let popupWindow: NSWindow? = NSApp.windows[1]
    if let window: NSWindow = popupWindow {
        if window.isVisible {
            print("hide-window")
            window.orderOut(nil)
            
            // FIXME: fix !!!
            
            // cancel auto-hide window worker, as window is already closed
            workItem.cancel()
        }
    }
}

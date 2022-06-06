//
//  hide-and-show-window.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

func showPopupWindow(_ viewController: PopupViewController) {
    let popupWindow: NSWindow? = viewController.view.window
    if let window: NSWindow = popupWindow {
        // show window / send window to front
        window.orderFrontRegardless()
    }
}

func hidePopupWindow(_ viewController: PopupViewController) {
    let popupWindow: NSWindow? = viewController.view.window
    if let window: NSWindow = popupWindow {
        if window.isVisible {
            window.orderOut(nil)
            // cancel auto-hide window worker, as window is already closed
            viewController.workItem?.cancel()
        }
    }
}

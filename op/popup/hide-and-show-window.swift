//
//  hide-and-show-window.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import AppKit

func showPopupWindow(_ viewController: PopupViewController) {
    let popupWindow: FloatingPanel? = viewController.appDelegate.popupWindow
    if let window: FloatingPanel = popupWindow {
        // show window / send window to front
        window.orderFrontRegardless()
    }
}

func hidePopupWindow(_ viewController: PopupViewController) {
    let popupWindow: FloatingPanel? = viewController.appDelegate.popupWindow
    if let window: FloatingPanel = popupWindow {
        if window.isVisible {
            window.orderOut(nil)
            // cancel auto-hide window worker, as window is already closed
            viewController.workItem?.cancel()
        }
    }
}

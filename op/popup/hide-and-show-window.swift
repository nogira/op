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
//    print("the-hide-func")
    let popupWindow: NSWindow? = viewController.view.window
    if let window: NSWindow = popupWindow {
        if window.isVisible {
            print("hide-window")
            window.orderOut(nil)
            
            // FIXME: fix !!!
            print("pre")
            print("is-canceled: \(viewController.workItem?.isCancelled)")
            // cancel auto-hide window worker, as window is already closed
            viewController.workItem?.cancel()
            print("post")
            print("is-canceled: \(viewController.workItem?.isCancelled)")
        }
    }
}

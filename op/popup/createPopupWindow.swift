//
//  createPopupWindow.swift
//  op
//
//  Created by nogira on 6/6/2022.
//

import AppKit

func createPopupWindow() -> (NSWindow, PopupViewController) {
    let popupWindow: NSWindow! = NSWindow( // 10, 1000, 200, 20
        contentRect: NSMakeRect(10, 800, 94, 24),
        styleMask: .unifiedTitleAndToolbar,
        backing: .buffered,
        defer: false
    )
    // always open window in the active space rather than the first space it opened in
    // space is another word for desktop (e.g. i have fullscreen safari on one desktop and xcode on another desktop)
    popupWindow?.collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
//    popupWindow?.hidesOnDeactivate = true
    let popupViewController: PopupViewController! = PopupViewController()
    let popupContent = popupWindow!.contentView! as NSView
    let popupView = popupViewController!.view
    popupContent.addSubview(popupView)
    
    return (popupWindow, popupViewController)
}

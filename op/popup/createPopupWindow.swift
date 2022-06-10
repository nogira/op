//
//  createPopupWindow.swift
//  op
//
//  Created by nogira on 6/6/2022.
//

import AppKit

func createPopupWindow() -> (FloatingPanel, PopupViewController) {
    let popupWindow: FloatingPanel! = FloatingPanel( // 10, 1000, 200, 20
        contentRect: NSMakeRect(10, 800, 94, 24),
        //styleMask: [.unifiedTitleAndToolbar, .hudWindow],
        backing: .buffered,
        defer: false
    )
    // always open window in the active space rather than the first space it opened in
    // space is another word for desktop (e.g. i have fullscreen safari on one desktop and xcode on another desktop)
    popupWindow?.collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
//    popupWindow?.hidesOnDeactivate = true
    
    
    popupWindow?.alphaValue = 0.9
    // ALLOW CUSTOM WINDOW BORDER RADIUS BY REMOVING THE SQUARE WINDOW BACKGROUND AND ALLOWING THE VIEW TO BE THE BACKGROUND
    popupWindow?.backgroundColor = .clear
    
    let popupViewController: PopupViewController! = PopupViewController()
    let popupContent = popupWindow!.contentView! as NSView
    let popupView = popupViewController!.view
    popupContent.addSubview(popupView)
    
    return (popupWindow, popupViewController)
}

//
//  createSettingsWindow.swift
//  op
//
//  Created by nogira on 6/6/2022.
//

import AppKit

func createSettingsWindow() -> (NSWindow, SettingsViewController) {
    let settingsWindow: NSWindow! = NSWindow(
        contentRect: NSMakeRect(0, 0, 300, 300),
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false
    )
    // center the window on screen
    settingsWindow.center()
    settingsWindow?.title = "Settings"
    // always open window in the active space rather than the first space it opened in
    // space is another word for desktop (e.g. i have fullscreen safari on one desktop and xcode on another desktop)
    settingsWindow?.collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
    let settingsViewController: SettingsViewController! = SettingsViewController()
    let settingsContent = settingsWindow!.contentView! as NSView
    let settingsView = settingsViewController!.view
    settingsContent.addSubview(settingsView)
    
    return (settingsWindow, settingsViewController)
}

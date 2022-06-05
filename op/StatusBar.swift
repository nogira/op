//
//  StatusBar.swift
//  pop
//
//  Created by nogira on 1/6/2022.
//

import AppKit

func createStatusBarItem() -> NSStatusItem {
    // https://8thlight.com/blog/casey-brant/2019/05/21/macos-menu-bar-extras.html

    // the is the bar and all its icons
    let statusBar = NSStatusBar.system
    
    // add new bar button/icon to bar
    let statusBarItem = statusBar.statusItem(
        withLength: NSStatusItem.variableLength)
    if let button = statusBarItem.button {
        button.image = NSImage(
            systemSymbolName: "character.cursor.ibeam",
            accessibilityDescription: "character.cursor.ibeam")
    }

    // these are the menu buttons after you click the icon
    let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
    // attach to bar button/icon
    statusBarItem.menu = statusBarMenu
    // add each menu item
    statusBarMenu.addItem(
        withTitle: "show",
        action: #selector(AppDelegate.show),
        keyEquivalent: "")

    statusBarMenu.addItem(
        withTitle: "hide",
        action: #selector(AppDelegate.hide),
        keyEquivalent: "")

    statusBarMenu.addItem(
        withTitle: "quit",
        action: #selector(AppDelegate.quit),
        keyEquivalent: "")

    return statusBarItem
}

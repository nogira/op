//
//  key-press.swift
//  op
//
//  Created by nogira on 5/6/2022.
//

import Quartz

func pressKeyAndCmd(_ key_num: CGKeyCode) -> Void {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: key_num, keyDown: true)!
    event.flags = CGEventFlags.maskCommand
    event.post(tap: CGEventTapLocation.cgSessionEventTap)
}

func releaseKeyAndCmd(_ key_num: CGKeyCode) -> Void {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: key_num, keyDown: false)!
    event.flags = CGEventFlags.maskCommand
    event.post(tap: CGEventTapLocation.cgSessionEventTap)
}

func tapCmdAndKey(_ key: String) -> Void {
    var keyCode: CGKeyCode
    switch key {
    case "c":
        keyCode = 8
    case "v":
        keyCode = 9
    default:
        return
    }
    pressKeyAndCmd(keyCode)
    releaseKeyAndCmd(keyCode)
}

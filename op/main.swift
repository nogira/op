//
//  main.swift
//  op
//
//  Created by nogira on 1/6/2022.
//

import Cocoa

let delegate = AppDelegate() //alloc main app's delegate class
NSApplication.shared.delegate = delegate //set as app's delegate
NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv) //start of run loop

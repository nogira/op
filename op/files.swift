//
//  files.swift
//  op
//
//  Created by nogira on 8/6/2022.
//

import AppKit

/**
 get the application's application support folder
 */
func applicationFolder() -> URL {
    // create application support folder if not already
    let appSupFolder: URL = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let baseFolder: URL =  appSupFolder.appendingPathComponent("nogira.op")
    return baseFolder
}

/**
 get the application's plugin folder in application support folder
 */
func pluginsFolder() -> URL {
    // create application support folder if not already
    let applicationFolder: URL = applicationFolder()
    let pluginsFolder: URL =  applicationFolder.appendingPathComponent("plugins")
    return pluginsFolder
}

// https://stackoverflow.com/questions/31155299/how-to-resize-nsimage-in-swift

func resizeImage(image: NSImage, w: Int, h: Int) -> NSImage {
    var destSize = NSMakeSize(CGFloat(w), CGFloat(h))
    var newImage = NSImage(size: destSize)
    newImage.lockFocus()
    image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: .sourceOver, fraction: CGFloat(1))
    newImage.unlockFocus()
    newImage.size = destSize
    return newImage
}

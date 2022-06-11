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

func proportionalResizeImage(image: NSImage, w: CGFloat, h: CGFloat) -> NSImage {
    let imgW = image.size.width
    let imgH = image.size.height
    let prop1 = imgW / imgH
    let prop2 = w / h
    var newImgW: CGFloat!
    var newImgH: CGFloat!
    var padW: CGFloat!
    var padH: CGFloat!
    // work out if / which sides needs padding
    // if input resize is w=h, and image is w>h: → prop1>prop2, and new imgW will match w, so height will be padded
    // also, imgH will have to be resized as imgH * (w/imgW)
    if prop1 > prop2 {
        newImgW = w
        newImgH = imgH * (w/imgW)
        // pad height
        padH = (h - newImgH) / 2
        padW = 0
    } else {
        newImgH = h
        newImgW = imgW * (h/imgH)
        // pad width
        padW = (w - newImgW) / 2
        padH = 0
    }
    let newImgSize: NSSize = NSMakeSize(newImgW, newImgH)
    let destSize: NSSize = NSMakeSize(w, h)

    let newImage = NSImage(size: destSize)
    newImage.lockFocus()
    image.draw(in: NSMakeRect(padW, padH, newImgSize.width, newImgSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: .sourceOver, fraction: CGFloat(1))
    newImage.unlockFocus()
    newImage.size = destSize
    return newImage
}

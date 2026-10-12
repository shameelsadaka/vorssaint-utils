// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
import AppKit
import ImageIO
import UniformTypeIdentifiers

// Package the approved prototype's sheet with its original planet registration.
// Run from the repository root: swift Tools/prepare-away-logo.swift
let sourceURL = URL(fileURLWithPath: "Resources/Brand/AwayLogo-sheet.jpg")
let bitmap = NSBitmapImageRep(data: try Data(contentsOf: sourceURL))!
let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil)!
let sheet = CGImageSourceCreateImageAtIndex(source, 0, nil)!
let cellWidth = Double(sheet.width) / 4
let cellHeight = Double(sheet.height) / 3
func bright(_ x: Int, _ y: Int) -> Bool {
    bitmap.colorAt(x: x, y: y)!.usingColorSpace(.deviceRGB)!.redComponent > 180.0 / 255
}
for index in 0..<12 {
    let left = Int((Double(index % 4) * cellWidth).rounded())
    let top = Int((Double(index / 4) * cellHeight).rounded())
    let mid = Int((Double(left) + cellWidth / 2).rounded())
    var lo = sheet.height
    var hi = -1
    for y in top..<min(sheet.height, Int((Double(top) + cellHeight).rounded())) {
        if bright(mid, y) { lo = min(lo, y); hi = max(hi, y) }
    }
    precondition(hi > lo, "Missing planet in frame \(index)")
    var sum = 0
    var count = 0
    for y in lo..<min(lo + 12, hi) {
        for x in left..<min(sheet.width, Int((Double(left) + cellWidth).rounded())) {
            if bright(x, y) { sum += x; count += 1 }
        }
    }
    let cx = count > 0 ? Double(sum) / Double(count) : Double(mid)
    let cy = Double(lo + hi) / 2
    let scale = 280 / Double(hi - lo + 1)
    let context = CGContext(data: nil, width: 640, height: 440, bitsPerComponent: 8,
                            bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.setFillColor(CGColor(gray: 0, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: 640, height: 440))
    context.interpolationQuality = .high
    let x = 320 + (Double(left) - cx) * scale
    let topY = 220 + (Double(top) - cy) * scale
    context.clip(to: CGRect(x: x, y: 440 - topY - cellHeight * scale,
                           width: cellWidth * scale, height: cellHeight * scale))
    context.draw(sheet, in: CGRect(x: 320 - cx * scale,
                                  y: 220 - (Double(sheet.height) - cy) * scale,
                                  width: Double(sheet.width) * scale,
                                  height: Double(sheet.height) * scale))
    // White artwork with luminance as alpha, stored premultiplied. Baking the
    // mask avoids SwiftUI compositing differences between display backings.
    let pixels = context.data!.assumingMemoryBound(to: UInt8.self)
    for y in 0..<440 {
        for x in 0..<640 {
            let offset = y * context.bytesPerRow + x * 4
            let alpha = pixels[offset]
            pixels[offset] = alpha
            pixels[offset + 1] = alpha
            pixels[offset + 2] = alpha
            pixels[offset + 3] = alpha
        }
    }
    let output = URL(fileURLWithPath: String(format: "Resources/Images/AwayLogo-%02d.png", index))
    let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, context.makeImage()!, nil)
    precondition(CGImageDestinationFinalize(destination))
    print("Frame \(index): center \(cx), \(cy); diameter \(hi - lo + 1)")
}

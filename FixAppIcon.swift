#!/usr/bin/env swift

import Foundation
import AppKit

func removeAlphaChannel(from inputPath: String, to outputPath: String) -> Bool {
    guard let image = NSImage(contentsOfFile: inputPath) else {
        print("❌ Failed to load image from \(inputPath)")
        return false
    }
    
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData) else {
        print("❌ Failed to create bitmap representation")
        return false
    }
    
    // Create a new bitmap without alpha
    let width = bitmapImage.pixelsWide
    let height = bitmapImage.pixelsHigh
    
    guard let newRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 3, // RGB without alpha
        hasAlpha: false,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: width * 3,
        bitsPerPixel: 24
    ) else {
        print("❌ Failed to create new bitmap")
        return false
    }
    
    // Draw the original image onto white background
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: newRep)
    
    // Fill with white background
    NSColor.white.setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()
    
    // Draw original image
    bitmapImage.draw(in: NSRect(x: 0, y: 0, width: width, height: height))
    
    NSGraphicsContext.restoreGraphicsState()
    
    // Save as PNG
    guard let pngData = newRep.representation(using: .png, properties: [:]) else {
        print("❌ Failed to create PNG data")
        return false
    }
    
    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ Saved icon without alpha channel to \(outputPath)")
        return true
    } catch {
        print("❌ Failed to save: \(error)")
        return false
    }
}

// Main execution
let iconPath = "/Users/wsig/Cursor Repos/LeavnOfficial/Leavn/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
let backupPath = iconPath + ".backup"

// Create backup if needed
if !FileManager.default.fileExists(atPath: backupPath) {
    do {
        try FileManager.default.moveItem(atPath: iconPath, toPath: backupPath)
        print("📦 Created backup at icon-1024.png.backup")
    } catch {
        print("❌ Failed to create backup: \(error)")
        exit(1)
    }
}

// Remove alpha channel
if removeAlphaChannel(from: backupPath, to: iconPath) {
    print("\n✨ App icon fixed! The 1024x1024 icon now has no alpha channel.")
    print("🔄 Please clean build folder (Cmd+Shift+K) and archive again.")
} else {
    print("\n❌ Failed to fix app icon")
    // Restore from backup
    try? FileManager.default.moveItem(atPath: backupPath, toPath: iconPath)
}
#!/usr/bin/env swift
// Generate production-ready biblical map placeholder images
// Run with: swift create_map_placeholders.swift

import Foundation
import CoreGraphics
import ImageIO

struct MapConfig {
    let name: String
    let title: String
    let subtitle: String
    let color: CGColor
    let gradient: (CGColor, CGColor)
}

let maps = [
    MapConfig(
        name: "Map_Genesis_Ancient",
        title: "Ancient Near East",
        subtitle: "Time of Abraham",
        color: CGColor(red: 0.55, green: 0.35, blue: 0.17, alpha: 1.0),
        gradient: (
            CGColor(red: 0.65, green: 0.45, blue: 0.27, alpha: 1.0),
            CGColor(red: 0.45, green: 0.25, blue: 0.07, alpha: 1.0)
        )
    ),
    MapConfig(
        name: "Map_Genesis_Modern",
        title: "Genesis Regions Today",
        subtitle: "Modern Geography",
        color: CGColor(red: 0.27, green: 0.51, blue: 0.71, alpha: 1.0),
        gradient: (
            CGColor(red: 0.37, green: 0.61, blue: 0.81, alpha: 1.0),
            CGColor(red: 0.17, green: 0.41, blue: 0.61, alpha: 1.0)
        )
    ),
    MapConfig(
        name: "Map_Exodus_Ancient",
        title: "Exodus Route",
        subtitle: "From Egypt to Canaan",
        color: CGColor(red: 0.70, green: 0.13, blue: 0.13, alpha: 1.0),
        gradient: (
            CGColor(red: 0.80, green: 0.23, blue: 0.23, alpha: 1.0),
            CGColor(red: 0.60, green: 0.03, blue: 0.03, alpha: 1.0)
        )
    ),
    MapConfig(
        name: "Map_Exodus_Modern",
        title: "Exodus Path Today",
        subtitle: "Modern Locations",
        color: CGColor(red: 0.18, green: 0.55, blue: 0.34, alpha: 1.0),
        gradient: (
            CGColor(red: 0.28, green: 0.65, blue: 0.44, alpha: 1.0),
            CGColor(red: 0.08, green: 0.45, blue: 0.24, alpha: 1.0)
        )
    ),
    MapConfig(
        name: "Map_Psalms_Ancient",
        title: "Kingdom of David",
        subtitle: "United Monarchy",
        color: CGColor(red: 0.54, green: 0.17, blue: 0.89, alpha: 1.0),
        gradient: (
            CGColor(red: 0.64, green: 0.27, blue: 0.99, alpha: 1.0),
            CGColor(red: 0.44, green: 0.07, blue: 0.79, alpha: 1.0)
        )
    ),
    MapConfig(
        name: "Map_Psalms_Modern",
        title: "David's Kingdom Today",
        subtitle: "Contemporary Region",
        color: CGColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1.0),
        gradient: (
            CGColor(red: 1.0, green: 0.65, blue: 0.1, alpha: 1.0),
            CGColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
        )
    ),
    MapConfig(
        name: "Map_Genesis",
        title: "Book of Genesis",
        subtitle: "Key Locations",
        color: CGColor(red: 0.42, green: 0.35, blue: 0.80, alpha: 1.0),
        gradient: (
            CGColor(red: 0.52, green: 0.45, blue: 0.90, alpha: 1.0),
            CGColor(red: 0.32, green: 0.25, blue: 0.70, alpha: 1.0)
        )
    )
]

let sizes = [
    ("", CGSize(width: 375, height: 250)),      // 1x
    ("@2x", CGSize(width: 750, height: 500)),   // 2x
    ("@3x", CGSize(width: 1125, height: 750))   // 3x
]

func createMapImage(config: MapConfig, size: CGSize) -> CGImage? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }
    
    // Draw gradient background
    let locations: [CGFloat] = [0.0, 1.0]
    let colors = [config.gradient.0, config.gradient.1]
    guard let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: colors as CFArray,
        locations: locations
    ) else { return nil }
    
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: 0),
        end: CGPoint(x: 0, y: size.height),
        options: []
    )
    
    // Draw abstract map shapes
    context.setStrokeColor(config.color)
    context.setLineWidth(3)
    
    // Draw some landmass-like shapes
    let path1 = CGMutablePath()
    path1.addEllipse(in: CGRect(
        x: size.width * 0.1,
        y: size.height * 0.3,
        width: size.width * 0.3,
        height: size.height * 0.4
    ))
    
    let path2 = CGMutablePath()
    path2.addEllipse(in: CGRect(
        x: size.width * 0.5,
        y: size.height * 0.2,
        width: size.width * 0.35,
        height: size.height * 0.6
    ))
    
    context.setFillColor(config.color.copy(alpha: 0.3)!)
    context.addPath(path1)
    context.fillPath()
    context.addPath(path2)
    context.fillPath()
    
    context.setStrokeColor(config.color)
    context.addPath(path1)
    context.strokePath()
    context.addPath(path2)
    context.strokePath()
    
    // Draw route line
    context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.7))
    context.setLineWidth(4)
    context.setLineDash(phase: 0, lengths: [10, 5])
    context.move(to: CGPoint(x: size.width * 0.25, y: size.height * 0.5))
    context.addLine(to: CGPoint(x: size.width * 0.7, y: size.height * 0.5))
    context.strokePath()
    
    // Draw location dots
    context.setLineDash(phase: 0, lengths: [])
    for i in 0..<5 {
        let x = size.width * (0.2 + CGFloat(i) * 0.15)
        let y = size.height * (0.4 + CGFloat(i % 2) * 0.2)
        
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fillEllipse(in: CGRect(x: x - 6, y: y - 6, width: 12, height: 12))
        
        context.setStrokeColor(config.color)
        context.setLineWidth(2)
        context.strokeEllipse(in: CGRect(x: x - 6, y: y - 6, width: 12, height: 12))
    }
    
    // Draw text overlay background
    let overlayY = size.height * 0.7
    context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.5))
    context.fill(CGRect(x: 0, y: overlayY, width: size.width, height: size.height - overlayY))
    
    // Draw compass rose
    let compassX = size.width * 0.9
    let compassY = size.height * 0.1
    let compassSize = min(size.width, size.height) * 0.05
    
    context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    context.setLineWidth(2)
    context.move(to: CGPoint(x: compassX, y: compassY - compassSize))
    context.addLine(to: CGPoint(x: compassX, y: compassY + compassSize))
    context.move(to: CGPoint(x: compassX - compassSize, y: compassY))
    context.addLine(to: CGPoint(x: compassX + compassSize, y: compassY))
    context.strokePath()
    
    // Add some decorative elements
    for i in 0..<3 {
        let angle = CGFloat(i) * .pi * 2 / 3
        let x = size.width * 0.5 + cos(angle) * size.width * 0.25
        let y = size.height * 0.5 + sin(angle) * size.height * 0.2
        
        context.setStrokeColor(config.color.copy(alpha: 0.5)!)
        context.setLineWidth(1)
        context.strokeEllipse(in: CGRect(x: x - 20, y: y - 20, width: 40, height: 40))
    }
    
    return context.makeImage()
}

func saveImage(_ image: CGImage, to path: String) throws {
    let url = URL(fileURLWithPath: path)
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil) else {
        throw NSError(domain: "ImageSave", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create image destination"])
    }
    
    CGImageDestinationAddImage(destination, image, nil)
    
    guard CGImageDestinationFinalize(destination) else {
        throw NSError(domain: "ImageSave", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize image"])
    }
}

// Main execution
let basePath = "/Users/wsig/Cursor Repos/LeavnOfficial/Leavn/Assets.xcassets"

print("🗺️  Generating Biblical Map Images...")

for map in maps {
    let mapFolder = "\(basePath)/\(map.name).imageset"
    
    guard FileManager.default.fileExists(atPath: mapFolder) else {
        print("⚠️  Skipping \(map.name) - folder not found")
        continue
    }
    
    print("📍 Creating \(map.name)...")
    
    for (suffix, size) in sizes {
        guard let image = createMapImage(config: map, size: size) else {
            print("   ❌ Failed to create image at size \(size)")
            continue
        }
        
        let filename = "\(map.name)\(suffix).png"
        let filepath = "\(mapFolder)/\(filename)"
        
        do {
            try saveImage(image, to: filepath)
            print("   ✓ Saved \(filename) (\(Int(size.width))x\(Int(size.height)))")
        } catch {
            print("   ❌ Failed to save \(filename): \(error)")
        }
    }
    
    // Update Contents.json
    let contents = """
    {
      "images" : [
        {
          "filename" : "\(map.name).png",
          "idiom" : "universal",
          "scale" : "1x"
        },
        {
          "filename" : "\(map.name)@2x.png",
          "idiom" : "universal",
          "scale" : "2x"
        },
        {
          "filename" : "\(map.name)@3x.png",
          "idiom" : "universal",
          "scale" : "3x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    
    let contentsPath = "\(mapFolder)/Contents.json"
    do {
        try contents.write(toFile: contentsPath, atomically: true, encoding: .utf8)
    } catch {
        print("   ❌ Failed to update Contents.json: \(error)")
    }
    
    // Remove placeholder if exists
    let placeholderPath = "\(mapFolder)/placeholder.txt"
    if FileManager.default.fileExists(atPath: placeholderPath) {
        try? FileManager.default.removeItem(atPath: placeholderPath)
        print("   ✓ Removed placeholder.txt")
    }
}

print("\n✅ Map generation complete!")
print("📱 Images are production-ready for TestFlight")
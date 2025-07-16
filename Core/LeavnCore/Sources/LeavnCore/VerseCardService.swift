import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Verse Card Service Protocol
/// Generates beautiful shareable verse card images
public protocol VerseCardServiceProtocol {
    func generateCard(for verse: BibleVerse, template: VerseCardTemplate, customization: VerseCardCustomization?) async throws -> UIImage
    func generateCardData(for verse: BibleVerse, template: VerseCardTemplate, customization: VerseCardCustomization?) async throws -> Data
    func getAvailableTemplates() -> [VerseCardTemplate]
    func getRecommendedTemplate(for occasion: VerseCardOccasion) -> VerseCardTemplate
}

// MARK: - Verse Card Types
public enum VerseCardTemplate: String, CaseIterable, Identifiable, Sendable {
    case minimalist = "Minimalist"
    case gradient = "Gradient"
    case nature = "Nature"
    case geometric = "Geometric"
    case watercolor = "Watercolor"
    case vintage = "Vintage"
    case modern = "Modern"
    case elegant = "Elegant"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .minimalist: return "Clean and simple design"
        case .gradient: return "Beautiful color gradients"
        case .nature: return "Nature-inspired backgrounds"
        case .geometric: return "Modern geometric patterns"
        case .watercolor: return "Soft watercolor effects"
        case .vintage: return "Classic vintage style"
        case .modern: return "Contemporary design"
        case .elegant: return "Sophisticated and refined"
        }
    }
    
    public var defaultColors: [Color] {
        switch self {
        case .minimalist: return [.white, .black]
        case .gradient: return [Color(hex: "#667eea"), Color(hex: "#764ba2")]
        case .nature: return [Color(hex: "#134e4a"), Color(hex: "#14b8a6")]
        case .geometric: return [Color(hex: "#f59e0b"), Color(hex: "#ef4444")]
        case .watercolor: return [Color(hex: "#fbbf24"), Color(hex: "#a78bfa")]
        case .vintage: return [Color(hex: "#92400e"), Color(hex: "#fef3c7")]
        case .modern: return [Color(hex: "#1e40af"), Color(hex: "#60a5fa")]
        case .elegant: return [Color(hex: "#1f2937"), Color(hex: "#d1d5db")]
        }
    }
}

public enum VerseCardOccasion: String, CaseIterable, Sendable {
    case daily = "Daily Verse"
    case encouragement = "Encouragement"
    case prayer = "Prayer"
    case gratitude = "Gratitude"
    case hope = "Hope"
    case love = "Love"
    case faith = "Faith"
    case peace = "Peace"
    case strength = "Strength"
    case wisdom = "Wisdom"
}

public struct VerseCardCustomization: Sendable {
    public let backgroundColor: Color?
    public let textColor: Color?
    public let accentColor: Color?
    public let fontName: String?
    public let fontSize: CGFloat?
    public let includeLeavnBranding: Bool
    public let watermarkOpacity: Double
    public let padding: CGFloat
    
    public init(
        backgroundColor: Color? = nil,
        textColor: Color? = nil,
        accentColor: Color? = nil,
        fontName: String? = nil,
        fontSize: CGFloat? = nil,
        includeLeavnBranding: Bool = true,
        watermarkOpacity: Double = 0.8,
        padding: CGFloat = 40
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.accentColor = accentColor
        self.fontName = fontName
        self.fontSize = fontSize
        self.includeLeavnBranding = includeLeavnBranding
        self.watermarkOpacity = watermarkOpacity
        self.padding = padding
    }
}

// MARK: - Verse Card Service Implementation
public final class VerseCardService: VerseCardServiceProtocol {
    private let imageSize = CGSize(width: 1080, height: 1080) // Instagram square format
    private let storySize = CGSize(width: 1080, height: 1920) // Instagram story format
    
    public init() {}
    
    public func generateCard(for verse: BibleVerse, template: VerseCardTemplate, customization: VerseCardCustomization?) async throws -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: imageSize)
            
            // Draw background
            drawBackground(in: context, rect: rect, template: template, customization: customization)
            
            // Draw verse content
            drawVerseContent(verse: verse, in: context, rect: rect, template: template, customization: customization)
            
            // Draw Leavn branding
            if customization?.includeLeavnBranding ?? true {
                drawLeavnBranding(in: context, rect: rect, customization: customization)
            }
        }
    }
    
    public func generateCardData(for verse: BibleVerse, template: VerseCardTemplate, customization: VerseCardCustomization?) async throws -> Data {
        let image = try await generateCard(for: verse, template: template, customization: customization)
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw VerseCardError.imageGenerationFailed
        }
        return data
    }
    
    public func getAvailableTemplates() -> [VerseCardTemplate] {
        VerseCardTemplate.allCases
    }
    
    public func getRecommendedTemplate(for occasion: VerseCardOccasion) -> VerseCardTemplate {
        switch occasion {
        case .daily: return .gradient
        case .encouragement: return .nature
        case .prayer: return .watercolor
        case .gratitude: return .elegant
        case .hope: return .minimalist
        case .love: return .watercolor
        case .faith: return .vintage
        case .peace: return .nature
        case .strength: return .geometric
        case .wisdom: return .modern
        }
    }
    
    // MARK: - Private Drawing Methods
    
    private func drawBackground(in context: UIGraphicsRendererContext, rect: CGRect, template: VerseCardTemplate, customization: VerseCardCustomization?) {
        let colors = customization?.backgroundColor != nil ? [customization!.backgroundColor!] : template.defaultColors
        
        switch template {
        case .minimalist:
            UIColor(colors[0]).setFill()
            context.fill(rect)
            
        case .gradient:
            drawGradient(in: context, rect: rect, colors: colors)
            
        case .nature:
            drawNatureBackground(in: context, rect: rect, colors: colors)
            
        case .geometric:
            drawGeometricPattern(in: context, rect: rect, colors: colors)
            
        case .watercolor:
            drawWatercolorEffect(in: context, rect: rect, colors: colors)
            
        case .vintage:
            drawVintageTexture(in: context, rect: rect, colors: colors)
            
        case .modern:
            drawModernDesign(in: context, rect: rect, colors: colors)
            
        case .elegant:
            drawElegantBackground(in: context, rect: rect, colors: colors)
        }
    }
    
    private func drawGradient(in context: UIGraphicsRendererContext, rect: CGRect, colors: [Color]) {
        let cgColors = colors.map { UIColor($0).cgColor }
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors as CFArray, locations: nil) else { return }
        
        context.cgContext.drawLinearGradient(gradient, start: rect.origin, end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
    }
    
    private func drawNatureBackground(in context: UIGraphicsRendererContext, rect: CGRect, colors: [Color]) {
        // Base color
        UIColor(colors[0]).setFill()
        context.fill(rect)
        
        // Organic shapes
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.7))
        path.addCurve(to: CGPoint(x: rect.width, y: rect.height * 0.8),
                      controlPoint1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.6),
                      controlPoint2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.9))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.close()
        
        UIColor(colors.count > 1 ? colors[1] : colors[0]).withAlphaComponent(0.3).setFill()
        path.fill()
    }
    
    private func drawGeometricPattern(in context: UIGraphicsRendererContext, rect: CGRect, colors: [Color]) {
        UIColor(colors[0]).setFill()
        context.fill(rect)
        
        // Geometric shapes
        let shapeSize: CGFloat = 60
        let spacing: CGFloat = 80
        
        for x in stride(from: 0, to: rect.width, by: spacing) {
            for y in stride(from: 0, to: rect.height, by: spacing) {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x + shapeSize, y: y))
                path.addLine(to: CGPoint(x: x + shapeSize/2, y: y + shapeSize))
                path.close()
                
                UIColor(colors.count > 1 ? colors[1] : colors[0]).withAlphaComponent(0.1).setFill()
                path.fill()
            }
        }
    }
    
    private func drawWatercolorEffect(in context: UIGraphicsRendererContext, rect: CGRect, colors: [Color]) {
        // Soft watercolor-like circles
        for _ in 0..<5 {
            let center = CGPoint(x: CGFloat.random(in: 0...rect.width), y: CGFloat.random(in: 0...rect.height))
            let radius = CGFloat.random(in: 200...400)
            let color = colors.randomElement() ?? colors[0]
            
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            UIColor(color).withAlphaComponent(0.1).setFill()
            path.fill()
        }
    }
    
    private func drawVintageTexture(in context: UIGraphicsRendererContext, rect: CGRect, colors: [Color]) {
        UIColor(colors[0]).setFill()
        context.fill(rect)
        
        // Vintage texture overlay
        let noiseLayer = CALayer()
        noiseLayer.frame = rect
        noiseLayer.backgroundColor = UIColor.black.cgColor
        noiseLayer.opacity = 0.05
        noiseLayer.compositingFilter = "multiplyBlendMode"
    }
    
    private func drawModernDesign(in context: UIGraphicsRendererContext, rect: CGRect, colors: [Color]) {
        drawGradient(in: context, rect: rect, colors: colors)
        
        // Modern accent shapes
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width * 0.7, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.3))
        path.close()
        
        UIColor.white.withAlphaComponent(0.1).setFill()
        path.fill()
    }
    
    private func drawElegantBackground(in context: UIGraphicsRendererContext, rect: CGRect, colors: [Color]) {
        UIColor(colors[0]).setFill()
        context.fill(rect)
        
        // Subtle pattern
        let patternSize: CGFloat = 2
        for x in stride(from: 0, to: rect.width, by: patternSize * 2) {
            for y in stride(from: 0, to: rect.height, by: patternSize * 2) {
                let dotRect = CGRect(x: x, y: y, width: patternSize, height: patternSize)
                UIColor(colors.count > 1 ? colors[1] : colors[0]).withAlphaComponent(0.05).setFill()
                context.cgContext.fillEllipse(in: dotRect)
            }
        }
    }
    
    private func drawVerseContent(verse: BibleVerse, in context: UIGraphicsRendererContext, rect: CGRect, template: VerseCardTemplate, customization: VerseCardCustomization?) {
        let padding = customization?.padding ?? 40
        let contentRect = rect.insetBy(dx: padding, dy: padding)
        
        // Determine text color
        let textColor: UIColor = {
            if let customColor = customization?.textColor {
                return UIColor(customColor)
            }
            switch template {
            case .minimalist, .vintage: return .black
            case .gradient, .nature, .modern, .elegant: return .white
            case .geometric, .watercolor: return UIColor(Color(hex: "#1f2937"))
            }
        }()
        
        // Verse text
        let fontSize = customization?.fontSize ?? (verse.text.count > 150 ? 32 : 36)
        let fontName = customization?.fontName ?? "Georgia"
        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 8
        
        let verseAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let verseText = NSAttributedString(string: verse.text, attributes: verseAttributes)
        
        // Calculate text rect
        let textSize = verseText.boundingRect(with: contentRect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        let textRect = CGRect(x: contentRect.minX, y: contentRect.midY - textSize.height/2 - 40, width: contentRect.width, height: textSize.height)
        
        verseText.draw(in: textRect)
        
        // Reference
        let referenceFont = UIFont(name: fontName, size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        let referenceAttributes: [NSAttributedString.Key: Any] = [
            .font: referenceFont,
            .foregroundColor: textColor.withAlphaComponent(0.8),
            .paragraphStyle: paragraphStyle
        ]
        
        let referenceText = NSAttributedString(string: "\(verse.reference) (\(verse.translation))", attributes: referenceAttributes)
        let referenceSize = referenceText.boundingRect(with: contentRect.size, options: [.usesLineFragmentOrigin], context: nil).size
        let referenceRect = CGRect(x: contentRect.minX, y: textRect.maxY + 20, width: contentRect.width, height: referenceSize.height)
        
        referenceText.draw(in: referenceRect)
    }
    
    private func drawLeavnBranding(in context: UIGraphicsRendererContext, rect: CGRect, customization: VerseCardCustomization?) {
        let watermarkOpacity = customization?.watermarkOpacity ?? 0.8
        
        // Leavn logo/text at bottom
        let brandingText = "Shared from Leavn"
        let brandingFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let brandingAttributes: [NSAttributedString.Key: Any] = [
            .font: brandingFont,
            .foregroundColor: UIColor.white.withAlphaComponent(watermarkOpacity),
            .paragraphStyle: paragraphStyle
        ]
        
        let brandingString = NSAttributedString(string: brandingText, attributes: brandingAttributes)
        let brandingSize = brandingString.boundingRect(with: rect.size, options: [], context: nil).size
        
        // Background for branding
        let brandingBackground = CGRect(x: 0, y: rect.height - 60, width: rect.width, height: 60)
        UIColor.black.withAlphaComponent(0.3).setFill()
        context.fill(brandingBackground)
        
        // Draw branding text
        let brandingRect = CGRect(x: 0, y: rect.height - 40, width: rect.width, height: brandingSize.height)
        brandingString.draw(in: brandingRect)
        
        // App Store link hint
        let linkText = "Download on the App Store"
        let linkFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: linkFont,
            .foregroundColor: UIColor.white.withAlphaComponent(watermarkOpacity * 0.8),
            .paragraphStyle: paragraphStyle
        ]
        
        let linkString = NSAttributedString(string: linkText, attributes: linkAttributes)
        let linkRect = CGRect(x: 0, y: rect.height - 20, width: rect.width, height: 20)
        linkString.draw(in: linkRect)
    }
}

// MARK: - Error Types
public enum VerseCardError: LocalizedError {
    case imageGenerationFailed
    case invalidTemplate
    case renderingError
    
    public var errorDescription: String? {
        switch self {
        case .imageGenerationFailed:
            return "Failed to generate verse card image"
        case .invalidTemplate:
            return "Invalid verse card template"
        case .renderingError:
            return "Failed to render verse card"
        }
    }
}

// MARK: - Color Extension
// Color(hex:) initializer is now defined in Color+Theme.swift to avoid duplication
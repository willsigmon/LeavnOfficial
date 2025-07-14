import SwiftUI

// MARK: - Theme Validator
public struct ThemeValidator {
    
    // MARK: - Validation Results
    public struct ValidationResult {
        public let component: String
        public let foregroundColor: Color
        public let backgroundColor: Color
        public let contrastRatio: Double
        public let passesAA: Bool
        public let passesAAA: Bool
        public let recommendation: String?
        
        public var description: String {
            """
            Component: \(component)
            Contrast Ratio: \(String(format: "%.2f:1", contrastRatio))
            WCAG AA (4.5:1): \(passesAA ? "✅ Pass" : "❌ Fail")
            WCAG AAA (7:1): \(passesAAA ? "✅ Pass" : "❌ Fail")
            \(recommendation.map { "Recommendation: \($0)" } ?? "")
            """
        }
    }
    
    // MARK: - Validate All Theme Components
    public static func validateTheme() -> [ValidationResult] {
        var results: [ValidationResult] = []
        
        // Test both light and dark modes
        for colorScheme in [ColorScheme.light, .dark] {
            let schemePrefix = colorScheme == .light ? "Light Mode" : "Dark Mode"
            
            // Primary Text on Backgrounds
            results.append(contentsOf: validateTextOnBackgrounds(colorScheme: colorScheme, prefix: schemePrefix))
            
            // Button Combinations
            results.append(contentsOf: validateButtons(colorScheme: colorScheme, prefix: schemePrefix))
            
            // Semantic Colors
            results.append(contentsOf: validateSemanticColors(colorScheme: colorScheme, prefix: schemePrefix))
            
            // Interactive Elements
            results.append(contentsOf: validateInteractiveElements(colorScheme: colorScheme, prefix: schemePrefix))
        }
        
        return results
    }
    
    // MARK: - Text on Background Validation
    @MainActor @MainActor @MainActor @MainActor @MainActor private static func validateTextOnBackgrounds(colorScheme: ColorScheme, prefix: String) -> [ValidationResult] {
        var results: [ValidationResult] = []
        
        // Primary text on primary background
        let primaryText = getColor(Color.LeavnTextColors.primary, in: colorScheme)
        let primaryBg = getColor(Color.LeavnBackgroundColors.primary, in: colorScheme)
        
        results.append(validateContrast(
            component: "\(prefix) - Primary Text on Primary Background",
            foreground: primaryText,
            background: primaryBg,
            minimumAA: 4.5
        ))
        
        // Secondary text on primary background
        let secondaryText = getColor(Color.LeavnTextColors.secondary, in: colorScheme)
        
        results.append(validateContrast(
            component: "\(prefix) - Secondary Text on Primary Background",
            foreground: secondaryText,
            background: primaryBg,
            minimumAA: 4.5
        ))
        
        // Tertiary text on primary background
        let tertiaryText = getColor(Color.LeavnTextColors.tertiary, in: colorScheme)
        
        results.append(validateContrast(
            component: "\(prefix) - Tertiary Text on Primary Background",
            foreground: tertiaryText,
            background: primaryBg,
            minimumAA: 3.0 // Large text standard
        ))
        
        // Primary text on secondary background
        let secondaryBg = getColor(Color.LeavnBackgroundColors.secondary, in: colorScheme)
        
        results.append(validateContrast(
            component: "\(prefix) - Primary Text on Secondary Background",
            foreground: primaryText,
            background: secondaryBg,
            minimumAA: 4.5
        ))
        
        return results
    }
    
    // MARK: - Button Validation
    @MainActor @MainActor @MainActor private static func validateButtons(colorScheme: ColorScheme, prefix: String) -> [ValidationResult] {
        var results: [ValidationResult] = []
        
        // Primary button
        let primaryButton = getColor(Color.LeavnColors.primary, in: colorScheme)
        let whiteText = Color.white
        
        results.append(validateContrast(
            component: "\(prefix) - Primary Button Text",
            foreground: whiteText,
            background: primaryButton,
            minimumAA: 4.5
        ))
        
        // Secondary button (text on light background)
        _ = primaryButton.opacity(0.1)
        
        results.append(validateContrast(
            component: "\(prefix) - Secondary Button Text",
            foreground: primaryButton,
            background: getColor(Color.LeavnBackgroundColors.primary, in: colorScheme),
            minimumAA: 4.5
        ))
        
        // Destructive button
        let destructiveButton = getColor(Color.LeavnColors.error, in: colorScheme)
        
        results.append(validateContrast(
            component: "\(prefix) - Destructive Button Text",
            foreground: whiteText,
            background: destructiveButton,
            minimumAA: 4.5
        ))
        
        return results
    }
    
    // MARK: - Semantic Colors Validation
    @MainActor @MainActor @MainActor @MainActor @MainActor private static func validateSemanticColors(colorScheme: ColorScheme, prefix: String) -> [ValidationResult] {
        var results: [ValidationResult] = []
        let background = getColor(Color.LeavnBackgroundColors.primary, in: colorScheme)
        
        // Success color
        let success = getColor(Color.LeavnColors.success, in: colorScheme)
        results.append(validateContrast(
            component: "\(prefix) - Success Text on Background",
            foreground: success,
            background: background,
            minimumAA: 3.0 // For UI components
        ))
        
        // Warning color
        let warning = getColor(Color.LeavnColors.warning, in: colorScheme)
        results.append(validateContrast(
            component: "\(prefix) - Warning Text on Background",
            foreground: warning,
            background: background,
            minimumAA: 3.0
        ))
        
        // Error color
        let error = getColor(Color.LeavnColors.error, in: colorScheme)
        results.append(validateContrast(
            component: "\(prefix) - Error Text on Background",
            foreground: error,
            background: background,
            minimumAA: 3.0
        ))
        
        // Info color
        let info = getColor(Color.LeavnColors.info, in: colorScheme)
        results.append(validateContrast(
            component: "\(prefix) - Info Text on Background",
            foreground: info,
            background: background,
            minimumAA: 3.0
        ))
        
        return results
    }
    
    // MARK: - Interactive Elements Validation
    @MainActor @MainActor @MainActor @MainActor private static func validateInteractiveElements(colorScheme: ColorScheme, prefix: String) -> [ValidationResult] {
        var results: [ValidationResult] = []
        let background = getColor(Color.LeavnBackgroundColors.primary, in: colorScheme)
        
        // Links
        let link = getColor(Color.LeavnInteractiveColors.link, in: colorScheme)
        results.append(validateContrast(
            component: "\(prefix) - Link Color",
            foreground: link,
            background: background,
            minimumAA: 4.5
        ))
        
        // Disabled state
        let disabledText = getColor(Color.LeavnTextColors.disabled, in: colorScheme)
        results.append(validateContrast(
            component: "\(prefix) - Disabled Text",
            foreground: disabledText,
            background: background,
            minimumAA: 3.0 // Reduced requirement for disabled
        ))
        
        // Border color
        let border = getColor(Color.LeavnBorderColors.border, in: colorScheme)
        results.append(validateContrast(
            component: "\(prefix) - Border Color",
            foreground: border,
            background: background,
            minimumAA: 3.0 // For UI components
        ))
        
        return results
    }
    
    // MARK: - Helper Methods
    private static func validateContrast(
        component: String,
        foreground: Color,
        background: Color,
        minimumAA: Double = 4.5
    ) -> ValidationResult {
        let result = ContrastChecker.checkContrast(
            foreground: foreground,
            background: background
        )
        
        let passesAA = result.ratio >= minimumAA
        let passesAAA = result.ratio >= 7.0
        
        var recommendation: String?
        if !passesAA {
            let increase = minimumAA / result.ratio
            recommendation = "Increase contrast by \(String(format: "%.1fx", increase)) to meet WCAG AA"
        }
        
        return ValidationResult(
            component: component,
            foregroundColor: foreground,
            backgroundColor: background,
            contrastRatio: result.ratio,
            passesAA: passesAA,
            passesAAA: passesAAA,
            recommendation: recommendation
        )
    }
    
    private static func getColor(_ colorSet: ColorSet, in colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? colorSet.dark : colorSet.light
    }
    
    private static func getColor(_ color: Color, in colorScheme: ColorScheme) -> Color {
        // For static colors, return as is
        color
    }
}

// MARK: - Theme Validation View
public struct ThemeValidationView: View {
    @State private var validationResults: [ThemeValidator.ValidationResult] = []
    @State private var showOnlyFailures = false
    @State private var selectedColorScheme: ColorScheme = .light
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Controls
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Color Scheme", selection: $selectedColorScheme) {
                            Text("Light Mode").tag(ColorScheme.light)
                            Text("Dark Mode").tag(ColorScheme.dark)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Toggle("Show Only Failures", isOn: $showOnlyFailures)
                    }
                    .padding()
                    .background(Color.LeavnBackgroundColors.secondary.current)
                    .cornerRadius(12)
                    
                    // Results
                    ForEach(filteredResults, id: \.component) { result in
                        ValidationResultCard(result: result)
                    }
                }
                .padding()
            }
            .navigationTitle("Theme Validation")
            .onAppear {
                validationResults = ThemeValidator.validateTheme()
            }
        }
    }
    
    private var filteredResults: [ThemeValidator.ValidationResult] {
        let schemePrefix = selectedColorScheme == .light ? "Light Mode" : "Dark Mode"
        let schemeResults = validationResults.filter { $0.component.contains(schemePrefix) }
        
        if showOnlyFailures {
            return schemeResults.filter { !$0.passesAA }
        }
        return schemeResults
    }
}

// MARK: - Validation Result Card
private struct ValidationResultCard: View {
    let result: ThemeValidator.ValidationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(cleanComponentName)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: result.passesAA ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.passesAA ? .green : .red)
            }
            
            HStack(spacing: 20) {
                ColorSwatch(color: result.foregroundColor, name: "Foreground")
                ColorSwatch(color: result.backgroundColor, label: "Background")
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Contrast Ratio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f:1", result.contrastRatio))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            HStack(spacing: 16) {
                Label(
                    result.passesAA ? "WCAG AA" : "Fails AA",
                    systemImage: result.passesAA ? "checkmark" : "xmark"
                )
                .foregroundColor(result.passesAA ? .green : .red)
                .font(.caption)
                
                Label(
                    result.passesAAA ? "WCAG AAA" : "Fails AAA",
                    systemImage: result.passesAAA ? "checkmark" : "xmark"
                )
                .foregroundColor(result.passesAAA ? .green : .orange)
                .font(.caption)
            }
            
            if let recommendation = result.recommendation {
                Text(recommendation)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.LeavnBackgroundColors.secondary.current)
        .cornerRadius(12)
    }
    
    private var cleanComponentName: String {
        result.component
            .replacingOccurrences(of: "Light Mode - ", with: "")
            .replacingOccurrences(of: "Dark Mode - ", with: "")
    }
}

// MARK: - Color Swatch
private struct ColorSwatch: View {
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.LeavnBorderColors.border.current, lineWidth: 1)
                )
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

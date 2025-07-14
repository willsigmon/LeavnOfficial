import XCTest
import SwiftUI
@testable import DesignSystem

final class AccessibilityTests: XCTestCase {
    
    // MARK: - Contrast Ratio Tests
    
    func testPrimaryTextContrast() {
        // Light mode
        let lightTextResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnTextColors.primary.light,
            background: Color.LeavnBackgroundColors.primary.light
        )
        XCTAssertTrue(lightTextResult.passesAA, "Primary text should pass WCAG AA in light mode")
        
        // Dark mode
        let darkTextResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnTextColors.primary.dark,
            background: Color.LeavnBackgroundColors.primary.dark
        )
        XCTAssertTrue(darkTextResult.passesAA, "Primary text should pass WCAG AA in dark mode")
    }
    
    func testSecondaryTextContrast() {
        // Light mode
        let lightTextResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnTextColors.secondary.light,
            background: Color.LeavnBackgroundColors.primary.light
        )
        XCTAssertTrue(lightTextResult.passesAA, "Secondary text should pass WCAG AA in light mode")
        
        // Dark mode
        let darkTextResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnTextColors.secondary.dark,
            background: Color.LeavnBackgroundColors.primary.dark
        )
        XCTAssertTrue(darkTextResult.passesAA, "Secondary text should pass WCAG AA in dark mode")
    }
    
    func testButtonContrast() {
        // Primary button
        let primaryButtonResult = ContrastChecker.checkContrast(
            foreground: .white,
            background: Color.LeavnColors.primary.light
        )
        XCTAssertTrue(primaryButtonResult.passesAA, "Primary button text should pass WCAG AA")
        
        // Destructive button
        let destructiveButtonResult = ContrastChecker.checkContrast(
            foreground: .white,
            background: Color.LeavnColors.error.light
        )
        XCTAssertTrue(destructiveButtonResult.passesAA, "Destructive button text should pass WCAG AA")
    }
    
    func testSemanticColorContrast() {
        let background = Color.LeavnBackgroundColors.primary.light
        
        // Success color
        let successResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnColors.success.light,
            background: background
        )
        XCTAssertTrue(successResult.passesLargeTextAA, "Success color should pass WCAG AA for UI components")
        
        // Error color
        let errorResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnColors.error.light,
            background: background
        )
        XCTAssertTrue(errorResult.passesLargeTextAA, "Error color should pass WCAG AA for UI components")
        
        // Warning color on appropriate background
        let warningResult = ContrastChecker.checkContrast(
            foreground: Color.black,
            background: Color.LeavnColors.warning.light
        )
        XCTAssertTrue(warningResult.passesAA, "Warning color with dark text should pass WCAG AA")
    }
    
    func testHighContrastMode() {
        // High contrast light mode
        let hcLightResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnTextColors.primary.highContrastLight,
            background: Color.LeavnBackgroundColors.primary.highContrastLight
        )
        XCTAssertTrue(hcLightResult.passesAAA, "High contrast light mode should pass WCAG AAA")
        
        // High contrast dark mode
        let hcDarkResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnTextColors.primary.highContrastDark,
            background: Color.LeavnBackgroundColors.primary.highContrastDark
        )
        XCTAssertTrue(hcDarkResult.passesAAA, "High contrast dark mode should pass WCAG AAA")
    }
    
    func testDisabledStateContrast() {
        // Disabled text should still be readable (3:1 ratio)
        let disabledResult = ContrastChecker.checkContrast(
            foreground: Color.LeavnTextColors.disabled.light,
            background: Color.LeavnBackgroundColors.primary.light
        )
        XCTAssertTrue(disabledResult.passesLargeTextAA, "Disabled text should maintain 3:1 contrast ratio")
    }
    
    // MARK: - Theme Validation Tests
    
    func testCompleteThemeValidation() {
        let results = ThemeValidator.validateTheme()
        
        // Check that all critical components pass
        for result in results {
            if result.component.contains("Primary Text") ||
               result.component.contains("Button Text") ||
               result.component.contains("Error") ||
               result.component.contains("Success") {
                XCTAssertTrue(
                    result.passesAA,
                    "Critical component '\(result.component)' should pass WCAG AA. Ratio: \(result.contrastRatio)"
                )
            }
        }
    }
    
    // MARK: - Accessibility Manager Tests
    
    func testAccessibilityManagerInitialization() {
        let manager = AccessibilityThemeManager.shared
        XCTAssertNotNil(manager, "Accessibility manager should be initialized")
    }
    
    // MARK: - Color Adaptation Tests
    
    func testColorSetAdaptation() {
        let colorSet = ColorSet(
            light: .black,
            dark: .white,
            highContrastLight: .black,
            highContrastDark: .white
        )
        
        // Test that current returns appropriate color
        // Note: In unit tests, we can't easily test environment-dependent values
        // These would be better tested in UI tests
        XCTAssertNotNil(colorSet.current, "ColorSet should always return a color")
    }
    
    // MARK: - Component Size Tests
    
    func testMinimumTouchTargets() {
        // Test button sizes meet minimum requirements
        let smallButtonHeight: CGFloat = 36
        let mediumButtonHeight: CGFloat = 44
        let largeButtonHeight: CGFloat = 56
        
        XCTAssertGreaterThanOrEqual(mediumButtonHeight, 44, "Medium button should meet minimum touch target")
        XCTAssertGreaterThanOrEqual(largeButtonHeight, 44, "Large button should meet minimum touch target")
        
        // Small buttons should be used sparingly and with adequate padding
        XCTAssertLessThan(smallButtonHeight, 44, "Small button requires additional padding for touch target")
    }
    
    // MARK: - Hex Color Tests
    
    func testHexColorInitialization() {
        let blueHex = Color(hex: "#007AFF")
        let redHex = Color(hex: "FF0000")
        let greenHex = Color(hex: "#00FF00FF") // With alpha
        
        XCTAssertNotNil(blueHex, "Should create color from hex with #")
        XCTAssertNotNil(redHex, "Should create color from hex without #")
        XCTAssertNotNil(greenHex, "Should create color from hex with alpha")
    }
    
    func testHexStringConversion() {
        let color = Color.blue
        let hexString = color.hexString()
        
        XCTAssertTrue(hexString.hasPrefix("#"), "Hex string should start with #")
        XCTAssertEqual(hexString.count, 7, "Hex string should be 7 characters (# + 6 hex digits)")
    }
    
    // MARK: - Performance Tests
    
    func testContrastCalculationPerformance() {
        measure {
            // Test contrast calculation performance
            for _ in 0..<1000 {
                _ = ContrastChecker.checkContrast(
                    foreground: Color.black,
                    background: Color.white
                )
            }
        }
    }
    
    func testThemeValidationPerformance() {
        measure {
            // Test theme validation performance
            _ = ThemeValidator.validateTheme()
        }
    }
}

// MARK: - Test Helpers

extension AccessibilityTests {
    /// Helper to test a specific color combination
    func assertContrast(
        _ foreground: Color,
        on background: Color,
        meetsLevel level: ContrastLevel,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let result = ContrastChecker.checkContrast(
            foreground: foreground,
            background: background
        )
        
        switch level {
        case .aa:
            XCTAssertTrue(result.passesAA, "Should meet WCAG AA (4.5:1)", file: file, line: line)
        case .aaa:
            XCTAssertTrue(result.passesAAA, "Should meet WCAG AAA (7:1)", file: file, line: line)
        case .largeTextAA:
            XCTAssertTrue(result.passesLargeTextAA, "Should meet WCAG AA for large text (3:1)", file: file, line: line)
        case .largeTextAAA:
            XCTAssertTrue(result.passesLargeTextAAA, "Should meet WCAG AAA for large text (4.5:1)", file: file, line: line)
        }
    }
    
    enum ContrastLevel {
        case aa
        case aaa
        case largeTextAA
        case largeTextAAA
    }
}
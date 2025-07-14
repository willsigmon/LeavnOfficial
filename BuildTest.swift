// Quick build test to verify compilation
import Foundation

#if canImport(LeavnCore)

#endif

#if canImport(LeavnServices)

#endif

// Test that our new types compile
func testAIGuardrailsCompilation() {
    // Test AIError
    let error = AIError.missingAPIKey
    print("AIError compiles: \(error.errorDescription ?? "")")
    
    // Test AIGuardrails
    let result = AIGuardrails.validateResponse("Test content")
    print("AIGuardrails compiles: \(result.isValid)")
    
    // Test ContentFilterService
    let filter = ContentFilterService()
    print("ContentFilterService compiles")
    
    // Test BiblicalFactChecker
    let factChecker = BiblicalFactChecker()
    print("BiblicalFactChecker compiles")
    
    // Test AIMonitoringService
    let monitoring = AIMonitoringService()
    print("AIMonitoringService compiles")
    
    print("✅ All AI guardrail components compile successfully!")
}

// Run the test
testAIGuardrailsCompilation()
import SwiftUI

// MARK: - Privacy Policy View
public struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.bottom, 10)
                    
                    Group {
                        PolicySection(
                            title: "Information We Collect",
                            content: """
                            We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support. This may include:
                            
                            • Account information (name, email address)
                            • Reading preferences and progress
                            • Bookmarks, notes, and highlights
                            • Usage analytics to improve our services
                            """
                        )
                        
                        PolicySection(
                            title: "How We Use Your Information",
                            content: """
                            We use the information we collect to:
                            
                            • Provide and maintain our services
                            • Sync your data across devices
                            • Personalize your experience
                            • Send you important updates and notifications
                            • Improve our app and develop new features
                            """
                        )
                        
                        PolicySection(
                            title: "Data Security",
                            content: """
                            We take data security seriously and implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.
                            
                            Your API keys are stored securely on your device and are never transmitted to our servers.
                            """
                        )
                        
                        PolicySection(
                            title: "Third-Party Services",
                            content: """
                            Our app may integrate with third-party services (such as AI providers) when you choose to use those features. These services have their own privacy policies, and we encourage you to review them.
                            """
                        )
                        
                        PolicySection(
                            title: "Your Rights",
                            content: """
                            You have the right to:
                            
                            • Access your personal data
                            • Correct inaccurate data
                            • Delete your account and data
                            • Export your data
                            • Withdraw consent for data processing
                            """
                        )
                        
                        PolicySection(
                            title: "Contact Us",
                            content: """
                            If you have any questions about this Privacy Policy, please contact us at privacy@leavn.app
                            
                            Last updated: January 2024
                            """
                        )
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Terms of Service View
public struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.bottom, 10)
                    
                    Group {
                        PolicySection(
                            title: "Acceptance of Terms",
                            content: """
                            By accessing and using Leavn, you accept and agree to be bound by the terms and provision of this agreement.
                            """
                        )
                        
                        PolicySection(
                            title: "Use License",
                            content: """
                            Permission is granted to temporarily download one copy of Leavn for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:
                            
                            • Modify or copy the materials
                            • Use the materials for commercial purposes
                            • Attempt to reverse engineer the software
                            • Remove any copyright or proprietary notations
                            """
                        )
                        
                        PolicySection(
                            title: "User Account",
                            content: """
                            When you create an account with us, you must provide information that is accurate, complete, and current at all times. You are responsible for safeguarding the password and for all activities that occur under your account.
                            """
                        )
                        
                        PolicySection(
                            title: "Prohibited Uses",
                            content: """
                            You may not use our service:
                            
                            • For any unlawful purpose or to solicit others to unlawful acts
                            • To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances
                            • To infringe upon or violate our intellectual property rights or the intellectual property rights of others
                            • To harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate
                            • To submit false or misleading information
                            """
                        )
                        
                        PolicySection(
                            title: "Service Availability",
                            content: """
                            We strive to provide reliable service, but cannot guarantee 100% uptime. We reserve the right to modify or discontinue the service at any time without notice.
                            """
                        )
                        
                        PolicySection(
                            title: "Limitation of Liability",
                            content: """
                            In no event shall Leavn or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use Leavn.
                            """
                        )
                        
                        PolicySection(
                            title: "Contact Information",
                            content: """
                            If you have any questions about these Terms of Service, please contact us at legal@leavn.app
                            
                            Last updated: January 2024
                            """
                        )
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Policy Section Component
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 8)
    }
} 
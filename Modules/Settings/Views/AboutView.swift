import SwiftUI

public struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDeveloper = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Image("LeavnIcon") // Make sure this asset exists
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        
                        Text("Leavn")
                            .font(LeavnTheme.Typography.titleLarge)
                            .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                        
                        Text("Version 1.0.0 (Build 1)")
                            .font(LeavnTheme.Typography.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            FeatureRow(
                                icon: "icloud.fill",
                                title: "Sync Everywhere",
                                description: "Your data syncs across all devices",
                                color: LeavnTheme.Colors.success, delay: 0.1)
                            
                            FeatureRow(
                                icon: "person.2.fill",
                                title: "Community",
                                description: "Connect with fellow believers",
                                color: LeavnTheme.Colors.warning, delay: 0.2)
                                
                            FeatureRow(
                                icon: "book.fill",
                                title: "Multiple Translations",
                                description: "Access various Bible translations",
                                color: LeavnTheme.Colors.info, delay: 0.3)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 8) {
                            Text("Made with ❤️ for the glory of God")
                                .font(LeavnTheme.Typography.body)
                                .foregroundColor(.secondary)
                            
                            Button(action: { 
                                HapticManager.shared.buttonTap()
                                showDeveloper = true 
                            }) {
                                Text("By the Leavn Team")
                                    .font(LeavnTheme.Typography.caption)
                                    .foregroundColor(LeavnTheme.Colors.accent)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticManager.shared.buttonTap()
                        dismiss()
                    }
                }
            }
        }
        .alert("Developer", isPresented: $showDeveloper) {
            Button("OK") {
                HapticManager.shared.buttonTap()
            }
        } message: {
            Text("Developed with SwiftUI and love. Thank you for using Leavn!")
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LeavnTheme.Typography.headline)
                
                Text(description)
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    AboutView()
}
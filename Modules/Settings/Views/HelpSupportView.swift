import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    let faqs = [
        ("Getting Started", [
            ("How do I bookmark verses?", "Tap and hold any verse to see options for bookmarking, highlighting, or adding notes."),
            ("Can I read offline?", "Yes! Once downloaded, translations are available offline. Go to Settings > Downloads to manage offline content."),
            ("How do I change the font size?", "Go to Settings > Reading > Font Size, or use pinch gestures while reading.")
        ]),
        ("AI Features", [
            ("What AI providers are supported?", "We support OpenAI, Anthropic, and Google Gemini. Add your API keys in Settings > AI Providers."),
            ("Are my conversations private?", "Yes, all AI interactions happen directly between your device and the AI provider. We don't store or see your conversations."),
            ("Can I use AI features offline?", "No, AI features require an internet connection to communicate with the AI providers.")
        ]),
        ("Account & Sync", [
            ("How does sync work?", "When signed in, your data syncs automatically via iCloud. You can also manually sync in Settings > Sync."),
            ("What data is synced?", "Bookmarks, highlights, notes, reading progress, and reading plans sync across your devices."),
            ("Can I use Leavn without an account?", "Yes! You can use all features locally. Sign in only if you want to sync across devices.")
        ])
    ]
    
    var filteredFAQs: [(String, [(String, String)])] {
        guard !searchText.isEmpty else { return faqs }
        
        return faqs.compactMap { section, items in
            let filtered = items.filter { q, a in
                q.localizedCaseInsensitiveContains(searchText) ||
                a.localizedCaseInsensitiveContains(searchText)
            }
            return filtered.isEmpty ? nil : (section, filtered)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Search help topics", text: $searchText)
                        .font(.system(size: 17))
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            HapticManager.shared.impact(.light)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(UIColor.tertiarySystemBackground))
                )
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(filteredFAQs, id: \.0) { section, items in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(section)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                ForEach(items, id: \.0) { question, answer in
                                    ExpandableFAQ(question: question, answer: answer)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Contact section
                        VStack(spacing: 16) {
                            Text("Still need help?")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Link(destination: URL(string: "mailto:support@leavn.app")!) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 16))
                                    Text("Email Support")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(Color.blue)
                                )
                            }
                        }
                        .padding(.vertical, 40)
                    }
                }
            }
            .navigationTitle("Help & Support")
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

struct ExpandableFAQ: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                    HapticManager.shared.impact(.light)
                }
            } label: {
                HStack {
                    Text(question)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}
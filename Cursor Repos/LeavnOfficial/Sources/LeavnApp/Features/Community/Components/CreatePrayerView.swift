import SwiftUI
import ComposableArchitecture

struct CreatePrayerView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    @Environment(\.dismiss) var dismiss
    @State private var prayerText = ""
    @State private var isAnonymous = false
    @State private var selectedCategory: PrayerCategory = .personal
    @State private var tags: [String] = []
    @State private var newTag = ""
    @FocusState private var isTextFieldFocused: Bool
    
    enum PrayerCategory: String, CaseIterable {
        case personal = "Personal"
        case family = "Family"
        case health = "Health"
        case work = "Work & School"
        case spiritual = "Spiritual Growth"
        case relationships = "Relationships"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .personal: return "person.fill"
            case .family: return "person.3.fill"
            case .health: return "heart.fill"
            case .work: return "briefcase.fill"
            case .spiritual: return "sparkles"
            case .relationships: return "heart.circle.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Prayer Text
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Prayer Request", systemImage: "hands.sparkles")
                            .font(.headline)
                        
                        TextEditor(text: $prayerText)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                Group {
                                    if prayerText.isEmpty {
                                        Text("Share what's on your heart...")
                                            .foregroundColor(.placeholderText)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                        
                        Text("\(prayerText.count)/500")
                            .font(.caption)
                            .foregroundColor(prayerText.count > 500 ? .red : .secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Category", systemImage: "folder")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                            ForEach(PrayerCategory.allCases, id: \.self) { category in
                                CategoryPill(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tags (Optional)", systemImage: "tag")
                            .font(.headline)
                        
                        // Tag Input
                        HStack {
                            TextField("Add tag...", text: $newTag)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button("Add", action: addTag)
                                .disabled(newTag.isEmpty)
                        }
                        
                        // Tag List
                        if !tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    TagView(tag: tag) {
                                        tags.removeAll { $0 == tag }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Privacy Toggle
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $isAnonymous) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Post Anonymously")
                                    .font(.headline)
                                Text("Your name won't be shown with this prayer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .leavnPrimary))
                        
                        // Privacy Note
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lock.shield")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Your prayer will be visible to the community. You can delete it anytime.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Create Prayer Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        submitPrayer()
                    }
                    .fontWeight(.semibold)
                    .disabled(prayerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || prayerText.count > 500)
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) && tags.count < 5 {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func submitPrayer() {
        let prayer = CreatePrayerRequest(
            text: prayerText.trimmingCharacters(in: .whitespacesAndNewlines),
            isAnonymous: isAnonymous,
            category: selectedCategory.rawValue,
            tags: tags
        )
        store.send(.submitNewPrayer(prayer))
        dismiss()
    }
}

struct CategoryPill: View {
    let category: CreatePrayerView.PrayerCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title3)
                Text(category.rawValue)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? Color.leavnPrimary : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.callout)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .foregroundColor(.leavnPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.leavnPrimary.opacity(0.1))
        .cornerRadius(16)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let viewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + viewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: viewSize))
                lineHeight = max(lineHeight, viewSize.height)
                currentX += viewSize.width + spacing
                
                size.width = max(size.width, currentX - spacing)
            }
            
            size.height = currentY + lineHeight
        }
    }
}

// Mock CreatePrayerRequest
struct CreatePrayerRequest {
    let text: String
    let isAnonymous: Bool
    let category: String
    let tags: [String]
}
import SwiftUI

/// A hierarchical picker that implements progressive disclosure
/// Shows top-level categories first, then reveals subcategories
public struct HierarchicalPicker<Category: Hashable, Item: Identifiable>: View {
    public struct CategoryGroup {
        let name: String
        let icon: String
        let items: [Item]
        let id: Category
        
        public init(name: String, icon: String, items: [Item], id: Category) {
            self.name = name
            self.icon = icon
            self.items = items
            self.id = id
        }
    }
    
    let title: String
    let categories: [CategoryGroup]
    @Binding var selection: Item?
    let itemLabel: (Item) -> String
    let maxCategoriesVisible: Int
    
    @State private var selectedCategory: Category?
    @State private var isExpanded = false
    
    public init(
        title: String,
        categories: [CategoryGroup],
        selection: Binding<Item?>,
        itemLabel: @escaping (Item) -> String,
        maxCategoriesVisible: Int = 5
    ) {
        self.title = title
        self.categories = categories
        self._selection = selection
        self.itemLabel = itemLabel
        self.maxCategoriesVisible = maxCategoriesVisible
    }
    
    private var visibleCategories: [CategoryGroup] {
        if isExpanded {
            return categories
        }
        return Array(categories.prefix(maxCategoriesVisible))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                // Category Selection
                if selectedCategory == nil {
                    VStack(spacing: 8) {
                        ForEach(visibleCategories, id: \.id) { category in
                            CategoryButton<Category, Item>(
                                category: category,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = category.id
                                    }
                                }
                            )
                        }
                        
                        if categories.count > maxCategoriesVisible && !isExpanded {
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    isExpanded = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "ellipsis.circle")
                                    Text("Show \(categories.count - maxCategoriesVisible) more")
                                    Spacer()
                                }
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .push(from: .leading).combined(with: .opacity),
                        removal: .push(from: .trailing).combined(with: .opacity)
                    ))
                }
                
                // Item Selection
                if let categoryId = selectedCategory,
                   let category = categories.first(where: { $0.id == categoryId }) {
                    VStack(spacing: 8) {
                        // Back button
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = nil
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.caption)
                                Image(systemName: category.icon)
                                Text(category.name)
                                Spacer()
                            }
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                        
                        ScrollView {
                            VStack(spacing: 4) {
                                ForEach(category.items) { item in
                                    ItemButton(
                                        label: itemLabel(item),
                                        isSelected: selection?.id == item.id,
                                        action: {
                                            withAnimation(.spring(response: 0.3)) {
                                                selection = item
                                                selectedCategory = nil
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .transition(.asymmetric(
                        insertion: .push(from: .trailing).combined(with: .opacity),
                        removal: .push(from: .leading).combined(with: .opacity)
                    ))
                }
                
                // Selected item display
                if let selected = selection, selectedCategory == nil {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            if let category = categories.first(where: { $0.items.contains(where: { $0.id == selected.id }) }) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(itemLabel(selected))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selection = nil
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.3), value: selectedCategory)
        .animation(.spring(response: 0.3), value: selection?.id)
    }
}

private struct CategoryButton<Category: Hashable, Item: Identifiable>: View {
    let category: HierarchicalPicker<Category, Item>.CategoryGroup
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Text("\(category.items.count) options")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private struct ItemButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(LeavnTheme.Colors.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ? LeavnTheme.Colors.accent.opacity(0.1) : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Support

struct PreviewItem: Identifiable {
    let id = UUID()
    let name: String
}

#Preview("HierarchicalPicker") {
    struct PreviewWrapper: View {
        @State private var selection: PreviewItem?
        
        let emotionalCategories = [
            HierarchicalPicker.CategoryGroup(
                name: "Negative Active",
                icon: "exclamationmark.triangle",
                items: [
                    PreviewItem(name: "Anxious"),
                    PreviewItem(name: "Angry"),
                    PreviewItem(name: "Stressed"),
                    PreviewItem(name: "Overwhelmed")
                ],
                id: 1
            ),
            HierarchicalPicker.CategoryGroup(
                name: "Negative Passive",
                icon: "cloud.rain",
                items: [
                    PreviewItem(name: "Depressed"),
                    PreviewItem(name: "Sad"),
                    PreviewItem(name: "Lonely"),
                    PreviewItem(name: "Fearful")
                ],
                id: 2
            ),
            HierarchicalPicker.CategoryGroup(
                name: "Positive Active",
                icon: "sun.max",
                items: [
                    PreviewItem(name: "Joyful"),
                    PreviewItem(name: "Hopeful"),
                    PreviewItem(name: "Grateful")
                ],
                id: 3
            ),
            HierarchicalPicker.CategoryGroup(
                name: "Positive Passive",
                icon: "leaf",
                items: [
                    PreviewItem(name: "Peaceful"),
                    PreviewItem(name: "Content")
                ],
                id: 4
            ),
            HierarchicalPicker.CategoryGroup(
                name: "Uncertain",
                icon: "questionmark.circle",
                items: [
                    PreviewItem(name: "Confused"),
                    PreviewItem(name: "Worried"),
                    PreviewItem(name: "Uncertain")
                ],
                id: 5
            )
        ]
        
        var body: some View {
            HierarchicalPicker(
                title: "How are you feeling?",
                categories: emotionalCategories,
                selection: $selection,
                itemLabel: { $0.name }
            )
            .padding()
        }
    }
    
    return PreviewWrapper()
}
import SwiftUI

public struct LibraryView: View {
    @StateObject private var viewModel: LibraryViewModel
    @StateObject private var coordinator: LibraryCoordinator
    
    public init(viewModel: LibraryViewModel, coordinator: LibraryCoordinator) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content
                .navigationTitle("Library")
                .navigationDestination(for: LibraryItem.self) { item in
                    LibraryItemDetailView(item: item)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        addButton
                    }
                }
                .searchable(text: .init(
                    get: { viewModel.state.searchQuery },
                    set: { viewModel.updateSearchQuery($0) }
                ))
                .sheet(isPresented: $coordinator.isAddingItem) {
                    AddLibraryItemView(viewModel: viewModel)
                }
                .sheet(item: $coordinator.editingItem) { item in
                    EditLibraryItemView(item: item, viewModel: viewModel)
                }
        }
        .task {
            await viewModel.loadItems()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.state.isLoading {
            ProgressView("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.state.displayedItems.isEmpty {
            emptyStateView
        } else {
            itemsList
        }
    }
    
    private var itemsList: some View {
        List {
            ForEach(viewModel.state.displayedItems) { item in
                LibraryItemRow(item: item) {
                    viewModel.selectItem(item)
                }
                .swipeActions(edge: .trailing) {
                    Button("Edit") {
                        viewModel.editItem(item)
                    }
                    .tint(.blue)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Items",
            systemImage: "book.closed",
            description: Text("Add your first library item to get started")
        )
    }
    
    private var addButton: some View {
        Menu {
            ForEach(LibraryItemType.allCases, id: \.self) { type in
                Button(action: { viewModel.addNewItem(ofType: type) }) {
                    Label(type.rawValue.capitalized, systemImage: iconForType(type))
                }
            }
        } label: {
            Image(systemName: "plus")
        }
    }
    
    private func iconForType(_ type: LibraryItemType) -> String {
        switch type {
        case .bookmark: return "bookmark"
        case .note: return "note.text"
        case .highlight: return "highlighter"
        case .readingPlan: return "calendar"
        case .devotion: return "book.closed"
        case .prayerRequest: return "hands.sparkles"
        }
    }
}

// MARK: - Supporting Views

struct LibraryItemRow: View {
    let item: LibraryItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let verse = item.verse {
                    Text(verse.reference)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let content = item.content, !content.isEmpty {
                    Text(content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct LibraryItemDetailView: View {
    let item: LibraryItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.largeTitle)
                
                if let verse = item.verse {
                    VStack(alignment: .leading) {
                        Text(verse.reference)
                            .font(.headline)
                        Text(verse.text)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                if let content = item.content {
                    Text(content)
                        .font(.body)
                }
                
                if !item.tags.isEmpty {
                    FlowLayout {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddLibraryItemView: View {
    let viewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Add New Item")
                .navigationTitle("New Item")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct EditLibraryItemView: View {
    let item: LibraryItem
    let viewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Edit: \(item.title)")
                .navigationTitle("Edit Item")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews)
        return CGSize(width: proposal.replacingUnspecifiedDimensions().width, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width, x > 0 {
                    x = 0
                    y += rowHeight + 8
                    rowHeight = 0
                }
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
                x += size.width + 8
                rowHeight = max(rowHeight, size.height)
            }
            height = y + rowHeight
        }
    }
}
import SwiftUI

struct HighlightsPreview: View {
    let highlights: [Highlight]
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(highlights) { highlight in
                        HighlightCard(highlight: highlight)
                    }
                    
                    if highlights.count >= 5 {
                        ViewAllCard(title: "View All") {
                            onViewAll()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct HighlightCard: View {
    let highlight: Highlight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Color Bar
            Rectangle()
                .fill(Color(highlight.color.uiColor))
                .frame(height: 4)
            
            // Reference
            Text(highlight.reference)
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            // Text
            Text(highlight.text)
                .font(.callout)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Date
            Text(highlight.createdAt, style: .relative)
                .font(.caption2)
                .foregroundColor(.tertiaryLabel)
        }
        .padding(12)
        .frame(width: 200, height: 120)
        .background(Color.leavnSecondaryBackground)
        .cornerRadius(12)
    }
}

struct EnhancedHighlightsView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    @State private var selectedColor: HighlightColor?
    @State private var selectedBook: Book?
    @State private var groupBy: GroupOption = .none
    
    enum GroupOption: String, CaseIterable {
        case none = "None"
        case book = "Book"
        case color = "Color"
        case date = "Date"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Color Filters
                    ForEach(HighlightColor.allCases, id: \.self) { color in
                        ColorFilterButton(
                            color: color,
                            isSelected: selectedColor == color
                        ) {
                            if selectedColor == color {
                                selectedColor = nil
                            } else {
                                selectedColor = color
                            }
                        }
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Group By Menu
                    Menu {
                        ForEach(GroupOption.allCases, id: \.self) { option in
                            Button(action: { groupBy = option }) {
                                HStack {
                                    Text(option.rawValue)
                                    if groupBy == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "square.3.layers.3d")
                            Text("Group: \(groupBy.rawValue)")
                        }
                        .font(.callout)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            
            // Content
            if store.highlights.isEmpty {
                EmptyStateView(
                    icon: "highlighter",
                    title: "No Highlights Yet",
                    message: "Highlight verses while reading to see them here"
                )
            } else {
                ScrollView {
                    if groupBy == .none {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredHighlights) { highlight in
                                HighlightRow(highlight: highlight) {
                                    store.send(.selectHighlight(highlight))
                                }
                            }
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: 24) {
                            ForEach(groupedHighlights, id: \.key) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Section Header
                                    HStack {
                                        if groupBy == .color, let color = group.key as? HighlightColor {
                                            Circle()
                                                .fill(Color(color.uiColor))
                                                .frame(width: 12, height: 12)
                                        }
                                        
                                        Text(sectionTitle(for: group.key))
                                            .font(.headline)
                                        
                                        Text("(\(group.value.count))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    // Highlights
                                    ForEach(group.value) { highlight in
                                        HighlightRow(highlight: highlight) {
                                            store.send(.selectHighlight(highlight))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle("Highlights")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { store.send(.exportHighlights) }) {
                        Label("Export Highlights", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: { store.send(.shareHighlights) }) {
                        Label("Share All", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private var filteredHighlights: [Highlight] {
        var highlights = Array(store.highlights)
        
        if let color = selectedColor {
            highlights = highlights.filter { $0.color == color }
        }
        
        if let book = selectedBook {
            highlights = highlights.filter { $0.book == book }
        }
        
        return highlights
    }
    
    private var groupedHighlights: [(key: AnyHashable, value: [Highlight])] {
        let highlights = filteredHighlights
        
        switch groupBy {
        case .none:
            return [(key: "all" as AnyHashable, value: highlights)]
        case .book:
            let grouped = Dictionary(grouping: highlights) { $0.book }
            return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
                .map { (key: $0.key as AnyHashable, value: $0.value) }
        case .color:
            let grouped = Dictionary(grouping: highlights) { $0.color }
            return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
                .map { (key: $0.key as AnyHashable, value: $0.value) }
        case .date:
            let grouped = Dictionary(grouping: highlights) { 
                Calendar.current.startOfDay(for: $0.createdAt)
            }
            return grouped.sorted { $0.key > $1.key }
                .map { (key: $0.key as AnyHashable, value: $0.value) }
        }
    }
    
    private func sectionTitle(for key: AnyHashable) -> String {
        switch groupBy {
        case .none:
            return "All Highlights"
        case .book:
            if let book = key as? Book {
                return book.name
            }
        case .color:
            if let color = key as? HighlightColor {
                return color.name
            }
        case .date:
            if let date = key as? Date {
                if Calendar.current.isDateInToday(date) {
                    return "Today"
                } else if Calendar.current.isDateInYesterday(date) {
                    return "Yesterday"
                } else {
                    return date.formatted(date: .abbreviated, time: .omitted)
                }
            }
        }
        return ""
    }
}

struct ColorFilterButton: View {
    let color: HighlightColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(color.uiColor))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.primary, lineWidth: 2)
                        .opacity(isSelected ? 1 : 0)
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
    }
}

struct HighlightRow: View {
    let highlight: Highlight
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Color Indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(highlight.color.uiColor))
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Reference
                    HStack {
                        Text(highlight.reference)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(highlight.createdAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Highlighted Text
                    Text(highlight.text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Note Preview
                    if let note = highlight.note {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.caption)
                            Text(note)
                                .font(.caption)
                                .lineLimit(2)
                        }
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }
                    
                    // Actions
                    HStack(spacing: 20) {
                        Button(action: { /* Share */ }) {
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.caption)
                            .foregroundColor(.leavnPrimary)
                        }
                        
                        Button(action: { /* Copy */ }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy")
                            }
                            .font(.caption)
                            .foregroundColor(.leavnPrimary)
                        }
                        
                        if highlight.note == nil {
                            Button(action: { /* Add Note */ }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "note.text.badge.plus")
                                    Text("Add Note")
                                }
                                .font(.caption)
                                .foregroundColor(.leavnPrimary)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}
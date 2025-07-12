import SwiftUI

/// A searchable picker component that reduces cognitive load for large option sets
/// Implements progressive disclosure with search filtering
public struct SearchableOptionsPicker<T: Identifiable & CustomStringConvertible>: View {
    let title: String
    let options: [T]
    @Binding var selection: T?
    let maxVisibleOptions: Int
    let placeholder: String
    
    @State private var searchText = ""
    @State private var isExpanded = false
    @FocusState private var isSearchFocused: Bool
    
    public init(
        title: String,
        options: [T],
        selection: Binding<T?>,
        maxVisibleOptions: Int = 5,
        placeholder: String = "Search options..."
    ) {
        self.title = title
        self.options = options
        self._selection = selection
        self.maxVisibleOptions = maxVisibleOptions
        self.placeholder = placeholder
    }
    
    private var filteredOptions: [T] {
        if searchText.isEmpty {
            return Array(options.prefix(maxVisibleOptions))
        }
        return options.filter { option in
            option.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var shouldShowSearch: Bool {
        options.count > maxVisibleOptions
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 8) {
                if shouldShowSearch {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField(placeholder, text: $searchText)
                            .textFieldStyle(.plain)
                            .focused($isSearchFocused)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    isExpanded = true
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                isSearchFocused = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                }
                
                if isExpanded || !shouldShowSearch {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(filteredOptions) { option in
                                OptionRow(
                                    option: option,
                                    isSelected: selection?.id == option.id,
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selection = option
                                            if shouldShowSearch {
                                                isExpanded = false
                                                searchText = ""
                                                isSearchFocused = false
                                            }
                                        }
                                    }
                                )
                            }
                            
                            if filteredOptions.isEmpty && !searchText.isEmpty {
                                Text("No options match '\(searchText)'")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
                }
                
                if shouldShowSearch && !isExpanded && selection != nil {
                    OptionRow(
                        option: selection!,
                        isSelected: true,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                isExpanded = true
                                isSearchFocused = true
                            }
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.3), value: isExpanded)
        .animation(.spring(response: 0.3), value: searchText)
    }
}

private struct OptionRow<T: CustomStringConvertible>: View {
    let option: T
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option.description)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(LeavnTheme.Colors.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? LeavnTheme.Colors.accent.opacity(0.1) : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Support

struct PreviewOption: Identifiable, CustomStringConvertible {
    let id = UUID()
    let name: String
    var description: String { name }
}

#Preview("SearchableOptionsPicker") {
    struct PreviewWrapper: View {
        @State private var selection: PreviewOption?
        
        let options = [
            "Hope", "Love", "Faith", "Peace", "Strength",
            "Wisdom", "Gratitude", "Forgiveness", "Courage", "Joy",
            "Trust", "Compassion", "Endurance", "Perseverance",
            "Understanding", "Praise", "Worship", "Gospel"
        ].map(PreviewOption.init)
        
        var body: some View {
            SearchableOptionsPicker(
                title: "Select Theme",
                options: options,
                selection: $selection
            )
            .padding()
        }
    }
    
    return PreviewWrapper()
}
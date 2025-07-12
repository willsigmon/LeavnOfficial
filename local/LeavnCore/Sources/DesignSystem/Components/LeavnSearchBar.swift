import SwiftUI

public struct LeavnSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: () -> Void
    let onCancel: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    @State private var showCancelButton = false
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search",
        onSearch: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
        self.onCancel = onCancel
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            searchField
            
            if showCancelButton {
                cancelButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showCancelButton)
        .onChange(of: isFocused) { oldValue, newValue in
            showCancelButton = newValue || !text.isEmpty
        }
        .onChange(of: text) { oldValue, newValue in
            showCancelButton = isFocused || !newValue.isEmpty
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onSubmit {
                    onSearch()
                }
                .padding(.vertical, 8)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            text = ""
            isFocused = false
            onCancel?()
        }
        .padding(.leading, 8)
        .foregroundColor(.accentColor)
    }
}

// MARK: - Platform Specific Modifications
#if os(watchOS)
public struct CompactSearchBar: View {
    @Binding var text: String
    let onTap: () -> Void
    
    public var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text(text.isEmpty ? "Search" : text)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
#endif

#if os(visionOS)
public struct SpatialSearchBar: View {
    @Binding var text: String
    let onSearch: () -> Void
    
    public var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            TextField("Search the Bible", text: $text)
                .textFieldStyle(.plain)
                .font(.title3)
                .onSubmit(onSearch)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .hoverEffect()
    }
}
#endif

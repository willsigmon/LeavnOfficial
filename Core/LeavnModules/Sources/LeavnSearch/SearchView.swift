import SwiftUI

public struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.leavnSecondary)
                TextField("Search Scripture...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(Color.leavnBackground)
            .cornerRadius(10)
            .padding()
            
            // Results
            List(searchResults) { result in
                VStack(alignment: .leading, spacing: LeavnSpacing.xSmall) {
                    Text(result.reference)
                        .font(LeavnFont.headline.font)
                        .foregroundColor(.leavnPrimary)
                    Text(result.preview)
                        .font(LeavnFont.body.font)
                        .foregroundColor(.leavnText)
                        .lineLimit(2)
                }
                .padding(.vertical, LeavnSpacing.small)
            }
            .listStyle(PlainListStyle())
        }
        .background(Color.leavnBackground.ignoresSafeArea())
    }
}

public struct SearchResult: Identifiable {
    public let id = UUID()
    public let reference: String
    public let preview: String
    
    public init(reference: String, preview: String) {
        self.reference = reference
        self.preview = preview
    }
} 
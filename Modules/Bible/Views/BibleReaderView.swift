import SwiftUI

struct BibleReaderView: View {
    @StateObject private var viewModel = BibleReaderViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                Text(viewModel.currentChapter)
                    .font(.system(size: viewModel.fontSize))
                    .padding()
            }
        }
        .navigationTitle("Bible Reader")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Settings") {
                    // Show settings
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        BibleReaderView()
    }
}
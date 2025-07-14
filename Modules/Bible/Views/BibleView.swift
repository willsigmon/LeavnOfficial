import SwiftUI

struct BibleView: View {
    @StateObject private var viewModel = BibleViewModel()
    @State private var showBookPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: { showBookPicker = true }) {
                        Text("\(viewModel.selectedBook) \(viewModel.selectedChapter)")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Button(viewModel.selectedTranslation) {
                        // Show translation picker
                    }
                }
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    BibleReaderView()
                }
            }
            .navigationTitle("Bible")
            .sheet(isPresented: $showBookPicker) {
                BookPickerView()
            }
        }
    }
}

#Preview {
    BibleView()
}
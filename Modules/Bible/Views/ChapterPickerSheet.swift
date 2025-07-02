import SwiftUI
import LeavnCore

struct ChapterPickerSheet: View {
    let book: BibleBook
    @Binding var selectedChapter: Int
    @Binding var isPresented: Bool
    var onSelect: (Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var scrollToChapter: Int?
    
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(), spacing: 12), count: 6)
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(1...book.chapterCount, id: \.self) { chapter in
                            ChapterButton(
                                chapter: chapter,
                                isSelected: chapter == selectedChapter,
                                action: {
                                    selectedChapter = chapter
                                    onSelect(chapter)
                                    isPresented = false
                                }
                            )
                            .id(chapter)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    // Scroll to selected chapter when view appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(selectedChapter, anchor: .center)
                        }
                    }
                }
            }
            .navigationTitle("\(book.name) - Select Chapter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Chapter Button

private struct ChapterButton: View {
    let chapter: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(chapter)")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(isSelected ? 1 : 0), lineWidth: 2)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Chapter \(chapter)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Button Style

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
// MARK: - Preview

struct ChapterPickerSheet_Previews: PreviewProvider {
    static var previews: some View {
        ChapterPickerSheet(
            book: .genesis,
            selectedChapter: .constant(1),
            isPresented: .constant(true),
            onSelect: { _ in }
        )
    }
}

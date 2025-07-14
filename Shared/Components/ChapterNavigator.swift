import SwiftUI
import LeavnServices

/// A navigation component for browsing Bible chapters
/// Provides adaptive layouts for different platforms
public struct ChapterNavigator: View {
    let currentBook: String
    let currentChapter: Int
    let totalChapters: Int
    let onPreviousChapter: () -> Void
    let onNextChapter: () -> Void
    let onChapterSelect: (Int) -> Void
    
    @State private var showChapterPicker = false
    @Environment(\.hapticManager) private var hapticManager
    
    public init(
        currentBook: String,
        currentChapter: Int,
        totalChapters: Int,
        onPreviousChapter: @escaping () -> Void,
        onNextChapter: @escaping () -> Void,
        onChapterSelect: @escaping (Int) -> Void
    ) {
        self.currentBook = currentBook
        self.currentChapter = currentChapter
        self.totalChapters = totalChapters
        self.onPreviousChapter = onPreviousChapter
        self.onNextChapter = onNextChapter
        self.onChapterSelect = onChapterSelect
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Previous chapter button
            Button(action: { 
                hapticManager.triggerFeedback(.medium)
                onPreviousChapter() 
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(currentChapter > 1 ? .primary : .secondary)
            }
            .disabled(currentChapter <= 1)
            
            Spacer()
            
            // Current chapter display
            Button(action: { 
                hapticManager.triggerFeedback(.light)
                showChapterPicker = true 
            }) {
                VStack(spacing: 2) {
                    Text(currentBook)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Chapter \(currentChapter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showChapterPicker) {
                ChapterPickerView(
                    book: currentBook,
                    currentChapter: currentChapter,
                    totalChapters: totalChapters,
                    onChapterSelect: { chapter in
                        onChapterSelect(chapter)
                        showChapterPicker = false
                    }
                )
            }
            
            Spacer()
            
            // Next chapter button
            Button(action: { 
                hapticManager.triggerFeedback(.medium)
                onNextChapter() 
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(currentChapter < totalChapters ? .primary : .secondary)
            }
            .disabled(currentChapter >= totalChapters)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Chapter Picker View
private struct ChapterPickerView: View {
    let book: String
    let currentChapter: Int
    let totalChapters: Int
    let onChapterSelect: (Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.hapticManager) private var hapticManager
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1...totalChapters, id: \.self) { chapter in
                        Button(action: { 
                            hapticManager.triggerFeedback(.medium)
                            onChapterSelect(chapter) 
                        }) {
                            Text("\(chapter)")
                                .font(.headline)
                                .foregroundColor(
                                    chapter == currentChapter ? .white : .primary
                                )
                                .frame(width: 50, height: 50)
                                .background(
                                    chapter == currentChapter ? 
                                    Color("BookmarkBlue") : 
                                    Color(.systemGray5)
                                )
                                .cornerRadius(25)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("\(book) Chapters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Compact Navigator for Apple Watch
public struct CompactChapterNavigator: View {
    let currentBook: String
    let currentChapter: Int
    let totalChapters: Int
    let onPreviousChapter: () -> Void
    let onNextChapter: () -> Void
    
    @Environment(\.hapticManager) private var hapticManager
    
    public init(
        currentBook: String,
        currentChapter: Int,
        totalChapters: Int,
        onPreviousChapter: @escaping () -> Void,
        onNextChapter: @escaping () -> Void
    ) {
        self.currentBook = currentBook
        self.currentChapter = currentChapter
        self.totalChapters = totalChapters
        self.onPreviousChapter = onPreviousChapter
        self.onNextChapter = onNextChapter
    }
    
    public var body: some View {
        HStack {
            Button(action: { 
                hapticManager.triggerFeedback(.medium)
                onPreviousChapter() 
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            .disabled(currentChapter <= 1)
            
            Spacer()
            
            VStack(spacing: 1) {
                Text(currentBook)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("\(currentChapter)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button(action: { 
                hapticManager.triggerFeedback(.medium)
                onNextChapter() 
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(currentChapter >= totalChapters)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Preview
struct ChapterNavigator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ChapterNavigator(
                currentBook: "Psalms",
                currentChapter: 23,
                totalChapters: 150,
                onPreviousChapter: {},
                onNextChapter: {},
                onChapterSelect: { _ in }
            )
            
            ChapterNavigator(
                currentBook: "John",
                currentChapter: 1,
                totalChapters: 21,
                onPreviousChapter: {},
                onNextChapter: {},
                onChapterSelect: { _ in }
            )
            
            CompactChapterNavigator(
                currentBook: "Romans",
                currentChapter: 8,
                totalChapters: 16,
                onPreviousChapter: {},
                onNextChapter: {}
            )
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding()
    }
}
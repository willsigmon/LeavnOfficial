import SwiftUI

struct FavoriteVersesView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var selectedVerse: BibleVerse?
    @State private var showingShareCard = false
    @State private var showingVerseDetail = false
    
    private var favoriteVerses: [LibraryItem] {
        viewModel.libraryItems.filter { $0.type == .favorite }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if favoriteVerses.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(favoriteVerses) { item in
                            FavoriteVerseCard(
                                item: item,
                                onShare: { verse in
                                    selectedVerse = verse
                                    showingShareCard = true
                                },
                                onTap: { verse in
                                    selectedVerse = verse
                                    showingVerseDetail = true
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favorite Verses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: shareAllFavorites) {
                            Label("Share All", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: exportFavorites) {
                            Label("Export as PDF", systemImage: "doc.text")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareCard) {
            if let verse = selectedVerse {
                ShareableVerseCardView(verse: verse)
            }
        }
        .sheet(isPresented: $showingVerseDetail) {
            if let verse = selectedVerse {
                NavigationView {
                    VerseDetailView(verse: verse)
                        .navigationTitle("Verse Details")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingVerseDetail = false
                                }
                            }
                        }
                }
            }
        }
        .task {
            await viewModel.loadLibraryData()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "heart.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Favorite Verses Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the heart icon on any verse to add it to your favorites")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func shareAllFavorites() {
        // Share all favorites as a collection
    }
    
    private func exportFavorites() {
        // Export favorites as PDF
    }
}

// MARK: - Favorite Verse Card
struct FavoriteVerseCard: View {
    let item: LibraryItem
    let onShare: (BibleVerse) -> Void
    let onTap: (BibleVerse) -> Void
    
    @State private var isPressed = false
    
    private var verse: BibleVerse? {
        guard let metadata = item.metadata,
              let book = metadata["book"],
              let chapterStr = metadata["chapter"],
              let chapter = Int(chapterStr),
              let verseStr = metadata["verse"],
              let verseNum = Int(verseStr),
              let translation = metadata["translation"] else {
            return nil
        }
        
        return BibleVerse(
            id: item.id,
            reference: item.reference ?? "",
            text: item.content,
            book: book,
            chapter: chapter,
            verse: verseNum,
            translation: translation
        )
    }
    
    var body: some View {
        Button(action: { 
            if let verse = verse {
                onTap(verse)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Reference Header
                HStack {
                    Label(item.reference ?? "", systemImage: "book.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Share Button
                    Button(action: {
                        if let verse = verse {
                            onShare(verse)
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                // Verse Text
                Text(item.content)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Footer
                HStack {
                    if let translation = item.metadata?["translation"] {
                        Text(translation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(item.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.accentColor.opacity(isPressed ? 0.3 : 0), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1)
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
}

// MARK: - Preview
#Preview {
    FavoriteVersesView()
}
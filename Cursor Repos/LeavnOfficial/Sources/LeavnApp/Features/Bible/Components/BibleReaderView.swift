import SwiftUI
import ComposableArchitecture

struct BibleReaderView: View {
    @Bindable var store: StoreOf<BibleReducer>
    @Namespace private var namespace
    @State private var selectedVerseFrame: CGRect = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ChapterHeaderView(
                                book: store.currentBook,
                                chapter: store.currentChapter
                            )
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            ForEach(store.verses, id: \.number) { verse in
                                VerseView(
                                    verse: verse,
                                    isHighlighted: store.highlightedVerses.contains(verse.reference),
                                    isSelected: store.selectedVerse?.number == verse.number,
                                    namespace: namespace
                                ) {
                                    store.send(.verseSelected(verse.number))
                                }
                                .id(verse.number)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: VerseFrameKey.self,
                                            value: [verse.number: geo.frame(in: .global)]
                                        )
                                    }
                                )
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100) // Space for audio controls
                        }
                    }
                    .onChange(of: store.currentVerse) { _, newVerse in
                        if let verse = newVerse {
                            withAnimation {
                                proxy.scrollTo(verse, anchor: .center)
                            }
                        }
                    }
                }
                .onPreferenceChange(VerseFrameKey.self) { frames in
                    // Track verse positions for audio sync
                }
                
                // Audio Controls Overlay
                if store.showAudioControls {
                    AudioControlsOverlay(store: store)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Cross Reference Popover
                if let crossRef = store.selectedCrossReference {
                    CrossReferencePopover(
                        reference: crossRef,
                        onDismiss: { store.send(.dismissCrossReference) }
                    )
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
                }
            }
        }
        .coordinateSpace(name: "bible-reader")
    }
}

struct ChapterHeaderView: View {
    let book: Book
    let chapter: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LeavnTypography.bookTitle(book.name)
            LeavnTypography.chapterNumber(chapter)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
    }
}

struct VerseView: View {
    let verse: Verse
    let isHighlighted: Bool
    let isSelected: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    @State private var showContextMenu = false
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            LeavnTypography.verseNumber(verse.number)
                .frame(width: 30, alignment: .trailing)
            
            Text(verse.text)
                .font(.custom("Georgia", size: 18, relativeTo: .body))
                .lineSpacing(8)
                .foregroundColor(verse.isRedLetter ? LeavnColors.redLetter : .leavnLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Group {
                        if isHighlighted {
                            LeavnColors.verseHighlight
                                .cornerRadius(4)
                                .matchedGeometryEffect(id: "highlight-\(verse.number)", in: namespace)
                        }
                        
                        if isSelected {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(LeavnColors.accent, lineWidth: 2)
                                .matchedGeometryEffect(id: "selection", in: namespace)
                        }
                    }
                )
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture {
            showContextMenu = true
        }
        .contextMenu {
            VerseContextMenu(verse: verse)
        }
    }
}

struct VerseContextMenu: View {
    let verse: Verse
    
    var body: some View {
        Group {
            Button {
                // Copy action
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            Button {
                // Share action
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Divider()
            
            Button {
                // Highlight action
            } label: {
                Label("Highlight", systemImage: "highlighter")
            }
            
            Button {
                // Add note action
            } label: {
                Label("Add Note", systemImage: "note.text")
            }
            
            Button {
                // Bookmark action
            } label: {
                Label("Bookmark", systemImage: "bookmark")
            }
            
            Divider()
            
            Button {
                // Cross references action
            } label: {
                Label("Cross References", systemImage: "link")
            }
        }
    }
}

struct VerseFrameKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// Extension for BibleReaderView compatibility
extension Verse {
    var number: Int { verseNumber }
    var reference: String { "\(book) \(chapter):\(verseNumber)" }
    var isRedLetter: Bool {
        // Jesus' words are typically in red in the Gospels
        ["Matthew", "Mark", "Luke", "John"].contains(book) && 
        text.contains("\"") // Simple heuristic
    }
}
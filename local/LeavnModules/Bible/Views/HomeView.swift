import SwiftUI
import LeavnCore
import LeavnServices
import DesignSystem

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showShareSheet = false
    @State private var shareVerse: BibleVerse?
    @State private var isInitialized = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            if isInitialized {
                ScrollView {
                    VStack(spacing: 20) {
                        // Daily Verse Section - Enhanced
                        NavigationLink(destination: BibleReaderView(
                            book: viewModel.dailyVerse != nil ? BibleBook(from: viewModel.dailyVerse!.bookId) : nil,
                            chapter: viewModel.dailyVerse?.chapter ?? 1
                        )) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("✨ Verse of the Day")
                                            .font(.headline)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.purple, .blue]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        
                                        Text(Date(), style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if viewModel.isLoadingDailyVerse {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "chevron.right.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(
                                                .linearGradient(
                                                    colors: [.purple.opacity(0.7), .blue.opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                }
                                
                                if let verse = viewModel.dailyVerse {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(verse.text)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        HStack {
                                            Text("— \(verse.reference)")
                                                .font(.callout.bold())
                                                .foregroundStyle(
                                                    .linearGradient(
                                                        colors: [.purple, .blue],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                shareVerse = verse
                                                showShareSheet = true
                                            }) {
                                                Image(systemName: "square.and.arrow.up")
                                                    .font(.title3)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                } else if let error = viewModel.dailyVerseError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(20)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.purple.opacity(0.1),
                                                    Color.blue.opacity(0.1)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.purple.opacity(0.3),
                                                            Color.blue.opacity(0.3)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                }
                            )
                            .shadow(color: Color.purple.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        .disabled(viewModel.dailyVerse == nil)
                        
                        // Share Verse Widget
                        if !viewModel.suggestedVerses.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Share These Verses")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.suggestedVerses) { recommendation in
                                            Button(action: {
                                                shareVerse = recommendation.verse
                                                showShareSheet = true
                                            }) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(recommendation.verse.reference)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.accentColor)
                                                    
                                                    Text(recommendation.verse.text)
                                                        .font(.caption2)
                                                        .foregroundColor(.primary)
                                                        .lineLimit(3)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    HStack {
                                                        Spacer()
                                                        Image(systemName: "square.and.arrow.up")
                                                            .font(.caption)
                                                            .foregroundColor(.accentColor)
                                                    }
                                                }
                                                .frame(width: 200)
                                                .padding()
                                                .background(Color.secondary.opacity(0.05))
                                                .cornerRadius(8)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        Spacer(minLength: 80) // Space for tab bar
                    }
                    }
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.large)
                } else {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading Home...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear {
                Task {
                    await viewModel.initializeServices()
                    isInitialized = true
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let verse = shareVerse {
                    ShareVerseSheet(verse: verse, verseText: verse.text, defaultFormat: .image)
                }
            }
        }
    }

#Preview {
    HomeView()
}
